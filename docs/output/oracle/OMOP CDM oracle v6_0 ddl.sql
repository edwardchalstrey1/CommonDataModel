/*********************************************************************************
# Copyright 2018-08 Observational Health Data Sciences and Informatics
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
********************************************************************************/

/************************

 ####### #     # ####### ######      #####  ######  #     #            #####        ###
 #     # ##   ## #     # #     #    #     # #     # ##   ##    #    # #     #      #   #
 #     # # # # # #     # #     #    #       #     # # # # #    #    # #           #     #
 #     # #  #  # #     # ######     #       #     # #  #  #    #    # ######      #     #
 #     # #     # #     # #          #       #     # #     #    #    # #     # ### #     #
 #     # #     # #     # #          #     # #     # #     #     #  #  #     # ###  #   #
 ####### #     # ####### #           #####  ######  #     #      ##    #####  ###   ###

oracle script to create OMOP common data model version 6.0

last revised: 27-Aug-2018

Authors:  Patrick Ryan, Christian Reich, Clair Blacketer


*************************/


/************************

Standardized vocabulary

************************/


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.concept (
  concept_id			      INTEGER			NOT NULL ,
  concept_name			  	VARCHAR(255)	NOT NULL ,
  domain_id				      VARCHAR(20)		NOT NULL ,
  vocabulary_id			  	VARCHAR(20)		NOT NULL ,
  concept_class_id			VARCHAR(20)		NOT NULL ,
  standard_concept			VARCHAR(1)		NULL ,
  concept_code			  	VARCHAR(50)		NOT NULL ,
  valid_start_date			DATE			NOT NULL ,
  valid_end_date		  	DATE			NOT NULL ,
  invalid_reason		  	VARCHAR(1)		NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.vocabulary (
  vocabulary_id			      VARCHAR(20)		NOT NULL,
  vocabulary_name		      VARCHAR(255)	NOT NULL,
  vocabulary_reference		VARCHAR(255)	NOT NULL,
  vocabulary_version	  	VARCHAR(255)	NULL,
  vocabulary_concept_id		INTEGER			NOT NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.domain (
  domain_id			      VARCHAR(20)		NOT NULL,
  domain_name		      VARCHAR(255)	NOT NULL,
  domain_concept_id		INTEGER			NOT NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.concept_class (
  concept_class_id			      VARCHAR(20)		NOT NULL,
  concept_class_name		      VARCHAR(255)	NOT NULL,
  concept_class_concept_id		INTEGER			NOT NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.concept_relationship (
  concept_id_1			  INTEGER			NOT NULL,
  concept_id_2			  INTEGER			NOT NULL,
  relationship_id		  VARCHAR(20)		NOT NULL,
  valid_start_date		DATE			NOT NULL,
  valid_end_date		  DATE			NOT NULL,
  invalid_reason		  VARCHAR(1)		NULL
  )
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.relationship (
  relationship_id			  VARCHAR(20)		NOT NULL,
  relationship_name			  VARCHAR(255)	NOT NULL,
  is_hierarchical			    VARCHAR(1)		NOT NULL,
  defines_ancestry			  VARCHAR(1)		NOT NULL,
  reverse_relationship_id	VARCHAR(20)		NOT NULL,
  relationship_concept_id	INTEGER			  NOT NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.concept_synonym (
  concept_id			        INTEGER		    NOT NULL,
  concept_synonym_name	  VARCHAR(1000)	NOT NULL,
  language_concept_id	    INTEGER		    NOT NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.concept_ancestor (
  ancestor_concept_id		      INTEGER		NOT NULL,
  descendant_concept_id		  	INTEGER		NOT NULL,
  min_levels_of_separation		INTEGER		NOT NULL,
  max_levels_of_separation		INTEGER		NOT NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.source_to_concept_map (
  source_code				  	    VARCHAR(50)		NOT NULL,
  source_concept_id			  	INTEGER			  NOT NULL,
  source_vocabulary_id			VARCHAR(20)		NOT NULL,
  source_code_description		VARCHAR(255)	NULL,
  target_concept_id			  	INTEGER			  NOT NULL,
  target_vocabulary_id			VARCHAR(20)		NOT NULL,
  valid_start_date			  	DATE			    NOT NULL,
  valid_end_date			      DATE			    NOT NULL,
  invalid_reason			      VARCHAR(1)		NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.drug_strength (
  drug_concept_id				      INTEGER		  NOT NULL,
  ingredient_concept_id			  INTEGER		  NOT NULL,
  amount_value					      FLOAT		    NULL,
  amount_unit_concept_id		  INTEGER		  NULL,
  numerator_value				      FLOAT		    NULL,
  numerator_unit_concept_id		INTEGER		  NULL,
  denominator_value				    FLOAT		    NULL,
  denominator_unit_concept_id	INTEGER		  NULL,
  box_size						        INTEGER		  NULL,
  valid_start_date				    DATE		    NOT NULL,
  valid_end_date				      DATE		    NOT NULL,
  invalid_reason				      VARCHAR(1) 	NULL
)
;


/**************************

Standardized meta-data

***************************/


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.cdm_source
(
  cdm_source_name					        VARCHAR(255)	NOT NULL ,
  cdm_source_abbreviation			    VARCHAR(25)		NULL ,
  cdm_holder						          VARCHAR(255)	NULL ,
  source_description				      CLOB	NULL ,
  source_documentation_reference	VARCHAR(255)	NULL ,
  cdm_etl_reference					      VARCHAR(255)	NULL ,
  source_release_date				      DATE			    NULL ,
  cdm_release_date					      DATE			    NULL ,
  cdm_version						          VARCHAR(10)		NULL ,
  vocabulary_version				      VARCHAR(20)		NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.metadata
(
  metadata_concept_id       INTEGER       NOT NULL ,
  metadata_type_concept_id  INTEGER       NOT NULL ,
  name                      VARCHAR(250)  NOT NULL ,
  value_as_string           CLOB  NULL ,
  value_as_concept_id       INTEGER       NULL ,
  metadata_date             DATE          NULL ,
  metadata_datetime         TIMESTAMP     NULL
)
;

INSERT INTO OHDSI.metadata (metadata_concept_id, metadata_type_concept_id, name, value_as_string, value_as_concept_id, metadata_date, metadata_datetime) --Added cdm version record
VALUES (0,0,'CDM Version', '6.0',0,NULL,NULL)
;


/************************

Standardized clinical data

************************/


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.person
(
  person_id						        NUMBER(19)	  	  NOT NULL ,
  gender_concept_id				    INTEGER	  	  NOT NULL ,
  year_of_birth					      INTEGER	  	  NOT NULL ,
  month_of_birth				      INTEGER	  	  NULL,
  day_of_birth					      INTEGER	  	  NULL,
  birth_datetime				      TIMESTAMP	  	NULL,
  death_datetime					    TIMESTAMP		  NULL,
  race_concept_id				      INTEGER		    NOT NULL,
  ethnicity_concept_id			  INTEGER	  	  NOT NULL,
  location_id					        NUMBER(19)		    NULL,
  provider_id					        NUMBER(19)		    NULL,
  care_site_id					      NUMBER(19)		    NULL,
  person_source_value			    VARCHAR(50)   NULL,
  gender_source_value			    VARCHAR(50)   NULL,
  gender_source_concept_id    INTEGER		    NOT NULL,
  race_source_value				    VARCHAR(50)   NULL,
  race_source_concept_id		  INTEGER		    NOT NULL,
  ethnicity_source_value		  VARCHAR(50)   NULL,
  ethnicity_source_concept_id INTEGER		    NOT NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.observation_period
(
  observation_period_id				  NUMBER(19)		NOT NULL ,
  person_id							        NUMBER(19)		NOT NULL ,
  observation_period_start_date	DATE		  NOT NULL ,
  observation_period_end_date   DATE		  NOT NULL ,
  period_type_concept_id			  INTEGER		NOT NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.specimen
(
  specimen_id					        NUMBER(19)		  	NOT NULL ,
  person_id						        NUMBER(19)		  	NOT NULL ,
  specimen_concept_id			    INTEGER			  NOT NULL ,
  specimen_type_concept_id		INTEGER			  NOT NULL ,
  specimen_date					      DATE			    NULL ,
  specimen_datetime				    TIMESTAMP		  NOT NULL ,
  quantity						        FLOAT			    NULL ,
  unit_concept_id				      INTEGER			  NULL ,
  anatomic_site_concept_id		INTEGER			  NOT NULL ,
  disease_status_concept_id		INTEGER			  NOT NULL ,
  specimen_source_id			    VARCHAR(50)		NULL ,
  specimen_source_value			  VARCHAR(50)		NULL ,
  unit_source_value				    VARCHAR(50)		NULL ,
  anatomic_site_source_value	VARCHAR(50)		NULL ,
  disease_status_source_value	VARCHAR(50)		NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.visit_occurrence
(
  visit_occurrence_id			      NUMBER(19)			  NOT NULL ,
  person_id						          NUMBER(19)			  NOT NULL ,
  visit_concept_id				      INTEGER			  NOT NULL ,
  visit_start_date				      DATE			    NULL ,
  visit_start_datetime			    TIMESTAMP		  NOT NULL ,
  visit_end_date				        DATE			    NULL ,
  visit_end_datetime			      TIMESTAMP		  NOT NULL ,
  visit_type_concept_id			    INTEGER			  NOT NULL ,
  provider_id					          NUMBER(19)			  NULL,
  care_site_id					        NUMBER(19)			  NULL,
  visit_source_value			      VARCHAR(50)		NULL,
  visit_source_concept_id		    INTEGER			  NOT NULL ,
  admitted_from_concept_id      INTEGER     	NOT NULL ,
  admitted_from_source_value    VARCHAR(50) 	NULL ,
  discharge_to_source_value		  VARCHAR(50)		NULL ,
  discharge_to_concept_id		    INTEGER   		NOT NULL ,
  preceding_visit_occurrence_id	NUMBER(19)			  NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.visit_detail
(
  visit_detail_id                    NUMBER(19)      NOT NULL ,
  person_id                          NUMBER(19)      NOT NULL ,
  visit_detail_concept_id            INTEGER     NOT NULL ,
  visit_detail_start_date            DATE        NULL ,
  visit_detail_start_datetime        TIMESTAMP   NOT NULL ,
  visit_detail_end_date              DATE        NULL ,
  visit_detail_end_datetime          TIMESTAMP   NOT NULL ,
  visit_detail_type_concept_id       INTEGER     NOT NULL ,
  provider_id                        NUMBER(19)      NULL ,
  care_site_id                       NUMBER(19)      NULL ,
  discharge_to_concept_id            INTEGER     NOT NULL ,
  admitted_from_concept_id           INTEGER     NOT NULL ,
  admitted_from_source_value         VARCHAR(50) NULL ,
  visit_detail_source_value          VARCHAR(50) NULL ,
  visit_detail_source_concept_id     INTEGER     NOT NULL ,
  discharge_to_source_value          VARCHAR(50) NULL ,
  preceding_visit_detail_id          NUMBER(19)      NULL ,
  visit_detail_parent_id             NUMBER(19)      NULL ,
  visit_occurrence_id                NUMBER(19)      NOT NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.procedure_occurrence
(
  procedure_occurrence_id		  NUMBER(19)			NOT NULL ,
  person_id						        NUMBER(19)			NOT NULL ,
  procedure_concept_id			  INTEGER			NOT NULL ,
  procedure_date				      DATE			  NULL ,
  procedure_datetime			    TIMESTAMP		NOT NULL ,
  procedure_type_concept_id		INTEGER			NOT NULL ,
  modifier_concept_id			    INTEGER			NOT NULL ,
  quantity						        INTEGER			NULL ,
  provider_id					        NUMBER(19)			NULL ,
  visit_occurrence_id			    NUMBER(19)			NULL ,
  visit_detail_id             NUMBER(19)      NULL ,
  procedure_source_value		  VARCHAR(50)	NULL ,
  procedure_source_concept_id	INTEGER			NOT NULL ,
  modifier_source_value		    VARCHAR(50)	NULL
)
;

--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.drug_exposure
(
  drug_exposure_id				      NUMBER(19)			  NOT NULL ,
  person_id						          NUMBER(19)			  NOT NULL ,
  drug_concept_id				        INTEGER			  NOT NULL ,
  drug_exposure_start_date		  DATE			    NULL ,
  drug_exposure_start_datetime	TIMESTAMP		  NOT NULL ,
  drug_exposure_end_date		    DATE			    NULL ,
  drug_exposure_end_datetime	  TIMESTAMP		  NOT NULL ,
  verbatim_end_date				      DATE			    NULL ,
  drug_type_concept_id			    INTEGER			  NOT NULL ,
  stop_reason					          VARCHAR(20)		NULL ,
  refills						            INTEGER		  	NULL ,
  quantity						          FLOAT			    NULL ,
  days_supply					          INTEGER		  	NULL ,
  sig							              CLOB	NULL ,
  route_concept_id				      INTEGER			  NOT NULL ,
  lot_number					          VARCHAR(50)	  NULL ,
  provider_id					          NUMBER(19)			  NULL ,
  visit_occurrence_id			      NUMBER(19)			  NULL ,
  visit_detail_id               NUMBER(19)       	NULL ,
  drug_source_value				      VARCHAR(50)	  NULL ,
  drug_source_concept_id		    INTEGER			  NOT NULL ,
  route_source_value			      VARCHAR(50)		NULL ,
  dose_unit_source_value		    VARCHAR(50)	  NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.device_exposure
(
  device_exposure_id			        NUMBER(19)		    NOT NULL ,
  person_id						            NUMBER(19)		    NOT NULL ,
  device_concept_id			          INTEGER		    NOT NULL ,
  device_exposure_start_date	    DATE			    NULL ,
  device_exposure_start_datetime  TIMESTAMP		  NOT NULL ,
  device_exposure_end_date		    DATE			    NULL ,
  device_exposure_end_datetime    TIMESTAMP		  NULL ,
  device_type_concept_id		      INTEGER		    NOT NULL ,
  unique_device_id			          VARCHAR(50)	  NULL ,
  quantity						            INTEGER		    NULL ,
  provider_id					            NUMBER(19)		    NULL ,
  visit_occurrence_id			        NUMBER(19)		    NULL ,
  visit_detail_id                 NUMBER(19)        NULL ,
  device_source_value			        VARCHAR(100)	NULL ,
  device_source_concept_id		    INTEGER		    NOT NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.condition_occurrence
(
  condition_occurrence_id		    NUMBER(19)			NOT NULL ,
  person_id						          NUMBER(19)			NOT NULL ,
  condition_concept_id			    INTEGER			NOT NULL ,
  condition_start_date			    DATE			  NULL ,
  condition_start_datetime		  TIMESTAMP		NOT NULL ,
  condition_end_date			      DATE			  NULL ,
  condition_end_datetime		    TIMESTAMP		NULL ,
  condition_type_concept_id		  INTEGER			NOT NULL ,
  condition_status_concept_id	  INTEGER			NOT NULL ,
  stop_reason					          VARCHAR(20)	NULL ,
  provider_id					          NUMBER(19)			NULL ,
  visit_occurrence_id			      NUMBER(19)			NULL ,
  visit_detail_id               NUMBER(19)     	NULL ,
  condition_source_value		    VARCHAR(50)	NULL ,
  condition_source_concept_id	  INTEGER			NOT NULL ,
  condition_status_source_value	VARCHAR(50)	NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.measurement
(
  measurement_id				        NUMBER(19)			NOT NULL ,
  person_id						          NUMBER(19)			NOT NULL ,
  measurement_concept_id		    INTEGER			NOT NULL ,
  measurement_date				      DATE			NULL ,
  measurement_datetime			    TIMESTAMP		NOT NULL ,
  measurement_time              VARCHAR(10) 	NULL,
  measurement_type_concept_id	  INTEGER			NOT NULL ,
  operator_concept_id			      INTEGER			NULL ,
  value_as_number				        FLOAT			NULL ,
  value_as_concept_id			      INTEGER			NULL ,
  unit_concept_id				        INTEGER			NULL ,
  range_low					            FLOAT			NULL ,
  range_high					          FLOAT			NULL ,
  provider_id					          NUMBER(19)			NULL ,
  visit_occurrence_id			      NUMBER(19)			NULL ,
  visit_detail_id               NUMBER(19)	     	NULL ,
  measurement_source_value		  VARCHAR(50)		NULL ,
  measurement_source_concept_id	INTEGER			NOT NULL ,
  unit_source_value				      VARCHAR(50)		NULL ,
  value_source_value			      VARCHAR(50)		NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.note
(
  note_id						          NUMBER(19)			  NOT NULL ,
  person_id						        NUMBER(19)			  NOT NULL ,
  note_event_id         		  NUMBER(19)        NULL ,
  note_event_field_concept_id	INTEGER 		  NOT NULL ,
  note_date						        DATE			    NULL ,
  note_datetime					      TIMESTAMP		  NOT NULL ,
  note_type_concept_id			  INTEGER			  NOT NULL ,
  note_class_concept_id 		  INTEGER			  NOT NULL ,
  note_title					        VARCHAR(250)	NULL ,
  note_text						        CLOB  NULL ,
  encoding_concept_id			    INTEGER			  NOT NULL ,
  language_concept_id			    INTEGER			  NOT NULL ,
  provider_id					        NUMBER(19)			  NULL ,
  visit_occurrence_id			    NUMBER(19)			  NULL ,
  visit_detail_id       		  NUMBER(19)       	NULL ,
  note_source_value				    VARCHAR(50)		NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.note_nlp
(
  note_nlp_id					        NUMBER(19)			  NOT NULL ,
  note_id						          NUMBER(19)			  NOT NULL ,
  section_concept_id			    INTEGER			  NOT NULL ,
  snippet						          VARCHAR(250)	NULL ,
  "offset"					          VARCHAR(250)	NULL ,
  lexical_variant				      VARCHAR(250)	NOT NULL ,
  note_nlp_concept_id			    INTEGER			  NOT NULL ,
  nlp_system					        VARCHAR(250)	NULL ,
  nlp_date						        DATE			    NOT NULL ,
  nlp_datetime					      TIMESTAMP		  NULL ,
  term_exists					        VARCHAR(1)		NULL ,
  term_temporal					      VARCHAR(50)		NULL ,
  term_modifiers				      VARCHAR(2000)	NULL ,
  note_nlp_source_concept_id	INTEGER			  NOT NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.observation
(
  observation_id					      NUMBER(19)			NOT NULL ,
  person_id						          NUMBER(19)			NOT NULL ,
  observation_concept_id			  INTEGER			NOT NULL ,
  observation_date				      DATE			  NULL ,
  observation_datetime				  TIMESTAMP		NOT NULL ,
  observation_type_concept_id   INTEGER			NOT NULL ,
  value_as_number				        FLOAT			  NULL ,
  value_as_string				        VARCHAR(60) NULL ,
  value_as_concept_id			      INTEGER			NULL ,
  qualifier_concept_id			    INTEGER			NULL ,
  unit_concept_id				   	    INTEGER			NULL ,
  provider_id					          INTEGER			NULL ,
  visit_occurrence_id			      NUMBER(19)			NULL ,
  visit_detail_id               NUMBER(19)      NULL ,
  observation_source_value		  VARCHAR(50)	NULL ,
  observation_source_concept_id INTEGER			NOT NULL ,
  unit_source_value				      VARCHAR(50)	NULL ,
  qualifier_source_value			  VARCHAR(50)	NULL ,
  observation_event_id				  NUMBER(19)			NULL ,
  obs_event_field_concept_id		INTEGER			NOT NULL ,
  value_as_datetime					    TIMESTAMP		NULL
)
;


--HINT DISTRIBUTE ON KEY(person_id)
CREATE TABLE OHDSI.survey_conduct
(
  survey_conduct_id					      NUMBER(19)			  NOT NULL ,
  person_id						            NUMBER(19)			  NOT NULL ,
  survey_concept_id			  		    INTEGER			  NOT NULL ,
  survey_start_date				        DATE			    NULL ,
  survey_start_datetime				    TIMESTAMP		  NULL ,
  survey_end_date					        DATE			    NULL ,
  survey_end_datetime				      TIMESTAMP		  NOT NULL ,
  provider_id						          NUMBER(19)			  NULL ,
  assisted_concept_id	  			    INTEGER			  NOT NULL ,
  respondent_type_concept_id		  INTEGER			  NOT NULL ,
  timing_concept_id					      INTEGER			  NOT NULL ,
  collection_method_concept_id		INTEGER			  NOT NULL ,
  assisted_source_value		  		  VARCHAR(50)		NULL ,
  respondent_type_source_value		VARCHAR(100)  NULL ,
  timing_source_value				      VARCHAR(100)	NULL ,
  collection_method_source_value	VARCHAR(100)	NULL ,
  survey_source_value				      VARCHAR(100)	NULL ,
  survey_source_concept_id			  INTEGER			  NOT NULL ,
  survey_source_identifier			  VARCHAR(100)	NULL ,
  validated_survey_concept_id		  INTEGER			  NOT NULL ,
  validated_survey_source_value		VARCHAR(100)	NULL ,
  survey_version_number				    VARCHAR(20)		NULL ,
  visit_occurrence_id				      NUMBER(19)			  NULL ,
  visit_detail_id					        NUMBER(19)			  NULL ,
  response_visit_occurrence_id		NUMBER(19)			  NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.fact_relationship
(
  domain_concept_id_1			INTEGER			NOT NULL ,
  fact_id_1						    NUMBER(19)			NOT NULL ,
  domain_concept_id_2			INTEGER			NOT NULL ,
  fact_id_2						    NUMBER(19)			NOT NULL ,
  relationship_concept_id	INTEGER			NOT NULL
)
;



/************************

Standardized health system data

************************/


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.location
(
  location_id					  NUMBER(19)			  NOT NULL ,
  address_1						  VARCHAR(50)		NULL ,
  address_2						  VARCHAR(50)		NULL ,
  city							    VARCHAR(50)		NULL ,
  state							    VARCHAR(2)		NULL ,
  zip							      VARCHAR(9)		NULL ,
  county						    VARCHAR(20)		NULL ,
  country						    VARCHAR(100)	NULL ,
  location_source_value VARCHAR(50)		NULL ,
  latitude						  FLOAT				  NULL ,
  longitude						  FLOAT				  NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.location_history --Table added
(
  location_history_id           NUMBER(19)      NOT NULL ,
  location_id			              NUMBER(19)		  NOT NULL ,
  relationship_type_concept_id	INTEGER		  NOT NULL ,
  domain_id				              VARCHAR(50) NOT NULL ,
  entity_id				              NUMBER(19)			NOT NULL ,
  start_date			              DATE			  NOT NULL ,
  end_date				              DATE			  NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.care_site
(
  care_site_id						      NUMBER(19)			  NOT NULL ,
  care_site_name						    VARCHAR(255)  NULL ,
  place_of_service_concept_id	  INTEGER			  NOT NULL ,
  location_id						        NUMBER(19)			  NULL ,
  care_site_source_value			  VARCHAR(50)		NULL ,
  place_of_service_source_value VARCHAR(50)		NULL
)
;


--HINT DISTRIBUTE ON RANDOM
CREATE TABLE OHDSI.provider
(
  provider_id					        NUMBER(19)			  NOT NULL ,
  provider_name					      VARCHAR(255)	NULL ,
  NPI							            VARCHAR(20)		NULL ,
  DEA							            VARCHAR(20)		NULL ,
  specialty_concept_id			  INTEGER			  NOT NULL ,
  care_site_id					      NUMBER(19)			  NULL ,
  year_of_birth					      INTEGER			  NULL ,
  gender_concept_id				    INTEGER			  NOT NULL ,
  provider_source_value			  VARCHAR(50)		NULL ,
  specialty_source_value		  VARCHAR(50)		NULL ,
  specialty_source_concept_id	INTEGER			  NOT NULL ,
  gender_source_value			    VARCHAR(50)		NULL ,
  gender_source_concept_id		INTEGER			  NOT NULL
)
;


/************************

Standardized health economics

************************/


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.payer_plan_period
(
  payer_plan_period_id			    NUMBER(19)			    NOT NULL ,
  person_id						          NUMBER(19)			    NOT NULL ,
  contract_person_id            NUMBER(19)        	NULL ,
  payer_plan_period_start_date  DATE			      NOT NULL ,
  payer_plan_period_end_date	  DATE			      NOT NULL ,
  payer_concept_id              INTEGER       	NOT NULL ,
  plan_concept_id               INTEGER       	NOT NULL ,
  contract_concept_id           INTEGER       	NOT NULL ,
  sponsor_concept_id            INTEGER       	NOT NULL ,
  stop_reason_concept_id        INTEGER       	NOT NULL ,
  payer_source_value			      VARCHAR(50)	  	NULL ,
  payer_source_concept_id       INTEGER       	NOT NULL ,
  plan_source_value				      VARCHAR(50)	  	NULL ,
  plan_source_concept_id        INTEGER       	NOT NULL ,
  contract_source_value         VARCHAR(50)   	NULL ,
  contract_source_concept_id    INTEGER       	NOT NULL ,
  sponsor_source_value          VARCHAR(50)   	NULL ,
  sponsor_source_concept_id     INTEGER       	NOT NULL ,
  family_source_value			      VARCHAR(50)	  	NULL ,
  stop_reason_source_value      VARCHAR(50)   	NULL ,
  stop_reason_source_concept_id INTEGER       	NOT NULL
)
;


--HINT DISTRIBUTE ON KEY(person_id)
CREATE TABLE OHDSI.cost
(
  cost_id						          NUMBER(19)	    	NOT NULL ,
  person_id						        NUMBER(19)		  	NOT NULL,
  cost_event_id					      NUMBER(19)      	NOT NULL ,
  cost_event_field_concept_id	INTEGER			  NOT NULL ,
  cost_concept_id				      INTEGER		  	NOT NULL ,
  cost_type_concept_id		  	INTEGER     	NOT NULL ,
  currency_concept_id			    INTEGER		  	NOT NULL ,
  cost							          FLOAT		      NULL ,
  incurred_date					      DATE		      NOT NULL ,
  billed_date					        DATE		      NULL ,
  paid_date					        	DATE		      NULL ,
  revenue_code_concept_id		  INTEGER		  	NOT NULL ,
  drg_concept_id			        INTEGER		  	NOT NULL ,
  cost_source_value				    VARCHAR(50)		NULL ,
  cost_source_concept_id	  	INTEGER		  	NOT NULL ,
  revenue_code_source_value		VARCHAR(50) 	NULL ,
  drg_source_value			      VARCHAR(3)		NULL ,
  payer_plan_period_id			  NUMBER(19)			  NULL
)
;


/************************

Standardized derived elements

************************/


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.drug_era
(
  drug_era_id					NUMBER(19)			NOT NULL ,
  person_id						NUMBER(19)			NOT NULL ,
  drug_concept_id			INTEGER			NOT NULL ,
  drug_era_start_date	DATE			  NOT NULL ,
  drug_era_end_date		DATE			  NOT NULL ,
  drug_exposure_count	INTEGER			NULL ,
  gap_days						INTEGER			NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.dose_era
(
  dose_era_id					  NUMBER(19)			NOT NULL ,
  person_id						  NUMBER(19)			NOT NULL ,
  drug_concept_id				INTEGER			NOT NULL ,
  unit_concept_id				INTEGER			NOT NULL ,
  dose_value						FLOAT			  NOT NULL ,
  dose_era_start_date		DATE			  NOT NULL ,
  dose_era_end_date	    DATE			  NOT NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE OHDSI.condition_era
(
  condition_era_id				    NUMBER(19)			NOT NULL ,
  person_id						        NUMBER(19)			NOT NULL ,
  condition_concept_id			  INTEGER			NOT NULL ,
  condition_era_start_date		DATE			  NOT NULL ,
  condition_era_end_date			DATE			  NOT NULL ,
  condition_occurrence_count	INTEGER			NULL
)
;
