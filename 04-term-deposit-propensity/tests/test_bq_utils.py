import re

from src.bq_utils import load_queries

def test_load_queries_completo():
    q = load_queries()
    assert len(q) == 24
    for label, sql in q.items():
        assert re.search(r"\b(SELECT|WITH)\b", sql), label
        assert not re.search(r"FROM\s+'", sql), label