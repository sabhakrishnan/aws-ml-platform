
import argparse
import json
import os

import joblib
import pandas as pd

from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score


FEATURE_COLUMNS = [
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

TARGET_COLUMN = "cnt"


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--train",
        type=str,
        default=os.environ.get("SM_CHANNEL_TRAIN", "./data/hour"),
    )

    parser.add_argument(
        "--model-dir",
        type=str,
        default=os.environ.get("SM_MODEL_DIR", "./model"),
    )

    parser.add_argument(
        "--metrics-dir",
        type=str,
        default="./metrics",
    )

    parser.add_argument(
        "--n-estimators",
        type=int,
        default=200,
    )

    parser.add_argument(
        "--max-depth",
        type=int,
        default=None,
    )

    parser.add_argument(
        "--random-state",
        type=int,
        default=42,
    )

    return parser.parse_args()


def load_data(train_path):
    print(f"Loading training data from: {train_path}")

    if os.path.isdir(train_path):
        df = pd.read_parquet(train_path)
    else:
        df = pd.read_parquet(train_path)

    print(f"Dataset shape: {df.shape}")
    print(f"Columns: {df.columns.tolist()}")

    return df


def prepare_data(df):
    required_columns = FEATURE_COLUMNS + [TARGET_COLUMN, "instant"]

    missing_columns = [
        column
        for column in required_columns
        if column not in df.columns
    ]

    if missing_columns:
        raise ValueError(
            f"Missing required columns: {missing_columns}"
        )

    df = df[required_columns].copy()

    df = df.dropna()

    df = df.sort_values("instant")

    X = df[FEATURE_COLUMNS]
    y = df[TARGET_COLUMN]

    return X, y

def train_model(X_train, y_train, args):
    print("Training RandomForestRegressor...")

    model = RandomForestRegressor(
        n_estimators=args.n_estimators,
        max_depth=args.max_depth,
        random_state=args.random_state,
        n_jobs=-1,
    )

    model.fit(X_train, y_train)

    return model


def evaluate_model(model, X_test, y_test):
    predictions = model.predict(X_test)

    mae = mean_absolute_error(
        y_test,
        predictions,
    )

    mse = mean_squared_error(
        y_test,
        predictions,
    )

    rmse = mse ** 0.5

    r2 = r2_score(
        y_test,
        predictions,
    )

    metrics = {
        "mae": float(mae),
        "rmse": float(rmse),
        "r2": float(r2),
        "test_rows": int(len(y_test)),
    }

    print("\nModel evaluation:")
    print(f"MAE  : {mae:.4f}")
    print(f"RMSE : {rmse:.4f}")
    print(f"R2   : {r2:.4f}")

    return metrics


def save_model(model, model_dir):
    os.makedirs(model_dir, exist_ok=True)

    model_path = os.path.join(
        model_dir,
        "model.joblib",
    )

    joblib.dump(model, model_path)

    print(f"\nModel saved to: {model_path}")

    return model_path


def save_metrics(metrics, metrics_dir):
    os.makedirs(metrics_dir, exist_ok=True)

    metrics_path = os.path.join(
        metrics_dir,
        "metrics.json",
    )

    with open(metrics_path, "w") as file:
        json.dump(metrics, file, indent=2)

    print(f"Metrics saved to: {metrics_path}")

    return metrics_path


def main():
    args = parse_args()

    print("=" * 60)
    print("AWS ML Platform - Hourly Bike Demand Training")
    print("=" * 60)

    print("\nArguments:")
    print(f"Train path   : {args.train}")
    print(f"Model dir    : {args.model_dir}")
    print(f"Metrics dir  : {args.metrics_dir}")
    print(f"Estimators   : {args.n_estimators}")
    print(f"Max depth    : {args.max_depth}")
    print(f"Random state : {args.random_state}")

    # ---------------------------------------------------------
    # 1. Load data
    # ---------------------------------------------------------

    df = load_data(args.train)

    # ---------------------------------------------------------
    # 2. Prepare features and target
    # ---------------------------------------------------------

    X, y = prepare_data(df)

    print(f"\nFeatures: {FEATURE_COLUMNS}")
    print(f"Target: {TARGET_COLUMN}")
    print(f"Training rows: {len(X)}")

    # ---------------------------------------------------------
    # 3. Train/test split
    # ---------------------------------------------------------

    split_index = int(len(X) * 0.8)

    X_train = X.iloc[:split_index]
    X_test = X.iloc[split_index:]

    y_train = y.iloc[:split_index]
    y_test = y.iloc[split_index:]

    # ---------------------------------------------------------
    # 4. Train model
    # ---------------------------------------------------------

    model = train_model(
        X_train,
        y_train,
        args,
    )

    # ---------------------------------------------------------
    # 5. Evaluate
    # ---------------------------------------------------------

    metrics = evaluate_model(
        model,
        X_test,
        y_test,
    )

    # ---------------------------------------------------------
    # 6. Save model
    # ---------------------------------------------------------

    save_model(
        model,
        args.model_dir,
    )

    # ---------------------------------------------------------
    # 7. Save metrics
    # ---------------------------------------------------------

    save_metrics(
        metrics,
        args.metrics_dir,
    )

    print("\nTraining completed successfully.")


if __name__ == "__main__":
    main()
