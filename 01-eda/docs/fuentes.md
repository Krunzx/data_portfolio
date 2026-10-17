# Fuentes de datos de 01-eda (morosidad bancaria)

Verificación hecha el 2026-10-17. Criterio: solo dominios oficiales (`cmfchile.cl`, `bcentral.cl`, `ine.gob.cl` y subdominios). Las páginas se leyeron con una herramienta que resume su contenido, así que cada dato debe confirmarse una vez más al abrir el archivo real. Todavía no se descargó ningún archivo.

## Confirmado

### 1. Morosidad de 90 días o más por banco (CMF)

- Página: https://www.cmfchile.cl/portal/estadisticas/626/w4-propertyvalue-28914.html
- Nombre: "Indicador de morosidad de 90 días o más individual del Sistema Bancario".
- Contenido: indicador mensual para cada banco y para el sistema, por colocaciones comerciales, personas (consumo y vivienda) y adeudado por bancos.
- Formato: Excel, un archivo por mes (`.xlsx`; `.xls` en octubre a diciembre de 2015). Sin CSV.
- Cobertura: octubre 2015 a agosto 2026, unos 130 archivos mensuales de 28 a 154 KB.
- No indicado en la página: fórmula y unidades (el Informe Anual 2025 de la CMF la define como monto en mora sobre stock de colocaciones), si consumo y vivienda vienen separados dentro del archivo, lista de bancos, tratamiento de fusiones.
- Errores de la página: la entrada de marzo 2026 figura con fecha 28/02/2026 y una de 2019 dice "Agosoto". Verificar el período dentro de cada archivo, no por el nombre.

### 2. Morosidad por cartera y región (CMF)

- Página: https://www.cmfchile.cl/portal/estadisticas/626/w4-propertyvalue-29503.html
- Nombre: "Morosidad, índice de mora por cartera (mora 90 días o más)".
- Contenido: reporte mensual por región y por cartera (comercial, consumo, vivienda). No consta desglose por banco.
- Formato: Excel (`.xlsx`, unos 3 MB). La página lista una sola entrada (31/07/2026); el primer período no está indicado.

### 3. Colocaciones por institución (Banco Central)

- Serie de Datos Bancarios, publicación mensual con páginas por mes, por ejemplo https://www.bcentral.cl/contenido/-/details/serie-de-datos-bancarios-febrero-de-2025
- Según los resultados de búsqueda del sitio: colocaciones, depósitos e inversiones por institución, desde enero de 2008, en Excel y CSV, con un rezago de unos 3 meses.
- Las páginas no se pudieron leer completas en la herramienta (vinieron vacías), así que formato y cobertura quedan por confirmar abriendo la página en el navegador.

### 4. Tasa de política monetaria (Banco Central)

- Base de Datos Estadísticos, página de la serie: https://si3.bcentral.cl/Bdemovil/BDE/Series/MOV_SC_TI1 (código de página `MOV_SC_TI1`; cuadro `TPM_C1` en el portal Siete).
- Falta confirmar el código de serie para descarga.

## No verificado

- Códigos de serie del IMACEC y de la tasa de desocupación en la Base de Datos Estadísticos (la página `MOV_SC_CN1` los menciona pero no se pudo leer: dio demasiadas redirecciones). Fuente alternativa para desempleo: INE (`ine.gob.cl`), por consultar.
- La CMF menciona la plataforma BEST ("Base Estadística en Series Temporales") en el dominio `www.best-cmf.cl`, con series de provisiones por riesgo de crédito por banco, cartera y grupo de clasificación (enero 2011 a mayo 2021 según un comunicado de 2021). Ese dominio no es `cmfchile.cl`: no se usará hasta confirmar que `cmfchile.cl` enlaza a él.
- Una serie histórica de mora desde 2008 (por comuna e institución, de la antigua SBIF) aparece en un documento de la CMF, pero la lista indexada llegaba solo a marzo de 2020. No se usa.

## Consecuencia para el alcance

La comparación entre bancos solo es posible desde octubre de 2015 y con tres cortes (comercial, personas, adeudado por bancos), no con tres carteras separadas. La serie del sistema por cartera (consumo, vivienda, comercial) sí permite las tres, pero hay que ver desde cuándo. El cambio de régimen de 2020-2021 queda dentro de la ventana de 2015 a 2026 (unas 130 observaciones mensuales), más corta que los 200 meses imaginados en el diseño.

## Descargas pendientes

Sin descargar todavía. Requieren autorización explícita del usuario (archivo, fuente y tamaño), ver el mensaje del 2026-10-17.
