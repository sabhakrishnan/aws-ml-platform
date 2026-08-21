FROM python:3.11-slim

WORKDIR /opt/ml/code

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY inference.py .

RUN mkdir -p /opt/ml/model
COPY model/model.joblib /opt/ml/model/model.joblib

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--timeout", "120", "inference:app"]
