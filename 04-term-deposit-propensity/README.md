# Propensión de contratación de depósito a plazo

Modelo predictivo para priorizar a qué clientes contactar en una campaña de telemarketing bancario, usando el dataset [Bank Marketing (UCI)](https://archive.ics.uci.edu/dataset/222/bank+marketing).

> Estado: en desarrollo. La etapa 1 (planteamiento) está completa y los resultados se agregarán en cada etapa.

Stack: Python (pandas, scikit-learn, LightGBM), Google BigQuery y BigQuery ML, SQL, y Power BI (opcional).

---

## 1. Problema de negocio

Un banco llama por teléfono a sus clientes para ofrecerles un depósito a plazo. Cada llamada cuesta dinero y solo una minoría acepta: en este dataset, cerca del 11%.

La pregunta es qué clientes tienen mayor probabilidad de contratar, para decidir a quién contactar cuando el presupuesto es limitado.

Un modelo asigna a cada cliente un score (la probabilidad de contratar) y se llama primero a quienes lo tienen más alto. El modelo ordena la lista de contacto; no necesita acertar caso a caso quién va a contratar.

La decisión que apoya es esta: si el presupuesto alcanza para llamar al X% de la base, ¿a quiénes llamar para capturar la mayor cantidad de contrataciones?

## 2. Definición del problema predictivo

| Elemento | Definición |
|---|---|
| Unidad de análisis | Un contacto (cliente en una llamada de campaña) |
| Variable objetivo | `y` = 1 si el cliente contrata el depósito a plazo, 0 si no |
| Momento de decisión | Antes de llamar al cliente |
| Variables permitidas | Solo las conocidas antes de la llamada: demografía, historial financiero, contactos previos y contexto macroeconómico |
| Variable excluida | `duration` (duración de la llamada). Solo se conoce después de contactar, así que usarla sería *data leakage* |

## 3. Métricas de éxito

Con una clase minoritaria de ~11%, la accuracy engaña: un modelo que dijera "nadie contrata" acertaría ~89%. Por eso se usan dos grupos de métricas.

Métricas técnicas, que miden la calidad del ranking:

- PR-AUC (área bajo la curva precisión-recall), la métrica principal, porque es sensible a la clase minoritaria.
- ROC-AUC, como complemento y para comparar con otros trabajos sobre este dataset.
- Calibración (curva de calibración y Brier score), para que el score pueda leerse como probabilidad.

Métricas de negocio, que miden la utilidad de la campaña:

- Curva de ganancia acumulada: el % de contrataciones capturadas al contactar al X% con mayor score.
- Lift: cuántas veces supera la tasa de conversión del segmento contactado a la de contactar al azar.
- Precisión@K: la tasa de conversión dentro del top K% de clientes.
- Resultado económico simulado: el beneficio neto de la campaña bajo distintos supuestos de costo e ingreso (sección 4).

La referencia de comparación es contactar al azar. En ese caso, contactar al X% de la base captura en promedio el X% de las contrataciones, que es la diagonal de la curva de ganancia. Un modelo útil tiene que quedar claramente por encima de ella.

## 4. Modelo económico simplificado

Para traducir el score a dinero se usa una simulación con supuestos explícitos e ilustrativos. No provienen del dataset ni de un banco real.

| Parámetro | Valor de ejemplo | Comentario |
|---|---|---|
| Costo por contacto | 1 unidad | Se normaliza; solo importa la razón con el ingreso |
| Ingreso neto por contratación | 10 a 20 unidades | Se prueba un rango (análisis de sensibilidad) |

Con esto se calcula el beneficio neto para cada porcentaje de base contactada y se busca el punto de corte que lo maximiza. Se contacta a un cliente mientras `probabilidad × ingreso > costo`. Los resultados se presentan como función de la razón ingreso/costo, para no afirmar cifras que no se pueden respaldar.

## 5. Plan del proyecto

| Etapa | Contenido | Estado |
|---|---|---|
| 0 | Setup: repo, entorno Python 3.12, GCP/BigQuery | Completada |
| 1 | Problema de negocio y métricas | Completada |
| 2 | Carga a BigQuery y análisis exploratorio | Pendiente |
| 3 | Preparación de datos, control de leakage, split temporal | Pendiente |
| 4 | Baseline y modelos (regresión logística, árboles, gradient boosting) | Pendiente |
| 5 | Evaluación | Pendiente |
| 6 | Traducción a negocio | Pendiente |
| 7 | BigQuery ML (opcional) | Pendiente |
| 8 | Dashboard Power BI (opcional) | Pendiente |

## 6. Estructura del repositorio

```
├── data/               # raw (no versionado) y processed
├── sql/                # DDL, consultas EDA y BigQuery ML
├── notebooks/          # EDA, features, modelado, evaluación
├── src/                # código reutilizable (datos, features, entrenamiento, evaluación)
├── reports/figures/    # gráficos
├── dashboard/          # Power BI (opcional)
└── docs/decisiones.md  # bitácora de decisiones técnicas
```

## 7. Cómo reproducir

```bash
python -m venv .venv          # requiere Python 3.12
source .venv/Scripts/activate # Windows (Git Bash); en Linux/Mac: source .venv/bin/activate
pip install -r requirements.txt
gcloud auth application-default login
```

Los datos se descargan desde UCI y se cargan a BigQuery (instrucciones en la etapa 2).

---

# English summary

Term Deposit Propensity Model: a predictive model to prioritize which bank customers to call in a telemarketing campaign, using the UCI Bank Marketing dataset.

- Business question: which customers are most likely to subscribe to a term deposit, so a limited call budget goes to the right people?
- Approach: each customer gets a score and the contact list is ranked by it. The model is judged on how well it orders customers, not on a yes/no classification.
- Data leakage control: the `duration` variable (call length) is excluded because it is only known after the call.
- Evaluation: PR-AUC, ROC-AUC, calibration, cumulative gains and lift, compared against a random-contact baseline with a temporal train/test split.
- Business translation: "contacting the top X% by score captures Y% of subscriptions", plus a simulated net-benefit analysis under explicit, illustrative cost and revenue assumptions.
- Stack: Python, scikit-learn, LightGBM, BigQuery / BigQuery ML, SQL, Power BI (optional).

Status: work in progress.
