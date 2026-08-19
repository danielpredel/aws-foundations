from fastapi import FastAPI
from pydantic import BaseModel
import boto3

app = FastAPI()

class HealthResponse(BaseModel):
    status: str

s3 = boto3.client("s3")
BUCKET = "project-1-s3"

@app.get("/health", response_model=HealthResponse)
async def health():
    return {"status": "ok"}

@app.get("/files/{key:path}")
async def read_file(key: str):
    response = s3.get_object(Bucket=BUCKET, Key=key)
    return response["Body"].read().decode("utf-8")

@app.put("/files/{key:path}")
async def write_file(key: str, content: str):
    s3.put_object(Bucket=BUCKET, Key=key, Body=content)
    return {"status": "ok"}
