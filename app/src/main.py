from fastapi import FastAPI
from pydantic import BaseModel
import boto3
from pathlib import Path
import logging

app = FastAPI()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

logger = logging.getLogger(__name__)

class HealthResponse(BaseModel):
    status: str

s3 = boto3.client("s3")
BUCKET = (Path(__file__).parent / ".bucket_name").read_text().strip()


@app.get("/health", response_model=HealthResponse)
async def health():
    logger.info("Health check requested")
    return {"status": "ok"}


@app.get("/files/{key:path}")
async def read_file(key: str):
    logger.info("Reading file from S3: %s", key)

    try:
        response = s3.get_object(Bucket=BUCKET, Key=key)
        content = response["Body"].read().decode("utf-8")

        logger.info("Successfully read file from S3: %s", key)
        return content

    except Exception:
        logger.exception("Failed to read file from S3: %s", key)
        raise


@app.put("/files/{key:path}")
async def write_file(key: str, content: str):
    logger.info("Writing file to S3: %s", key)

    try:
        s3.put_object(Bucket=BUCKET, Key=key, Body=content)

        logger.info("Successfully wrote file to S3: %s", key)
        return {"status": "ok"}

    except Exception:
        logger.exception("Failed to write file to S3: %s", key)
        raise
