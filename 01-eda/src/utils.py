# Función para parsear periodos de la data
MESES = {
    'ENE': '01', 'FEB': '02', 'MAR': '03', 'ABR': '04',
    'MAY': '05', 'JUN': '06', 'JUL': '07', 'AGO': '08',
    'SEP': '09', 'OCT': '10', 'NOV': '11', 'DIC': '12'
}

def parsear_periodo(periodo):
    mes_abr = periodo[:3]
    anio = periodo[3:]
    return f"{anio}-{MESES[mes_abr]}-01"