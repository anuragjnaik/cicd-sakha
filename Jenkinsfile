pipeline {
  agent any

  options {
    timeout(time: 20, unit: 'MINUTES')      // no hanging builds
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  environment {
    IMAGE     = 'anuragjnaik/cicdproject'
    TAG       = "${BUILD_NUMBER}"
    TEST_HOST = 'ubuntu@172.31.10.224'
    APP_URL   = 'http://172.31.10.224:8080'
  }

  stages {
    stage('Install dependencies') {
      steps {
        sh '''
          python3 -m venv .venv
          . .venv/bin/activate
          pip install --quiet --upgrade pip
          pip install --quiet -r app/requirements.txt flake8 pytest-cov
        '''
      }
    }

    stage('Lint') {
      steps {
        sh '''
          . .venv/bin/activate
          flake8 app tests
        '''
      }
    }

    stage('Unit tests') {
      steps {
        sh '''
          . .venv/bin/activate
          python -m pytest tests --junitxml=test-results.xml --cov=app --cov-report=xml
        '''
      }
      post { always { junit allowEmptyResults: true, testResults: 'test-results.xml' } }
    }

    stage('SonarCloud scan + Quality Gate') {
      steps {
        withCredentials([string(credentialsId: 'sonartoken', variable: 'SONAR_TOKEN')]) {
          sh '''
            /opt/sonar-scanner/bin/sonar-scanner \
              -Dsonar.host.url=https://sonarcloud.io \
              -Dsonar.token=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Build Docker image') {
      steps { sh 'docker build -t $IMAGE:$TAG -t $IMAGE:latest .' }
    }

    stage('Trivy image scan') {
      steps {
        sh '''
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v trivy-cache:/root/.cache/ \
            aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 \
            $IMAGE:$TAG | tee trivy-report.txt
        '''
        archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh '''
            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
            docker push $IMAGE:$TAG
            docker push $IMAGE:latest
            docker logout
          '''
        }
      }
    }

    stage('Deploy to test server') {
      steps {
        sshagent(credentials: ['ec2-ssh-key']) {
          sh 'ssh -o StrictHostKeyChecking=accept-new $TEST_HOST "IMAGE=$IMAGE TAG=$TAG bash -s" < scripts/deploy.sh'
        }
      }
    }

    stage('Health check') {
      steps {
        script {
          try {
            retry(5) {
              sleep 5
              sh 'curl -fsS $APP_URL/health'
            }
          } catch (err) {
            echo 'Health check failed, rolling back to the previous version'
            sshagent(credentials: ['ec2-ssh-key']) {
              sh 'ssh -o StrictHostKeyChecking=accept-new $TEST_HOST "bash -s" < scripts/rollback.sh'
            }
            error('New version failed the health check and was rolled back')
          }
        }
      }
    }
  }

  post {
    success { echo "Deployed build ${BUILD_NUMBER} to ${APP_URL}" }
    failure { echo 'Pipeline FAILED. Open Console Output to see which stage broke.' }
    always  { sh 'docker image prune -f || true'; deleteDir() }
  }
}
