# Tracking 2022 Flu Vaccinations Among Active Patients in Massachusetts

This project analyzes a synthetic dataset that replicates the structure and format of a real flu vaccination dataset from a hospital, providing a realistic simulation for data analysis. The interactive Tableau Dashboard can be found _[here](https://public.tableau.com/app/profile/martin.guiller.iii/viz/TrackingFluVaccinationsforActivePatientsin2022/Dashboard1?publish=yes)_.

The dashboard provides in-depth tracking and analysis of flu immunizations among synthetic patients in Massachusetts.

![Screenshot 2024-08-15 144724](https://github.com/user-attachments/assets/4a1c62f1-b07f-4234-9beb-e5d758fe2cab)

### Synthetic Patients Immunizations Dataset Metrics & Dimensions

- **_id_**: Unique identifier for each patient.
- **_full_name_**: The full name of the patient.
- **_birthdate_**: The birth date of the patient.
- **_age_**: The age of the patient.
- **_race_**: The race or ethnicity of the patient.
- **_county_**: The county where the patient resides.
- **_flu_shot_date_**: The date when the patient received their flu shot.
- **_flu_shot_2022_**: A binary indicator (1 for "yes" and 0 for "no") showing whether the patient received a flu shot in 2022.

## Summary of Insights

#### 1. Overall Vaccination Compliance:
  - **Total Compliance:** The overall flu vaccination compliance among active patients in Massachusetts for 2022 is 81.4%.
  - **Total Flu Shots Administered:** 8,101 flu shots were given in 2022.

#### 2. Vaccination Rates by Age Group:
  - **High Compliance Age Groups:**
    - **50-64 years:** 96.3% compliance, indicating high vaccination rates among this age group.
    - **65+ years:** 91.2% compliance, showing a strong uptake among the elderly.
  - **Low Compliance Age Group:**
    - **18-34 years:** Only 62.2% compliance, indicating a need for targeted interventions to increase flu vaccinations among younger adults.

#### 3. Vaccination Rates by Race:
  - **High Compliance Racial Groups:**
    - **Black:** 84.9%
    - **Native:** 85.7%
    - **Asian:** 81.8%
  - **Low Compliance Racial Group:**
    - **Other:** 80.0% compliance, suggesting an area for improvement.

#### 4. Geographic Distribution (By County):
  - **Flu Shot % by County:** All counties in Massachusetts have an average flu vaccination compliance ranging from 79% to 82%, indicating consistent but slightly varied uptake across the state.

#### 5. Vaccination Trends Over Time:
  - **Running Sum of Flu Shots:** There was a steady increase in flu vaccinations throughout 2022, with significant increases in August and September, aligning with the start of the flu season.

## Recommendations:
  - **Target Younger Adults:** Increase efforts to boost vaccination rates in the 18-34 age group.
  - **Focus on "Other" Racial Category:** Address barriers to vaccination in the "Other" racial category to improve overall compliance.
  - **Address Geographic Disparities:** Target counties with lower vaccination rates for increased public health outreach and resources.

## Dataset Limitation:
  - **Synthetic Dataset & Gender Representation:** The dataset is synthetic and exclusively includes patients of the female gender. This limitation means that the analysis does not account for differences in flu vaccination rates by gender, which could lead to biased insights and limit the applicability of findings to a broader, more diverse population.

## Exploratory Data Analysis (EDA) & Data Manipulation Process using PostgreSQL:
  - **Synthetic Hospital Dataset:**
    - **Table 1: Conditions** - Contains information about medical conditions or diagnoses assigned to patients, including condition codes, descriptions, and potentially severity or duration.
    - **Table 2: Encounters** - Records details of patient visits or interactions with healthcare providers, including dates, types of encounters (e.g., office visits, hospital admissions), and associated conditions or treatments.
    - **Table 3: Immunizations** - Provides data on vaccinations administered to patients, including vaccine types, administration dates, and any relevant details about the immunization process.
    - **Table 4: Patients** - Contains personal and demographic information about patients, such as names, dates of birth, contact information, and possibly insurance details or medical history.
      
  - **SQL Query Sample**
    - **Query:** Patients with Flu Shots in 2022

      This SQL [query](https://github.com/mgmillimeter/Tracking-2022-Flu-Vaccinations-Among-Active-Patients-in-Massachusetts/blob/main/PostgreSQL-Flu%20Shots%20immunizations%202022.sql) identifies patients with encounters between 2020 and 2022 who have not recorded a death date (Active Patients). It also finds the earliest flu shot date in 2022 for each patient and combines patient details with their flu shot data.

      ```sql
      -- CTE to identify patients with encounters between 2020 and 2022 and no recorded death date
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
      ```

## Data Sources

Original dataset can be tracked _[here](https://github.com/Data-Wizardry)._

Credits: _Josh Matlock_
