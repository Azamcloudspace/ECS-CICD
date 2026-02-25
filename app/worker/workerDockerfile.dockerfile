FROM python:3.11-slim

COPY app/worker/worker-requirements.txt .
RUN pip install --no-cache-dir -r app/worker/worker-requirements.txt

COPY app/worker/worker.py .


CMD ["python", "worker.py"]
