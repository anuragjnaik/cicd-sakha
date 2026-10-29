import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'app'))

from app import app  # noqa: E402


def test_index():
    response = app.test_client().get('/')
    assert response.status_code == 200
    assert b'Hello' in response.data


def test_health():
    response = app.test_client().get('/health')
    assert response.status_code == 200
    assert response.get_json()['status'] == 'ok'
