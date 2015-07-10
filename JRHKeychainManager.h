//
//  JRHKeychainManager.h
//  eAR
//
//  Created by Jim Hurst on 8/30/12.
//
//  JRHKeychainManager.m: a password synchronization object
//  This is a singleton object, used to synchronize passwords between the local store on the iPad and the backend LAMP server. Due to 
//  subleties in the business logic (ie, users have locations, and some users move around), synchronization must occur with or without
//  deleting local entries that are not in the list returned by the back end.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JRHKeychainManager : NSObject

+ (JRHKeychainManager*) sharedInstance;
-(void)synchronize:(NSInteger)locationId;
-(void)synchronizeWithoutDelete:(NSInteger)locationId;
- (NSData *)searchKeychainCopyMatching:(NSString *)identifier;
-(NSString *)getHashForUser:(NSString *)username;
-(void)initialize:(NSArray *) jsonDict;
- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
-(void)updateDatabase:(NSDictionary *) theDict;
- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
@end
