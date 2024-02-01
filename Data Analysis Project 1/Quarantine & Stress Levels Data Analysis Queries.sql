--- Data Cleaning Process ---

SELECT *
FROM portfolio_project..mental_health_data
WHERE COALESCE(Age,Gender,Occupation,Days_Indoors,Growing_Stress,Quarantine_Frustrations,Changes_Habits,Mental_Health_History,Weight_Change,Mood_Swings,Coping_Struggles,Work_Interest,Social_Weakness) IS NULL;
-- Show rows with null entries. Given the nature of the project, there should be none, so all rows must be checked for Null entries --

SELECT Age, COUNT(Age) Age_Count
FROM portfolio_project..mental_health_data
GROUP BY (Age)
SELECT DISTINCT Len(Age) Age_Char_Len_Count
FROM portfolio_project..mental_health_data;
-- Show the number of entries matching all distinct ages and the character count of the Age Group designations. Both of these show if there are any inavlid entries or typos in the Age Column

--All typos, duplicates, and Nulls have been located and excluded from the table at this point--
--------------------------------------------------------END OF DATA CLEANING--------------------------------------------------------


--- Data Analysis ---

-- Days Indoors versus Growing Stress --
SELECT Gender, Age, Days_Indoors, Growing_Stress
FROM portfolio_project..mental_health_data
ORDER BY Gender, Age, Days_Indoors, Growing_Stress;
-- Show the growing stress levels of individuals based on the amount of time they have spent indoors. Is there a correlation between time spent indoors and stress levels?

-- Days Indoors versus Occupation --
SELECT Gender, Age, Occupation, Growing_Stress
FROM portfolio_project..mental_health_data
ORDER BY Gender, Age, Occupation, Growing_Stress;
-- Show the growing stress levels of individuals and compare it to their documented occupation. This is to see if people with different job positions are more or less stressed than others when quarantined

-- Days Indoors versus Growing Stress --
SELECT Gender, Age, Mental_Health_History, Growing_Stress
FROM portfolio_project..mental_health_data
ORDER BY Gender, Age, Mental_Health_History, Growing_Stress;
-- Show the growing stress levels of individuals and its correlation (if any) to the mental health history of the surveyed. Are those with a reported history more susceptible to higher stress levels?