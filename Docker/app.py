import logging
import boto3
from flask import Flask, jsonify, request
from botocore.exceptions import ClientError

app = Flask(__name__)

@app.route('/run_test/<string:bucket>', methods=['GET', 'POST'])
def run_test(bucket, prefix='', profile_name="swift-pcs-de", endpoint_url="https://s3.de.cloud.ovh.net"):
    """List files in an S3 bucket with optional prefix

    :param bucket: Bucket name from URL
    :param prefix: Prefix to filter files (optional)
    :param profile_name: AWS profile name. If not specified, default profile will be used
    :param endpoint_url: Endpoint URL for the S3 service (optional)
    :return: JSON response containing list of file keys in the bucket
    """
    if request.method == 'POST':
        # Retrieve optional parameters from request body
        data = request.json
        prefix = data.get('prefix', '')

    try:
        # Create a session with the specified profile
        session = boto3.Session(profile_name=profile_name)

        # Create an S3 client with optional endpoint URL
        s3_client = session.client('s3', endpoint_url=endpoint_url)

        # Use list_objects_v2 method of the s3 client to list files
        response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix)

        # Extract file keys from the response
        file_keys = [obj['Key'] for obj in response.get('Contents', [])]

        # Serialize output to JSON
        response = {'Files list': file_keys}
        return jsonify(response)

    except ClientError as e:
        logging.error(e)
        return jsonify({'error': 'Failed to list files in S3 bucket.'})

if __name__ == '__main__':
    app.run(debug=True)

