# EDA: Comercio Exterior de Chile — Exportaciones e Importaciones por País

## Problema
¿Cómo ha evolucionado la composición de los socios comerciales de Chile
(principales países de destino de exportaciones y origen de importaciones)
en los últimos años? ¿Existen patrones de concentración, dependencia de
pocos mercados, o cambios relevantes que cuenten una historia?

*(Esto se afina una vez exploremos los datos — es la hipótesis de partida,
no la conclusión.)*

## Datos
- **Fuente**: Banco Central de Chile, Base de Datos Estadísticos (BDE) /
  Boletín Estadístico, Capítulo 4.6 "Comercio Exterior"
- **Series usadas**:
  - Exportaciones por país (`exportaciones_por_pais.csv`, serie BH511)
  - Importaciones por país (`importaciones_por_pais.csv`, serie BH512)
- **Cobertura**: [completar tras descarga — rango de fechas real]
- **Método de acceso**: descarga directa en CSV (sin API, sin autenticación)
- **Fecha de descarga**: [2026-07-27]
- **Licencia / uso**: datos públicos del Banco Central de Chile, de libre
  acceso y reutilización

## Proceso
1. Carga y exploración inicial (estructura, tipos de datos, dimensiones)
2. Limpieza (nulos, formatos de fecha, nombres de columnas, duplicados)
3. Análisis exploratorio (distribuciones, tendencias temporales, outliers)
4. Storytelling visual (¿qué historia cuentan los datos?)

## Resultados
*(Se completa al finalizar el análisis — hallazgos clave, 2-4 insights
con su visualización correspondiente)*

## Aprendizajes
*(Se completa al finalizar — qué decisiones técnicas se tomaron y por qué,
qué se haría distinto la próxima vez)*

## Cómo reproducir
1. `pip install -r requirements.txt`
2. Abrir los notebooks en la carpeta `notebooks/`

## Estructura del proyecto
01-eda/
├── data/
│   ├── raw/          # datos originales, sin modificar
│   └── processed/    # datos limpios, listos para análisis
├── notebooks/         # notebooks de exploración y análisis
├── src/                # funciones reutilizables (limpieza, gráficos)
├── requirements.txt
└── README.md