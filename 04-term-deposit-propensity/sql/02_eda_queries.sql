-- =====================================================================
-- EDA: Propension de contratacion de deposito a plazo
-- Reemplazar TU_PROYECTO.TU_DATASET al ejecutar en BigQuery
-- Formato por consulta: pregunta, hipotesis, consulta, resultado (a completar)
-- =====================================================================


-- ---------------------------------------------------------------------
-- BLOQUE 0: CALIDAD Y ESTRUCTURA
-- ---------------------------------------------------------------------

-- P1a. Hipotesis: existen filas duplicadas.
-- duplicados = filas_totales - filas_distintas (row_id se excluye porque es unico)
SELECT
    COUNT(*) AS filas_totales,
    (
        SELECT
            COUNT(*)
        FROM (
            SELECT 
                DISTINCT * EXCEPT(row_id)
            FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
        )
    ) AS filas_distintas
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`;
-- Resultado: 
-- Filas totales: 41188
-- Filas distintas: 41176
-- Duplicados: 12 (0.03% del total de filas, se puede eliminar)

-- P1b. Nulos reales (repetir COUNTIF para el resto de columnas)
SELECT
    COUNTIF(age IS NULL) AS age_nulos,
    COUNTIF(job IS NULL) AS job_nulos,
    COUNTIF(marital IS NULL) AS marital_nulos,
    COUNTIF(education IS NULL) AS education_nulos,
    COUNTIF(default_credit IS NULL) AS default_credit_nulos,
    COUNTIF(housing IS NULL) AS housing_nulos,
    COUNTIF(loan IS NULL) AS loan_nulos,
    COUNTIF(contact IS NULL) AS contact_nulos,
    COUNTIF(month IS NULL) AS month_nulos,
    COUNTIF(day_of_week IS NULL) AS day_of_week_nulos,
    COUNTIF(duration IS NULL) AS duration_nulos,
    COUNTIF(campaign IS NULL) AS campaign_nulos,
    COUNTIF(pdays IS NULL) AS pdays_nulos,
    COUNTIF(previous IS NULL) AS previous_nulos,
    COUNTIF(poutcome IS NULL) AS poutcome_nulos,
    COUNTIF(emp_var_rate IS NULL) AS emp_var_rate_nulos,
    COUNTIF(cons_price_idx IS NULL) AS cons_price_idx_nulos,
    COUNTIF(cons_conf_idx IS NULL) AS cons_conf_idx_nulos,
    COUNTIF(euribor3m IS NULL) AS euribor3m_nulos,
    COUNTIF(nr_employed IS NULL) AS nr_employed_nulos,
    COUNTIF(y IS NULL) AS y_nulos
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`;
-- Resultado:
-- Ninguna columna tiene valores nulos.

-- P1c. Rangos: buscar valroes anómalos.
SELECT
    MIN(age) AS edad_min, MAX(age) AS edad_max,
    MIN(campaign) AS campaign_min, MAX(campaign) AS campaign_max,
    MIN(euribor3m) AS euribor_min, MAX(euribor3m) AS euribor_max
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`;
-- Resultado:
/* [{
    "edad_min": "17",
    "edad_max": "98",
    "campaign_min": "1",
    "campaign_max": "56",
    "euribor_min": "0.634",
    "euribor_max": "5.045"
}]
*/

-- P2. Hipótesis: default_credit es la variable con más valores `unknown`.
SELECT
    'job' AS variable,
    ROUND(COUNTIF(job = 'unknown') / COUNT(*), 4) AS pct_unknown
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
UNION ALL 
SELECT 
    'marital', 
    ROUND(COUNTIF(marital = 'unknown') / COUNT(*), 4)
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
UNION ALL 
SELECT 
    'education', 
    ROUND(COUNTIF(education = 'unknown') / COUNT(*), 4)
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
UNION ALL 
SELECT 
    'default_credit', 
    ROUND(COUNTIF(default_credit = 'unknown') / COUNT(*), 4)
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
UNION ALL 
SELECT 
    'housing', 
    ROUND(COUNTIF(housing = 'unknown') / COUNT(*), 4)
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
UNION ALL 
SELECT 
    'loan', 
    ROUND(COUNTIF(loan = 'unknown') / COUNT(*), 4)
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
ORDER BY pct_unknown DESC;
-- Resultado:
/*
[
    {"variable": "default_credit", "pct_unknown": "0.2087"}, 
    {"variable": "education", "pct_unknown": "0.042"}, 
    {"variable": "housing", "pct_unknown": "0.024"}, 
    {"variable": "loan", "pct_unknown": "0.024"}, 
    {"variable": "job", "pct_unknown": "0.008"}, 
    {"variable": "marital", "pct_unknown": "0.0019"}
]
*/

-- P3. Referencia: tasa de conversión global (ya verificada: 11,27%)
SELECT
    COUNT(*) AS total_contactos,
    COUNTIF(y='yes') AS total_contrataciones,
    ROUND(COUNTIF(y='yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`;
-- Resultado:
/*
[{
    "total_contactos": "41188",
    "total_contrataciones": "4640",
    "tasa_conversion": "0.1127"
}]
*/

-- ---------------------------------------------------------------------
-- BLOQUE 1: PERFIL DEL CLIENTE
-- ---------------------------------------------------------------------
-- P4a. Hipotesis: housemaid, student y unemployed convierten mas que el resto.
SELECT
    IF(job IN ('housemaid', 'student', 'unemployed'), 'grupo_H4', 'resto') AS grupo,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY grupo;
-- Resultado:
/*
[
    {"grupo": "grupo_H4", "n": "2949", "tasa_conversion": "0.178"}, 
    {"grupo": "resto", "n": "38239", "tasa_conversion": "0.1076"}
]
*/

-- P4b. Cada ocupacion por separado
SELECT 
    job, 
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY job
ORDER BY tasa_conversion DESC;
-- Resultado:
/*
[{"job": "student","n": "875","tasa_conversion": "0.3143"}, 
{"job": "retired","n": "1720","tasa_conversion": "0.2523"}, 
{"job": "unemployed","n": "1014","tasa_conversion": "0.142"}, 
{"job": "admin.","n": "10422","tasa_conversion": "0.1297"}, 
{"job": "management","n": "2924","tasa_conversion": "0.1122"}, 
{"job": "unknown","n": "330","tasa_conversion": "0.1121"}, 
{"job": "technician","n": "6743","tasa_conversion": "0.1083"}, 
{"job": "self-employed","n": "1421","tasa_conversion": "0.1049"}, 
{"job": "housemaid","n": "1060","tasa_conversion": "0.1"}, 
{"job": "entrepreneur","n": "1456","tasa_conversion": "0.0852"}, 
{"job": "services","n": "3969","tasa_conversion": "0.0814"}, 
{"job": "blue-collar","n": "9254","tasa_conversion": "0.0689"}]
*/

-- P5a. Hipotesis: educacion baja convierte mas que educacion media y alta.
SELECT 
    education, 
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY education
ORDER BY tasa_conversion DESC;
-- Resultado:
/*
[{"education": "illiterate","n": "18","tasa_conversion": "0.2222"}, 
{"education": "unknown","n": "1731","tasa_conversion": "0.145"}, 
{"education": "university.degree","n": "12168","tasa_conversion": "0.1372"}, 
{"education": "professional.course","n": "5243","tasa_conversion": "0.1135"}, 
{"education": "high.school","n": "9515","tasa_conversion": "0.1084"}, 
{"education": "basic.4y","n": "4176","tasa_conversion": "0.1025"}, 
{"education": "basic.6y","n": "2292","tasa_conversion": "0.082"}, 
{"education": "basic.9y","n": "6045","tasa_conversion": "0.0782"}]
*/

-- P5b. Hipotesis: married convierte más que single y divorced.
SELECT
    marital,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY marital
ORDER BY tasa_conversion DESC;
-- Resultado:
/*
[{"marital": "unknown","n": "80","tasa_conversion": "0.15"}, 
{"marital": "single","n": "11568","tasa_conversion": "0.14"}, 
{"marital": "divorced","n": "4612","tasa_conversion": "0.1032"}, 
{"marital": "married","n": "24928","tasa_conversion": "0.1016"}]
*/

-- P5c. Cruce job x education (solo celdas con al menos 100 casos)
SELECT
    job,
    education,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY job, education
HAVING COUNT(*) >= 100
ORDER BY tasa_conversion DESC;
-- Resultado:
/*
[{"job": "student","education": "unknown","n": "167","tasa_conversion": "0.3533"}, 
{"job": "student","education": "high.school","n": "357","tasa_conversion": "0.3193"}, 
{"job": "retired","education": "basic.4y","n": "597","tasa_conversion": "0.3099"}, 
{"job": "retired","education": "professional.course","n": "241","tasa_conversion": "0.2365"}, 
{"job": "retired","education": "university.degree","n": "285","tasa_conversion": "0.2316"}, 
{"job": "retired","education": "high.school","n": "276","tasa_conversion": "0.2246"}, 
{"job": "student","education": "university.degree","n": "170","tasa_conversion": "0.2059"}, 
{"job": "management","education": "unknown","n": "123","tasa_conversion": "0.1626"}, 
{"job": "admin.","education": "unknown","n": "249","tasa_conversion": "0.1526"}, 
{"job": "services","education": "university.degree","n": "173","tasa_conversion": "0.1503"}, 
{"job": "unemployed","education": "university.degree","n": "262","tasa_conversion": "0.1489"}, 
{"job": "admin.","education": "university.degree","n": "5753","tasa_conversion": "0.1431"}, 
{"job": "unemployed","education": "basic.4y","n": "112","tasa_conversion": "0.1429"}, 
{"job": "unemployed","education": "professional.course","n": "142","tasa_conversion": "0.1408"}, 
{"job": "unemployed","education": "basic.9y","n": "186","tasa_conversion": "0.1398"}, 
{"job": "admin.","education": "professional.course","n": "363","tasa_conversion": "0.135"}, 
{"job": "unemployed","education": "high.school","n": "259","tasa_conversion": "0.1313"}, 
{"job": "retired","education": "basic.9y","n": "145","tasa_conversion": "0.131"}, 
{"job": "unknown","education": "unknown","n": "131","tasa_conversion": "0.1298"}, 
{"job": "services","education": "unknown","n": "150","tasa_conversion": "0.1267"}, 
{"job": "self-employed","education": "university.degree","n": "765","tasa_conversion": "0.1255"}, 
{"job": "management","education": "university.degree","n": "2063","tasa_conversion": "0.1246"}, 
{"job": "technician","education": "university.degree","n": "1809","tasa_conversion": "0.1244"}, 
{"job": "housemaid","education": "university.degree","n": "139","tasa_conversion": "0.1223"}, 
{"job": "self-employed","education": "professional.course","n": "168","tasa_conversion": "0.119"}, 
{"job": "technician","education": "unknown","n": "212","tasa_conversion": "0.1179"}, 
{"job": "admin.","education": "high.school","n": "3329","tasa_conversion": "0.1147"}, 
{"job": "entrepreneur","education": "university.degree","n": "610","tasa_conversion": "0.1082"}, 
{"job": "housemaid","education": "basic.4y","n": "474","tasa_conversion": "0.1076"}, 
{"job": "blue-collar","education": "high.school","n": "878","tasa_conversion": "0.1071"}, 
{"job": "technician","education": "professional.course","n": "3320","tasa_conversion": "0.1033"}, 
{"job": "technician","education": "high.school","n": "873","tasa_conversion": "0.0974"}, 
{"job": "technician","education": "basic.9y","n": "384","tasa_conversion": "0.0964"}, 
{"job": "blue-collar","education": "professional.course","n": "453","tasa_conversion": "0.0905"}, 
{"job": "services","education": "basic.6y","n": "226","tasa_conversion": "0.0885"}, 
{"job": "services","education": "professional.course","n": "218","tasa_conversion": "0.0872"}, 
{"job": "admin.","education": "basic.9y","n": "499","tasa_conversion": "0.0842"}, 
{"job": "self-employed","education": "basic.9y","n": "220","tasa_conversion": "0.0818"}, 
{"job": "housemaid","education": "high.school","n": "174","tasa_conversion": "0.0805"}, 
{"job": "services","education": "high.school","n": "2682","tasa_conversion": "0.0757"}, 
{"job": "blue-collar","education": "basic.6y","n": "1426","tasa_conversion": "0.075"}, 
{"job": "services","education": "basic.9y","n": "388","tasa_conversion": "0.0747"}, 
{"job": "entrepreneur","education": "high.school","n": "234","tasa_conversion": "0.0684"}, 
{"job": "self-employed","education": "high.school","n": "118","tasa_conversion": "0.0678"}, 
{"job": "entrepreneur","education": "professional.course","n": "135","tasa_conversion": "0.0667"}, 
{"job": "management","education": "basic.9y","n": "166","tasa_conversion": "0.0663"}, 
{"job": "blue-collar","education": "basic.9y","n": "3623","tasa_conversion": "0.0662"}, 
{"job": "entrepreneur","education": "basic.9y","n": "210","tasa_conversion": "0.0571"}, 
{"job": "management","education": "high.school","n": "298","tasa_conversion": "0.057"}, 
{"job": "blue-collar","education": "basic.4y","n": "2318","tasa_conversion": "0.0531"}, 
{"job": "services","education": "basic.4y","n": "132","tasa_conversion": "0.053"}, 
{"job": "admin.","education": "basic.6y","n": "151","tasa_conversion": "0.053"}, 
{"job": "blue-collar","education": "unknown","n": "454","tasa_conversion": "0.0529"}, 
{"job": "entrepreneur","education": "basic.4y","n": "137","tasa_conversion": "0.0511"}, 
{"job": "management","education": "basic.4y","n": "100","tasa_conversion": "0.05"}]
*/

-- P6. Hipótesis: a mayor edad, menor conversión (inlcuidos los retired)
SELECT
    CASE
        WHEN age < 25 THEN '1_<25'
        WHEN age <35 THEN '2_25-34'
        WHEN age < 45 THEN '3_35-44'
        WHEN age < 55 THEN '4_45-54'
        WHEN age < 65 THEN '5_55-64'
        ELSE '6_65+'
    END AS tramo_edad,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY tramo_edad
ORDER BY tramo_edad;
-- Resultado:
/*
[{"tramo_edad": "1_\u003c25","n": "1068","tasa_conversion": "0.2397"}, 
{"tramo_edad": "2_25-34","n": "13686","tasa_conversion": "0.1217"}, 
{"tramo_edad": "3_35-44","n": "13500","tasa_conversion": "0.0865"}, 
{"tramo_edad": "4_45-54","n": "8704","tasa_conversion": "0.0865"}, 
{"tramo_edad": "5_55-64","n": "3567","tasa_conversion": "0.1357"}, 
{"tramo_edad": "6_65+","n": "663","tasa_conversion": "0.4721"}]
*/

-- P6b. Edad x estado civil: separa el efecto de la edad del efecto de tener pareja
SELECT
    CASE
        WHEN age < 35 THEN '1_<35'
        WHEN age < 50 THEN '2_35-49'
        ELSE '3_50+'
        END AS tramo_edad,
    marital,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY tramo_edad, marital
HAVING COUNT(*) >= 100
ORDER BY tramo_edad, marital;
-- Resultado:
/*
[{"tramo_edad": "1_\u003c35","marital": "divorced","n": "780","tasa_conversion": "0.0821"}, 
{"tramo_edad": "1_\u003c35","marital": "married","n": "6341","tasa_conversion": "0.0982"}, 
{"tramo_edad": "1_\u003c35","marital": "single","n": "7596","tasa_conversion": "0.1618"}, 
{"tramo_edad": "2_35-49","marital": "divorced","n": "2381","tasa_conversion": "0.0848"}, 
{"tramo_edad": "2_35-49","marital": "married","n": "12467","tasa_conversion": "0.0808"}, 
{"tramo_edad": "2_35-49","marital": "single","n": "3510","tasa_conversion": "0.0957"}, 
{"tramo_edad": "3_50+","marital": "divorced","n": "1451","tasa_conversion": "0.1447"}, 
{"tramo_edad": "3_50+","marital": "married","n": "6120","tasa_conversion": "0.1474"}, 
{"tramo_edad": "3_50+","marital": "single","n": "462","tasa_conversion": "0.119"}]
*/

-- P7. Hipótesis: con housing = yes o loan = yes, menor conversión.
SELECT
    housing,
    loan,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY housing, loan
ORDER BY housing, loan;
-- Resultado:
/*
[{"housing": "no","loan": "no","n": "16065","tasa_conversion": "0.1091"}, 
{"housing": "no","loan": "yes","n": "2557","tasa_conversion": "0.1072"}, 
{"housing": "unknown","loan": "unknown","n": "990","tasa_conversion": "0.1081"}, 
{"housing": "yes","loan": "no","n": "17885","tasa_conversion": "0.1173"}, 
{"housing": "yes","loan": "yes","n": "3691","tasa_conversion": "0.1108"}]
*/

-- ---------------------------------------------------------------------
-- BLOQUE 2: DINAMICA DE LA CAMPAÑA
-- ---------------------------------------------------------------------
-- P8a. Hipótesis: los meses con más llamados tienen mayor conversión.
-- Ordenado por volumen para comparar n con la tasa.
SELECT
    month,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY month
ORDER BY n DESC;
-- Resultado:
/*
[{"month": "may","n": "13769","tasa_conversion": "0.0643"}, 
{"month": "jul","n": "7174","tasa_conversion": "0.0905"}, 
{"month": "aug","n": "6178","tasa_conversion": "0.106"}, 
{"month": "jun","n": "5318","tasa_conversion": "0.1051"}, 
{"month": "nov","n": "4101","tasa_conversion": "0.1014"}, 
{"month": "apr","n": "2632","tasa_conversion": "0.2048"}, 
{"month": "oct","n": "718","tasa_conversion": "0.4387"}, 
{"month": "sep","n": "570","tasa_conversion": "0.4491"}, 
{"month": "mar","n": "546","tasa_conversion": "0.5055"}, 
{"month": "dec","n": "182","tasa_conversion": "0.489"}]
*/

-- P8b. Día de la semana
SELECT
    day_of_week,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY day_of_week
ORDER BY n DESC;
-- Resultado:
/*
[{"day_of_week": "thu","n": "8623","tasa_conversion": "0.1212"}, 
{"day_of_week": "mon","n": "8514","tasa_conversion": "0.0995"}, 
{"day_of_week": "wed","n": "8134","tasa_conversion": "0.1167"}, 
{"day_of_week": "tue","n": "8090","tasa_conversion": "0.1178"}, 
{"day_of_week": "fri","n": "7827","tasa_conversion": "0.1081"}]
*/

-- P9. Hipótesis: celular convierte más que teléfono fijo.
SELECT
    contact,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY contact;
-- Resultado:
/*
[{"contact": "telephone","n": "15044","tasa_conversion": "0.0523"}, 
{"contact": "cellular","n": "26144","tasa_conversion": "0.1474"}]
*/

-- P10. Hipótesis: la conversión decar después del tercer intento.
-- El valor 7 agrupa "7 o más" para evitar grupos pequeños.
SELECT
    LEAST(campaign, 7) AS intento,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY intento
ORDER BY intento;
-- Resultado:
/*
[{"intento": "1","n": "17642","tasa_conversion": "0.1304"}, 
{"intento": "2","n": "10570","tasa_conversion": "0.1146"}, 
{"intento": "3","n": "5341","tasa_conversion": "0.1075"}, 
{"intento": "4","n": "2651","tasa_conversion": "0.0939"}, 
{"intento": "5","n": "1599","tasa_conversion": "0.075"}, 
{"intento": "6","n": "979","tasa_conversion": "0.0766"}, 
{"intento": "7","n": "2406","tasa_conversion": "0.0461"}]
*/

-- ---------------------------------------------------------------------
-- BLOQUE 3: HISTORIAL CON EL BANCO
-- ---------------------------------------------------------------------
-- P11. Hipótesis: con historial de conversión previo (poutcome = success), mayor conversión.
SELECT
    poutcome,
    IF(pdays = 999, 'nunca_contactado', 'contactado_antes') AS historial_pdays,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY poutcome, historial_pdays
ORDER BY poutcome, historial_pdays;
-- Resultado:
/*
[{"poutcome": "failure","historial_pdays": "contactado_antes","n": "142","tasa_conversion": "0.5141"}, 
{"poutcome": "failure","historial_pdays": "nunca_contactado","n": "4110","tasa_conversion": "0.1294"}, 
{"poutcome": "nonexistent","historial_pdays": "nunca_contactado","n": "35563","tasa_conversion": "0.0883"}, 
{"poutcome": "success","historial_pdays": "contactado_antes","n": "1373","tasa_conversion": "0.6511"}]
*/

-- ---------------------------------------------------------------------
-- BLOQUE 4: TIEMPO Y MACRO
-- ---------------------------------------------------------------------
-- P12a. Hipótesis: la conversión no es estable; entre bloque más alto y el
-- más bajo hay más de 3 puntos porcentuales.
-- (NTILE va en una CTE: no se puede agrupar por una función de ventana)
WITH bloques AS (
    SELECT 
        *,
        NTILE(10) OVER (ORDER BY row_id) AS bloque
    FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
)
SELECT
    bloque,
    MIN(row_id) AS desde,
    MAX(row_id) AS hasta,
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion,
    ROUND(AVG(euribor3m), 2) AS euribor_prom,
    ROUND(AVG(emp_var_rate), 2) AS emp_var_prom,
    ROUND(AVG(nr_employed), 0) AS nr_employed_prom,
FROM bloques
GROUP BY bloque
ORDER BY bloque;
-- Resultado:
/*
[{"bloque": "1","desde": "0","hasta": "4118","n": "4119","tasa_conversion": "0.0277","euribor_prom": "4.86","emp_var_prom": "1.1","nr_employed_prom": "5191.0"}, 
{"bloque": "2","desde": "4119","hasta": "8237","n": "4119","tasa_conversion": "0.0352","euribor_prom": "4.86","emp_var_prom": "1.13","nr_employed_prom": "5195.0"}, 
{"bloque": "3","desde": "8238","hasta": "12356","n": "4119","tasa_conversion": "0.0422","euribor_prom": "4.94","emp_var_prom": "1.4","nr_employed_prom": "5228.0"}, 
{"bloque": "4","desde": "12357","hasta": "16475","n": "4119","tasa_conversion": "0.0663","euribor_prom": "4.96","emp_var_prom": "1.4","nr_employed_prom": "5228.0"}, 
{"bloque": "5","desde": "16476","hasta": "20594","n": "4119","tasa_conversion": "0.0624","euribor_prom": "4.96","emp_var_prom": "1.4","nr_employed_prom": "5228.0"}, 
{"bloque": "6","desde": "20595","hasta": "24713","n": "4119","tasa_conversion": "0.0546","euribor_prom": "4.84","emp_var_prom": "1.14","nr_employed_prom": "5222.0"}, 
{"bloque": "7","desde": "24714","hasta": "28832","n": "4119","tasa_conversion": "0.1017","euribor_prom": "3.37","emp_var_prom": "-0.57","nr_employed_prom": "5169.0"}, 
{"bloque": "8","desde": "28833","hasta": "32951","n": "4119","tasa_conversion": "0.1197","euribor_prom": "1.35","emp_var_prom": "-1.8","nr_employed_prom": "5099.0"}, 
{"bloque": "9","desde": "32952","hasta": "37069","n": "4118","tasa_conversion": "0.1574","euribor_prom": "1.26","emp_var_prom": "-2.03","nr_employed_prom": "5094.0"}, 
{"bloque": "10","desde": "37070","hasta": "41187","n": "4118","tasa_conversion": "0.4594","euribor_prom": "0.8","emp_var_prom": "-2.36","nr_employed_prom": "5015.0"}]
*/

-- P12b. Hipótesis: emp_var_rate, euribor3m y nr_employed tienen |r| > 0.8 entre si.
SELECT
    ROUND(CORR(emp_var_rate, euribor3m), 3) AS empvar_euribor,
    ROUND(CORR(emp_var_rate, nr_employed), 3) AS empvar_nremp,
    ROUND(CORR(euribor3m, nr_employed), 3) AS euribor_nremp,
    ROUND(CORR(cons_price_idx, emp_var_rate), 3) AS ipc_empvar,
    ROUND(CORR(cons_conf_idx, euribor3m), 3) AS confianza_euribor
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`;
-- Resultado:
-- [{"empvar_euribor": "0.972","empvar_nremp": "0.907","euribor_nremp": "0.945","ipc_empvar": "0.775","confianza_euribor": "0.278"}]

-- P13. Hipótesis: a menor Euribor, menor conversión.
-- Tramo 0 = Euribor entre 0 y 1, tramo 1 = entre 1 y 2, etc.
SELECT 
    CAST(FLOOR(euribor3m) AS INT64) AS euribor_tramo, 
    COUNT(*) AS n,
    ROUND(COUNTIF(y = 'yes') / COUNT(*), 4) AS tasa_conversion
FROM `TU_PROYECTO.TU_DATASET.bank_additional_full`
GROUP BY euribor_tramo
ORDER BY euribor_tramo;
-- Resultado:
/*
[{"euribor_tramo": "0","n": "3890","tasa_conversion": "0.4571"}, 
{"euribor_tramo": "1","n": "9608","tasa_conversion": "0.1585"}, 
{"euribor_tramo": "3","n": "14","tasa_conversion": "0.0714"}, 
{"euribor_tramo": "4","n": "27660","tasa_conversion": "0.0481"}, 
{"euribor_tramo": "5","n": "16","tasa_conversion": "0.5"}]
*/
