FROM python:3.12-alpine
WORKDIR /flask_app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
RUN adduser -D appuser
USER appuser
EXPOSE 8080
CMD ["python", "app.py"]
