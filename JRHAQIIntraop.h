//
//  JRHPatientConsent.h
//  eps
//
//  Created by Jim Hurst on 11/12/14.
//  
//  Header file for Anesthesia Quality Institute Intraoperative report data model. This is just a list of variables 
//  used to capture intraoperative adverse events, and communicate them with the LAMP back end. Not much to see: a 
//  list of variable names, and method declarations.

#import <Foundation/Foundation.h>

@interface JRHAQIIntraop : NSObject

@property (assign, nonatomic) NSInteger encounterId;
@property (assign, nonatomic) NSInteger patientId;
@property (strong, nonatomic) NSString *aqi_intra_account_number;
@property (strong, nonatomic) NSString *aqi_intra_date_of_service;
@property (strong, nonatomic) NSString *aqi_intra_mrn;
@property (strong, nonatomic) NSString *aqi_intra_asa_class;
@property (strong, nonatomic) NSString *aqi_intra_anesthesia_type;
@property (strong, nonatomic) NSString *aqi_intra_provider_id;
@property (strong, nonatomic) NSString *aqi_intra_crna_id;
@property (strong, nonatomic) NSString *aqi_intra_additional_provider;
@property (strong, nonatomic) NSString *aqi_intra_no_adverse_outcomes;
@property (strong, nonatomic) NSString *aqi_intra_death;
@property (strong, nonatomic) NSString *aqi_intra_case_cancelled;
@property (strong, nonatomic) NSString *aqi_intra_unplanned_icu;
@property (strong, nonatomic) NSString *aqi_intra_unplanned_outpatient_admission;
@property (strong, nonatomic) NSString *aqi_intra_incorrect_site;
@property (strong, nonatomic) NSString *aqi_intra_incorrect_patient;
@property (strong, nonatomic) NSString *aqi_intra_incorrect_procedure;
@property (strong, nonatomic) NSString *aqi_intra_cardiac_arrest;
@property (strong, nonatomic) NSString *aqi_intra_provider_name;
@property (strong, nonatomic) NSString *aqi_intra_crna_name;
@property (strong, nonatomic) NSString *aqi_intra_procedure_description;
@property (strong, nonatomic) NSString *aqi_intra_procedure_code;
@property (strong, nonatomic) NSString *aqi_intra_new_pvcs;
@property (strong, nonatomic) NSString *aqi_intra_myocardial_ischemia;
@property (strong, nonatomic) NSString *aqi_intra_hypotension;
@property (strong, nonatomic) NSString *aqi_intra_pulmonary_edema;
@property (strong, nonatomic) NSString *aqi_intra_difficult_airway;
@property (strong, nonatomic) NSString *aqi_intra_inability_to_secure_airway;
@property (strong, nonatomic) NSString *aqi_intra_unplanned_reintubation;
@property (strong, nonatomic) NSString *aqi_intra_respiratory_arrest;
@property (strong, nonatomic) NSString *aqi_intra_aspiration;
@property (strong, nonatomic) NSString *aqi_intra_laryngospasm;
@property (strong, nonatomic) NSString *aqi_intra_brochospasm;
@property (strong, nonatomic) NSString *aqi_intra_anaphylaxis;
@property (strong, nonatomic) NSString *aqi_intra_adverse_reaction;
@property (strong, nonatomic) NSString *aqi_intra_malignant_hypothermia;
@property (strong, nonatomic) NSString *aqi_intra_transfusion_reaction;
@property (strong, nonatomic) NSString *aqi_intra_medication_error;
@property (strong, nonatomic) NSString *aqi_intra_reversal_agents;
@property (strong, nonatomic) NSString *aqi_intra_muscular_blockade;
@property (strong, nonatomic) NSString *aqi_intra_delayed_emergence;
@property (strong, nonatomic) NSString *aqi_intra_vessel_injury;
@property (strong, nonatomic) NSString *aqi_intra_pneumothorax;
@property (strong, nonatomic) NSString *aqi_intra_high_spinal;
@property (strong, nonatomic) NSString *aqi_intra_systemic_toxicity;
@property (strong, nonatomic) NSString *aqi_intra_failed_regional;
@property (strong, nonatomic) NSString *aqi_intra_dural_puncture;
@property (strong, nonatomic) NSString *aqi_intra_seizure;
@property (strong, nonatomic) NSString *aqi_intra_unanticipated_transfusion;
@property (strong, nonatomic) NSString *aqi_intra_surgical_fire;
@property (strong, nonatomic) NSString *aqi_intra_burn_injury;
@property (strong, nonatomic) NSString *aqi_intra_equipment_failure;
@property (strong, nonatomic) NSString *aqi_intra_equipment_unavailability;
@property (strong, nonatomic) NSString *aqi_intra_fall;
@property (strong, nonatomic) NSString *aqi_intra_positioning_injury;
@property (strong, nonatomic) NSString *aqi_intra_code_call;
@property (strong, nonatomic) NSString *aqi_intra_other_events;
@property (strong, nonatomic) NSString *aqi_intra_forced_warming;
@property (strong, nonatomic) NSString *aqi_intra_informed_consent;
@property (strong, nonatomic) NSString *aqi_intra_who_checklist;
@property (strong, nonatomic) NSString *aqi_intra_antibiotics_completed;
@property (strong, nonatomic) NSString *aqi_intra_toc_icu;
@property (strong, nonatomic) NSString *aqi_intra_toc_pacu;
@property (strong, nonatomic) NSString *aqi_intra_toc_patient_id;
@property (strong, nonatomic) NSString *aqi_intra_toc_provider_id;
@property (strong, nonatomic) NSString *aqi_intra_toc_history;
@property (strong, nonatomic) NSString *aqi_intra_toc_procedure;
@property (strong, nonatomic) NSString *aqi_intra_toc_intraop;
@property (strong, nonatomic) NSString *aqi_intra_toc_expectations;
@property (strong, nonatomic) NSString *aqi_intra_toc_questions;
@property (nonatomic, strong) NSArray *procedureArray;


- (void) loadWithEncounterId:(NSInteger)encounterId completion:(void (^)(JRHAQIIntraop *,NSError *))completion;
- (void) addProcedure:(NSInteger) encounterId description:(NSString *)description code:(NSString *)code timeRecorded:(NSString *)timeRecorded completion:(void (^)(NSError *))completion;
-(void) deleteItemForEncounterId:(NSInteger)encounterId description:(NSString *)description completion:(void(^)(NSError *error)) completion;

@end
