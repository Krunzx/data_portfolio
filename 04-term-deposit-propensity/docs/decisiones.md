# Bitácora de decisiones técnicas

Registro de cada decisión con su justificación, pensado como guion para entrevistas.

| # | Decisión | Alternativas | Por qué |
|---|---|---|---|
| D1 | Dataset `bank-additional-full` (41.188 filas) | `bank-full` | Incluye variables macroeconómicas y orden cronológico, lo que permite un split temporal |
| D2 | Excluir `duration` del modelo | Incluirla | Solo se conoce después de la llamada, así que es leakage. No estaría disponible al decidir a quién contactar |
| D3 | Split temporal (train/valid/test por orden cronológico) | Split aleatorio estratificado | Imita el uso real: entrenar con el pasado y predecir el futuro |
| D4 | Métricas: PR-AUC, lift, ganancia acumulada y ROC-AUC | Accuracy | Con ~11% de positivos la accuracy engaña |
| D5 | Baseline: contacto aleatorio y una heurística simple | Ninguno | Da el punto de comparación para medir el valor del modelo |
| D6 | Plantear el problema como ranking (ordenar por score) | Clasificar con corte fijo en 0,5 | La decisión real es a quién llamar primero dado un presupuesto. El umbral depende del presupuesto y de la razón costo/ingreso |
| D7 | PR-AUC como métrica técnica principal, ROC-AUC como complemento | Solo ROC-AUC | Con ~11% de positivos el ROC-AUC se ve optimista porque abundan los negativos. El PR-AUC refleja mejor el desempeño sobre la clase de interés |
| D8 | Simulación económica con costo e ingreso ilustrativos y análisis de sensibilidad | Cifras "reales" inventadas | El dataset no trae costos ni ingresos. Declarar los supuestos y variarlos es más honesto y más fácil de defender |
| D9 | Regla de contacto: llamar si `p × ingreso > costo` | Corte arbitrario | Es la regla óptima bajo ese modelo de costos, pero exige probabilidades calibradas. Por eso la calibración es una métrica |

## Preguntas típicas de entrevista (etapa 1)

¿Por qué no usar accuracy? Un modelo que predice "no" siempre acierta ~89% y no aporta valor de negocio.

¿Por qué excluir `duration`? Se conoce después de la llamada y no está disponible cuando se decide a quién llamar. Incluirla infla el AUC, y el modelo no serviría en producción.

¿Qué significa un lift de 3 en el primer decil? Que ese 10% de clientes convierte 3 veces más que el promedio de la base.

¿Por qué importa la calibración? La regla `p × ingreso > costo` necesita una probabilidad fiable, no solo un buen orden.
