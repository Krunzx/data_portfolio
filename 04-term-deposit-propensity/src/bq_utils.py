import os
import re
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from google.cloud import bigquery
from functools import lru_cache

import warnings

warnings.filterwarnings("ignore", message="BigQuery Storage module not found")

ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / "creds.env")

def _need(name: str) -> str:
    if name not in os.environ:
        raise RuntimeError(f"Falta {name}. Copia creds.env.example a creds.env y complétalo.")
    return os.environ[name]

PROJECT = _need("GCP_PROJECT_ID")
DATASET = _need("BQ_DATASET")
PLACEHOLDER = "TU_PROYECTO.TU_DATASET"

@lru_cache
def _client() -> bigquery.Client:
    return bigquery.Client(project=PROJECT)

def load_queries(path: str = 'sql/02_eda_queries.sql') -> dict[str, str]:
    """
    Separa el archivo .sql en consultas, indexadas por su
    etiqueta (P1a, P6, ...).
    """
    text = (ROOT / path).read_text(encoding='utf-8')
    queries = {}

    for chunk in re.split(r';\s*\n', text):
        sin_comentarios = re.sub(r'--.*', '', chunk).strip()
        label = re.search(r'^--\s*(P\d+[a-z]?\b)', chunk, re.M)

        if sin_comentarios and label:
            queries[label.group(1)] = chunk.strip()

    return queries

def run(sql: str) -> pd.DataFrame:
    """
    Ejecuta una consulta SQL en BigQuery y devuelve un DataFrame.
    """
    return _client().query(sql.replace(PLACEHOLDER, f"{PROJECT}.{DATASET}")).to_dataframe()
