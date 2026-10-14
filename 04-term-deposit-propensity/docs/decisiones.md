# Bitácora de decisiones técnicas

Registro de cada decisión con su justificación, pensado como guion para entrevistas.

## Decisiones tomadas

| # | Decisión | Alternativas | Por qué |
|---|---|---|---|
| D1 | Dataset `bank-additional-full` (41.188 filas) | `bank-full` | Incluye variables macroeconómicas y orden cronológico, lo que permite un split temporal |
| D2 | Excluir `duration` del modelo | Incluirla | Solo se conoce después de la llamada, así que es leakage. No estaría disponible al decidir a quién contactar |
| D3 | Split temporal (train/valid/test por orden cronológico). Las proporciones y la forma de manejar la deriva están por definir (ver A1) | Split aleatorio estratificado | Imita el uso real: entrenar con el pasado y predecir el futuro |
| D4 | Métricas: PR-AUC, lift, ganancia acumulada y ROC-AUC | Accuracy | Con ~11% de positivos la accuracy engaña |
| D5 | Baseline: contacto aleatorio y una heurística simple | Ninguno | Da el punto de comparación para medir el valor del modelo |
| D6 | Plantear el problema como ranking (ordenar por score) | Clasificar con corte fijo en 0,5 | La decisión real es a quién llamar primero dado un presupuesto. El umbral depende del presupuesto y de la razón costo/ingreso |
| D7 | PR-AUC como métrica técnica principal, ROC-AUC como complemento. Sujeta a revisión por la deriva temporal (ver A2) | Solo ROC-AUC | Con ~11% de positivos el ROC-AUC se ve optimista porque abundan los negativos. El PR-AUC refleja mejor el desempeño sobre la clase de interés |
| D8 | Simulación económica con costo e ingreso ilustrativos y análisis de sensibilidad | Cifras "reales" inventadas | El dataset no trae costos ni ingresos. Declarar los supuestos y variarlos es más honesto y más fácil de defender |
| D9 | Regla de contacto: llamar si `p × ingreso > costo` | Corte arbitrario | Es la regla óptima bajo ese modelo de costos, pero exige probabilidades calibradas. Por eso la calibración es una métrica |
| D10 | Cargar los datos a BigQuery desde Python, agregando una columna `row_id` | `bq load` directo desde el CSV | BigQuery no garantiza el orden de las filas y el split temporal depende del orden cronológico original |
| D11 | Guardar las consultas del EDA en un archivo `.sql` versionado, con un marcador en lugar del proyecto y el dataset, y ejecutarlas desde el notebook | Pegarlas a mano en la consola o escribirlas dentro del notebook | Deja el análisis reproducible y permite mantener el proyecto y el dataset fuera del repositorio, en un archivo de credenciales ignorado por Git |
| D12 | Eliminar los 12 duplicados exactos (0,03%) antes de separar los datos, conservando la primera aparición | Dejarlos | No aportan información y, si quedan, una misma fila puede caer en train y en test |
| D13 | Mantener `unknown` como categoría propia | Imputar con la moda o eliminar las filas | `default_credit` tiene 20,9% de `unknown`, así que eliminar perdería una quinta parte de los datos. Además sus tasas difieren de las demás categorías (por ejemplo `education` desconocida convierte 14,5% contra 11,3% global) |
| D14 | Construir la bandera de contacto previo con `previous > 0`, no con `pdays = 999`. Usar `pdays` solo como número de días en las 1.515 filas con valor real, con un indicador aparte para el resto | Usar `pdays = 999` como "nunca contactado" | En 4.110 filas `poutcome = failure` tiene `pdays = 999` y `previous > 0`: hubo contacto previo sin fecha registrada. El 999 mezcla "nunca contactado" (35.563 filas, `previous = 0`) con "contactado sin fecha". `previous` y `poutcome` son consistentes entre sí |

## Decisiones abiertas

La numeración de las abiertas no se reordena: A4 (`pdays` y `poutcome`) se cerró como D14.

| # | Tema | Situación | Opciones |
|---|---|---|---|
| A1 | Esquema del split temporal | La conversión crece de 2,8% a 45,9% entre el primer y el último décimo de los datos. Con un corte 60/20/20, train tendría cerca de 4,8% de positivos y test cerca de 30,8% | Mantener el split temporal y documentar la deriva; ventana expansiva (`TimeSeriesSplit`); otras proporciones. Un split aleatorio se usaría solo como contraste |
| A2 | Métricas principales | PR-AUC depende de la tasa base, que cambia entre períodos, y las probabilidades estimadas en train no estarían calibradas en test | ROC-AUC, lift y ganancia como métricas principales, PR-AUC junto a la tasa base de cada período y recalibración con el conjunto de validación |
| A3 | Variable `campaign` | Según la documentación del dataset incluye el último contacto, y su valor depende de cómo terminó la secuencia de llamadas | Usarla tal cual, restarle 1 o excluirla |
| A5 | Razón ingreso/costo de la simulación | Con razón 10 el umbral de probabilidad (10%) queda muy cerca de la tasa base (11,3%) | Probar también razones más bajas, por ejemplo de 3 a 10 |

## Hallazgos del EDA

Cada pregunta se planteó con una hipótesis escrita antes de ejecutar la consulta. El detalle de las consultas y sus resultados está en `sql/02_eda_queries.sql`.

| # | Hipótesis | Resultado | Veredicto |
|---|---|---|---|
| 1 | Hay filas duplicadas | 12 de 41.188 (0,03%) | Confirmada |
| 2 | `default_credit` concentra más valores `unknown` | 20,9%, seguida de `education` con 4,2% | Confirmada |
| 3 | Tasa de conversión global | 11,27% (4.640 de 41.188) | Referencia |
| 4 | `housemaid`, `student` y `unemployed` convierten más que el resto | 17,8% contra 10,8%. Lo explica `student` (31,4%); `housemaid` queda en 10,0% | Parcial |
| 5A | Educación baja convierte más | Las categorías `basic` están entre 7,8% y 10,3%; `university.degree` 13,7% | Refutada |
| 5B | `married` convierte más que `single` y `divorced` | `single` 14,0%, `divorced` 10,3%, `married` 10,2% | Refutada |
| 6 | A mayor edad, menor conversión | Forma de U: 24,0% bajo 25 años, 8,65% entre 35 y 54 años, 47,2% sobre 65 años (663 casos). Los `retired` convierten 25,2% | Refutada |
| 7 | Tener crédito (`housing` o `loan`) reduce la conversión | Todas las combinaciones entre 10,7% y 11,7% | Refutada, con efecto menor a 1 punto |
| 8 | Los meses con más llamados convierten más | Mayo, con 13.769 llamadas, convierte 6,4%. Marzo, septiembre, octubre y diciembre convierten entre 44% y 51% con 182 a 718 llamadas | Refutada. El período explica la mayor parte: mayo convierte 2,8% en el primer décimo, 7,7% en el octavo y 57,6% en el último. Septiembre y diciembre solo existen en el último décimo (P14) |
| 9 | Celular convierte más que teléfono fijo | 14,7% contra 5,2% en total. Dentro de cada décimo el celular gana entre 1,3 y 2,8 veces, salvo el sexto (teléfono fijo 23,5%, n=306). Los décimos 1 a 3 son solo teléfono fijo (P15) | Confirmada con matiz: efecto propio, pero menor que el global |
| 10 | La conversión decae después del tercer intento | 13,0% en el primer intento, 10,8% en el tercero y 4,6% con siete o más. La baja es gradual desde el primero | Confirmada en dirección |
| 11 | Haber contratado en una campaña anterior aumenta la conversión | `success` 65,1% contra 8,8% sin contacto previo | Confirmada |
| 12A | La conversión no es estable en el tiempo | De 2,8% a 45,9% entre el primer y el último décimo | Confirmada |
| 12B | Las variables macro están muy correlacionadas entre sí | `emp_var_rate` con `euribor3m` 0,97; con `nr_employed` 0,91; `euribor3m` con `nr_employed` 0,95 | Confirmada |
| 13 | A menor Euribor, menor conversión | Euribor bajo 1: 45,7%. Entre 4 y 5: 4,8% | Refutada. Coincide con el período |

Siete hipótesis se sostienen total o parcialmente y seis se refutan. Las refutadas son resultados útiles: orientan qué variables conservar y cómo interpretarlas.

### Lectura de los hallazgos

- La conversión sube a lo largo del período junto con la caída del Euribor (de 4,9 a 0,8 en promedio entre el primer y el último décimo). Esto condiciona el split, las métricas y la calibración (A1 y A2).
- El mes, el canal y el nivel del Euribor están asociados al período en que se llamó. Al cruzar con el período, el efecto del mes casi desaparece (el mismo mes convierte de 2,8% a 57,6% según el período) y el del canal se reduce, aunque se mantiene. El Euribor no se cruzó: su efecto aparente sigue sin poder separarse del tiempo. Por eso el mes es una variable riesgosa para el modelo, porque puede funcionar como sustituto del período.
- La edad y la ocupación están entrelazadas (estudiantes jóvenes, jubilados mayores), lo que explica la forma de U de la conversión por edad. Por eso conviene analizarlas juntas.
- El historial con el banco es la señal más fuerte del EDA. La aparente inconsistencia entre `poutcome` y `pdays` se aclaró con P16: `pdays = 999` mezcla "nunca contactado" con "contactado sin fecha", y la bandera correcta es `previous > 0` (D14).
- Las variables `housing` y `loan` son `unknown` en las mismas 990 filas, así que corresponden a un solo evento de dato faltante.
- Las variables macro se mueven casi en bloque. Se reportarán resultados con y sin ellas y sus coeficientes no se interpretarán por separado.

## Preguntas típicas de entrevista

¿Por qué no usar accuracy? Un modelo que predice "no" siempre acierta ~89% y no aporta valor de negocio.

¿Por qué excluir `duration`? Se conoce después de la llamada y no está disponible cuando se decide a quién llamar. Incluirla infla el AUC, y el modelo no serviría en producción.

¿Qué significa un lift de 3 en el primer decil? Que ese 10% de clientes convierte 3 veces más que el promedio de la base.

¿Por qué importa la calibración? La regla `p × ingreso > costo` necesita una probabilidad fiable, no solo un buen orden.

¿Qué encontraste en el EDA que cambió tu plan? Que la conversión sube de 2,8% a 45,9% a lo largo del período. Eso obliga a reportar métricas que no dependan de la tasa base, a recalibrar y a explicar que el test corresponde a un contexto distinto del de entrenamiento.

¿Por qué no basta un split aleatorio? Mezcla períodos con contextos distintos y entrega un resultado optimista que no se sostendría al usar el modelo con clientes futuros.

¿Qué hipótesis tuya se refutó? Por ejemplo, esperaba que la conversión bajara con la edad y resultó ser una U, con jubilados y menores de 25 años por encima del promedio. Lo atribuyo en parte a que edad y ocupación están entrelazadas.

¿Por qué no afirmar que el canal o el mes causan la conversión? Porque ambos coinciden con el período en que se llamó, y el EDA solo muestra asociaciones. Al cruzarlos con el período, el mes casi pierde su efecto (mayo va de 2,8% a 57,6%) y el celular conserva una ventaja de 1,3 a 2,8 veces, menor que la brecha global de 14,7% contra 5,2%. Incluso así son asociaciones, no causas.

¿Qué revisaste en las variables de historial? Que `pdays = 999` no significa siempre "nunca contactado": 4.110 clientes con `poutcome = failure` tienen ese valor pero sí fueron contactados antes. Armé la bandera con `previous > 0` para no mezclar ambos casos.
