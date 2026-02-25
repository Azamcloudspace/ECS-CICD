FROM python:3.11-slim

COPY app/api/app-requirements.txt .
RUN pip install --no-cache-dir -r app/api/app-requirements.txt

COPY app/api/app.py .

EXPOSE 5000

CMD ["python", "app.py"]
