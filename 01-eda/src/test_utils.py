from utils import parsear_periodo

def test_parsear_periodo_enero():
    assert parsear_periodo('ENE2003') == '2003-01-01'

def test_parsear_periodo_diciembre():
    assert parsear_periodo('DIC2025') == '2025-12-01'

def test_parsear_periodo_mes_desconocido():
    try:
        parsear_periodo('XYZ2003')
        assert False, "Debería haber lanzado un error"
    except KeyError:
        pass