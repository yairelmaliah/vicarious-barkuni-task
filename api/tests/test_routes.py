import pytest
from unittest.mock import patch, MagicMock
from flask import template_rendered
from contextlib import contextmanager
from app.app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@contextmanager
def captured_templates(app):
    recorded = []
    def record(sender, template, context, **extra):
        recorded.append((template, context))
    template_rendered.connect(record, app)
    try:
        yield recorded
    finally:
        template_rendered.disconnect(record, app)

def test_welcome(client):
    with captured_templates(app) as templates:
        response = client.get('/')
        assert response.status_code == 200
        assert len(templates) == 1
        template, _ = templates[0]
        assert template.name == 'index.html'

def test_health(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}

# @patch('kubernetes.client.CoreV1Api.list_namespaced_pod')
# def test_list_pods(mock_list_pods, client):
#     # Mock the response from Kubernetes API
#     mock_pod = MagicMock()
#     mock_pod.metadata.generate_name = "pod1"
#     mock_list_pods.return_value.items = [mock_pod]

#     response = client.get('/pods')
#     assert response.status_code == 200
#     assert response.get_json() == ["pod1"]
