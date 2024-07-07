'''
This is a simple Flask application that creates an EC2 instance using the boto3 library.
'''

from flask import Flask, request, jsonify
import boto3
from botocore.exceptions import ClientError

app = Flask(__name__)

## Explicit aws credentials (locally)
# from botocore.config import Config
# session = boto3.Session(profile_name="terraform")
# ec2 = session.client('ec2', config=Config(region_name='us-east-1'))
# ssm = session.client('ssm', config=Config(region_name='us-east-1'))

# Using the default credentials
ssm = boto3.client('ssm', region_name='us-east-1')
ec2 = boto3.client('ec2', region_name='us-east-1')

def validate_parameters(params):
    """ Validate the provided parameters for missing or empty values. """
    for key in ['instance_type', 'ami_id', 'subnet_id']:
        if key not in params or not params[key]:
            return f"Error: '{key}' is required and cannot be empty."
    return None

def create_instance(instance_type, instance_name, ami_id, subnet_id):
    """ Attempt to create an EC2 instance with the given parameters. """
    tags = [{'Key': 'Name', 'Value': instance_name}] if instance_name else []
    try:
        response = ec2.run_instances(
            ImageId=ami_id,
            InstanceType=instance_type,
            MaxCount=1,
            MinCount=1,
            NetworkInterfaces=[{
                'AssociatePublicIpAddress': True,
                'DeviceIndex': 0,
                'SubnetId': subnet_id
            }],
            TagSpecifications=[{
                'ResourceType': 'instance',
                'Tags': tags
            }]     
        )
        return {"instance_id": response['Instances'][0]['InstanceId']}
    except ClientError as e:
        return {"error": str(e)}

@app.route('/ec2', methods=['POST'])
def create_ec2():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    data['instance_type'] = data.get('instance_type', 't2.micro')  # default type if not specified

    validation_error = validate_parameters(data)
    if validation_error:
        return jsonify({"error": validation_error}), 400

    result = create_instance(**data)
    if 'error' in result:
        return jsonify(result), 500

    return jsonify({"message": "EC2 instance created successfully", **result}), 201

if __name__ == '__main__':
    app.run(debug=True)
