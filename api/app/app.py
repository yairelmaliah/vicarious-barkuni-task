from flask import Flask, jsonify, request, render_template
import boto3
import kubernetes
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Endpoint to view a welcome message
@app.route('/')
def welcome():
    return render_template('index.html')

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

# Endpoint to list running pods in the kube-system namespace
@app.route('/pods', methods=['GET'])
def list_pods():
    # for local testing
    # kubernetes.config.load_kube_config(config_file="~/.kube/config")
    kubernetes.config.load_incluster_config()
    v1 = kubernetes.client.CoreV1Api()
    pods = v1.list_namespaced_pod("default")
    pod_names = [pod.metadata.generate_name for pod in pods.items]
    return jsonify(pod_names)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
