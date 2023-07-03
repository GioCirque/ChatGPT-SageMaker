import os
import boto3
import json
from transformers import AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained("tiiuae/falcon-40b-instruct")
sagemaker_client = boto3.client("runtime.sagemaker")


def write_history_to_s3(bucket, key, history):
    s3_client = boto3.client("s3")
    s3_client.put_object(Body=json.dumps(history), Bucket=bucket, Key=key)


def load_history_from_s3(bucket, key):
    s3_client = boto3.client("s3")
    response = s3_client.get_object(Bucket=bucket, Key=key)
    return json.loads(response["Body"].read().decode())


def format_history_entry(entry):
    return f"{entry['source']}: {entry['content']}\n"


def invoke_with_history(endpoint_name, input_message, bucket, key):
    new_entry = {"source": "user", "content": input_message}
    history = load_history_from_s3(bucket, key)
    history.append(new_entry)

    # Stack the first message as an overarching prompt
    prompt = tokenizer.encode(format_history_entry(history[0]))
    prompt_tokens = len(prompt)

    # Ensure the current input length is accommodated
    new_input = tokenizer.encode(format_history_entry(new_entry))
    new_tokens = len(new_input)

    # Trim the history to keep the most recent 2048 tokens
    total_tokens = prompt_tokens + new_tokens
    trimmed_history = [prompt, new_input]
    for message in reversed(history):
        encoded_message = tokenizer.encode(format_history_entry(message))
        if total_tokens + len(encoded_message) <= 2048:
            total_tokens += len(encoded_message)
            trimmed_history.insert(1, message)
        else:
            break

    payload = json.dumps(trimmed_history)

    response = sagemaker_client.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType="application/json",
        Body=payload
    )

    output_message = json.loads(response["Body"].read().decode())

    history.append({"source": "system", "content": output_message})
    write_history_to_s3(bucket, key, history)

    return output_message


def lambda_handler(event, context):
    # Fixed key for simplicity, should be unique per user in a multi-user system
    key = "history.json"

    bucket = os.environ["BUCKET"]
    endpoint_name = os.environ["ENDPOINT_NAME"]

    input_message = event["user_message"]

    response = invoke_with_history(endpoint_name, input_message, bucket, key)

    return {
        "statusCode": 200,
        "body": response
    }
