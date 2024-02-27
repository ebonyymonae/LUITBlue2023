import boto3

def get_running_instances():
    
    region = 'us-east-1'

    
    ec2_client = boto3.client('ec2', region_name=region)

    try:
        
        instances = ec2_client.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])

        
        instance_ids = [instance['InstanceId'] for reservation in instances['Reservations'] for instance in reservation['Instances']]

        return instance_ids

    except Exception as e:
        print(f"Error getting running instances: {e}")
        return []

def print_instances_to_stop(instance_ids):
    if not instance_ids:
        print("No running instances found.")
    else:
        print("Instances to stop:")
        for instance_id in instance_ids:
            print(instance_id)

def stop_all_running_instances(instance_ids):
    
    region = 'us-east-1'

    
    ec2_client = boto3.client('ec2', region_name=region)

    try:
        if not instance_ids:
            print("No running instances to stop.")
            return

        
        response = ec2_client.stop_instances(InstanceIds=instance_ids)

        
        print(f"Instances stopped successfully: {response['StoppingInstances']}")

    except Exception as e:
        print(f"Error stopping instances: {e}")

def lambda_handler(event, context):
    
    running_instance_ids = get_running_instances()
    print_instances_to_stop(running_instance_ids)
    stop_all_running_instances(running_instance_ids)

if __name__ == "__main__":
    # For testing locally
    running_instance_ids = get_running_instances()
    print_instances_to_stop(running_instance_ids)
    stop_all_running_instances(running_instance_ids)