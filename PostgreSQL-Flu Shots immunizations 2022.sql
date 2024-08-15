/****** 2022 FLU SHOTS IMMUNIZATIONS EDA *******/

/*EXPLORATORY DATA ANALYSIS*/


/*

OBJECTIVES: Come up with flu shots dashboard for 2022 that does the following:
1.) Total % of patients getting flu shots stratified by
	a.) Age
	b.) Race
	c.) County (Map)
	d.) Overall
2.) Running Total of Flu Shots over the course of 2022
3.) Total Number of Flu shots given in 2022
4.) A list of Patients that show whether or not they received the flu shots.

REQUIREMENT(S): Patients must have been "Active at the hospital".

*/

-- EDA Query Script: 

-- CTE to identify patients with encounters between 2020 and 2022 and no recorded deathdate
WITH active_patients AS (
    SELECT DISTINCT e.patient
    FROM encounters AS e
    JOIN patients AS pat ON e.patient = pat.id
    WHERE e.start BETWEEN '2020-01-01 00:00' AND '2022-12-31 23:59'
      AND pat.deathdate IS NULL
),

-- CTE to find the earliest flu shot date in 2022 for each patient
flu_shot_2022 AS (
    SELECT patient, MIN(date) AS earliest_flu_shot_2022 
    FROM immunizations
    WHERE code = '5302'
      AND date BETWEEN '2022-01-01 00:00' AND '2022-12-31 23:59'
    GROUP BY patient
)
-- Final query to combine patient details with their earliest flu shot data
SELECT 
    pat.id,
    pat.first,
    pat.last,
    pat.birthdate,
    EXTRACT(YEAR FROM age('2022-12-31'::date, pat.birthdate)) AS age,
    pat.race,
    pat.county,
    pat.gender,
    flu.earliest_flu_shot_2022,
    CASE WHEN flu.patient IS NOT NULL THEN 1 ELSE 0 END AS flu_shot_2022
FROM patients AS pat
LEFT JOIN flu_shot_2022 AS flu ON pat.id = flu.patient
WHERE pat.id IN (SELECT patient FROM active_patients);

-- Query Script Explanations below




-- Query explanations
-- CTE 1:
/* Line 1: 
(SELECT DISTINCT e.patient) 
	- Select distinct patient identifiers from the 'encounters' table
	- to retrieve a list of unique patients.

/* Line 2: 
(FROM encounters AS e JOIN patients AS pat ON e.patient = pat.id)
	- Join the 'encounters' table (aliased as 'e') with the 'patients' table (aliased as 'pat')
	- using the 'patient' column from the 'encounters' table and the 'id' column from the 'patients' table
	- to match records where these columns have the same values.

/* Line 3 & 4: 
(WHERE e.start BETWEEN '2020-01-01 00:00' AND '2022-12-31 23:59')
(AND pat.deathdate IS NULL)
	- Filter the records to include only encounters where the 'start' date falls between '2020-01-01 00:00' and '2022-12-31 23:59'
	- This helps identify encounters within the specified 3-year period.
	- Additionally, exclude patients who have a 'deathdate' recorded, as this indicates they are no longer active.


-- CTE 2:
/* Line 1: 
(SELECT patient, MIN(date) AS earliest_flu_shot_2022)
	- Retrieve the patient identifier and the earliest date of their flu shot within 2022.
	- Alias the earliest date as 'earliest_flu_shot_2022'.
    - Use MIN(date) to find the earliest flu shot date for each patient, considering they may have multiple records.
    - Annual flu shots are required for individuals aged 6 months and older, so this query identifies the first recorded flu shot within the year.

/* Line 2, 3 & 4: 
(FROM immunizations WHERE code = '5302'
AND date BETWEEN '2022-01-01 00:00' AND '2022-12-31 23:59'
GROUP BY patient)
   - Select records from the 'immunizations' table where the immunization code is '5302' (indicating a flu shot).
   - Filter the records to include only those with dates within the year 2022.
   - Group the results by patient to aggregate their flu shot records and find the earliest date per patient.

-- FINAL QUERY OF THE 2 CTEs
SELECT 
    pat.id,  -- Patient ID
    pat.first,  -- Patient's first name
    pat.last,  -- Patient's last name
    pat.birthdate,  -- Patient's birthdate
    EXTRACT(YEAR FROM age('2022-12-31'::date, pat.birthdate)) AS age,  -- Calculate the patient's age as of December 31, 2022
    pat.race,  -- Patient's race
    pat.county,  -- Patient's county of residence
    pat.gender,  -- Patient's gender
    flu.earliest_flu_shot_2022,  -- The earliest date of the flu shot in 2022 for the patient
    CASE WHEN flu.patient IS NOT NULL THEN 1 ELSE 0 END AS flu_shot_2022  -- Indicator (1 or 0) showing if the patient received a flu shot in 2022
FROM patients AS pat
LEFT JOIN flu_shot_2022 AS flu ON pat.id = flu.patient  -- Left join to include all patients and their flu shot data if available
WHERE pat.id IN (SELECT patient FROM active_patients);  -- Filter to include only patients listed as active

*/