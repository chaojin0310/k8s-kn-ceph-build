import os

from flask import Flask
import boto3
import logging
from botocore.exceptions import ClientError

app = Flask(__name__)

AWS_HOST = os.getenv('AWS_HOST')
AWS_PORT = os.getenv('AWS_PORT')
BUCKET_NAME = os.getenv('BUCKET_NAME')
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')

@app.route('/')
def upload_file():
    # with open('/tmp/rookObj', 'w+') as f:
    #     f.write('Test successful!')

    s3_client = boto3.client(
        service_name='s3',
        endpoint_url='http://{}:{}'.format(AWS_HOST, AWS_PORT),
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    )

    try:
        s3_client.upload_file("/app/input0", BUCKET_NAME, "input0")
    except ClientError as e:
        logging.error(e)
        return "Failed to upload input0\n"
    
    try:
        s3_client.upload_file("/app/input1", BUCKET_NAME, "input1")
    except ClientError as e:
        logging.error(e)
        return "Failed to upload input1\n"
    
    return "Successfully uploaded\n"




if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 80)))
