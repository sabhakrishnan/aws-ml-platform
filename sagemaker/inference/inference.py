import json
import os

import joblib
import pandas as pd
from flask import Flask, request, jsonify


MODEL_PATH = os.path.join(
    os.environ.get("MODEL_DIR", "/opt/ml/model"),
    "model.joblib"
)

FEATURES = [
    "season",
    "yr",
    "mnth",
    "hr",
    "holiday",
    "weekday",
    "workingday",
    "weathersit",
    "temp",
    "atemp",
    "hum",
    "windspeed",
]

app = Flask(__name__)

model = joblib.load(MODEL_PATH)
print(f"Model loaded from: {MODEL_PATH}")


@app.route("/ping", methods=["GET"])
def ping():
    if model is None:
        return jsonify({"status": "unhealthy"}), 503

    return jsonify({"status": "healthy"}), 200


@app.route("/invocations", methods=["POST"])
def invocations():
    if model is None:
        return jsonify({"error": "Model not loaded"}), 503

    try:
        data = request.get_json()

        if isinstance(data, dict):
            data = [data]

        df = pd.DataFrame(data)

        missing = [
            feature
            for feature in FEATURES
            if feature not in df.columns
        ]

        if missing:
            return jsonify({
                "error": f"Missing required features: {missing}"
            }), 400

        df = df[FEATURES]

        predictions = model.predict(df)

        return jsonify({
            "predictions": predictions.tolist()
        })

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500
