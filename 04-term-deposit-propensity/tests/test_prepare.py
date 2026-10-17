import pandas as pd

from src.prepare import clean, split_temporal, feature_cols, make_preprocessor

def _fila(**kw):
    base = dict(
        age=40, 
        job="admin.", 
        marital="single",
        education="university.degree",
        default_credit="no",
        housing="yes",
        loan="no",
        contact="cellular",
        month="may",
        day_of_week="mon",
        duration=100,
        campaign=2,
        pdays=999,
        previous=0,
        poutcome="nonexistent",
        emp_var_rate=1.1,
        cons_price_idx=93.9,
        cons_conf_idx=-36.4,
        euribor3m=4.8,
        nr_employed=5191.0,
        y="no"
    )
    base.update(kw)
    return base


def _df(filas):
    df = pd.DataFrame(filas)
    df["row_id"] = range(len(df))
    return df


def test_duplicados_y_duration():
    out = clean(_df([_fila(), _fila(), _fila(age=50)]))
    assert len(out) == 2
    assert "duration" not in out.columns


def test_contacto_previo_con_pdays_999():
    out = clean(
        _df([_fila(poutcome="failure", previous=1, pdays=999),
        _fila(age=30),
        _fila(age=31, pdays=5, previous=1, poutcome="success")])
    )
    assert out.contacto_previo.to_list() == [1, 0, 1]
    assert out.pdays_real.to_list() == [0, 0, 1]
    assert out.pdays_dias.to_list() == [0, 0, 5]
    assert out.intentos_previos.to_list() == [1, 1, 1]
    assert out.y_bin.to_list() == [0, 0, 0]


def test_split_es_temporal():
    out = clean(
        _df(
            [_fila(age=20 + i) for i in range(10)]
        )
    )
    tr, va, te = split_temporal(out)
    assert (len(tr), len(va), len(te)) == (6, 2, 2)
    assert tr.row_id.max() < va.row_id.min() < te.row_id.min()


def test_categoria_no_vista():
    tr = clean(
        _df(
            [_fila(age=20 + i) for i in range(5)]
        )
    )
    nuevo = clean(
        _df(
            [_fila(job="student")]
        )
    )
    cat, num = feature_cols(use_macro=True, use_month=True)
    pre = make_preprocessor(cat, num, scale=True).fit(tr)
    assert pre.transform(nuevo).shape[0] == 1