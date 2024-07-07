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

# Endpoint to create an EC2 instance (Bonus)
@app.route('/api/v1/ec2', methods=['POST'])
def create_ec2():
    data = request.json
    instance_type = data.get('instance_type', 't2.micro')
    ami_id = data.get('ami_id')
    subnet_id = data.get('subnet_id')
    
    ec2 = boto3.client('ec2')
    instances = ec2.run_instances(
        ImageId=ami_id,
        InstanceType=instance_type,
        SubnetId=subnet_id,
        MinCount=1,
        MaxCount=1
    )
    instance_id = instances['Instances'][0]['InstanceId']
    return jsonify({"instance_id": instance_id}), 201

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
