import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from google.cloud import bigquery

ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / "creds.env")

PROJECT = os.environ["GCP_PROJECT_ID"]
DATASET = os.environ["BQ_DATASET"]
TABLE = "bank_additional_full"
CSV = ROOT / "data/raw/bank-additional/bank-additional-full.csv"

COLUMNS = {
    "row_id": "INT64",
    "age": "INT64",
    "job": "STRING",
    "marital": "STRING",
    "education": "STRING",
    "default_credit": "STRING",
    "housing": "STRING",
    "loan": "STRING",
    "contact": "STRING",
    "month": "STRING",
    "day_of_week": "STRING",
    "duration": "INT64",
    "campaign": "INT64",
    "pdays": "INT64",
    "previous": "INT64",
    "poutcome": "STRING",
    "emp_var_rate": "FLOAT64",
    "cons_price_idx": "FLOAT64",
    "cons_conf_idx": "FLOAT64",
    "euribor3m": "FLOAT64",
    "nr_employed": "FLOAT64",
    "y": "STRING",
}

df = pd.read_csv(CSV, sep=";")
df.columns = [c.replace(".", "_") for c in df.columns]
df = df.rename(columns={"default": "default_credit"})
df.insert(0, "row_id", range(len(df)))  # BigQuery no garantiza el orden; lo fijamos para el split temporal

client = bigquery.Client(project=PROJECT)
client.create_dataset(f"{PROJECT}.{DATASET}", exists_ok=True)

job = client.load_table_from_dataframe(
    df,
    f"{PROJECT}.{DATASET}.{TABLE}",
    job_config=bigquery.LoadJobConfig(
        schema=[bigquery.SchemaField(name, dtype) for name, dtype in COLUMNS.items()],
        write_disposition="WRITE_TRUNCATE",
    ),
)
job.result()
print("Filas cargadas:", job.output_rows)
