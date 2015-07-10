//
//  JRHAQIIntraop.m
//  eps
//
//  Created by Jim Hurst on 10/23/14.
//
//  Header file for Anesthesia Quality Institute Intraoperative report data model. This is just a list of variable 
//  used to capture intraoperative adverse events, and communicate them with the LAMP back end. There are three 
//  visible methods, one to read, one to create/update, and one to delete. They all operate asynchronously, so as not 
//  to block the gui main thread.

#import "JRHAQIIntraop.h"

@implementation JRHAQIIntraop

- (void) loadWithEncounterId:(NSInteger)encounterId completion:(void (^)(JRHAQIIntraop *,NSError *))completion
{
    NSString *userId = [NSString stringWithFormat:@"%ld", (long)SharedAppDelegate.currentUser.userId];
    NSString *pass = SharedAppDelegate.currentUser.passwordHash;
    
    NSString *requestString = [NSString stringWithFormat:@"{\"request_type\":\"8\",\"encounter_id\":\"%ld\", \"is_eps\" : \"1\"}", (long)encounterId];
    
    NSDictionary *parameters = @{@"user" : [NSString stringWithFormat:@"%@", userId], @"pass" : [NSString stringWithFormat:@"%@", pass], @"data" : requestString};
    
    JRHHTTPSessionManager *sharedSessionManager = [JRHHTTPSessionManager sharedManager];
    [sharedSessionManager POST:[NSString stringWithFormat:@"%@%@", kServerURL, kServerScriptController] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            self.encounterId = encounterId;
            //Wishlist:  Iterate through an array or plist to manage this.
            [self loadEncounterProceduresWithCompletion:^(NSError *error)
            {
                self.aqi_intra_account_number = responseObject[@"aqi_intra_account_number"];
                self.aqi_intra_date_of_service = responseObject[@"aqi_intra_date_of_service"];
                self.aqi_intra_mrn = responseObject[@"aqi_intra_mrn"];
                self.aqi_intra_asa_class = responseObject[@"aqi_intra_asa_class"];
                self.aqi_intra_anesthesia_type = responseObject[@"aqi_intra_anesthesia_type"];
                self.aqi_intra_provider_id = responseObject[@"aqi_intra_provider_id"];
                self.aqi_intra_crna_id = responseObject[@"aqi_intra_crna_id"];
                self.aqi_intra_additional_provider = responseObject[@"aqi_intra_additional_provider"];
                self.aqi_intra_no_adverse_outcomes = responseObject[@"aqi_intra_no_adverse_outcomes"];
                self.aqi_intra_case_cancelled = responseObject[@"aqi_intra_case_cancelled"];
                self.aqi_intra_unplanned_icu = responseObject[@"aqi_intra_unplanned_icu"];
                self.aqi_intra_unplanned_outpatient_admission = responseObject[@"aqi_intra_unplanned_outpatient_admission"];
                self.aqi_intra_incorrect_site = responseObject[@"aqi_intra_incorrect_site"];
                self.aqi_intra_incorrect_patient = responseObject[@"aqi_intra_incorrect_patient"];
                self.aqi_intra_incorrect_procedure = responseObject[@"aqi_intra_incorrect_procedure"];
                self.aqi_intra_cardiac_arrest = responseObject[@"aqi_intra_cardiac_arrest"];
                self.aqi_intra_provider_name = responseObject[@"aqi_intra_provider_name"];
                self.aqi_intra_crna_name = responseObject[@"aqi_intra_crna_name"];
                self.aqi_intra_procedure_description = responseObject[@"aqi_intra_procedure_description"];
                self.aqi_intra_procedure_code = responseObject[@"aqi_intra_procedure_code"];
                self.aqi_intra_new_pvcs = responseObject[@"aqi_intra_new_pvcs"];
                self.aqi_intra_myocardial_ischemia = responseObject[@"aqi_intra_myocardial_ischemia"];
                self.aqi_intra_hypotension = responseObject[@"aqi_intra_hypotension"];
                self.aqi_intra_pulmonary_edema = responseObject[@"aqi_intra_pulmonary_edema"];
                self.aqi_intra_difficult_airway = responseObject[@"aqi_intra_difficult_airway"];
                self.aqi_intra_inability_to_secure_airway = responseObject[@"aqi_intra_inability_to_secure_airway"];
                self.aqi_intra_unplanned_reintubation = responseObject[@"aqi_intra_unplanned_reintubation"];
                self.aqi_intra_respiratory_arrest = responseObject[@"aqi_intra_respiratory_arrest"];
                self.aqi_intra_aspiration = responseObject[@"aqi_intra_aspiration"];
                self.aqi_intra_laryngospasm = responseObject[@"aqi_intra_laryngospasm"];
                self.aqi_intra_brochospasm = responseObject[@"aqi_intra_bronchospasm"];
                self.aqi_intra_anaphylaxis = responseObject[@"aqi_intra_anaphylaxis"];
                self.aqi_intra_adverse_reaction = responseObject[@"aqi_intra_adverse_reaction"];
                self.aqi_intra_malignant_hypothermia = responseObject[@"aqi_intra_malignant_hypothermia"];
                self.aqi_intra_transfusion_reaction = responseObject[@"aqi_intra_transfusion_reaction"];
                self.aqi_intra_medication_error = responseObject[@"aqi_intra_medication_error"];
                self.aqi_intra_reversal_agents = responseObject[@"aqi_intra_reversal_agents"];
                self.aqi_intra_muscular_blockade = responseObject[@"aqi_intra_muscular_blockade"];
                self.aqi_intra_delayed_emergence = responseObject[@"aqi_intra_delayed_emergence"];
                self.aqi_intra_vessel_injury = responseObject[@"aqi_intra_vessel_injury"];
                self.aqi_intra_pneumothorax = responseObject[@"aqi_intra_pneumothorax"];
                self.aqi_intra_high_spinal = responseObject[@"aqi_intra_high_spinal"];
                self.aqi_intra_systemic_toxicity = responseObject[@"aqi_intra_systemic_toxicity"];
                self.aqi_intra_failed_regional = responseObject[@"aqi_intra_failed_regional"];
                self.aqi_intra_dural_puncture = responseObject[@"aqi_intra_dural_puncture"];
                self.aqi_intra_seizure = responseObject[@"aqi_intra_seizure"];
                self.aqi_intra_unanticipated_transfusion = responseObject[@"aqi_intra_unanticipated_transfusion"];
                self.aqi_intra_surgical_fire = responseObject[@"aqi_intra_surgical_fire"];
                self.aqi_intra_burn_injury = responseObject[@"aqi_intra_burn_injury"];
                self.aqi_intra_equipment_failure = responseObject[@"aqi_intra_equipment_failure"];
                self.aqi_intra_equipment_unavailability = responseObject[@"aqi_intra_equipment_unavailability"];
                self.aqi_intra_fall = responseObject[@"aqi_intra_fall"];
                self.aqi_intra_positioning_injury = responseObject[@"aqi_intra_positioning_injury"];
                self.aqi_intra_code_call = responseObject[@"aqi_intra_code_call"];
                self.aqi_intra_death = responseObject[@"aqi_intra_death"];
                self.aqi_intra_other_events = responseObject[@"aqi_intra_other_events"];
                self.aqi_intra_forced_warming = responseObject[@"aqi_intra_forced_warming"];
                self.aqi_intra_informed_consent = responseObject[@"aqi_intra_informed_consent"];
                self.aqi_intra_who_checklist = responseObject[@"aqi_intra_who_checklist"];
                self.aqi_intra_antibiotics_completed = responseObject[@"aqi_intra_antibiotics_completed"];
                self.aqi_intra_toc_icu = responseObject[@"aqi_intra_toc_icu"];
                self.aqi_intra_toc_pacu = responseObject[@"aqi_intra_toc_pacu"];
                self.aqi_intra_toc_patient_id = responseObject[@"aqi_intra_toc_patient_id"];
                self.aqi_intra_toc_provider_id = responseObject[@"aqi_intra_toc_provider_id"];
                self.aqi_intra_toc_history = responseObject[@"aqi_intra_toc_history"];
                self.aqi_intra_toc_procedure = responseObject[@"aqi_intra_toc_procedure"];
                self.aqi_intra_toc_intraop = responseObject[@"aqi_intra_toc_intraop"];
                self.aqi_intra_toc_expectations = responseObject[@"aqi_intra_toc_expectations"];
                self.aqi_intra_toc_questions = responseObject[@"aqi_intra_toc_questions"];
                completion(self, nil);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        completion(nil, error);
    }];
    
}

- (void) loadEncounterDataWithCompletion:(void (^)(NSError *))completion
{
    NSString *userId = [NSString stringWithFormat:@"%ld", (long)SharedAppDelegate.currentUser.userId];
    NSString *pass = SharedAppDelegate.currentUser.passwordHash;
    
    NSString *requestString = [NSString stringWithFormat:@"{\"request_type\":\"74\",\"encounter_id\":\"%ld\"}", (long)self.encounterId];
    
    NSDictionary *parameters = @{@"user" : [NSString stringWithFormat:@"%@", userId], @"pass" : [NSString stringWithFormat:@"%@", pass], @"data" : requestString};
    
    JRHHTTPSessionManager *sharedSessionManager = [JRHHTTPSessionManager sharedManager];
    [sharedSessionManager POST:[NSString stringWithFormat:@"%@%@", kServerURL, kServerScriptController] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        completion(error);
        
    }];
    
}

- (void) loadEncounterProceduresWithCompletion:(void (^)(NSError *))completion
{
    NSString *userId = [NSString stringWithFormat:@"%ld", (long)SharedAppDelegate.currentUser.userId];
    NSString *pass = SharedAppDelegate.currentUser.passwordHash;
    
    NSString *requestString = [NSString stringWithFormat:@"{\"request_type\":\"86\",\"encounter_id\":\"%ld\"}", (long)self.encounterId];
    
    NSDictionary *parameters = @{@"user" : [NSString stringWithFormat:@"%@", userId], @"pass" : [NSString stringWithFormat:@"%@", pass], @"data" : requestString};
    
    JRHHTTPSessionManager *sharedSessionManager = [JRHHTTPSessionManager sharedManager];
    [sharedSessionManager POST:[NSString stringWithFormat:@"%@%@", kServerURL, kServerScriptController] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ( (responseObject != nil) && ([responseObject isKindOfClass:[NSDictionary class]]) && ([responseObject count] > 0) )
        {
            NSArray *procedureObjects = (NSArray *)responseObject[@"procedures"];
            if (procedureObjects.count)
            {
                NSArray *procedureArray = procedureObjects[0];
                NSMutableArray *theArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSString *thisProcedure in procedureArray)
                {
                    [theArray addObject:thisProcedure];
                }
                self.procedureArray = theArray;
            }
        }
        completion(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        completion(error);
        
    }];
    
}

-(void) deleteItemForEncounterId:(NSInteger)encounterId description:(NSString *)description completion:(void(^)(NSError *error)) completion
{
    {
        NSString *userId = [NSString stringWithFormat:@"%ld", (long)SharedAppDelegate.currentUser.userId];
        NSString *pass = SharedAppDelegate.currentUser.passwordHash;
        NSString *newDescription = [JRHUtilities JSONString:description];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        
        NSString *requestString = [NSString stringWithFormat:@"{\"request_type\":\"85\",\"encounter_id\":\"%ld\",\"procedure_description\" : \"%@\",\"local_timestamp\" : \"%@\"}", (long)encounterId, newDescription, [dateFormatter stringFromDate:[NSDate date]]];
        
        NSDictionary *parameters = @{@"user" : [NSString stringWithFormat:@"%@", userId], @"pass" : [NSString stringWithFormat:@"%@", pass], @"data" : requestString};
        
        JRHHTTPSessionManager *sharedSessionManager = [JRHHTTPSessionManager sharedManager];
        [sharedSessionManager POST:[NSString stringWithFormat:@"%@%@", kServerURL, kServerScriptController] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completion(nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            completion(error);
        }];
    }
    
}

- (void) addProcedure:(NSInteger) encounterId description:(NSString *)description code:(NSString *)code timeRecorded:(NSString *)timeRecorded completion:(void (^)(NSError *))completion
{
    NSString *userId = [NSString stringWithFormat:@"%ld", (long)SharedAppDelegate.currentUser.userId];
    NSString *pass = SharedAppDelegate.currentUser.passwordHash;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSString *requestString = [NSString stringWithFormat:@"{\"request_type\":\"84\",\"encounter_id\":\"%ld\",\"procedure_description\" : \"%@\", \"procedure_code\" : \"%@\",\"local_timestamp\" : \"%@\", \"time_recorded\":\"%@\"}", (long)encounterId, description, code, [dateFormatter stringFromDate:[NSDate date]], timeRecorded];
    
    NSDictionary *parameters = @{@"user" : [NSString stringWithFormat:@"%@", userId], @"pass" : [NSString stringWithFormat:@"%@", pass], @"data" : requestString};
    
    JRHHTTPSessionManager *sharedSessionManager = [JRHHTTPSessionManager sharedManager];
    [sharedSessionManager POST:[NSString stringWithFormat:@"%@%@", kServerURL, kServerScriptController] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completion(error);
    }];
}

@end
