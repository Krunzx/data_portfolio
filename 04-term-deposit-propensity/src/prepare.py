import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler

# Columnas de tipo categorico
CAT = [
    "job", "marital", "education", "default_credit", 
    "housing", "loan", "contact", "day_of_week", "poutcome"
]

# Columnas de tipo numérico
NUM = [
    "age", "intentos_previos", "previous", "pdays_dias",
    "contacto_previo", "pdays_real"
]

# Columnas macro económicas
MACRO = [
    "emp_var_rate", "cons_price_idx", "cons_conf_idx",
    "euribor3m", "nr_employed"
]

def clean(df: pd.DataFrame) -> pd.DataFrame:
    """
        Función para limpiar duplicados y columna `duration`.
        Además, agrega una serie de columnas que ayudan al proceso de modelado.
    """
    sin_id = [c for c in df.columns if c != "row_id"]
    out = df.sort_values("row_id").drop_duplicates(subset=sin_id, keep="first").copy()
    out = out.drop(columns=["duration"]) # D2: leakage
    out["y_bin"] = (out["y"] == "yes").astype(int)
    out["contacto_previo"] = (out["previous"] > 0).astype(int) # D14
    out["pdays_real"] = (out["pdays"] != 999).astype(int)
    out["pdays_dias"] = out["pdays"].where(out["pdays"] != 999, 0)
    out["intentos_previos"] = out["campaign"] - 1 # A3: campaign incluye la llamada actual

    return out.reset_index(drop=True)


def split_temporal(df, fracs=(0.6, 0.2, 0.2)):
    """
        Divide un dataframe en las siguiente proporciones:
        60, 20 , 20.
    """
    df = df.sort_values("row_id")
    a = int(len(df) * fracs[0])
    b = int(len(df) * (fracs[0] + fracs[1]))

    return df.iloc[:a], df.iloc[a:b], df.iloc[b:]


def feature_cols(use_macro: bool, use_month: bool):
    cat = CAT + (["month"] if use_month else [])
    num = NUM + (MACRO if use_macro else [])

    return cat, num

def make_preprocessor(cat, num, scale:bool) -> ColumnTransformer:
    num_step = StandardScaler() if scale else "passthrough"

    return ColumnTransformer([
        ("cat", 
        OneHotEncoder(handle_unknown="ignore", sparse_output=False),
        cat),
        ("num", num_step, num),
    ])