import os
import re
import boto3
import logging
from flask import Flask
from botocore.exceptions import ClientError

app = Flask(__name__)

AWS_HOST = os.getenv('AWS_HOST')
AWS_PORT = os.getenv('AWS_PORT')
BUCKET_NAME = os.getenv('BUCKET_NAME')
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')

stop_list = ['\n']

def read(filename, split = " "):
    assert isinstance(filename, str)
    assert isinstance(split, str)
    return_list = []
    with open(filename, 'r') as f:
        tmpstr = f.readline()
        while(tmpstr):
            tmplist = re.split(split, tmpstr)
            for i in stop_list:
                try:
                    tmplist.remove(i)
                except:
                    pass
            return_list.append(tmplist)
            tmpstr = f.readline()
    return return_list

@app.route('/max_id/<max_id>')
def wc_reduce(max_id):
    s3_client = boto3.client(
        service_name='s3',
        endpoint_url='http://{}:{}'.format(AWS_HOST, AWS_PORT),
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    )

    cnt = dict()

    # iterate over all intermediate files
    for id in range(int(max_id.strip())+1):
        # download intermediate data from s3
        input_path = "/app/intermediate_data_"+str(id)
        input_name = "intermediate_data_"+str(id)
        try:
            s3_client.download_file(BUCKET_NAME, input_name, input_path)
        except ClientError as e:
            logging.error(e)
            return "Failed to download {}\n".format(input_name)

        # word count reducing computation
        res = read(input_path)
        for line in res:
            word = line[0]
            num = int(line[1].strip())
            if not word in cnt:
                cnt[word] = num
            else:
                cnt[word] += num


    # upload final results
    output_path = "/app/wc_result"
    output_name = "wc_result"
    with open(output_path, "w+") as f:
        for k in cnt:
            f.write(k+" "+str(cnt[k])+"\n")
    
    try:
        s3_client.upload_file(output_path, BUCKET_NAME, output_name)
    except ClientError as e:
        logging.error(e)
        return "Failed to upload output data\n"
    
    return cnt


if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 80)))
