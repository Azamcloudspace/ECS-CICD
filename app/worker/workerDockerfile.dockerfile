FROM python:3.11-slim

WORKDIR /app

COPY app/worker/worker-requirements.txt .
RUN pip install --no-cache-dir -r worker-requirement.txt

COPY app/api/app.py .

EXPOSE 5000

CMD ["python", "worker.py"]

