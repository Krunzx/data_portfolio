import os

import pandas as pd
from dotenv import load_dotenv
from google.cloud import bigquery

load_dotenv('creds.env')

PROJECT = os.environ['GCP_PROJECT_ID']
DATASET = os.environ['BQ_DATASET']
TABLE = 'bank_additional_full'
CSV = 'data/raw/bank-additional/bank-additional-full.csv'

df = pd.read_csv(CSV, sep=';')
df.columns = [c.replace('.', '_') for c in df.columns]
df = df.rename(columns={'default': 'default_credit'})
df.insert(0, 'row_id', range(len(df)))

client = bigquery.Client(project=PROJECT)
client.create_dataset(
    bigquery.Dataset(f"{PROJECT}.{DATASET}"), exists_ok=True
)

schema = [
    bigquery.SchemaField('row_id', 'INT64'),
    bigquery.SchemaField('age', 'INT64'),
    bigquery.SchemaField('job', 'STRING'),
    bigquery.SchemaField('marital', 'STRING'),
    bigquery.SchemaField('education', 'STRING'),
    bigquery.SchemaField("default_credit", "STRING"),
    bigquery.SchemaField("housing", "STRING"),
    bigquery.SchemaField("loan", "STRING"),
    bigquery.SchemaField("contact", "STRING"),
    bigquery.SchemaField("month", "STRING"),
    bigquery.SchemaField("day_of_week", "STRING"),
    bigquery.SchemaField("duration", "INT64"),
    bigquery.SchemaField("campaign", "INT64"),
    bigquery.SchemaField("pdays", "INT64"),
    bigquery.SchemaField("previous", "INT64"),
    bigquery.SchemaField("poutcome", "STRING"),
    bigquery.SchemaField("emp_var_rate", "FLOAT64"),
    bigquery.SchemaField("cons_price_idx", "FLOAT64"),
    bigquery.SchemaField("cons_conf_idx", "FLOAT64"),
    bigquery.SchemaField("euribor3m", "FLOAT64"),
    bigquery.SchemaField("nr_employed", "FLOAT64"),
    bigquery.SchemaField("y", "STRING"),
]

job = client.load_table_from_dataframe(
    df, 
    f"{PROJECT}.{DATASET}.{TABLE}", 
    job_config=bigquery.LoadJobConfig(schema=schema, write_disposition="WRITE_TRUNCATE"),
)
job.result()
print('Filas cargadas:', client.get_table(f"{PROJECT}.{DATASET}.{TABLE}").num_rows)

