COPY person(person_id,gender_concept_id,year_of_birth,race_concept_id,ethnicity_concept_id,gender_source_concept_id,race_source_concept_id,ethnicity_source_concept_id,person_source_value)
FROM '/var/lib/postgresql/csv/person.csv' DELIMITER ',' CSV HEADER;