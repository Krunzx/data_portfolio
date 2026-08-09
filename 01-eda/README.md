# EDA: Comercio Exterior de Chile — Exportaciones e Importaciones por País

## Problema
¿Cómo ha evolucionado la composición de los socios comerciales de Chile
(principales países de destino de exportaciones y origen de importaciones)
en los últimos años? ¿Qué explica los cambios más importantes en el tiempo?

## Datos
- **Fuente principal**: Banco Central de Chile, Base de Datos Estadísticos (BDE) /
  Boletín Estadístico, Capítulo 4.6 "Comercio Exterior"
- **Fuente complementaria**: Comisión Chilena del Cobre (Cochilco), Boletín
  Electrónico Mensual, Tabla 21 "Embarques Físicos de Exportación de Cobre y
  Molibdeno"
- **Series usadas**:
  - Exportaciones por país (`exportaciones_por_pais.csv`, serie BH511)
  - Importaciones por país (`importaciones_por_pais.csv`, serie BH512)
  - Precio del cobre refinado BML, USD/libra (`precio_cobre_bml.csv`,
    serie F019.PPB.PRE.40.M del BCCh — extraída manualmente de la BDE, ya
    que el botón de exportación de esa página requiere sesión iniciada)
  - Volumen físico de exportación de cobre (`volumen_exportacion_cobre.csv`,
    Tabla 21 de Cochilco)
- **Cobertura**:
  - Exportaciones e importaciones por país: enero 2003 - junio 2026 (282 meses, sin nulos)
  - Precio del cobre: enero 2003 - julio 2026 (283 meses)
  - Volumen exportado de cobre: enero 2023 - mayo 2026 únicamente (43 meses)
    — Cochilco solo publica el detalle mensual de los últimos años; años
    anteriores solo están disponibles como totales anuales.
- **Método de acceso**: descarga directa en CSV/Excel, sin necesidad de API
  ni autenticación
- **Fecha de descarga**: 2026-07-27
- **Licencia / uso**: datos públicos del Banco Central de Chile y de
  Cochilco, de libre acceso y reutilización

## Proceso
1. **Carga y exploración inicial**: identificación de la estructura real de
   los CSV del BCCh (3 filas de metadata antes de la tabla de datos:
   códigos de serie, descripción, unidad)
2. **Limpieza**:
   - Parseo de fechas en formato `MESAAAA` en español (sin depender de
     locale del sistema, con diccionario manual reutilizable en `src/utils.py`)
   - Separación de columnas de países individuales vs. totales agregados por
     región, para evitar doble conteo
   - Reshape de formato ancho a largo (`pd.melt()`) para facilitar
     comparaciones y visualización
   - Descomposición de la jerarquía geográfica (continente / subregión /
     país) a partir de los nombres de columna originales, con corrección
     del caso especial de Europa y Asia (que solo tienen 2 niveles de
     jerarquía en vez de 3)
3. **Análisis exploratorio**:
   - Tendencias de exportación por continente/subregión (2003-2026)
   - Cruce de exportaciones a Asia con el precio del cobre (correlación y
     visualización con doble eje)
   - Descomposición precio vs. volumen para el período 2023-2026
4. **Testing**: función de parseo de fechas cubierta con tests unitarios
   (`src/test_utils.py`, `pytest`)

## Resultados

**1. Asia es, por lejos, el principal destino de las exportaciones chilenas**
entre los continentes/subregiones desglosados, seguido de América del Norte,
Europa y América del Sur (estos tres últimos con niveles similares entre sí
durante la mayor parte del período).

**2. Cambio de régimen desde 2020-2021**: las exportaciones a Asia pasaron de
un promedio de ~2.400 MUSD a ~4.600 MUSD mensuales (+90% aprox.), con un
salto mucho más pronunciado que el resto de las regiones. América del Norte
también creció en este período, aunque de forma más moderada; Europa y
América del Sur se mantuvieron prácticamente planas.

**3. El precio del cobre explica buena parte del comportamiento de las
exportaciones a Asia**: correlación de 0.82 entre ambas series para el
período completo (2003-2026). La relación es más débil en los primeros años
(hasta ~2012) y se estrecha después, coincidiendo con una etapa de menor
expansión de capacidad minera y mayor influencia del precio en el valor
exportado.

**4. Para el período 2023-2026** (único con datos de volumen físico
disponibles), la descomposición muestra que el crecimiento en el valor
exportado está más ligado al precio que al volumen: el precio del cobre
subió ~47% en el período, mientras que el volumen físico exportado se
mantuvo prácticamente estable (+5%). Las exportaciones a Asia en este tramo
muestran alta volatilidad mes a mes, con una correlación moderada (0.44)
frente al precio — más ruidosa que en la serie completa de 23 años.

## Aprendizajes

- **El dataset del BCCh no incluye un total mundial de exportaciones** —
  solo desglosa América, Europa y Asia. Cualquier análisis de "tendencia
  general" debe aclarar que se refiere a estos tres continentes, no al
  total exportado por Chile a todo el mundo.
- **`str.split()` con un patrón de más de un carácter se interpreta como
  regex por defecto en pandas** — el punto (`.`) significa "cualquier
  carácter", no un punto literal. Usar `regex=False` o escapar el patrón
  evita separaciones incorrectas del texto.
- **El valor exportado (USD) combina precio y volumen** — un aumento en el
  valor no implica necesariamente más volumen físico exportado. Separar
  ambos factores requiere conseguir la serie de volumen por separado, que
  no siempre está disponible con la misma cobertura temporal que el valor.
- **Un dato que no cubre exactamente el período de interés puede seguir
  siendo útil** si se reformula la pregunta a lo que sí permite responder,
  documentando explícitamente qué queda sin confirmar.
- **Las correlaciones calculadas sobre pocas observaciones (ej. 41 meses)
  son más sensibles al ruido** que las calculadas sobre series largas —
  conviene no sobre-interpretarlas con el mismo nivel de confianza.
- **Comparar solo el primer y el último punto de una serie para calcular
  variación porcentual es poco confiable** si esos puntos puntuales no son
  representativos de la tendencia general; promediar ventanas de varios
  meses en cada extremo da una lectura más robusta.

## Cómo reproducir
1. `pip install -r requirements.txt`
2. Abrir los notebooks en la carpeta `notebooks/`, en orden:
   `01_exploracion_inicial.ipynb` (carga y limpieza) y
   `02_analisis_exploratorio.ipynb` (análisis y visualizaciones)

## Estructura del proyecto
```
01-eda/
├── data/
│   ├── raw/          # datos originales, sin modificar
│   └── processed/    # datos limpios, listos para análisis
├── notebooks/         # notebooks de exploración y análisis
├── src/                # funciones reutilizables (limpieza, gráficos) y tests
├── requirements.txt
└── README.md
```
