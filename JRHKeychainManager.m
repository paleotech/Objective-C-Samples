//
//  JRHKeychainManager.m
//
//  Created by Jim Hurst on 8/30/12.
//
//  JRHKeychainManager.m: a password synchronization object
//  This is a singleton object, used to synchronize passwords between the local store on the iPad and the backend LAMP server. Due to 
//  subleties in the business logic (ie, users have locations, and some users move around), synchronization must occur with or without
//  deleting local entries that are not in the list returned by the back end. The singleton object is initialized on startup. To log
//  in successfully, the user must be online, so that the KeychainManager can populate to local store. Password hashes are encrypted 
//  and stored in the local keychain. On subsequent logins, this object will be used to synchronize on a per-location basis with the 
//  back end server: the ipad reports a location,and the server responds with key-value pairs of usernames and password hashes. The
//  KeychainManager then tests those pairs against the local store, adding and deleting as needed. (If the user is a traveller, as
//  defined in JRHUser.m, the KeychainManager should not delete local users who are not in the list)

#import "JRHKeychainManager.h"
#import "JRHQueryManager.h"
#import "JRHUser.h"
#import "JRHSession.h"
#import <UIKit/UIKit.h>
#import <Security/Security.h>

#ifdef QA_BUILD
static NSString *serviceName = @"biz.yourCo.yourApp";
#else
static NSString *serviceName = @"biz.yourCo.yourAppQA";
#endif

#define TEST 0

@implementation JRHKeychainManager

+ (JRHKeychainManager*)sharedInstance {
    
	static JRHKeychainManager *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
        });
    }
    
    return _sharedInstance;
}

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    if (! identifier)
        return nil;
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];  
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSString *passwordKey = @"Password";
    NSData *encodedPasswordKey = [passwordKey dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedPasswordKey forKey:(__bridge id)kSecAttrGeneric];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    NSData *result = nil;
    CFDataRef outAttributes = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary,
                                          (CFTypeRef *)&outAttributes);
    result = (__bridge_transfer NSData *) outAttributes;
    
    return result;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    
    if (status == errSecSuccess) 
    {
        return YES;
    }
    return NO;
}

- (BOOL)deleteFromKeychain:(NSString *)identifier {
    
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];  
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
    
    if (status == errSecSuccess) 
    {
        return YES;
    }
    return NO;
}

- (NSMutableDictionary *)newUserDictionary
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];  
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSString *identifier = @"";
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

- (NSArray *)searchKeychainCopyAll
{
    
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];  
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    NSArray *result = nil;
    CFDataRef outAttributes = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary,
                                          (CFTypeRef *)&outAttributes);
    result = (__bridge_transfer NSArray *) outAttributes;
    
    return result;
}

-(NSString *)getHashForUser:(NSString *)username
{
    NSData *passwordData = [self searchKeychainCopyMatching:username];
    // If there is a match, the user exists.  Either everything is good, or we need to update the password.
    if (passwordData) 
    {
        NSString *password = [[NSString alloc] initWithData:passwordData
                                                   encoding:NSUTF8StringEncoding];
        return password;
    }
    return nil;
}

-(void)initialize:(NSArray *) jsonDict
{
    // First off, test to see if the a user has a value in the keychain.  If it does, do nothing.  If it
    // does not, add the known default users.
    NSData *aData = [self searchKeychainCopyMatching:@"a"];
    if ([aData length] > 0) 
    {
        NSString *pass = [[NSString alloc] initWithData:aData
                                                   encoding:NSUTF8StringEncoding];
        if ([pass length] > 0)
            return;

    }
    NSEnumerator *e = [jsonDict objectEnumerator];
    NSDictionary *theDict;
    while (theDict = [e nextObject]) 
    {
        NSString *theUser = [theDict objectForKey:@"username"];
        NSString *thePass = [theDict objectForKey:@"passhash"];
        // Save the list of users, since we're going to delete all users not in this list.
        // Get password from keychain (if it exists)  
        NSData *passwordData = [self searchKeychainCopyMatching:theUser];
        // If there is a match, the user exists.  Either everything is good, or we need to update the password.
        if (passwordData) 
        {
            NSString *password = [[NSString alloc] initWithData:passwordData
                                                       encoding:NSUTF8StringEncoding];
            // We got a password, now compare the array value to the keychain value
            if ([password isEqualToString:thePass])
            {
                // Everything checks out, nothing to do
            }
            else
            {
                // Mismatch.  Update the keychain password with the one downloaded.
                [self updateKeychainValue:thePass forIdentifier:theUser];
            }
        }
        // If there was no match, we need to add the user.
        else 
        {
            [self createKeychainValue:thePass forIdentifier:theUser];
	    
            // Now test it:
            NSData *roundTwo = [self searchKeychainCopyMatching:theUser];
            NSString *password2 = [[NSString alloc] initWithData:roundTwo encoding:NSUTF8StringEncoding];
        }
    }
    
    return;
}

-(void)updateDatabase:(NSDictionary *) theDict
{
    NSString *theUser = [theDict objectForKey:@"username"];
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [[JRHSession sharedInstance] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ar_user" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"username == %@", theUser];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *objects = [moc executeFetchRequest:request error:&error];
    // If you get nothing back from the query, insert the new record.
    if ((!objects) || ([objects count] == 0) )
    {
        Ar_user *aUser = (Ar_user *) [NSEntityDescription insertNewObjectForEntityForName:@"Ar_user" 
                                                                   inManagedObjectContext:moc];
        
        aUser.id = [NSNumber numberWithInteger:[[theDict objectForKey:@"id"] intValue]];
        aUser.username = [theDict objectForKey:@"username"];
        aUser.first_name = [theDict objectForKey:@"first_name"];
        aUser.last_name = [theDict objectForKey:@"last_name"];
        aUser.role = [theDict objectForKey:@"role"];
        aUser.passhash = @""; // Updated security posture: don't save it in the db anymore
        
        aUser.default_location = [NSNumber numberWithInteger:[[theDict objectForKey:@"default_location"] intValue]];
        
    }
    // If the record does exist, copy all the fields from the server (except ID) into the existing record.
    else 
    {
        Ar_user *thisObject = [objects objectAtIndex:0];
        thisObject.username = theUser;
        thisObject.id = [NSNumber numberWithInteger:[[theDict objectForKey:@"id"] intValue]];
        thisObject.first_name = [theDict objectForKey:@"first_name"];
        thisObject.last_name = [theDict objectForKey:@"last_name"];
        thisObject.role = [theDict objectForKey:@"role"];
        thisObject.passhash = @""; // Updated security posture: was assigned from [theDict objectForKey:@"passhash"];
        
        thisObject.default_location = [NSNumber numberWithInteger:[[theDict objectForKey:@"default_location"] intValue]];
    }
    if (![moc save:&error])
        NSLog(@"Error: %@", [error localizedFailureReason]);
}

-(void)deleteFromDatabase:(NSDictionary *) theDict
{
    NSString *theUser = [theDict objectForKey:@"username"];
    JRHSession *theSession = [JRHSession sharedInstance];
    NSManagedObjectContext *moc = theSession.managedObjectContext;
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ar_user" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"username == %@", theUser];
    [request setPredicate:predicate];

    // Execute the fetch.
    NSFetchedResultsController __block *fetched;
    fetched = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"Ar_user"];
    
    if (![fetched performFetch:&error])    
        NSLog(@"Error: %@", [error localizedFailureReason]);
    
    NSArray *objects = [moc executeFetchRequest:request error:&error];

    for (id theObject in objects)
    {
        [moc deleteObject:theObject];
        if (![moc save:&error])
            NSLog(@"JRHKeyChainManager:deleteFromDatabase Error: %@", [error localizedFailureReason]);
    }
}

-(void)synchronize:(NSInteger)locationId
{
    //NSArray *theUsers = [JRHUser getAvailableUsers];
    JRHQueryManager *theQM = [JRHQueryManager sharedInstance];
    NSArray *theUsers = [theQM getRemoteUsers:locationId];
    NSMutableArray *userList = [[NSMutableArray alloc] init];;
    
    if ([theUsers count] < 1)
        return;
    
    NSEnumerator *e = [theUsers objectEnumerator];
    NSDictionary *theDict;
    while (theDict = [e nextObject]) 
    {
        NSString *theUser = [theDict objectForKey:@"username"];
        NSString *thePass = [theDict objectForKey:@"passhash"];
        // Save the list of users, since we're going to delete all users not in this list.
        [userList addObject:theUser];
        
        // Get password from keychain (if it exists)  
        NSData *passwordData = [self searchKeychainCopyMatching:theUser];
        // If there is a match, the user exists.  Either everything is good, or we need to update the password.
        if (passwordData) 
        {
            NSString *password = [[NSString alloc] initWithData:passwordData
                                                       encoding:NSUTF8StringEncoding];
            
            // We got a password, now compare the array value to the keychain value
            if ([password isEqualToString:thePass])
            {
                // Everything checks out, but update the database on the chance that other fields differ, or to clear legacy data
                [self updateDatabase:theDict];
            }
            else
            {
                // Mismatch.  Update the keychain password with the one downloaded.
                [self updateKeychainValue:thePass forIdentifier:theUser];
                [self updateDatabase:theDict];
            }
        }
        // If there was no match, we need to add the user.
        else 
        {
            [self createKeychainValue:thePass forIdentifier:theUser];
            [self updateDatabase:theDict];
                
            // Now test it:
            NSData *roundTwo = [self searchKeychainCopyMatching:theUser];
            NSString *password2 = [[NSString alloc] initWithData:roundTwo encoding:NSUTF8StringEncoding];
        }
    }
    
    // Now it's time to delete any users that are not in the list downloaded from the server.
    NSArray *userData = [self searchKeychainCopyAll];

    for (id thisItem in userData)
    {
        if ([thisItem isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *thisDict = (NSDictionary *) thisItem;
            NSData *accountData = [thisDict objectForKey:@"acct"];
            NSString *accountString = [[NSString alloc] initWithData:accountData encoding:NSUTF8StringEncoding];
            
            // If this username was not in the list from the server, it needs to be deleted.
            if ([userList indexOfObject:accountString] == NSNotFound)
            {
                [self deleteFromKeychain:accountString];
                NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:accountString, @"username", nil];
                [self deleteFromDatabase:newDict];
            }
        }
        

    }
    // Now go through the DB, and delete every record that is not in userList.
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [[JRHSession sharedInstance] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ar_user" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *objects = [moc executeFetchRequest:request error:&error];
    for (id theObject in objects)
    {
        Ar_user *theUser = theObject;
        NSString *theUsername = theUser.username;
        // If this username was not in the list from the server, it needs to be deleted.
        if ([userList indexOfObject:theUsername] == NSNotFound)
        {
            [self deleteFromKeychain:theUsername];
            NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:theUsername, @"username", nil];
            [self deleteFromDatabase:newDict];
        }
    }
    return;
}

-(void)synchronizeWithoutDelete:(NSInteger)locationId
{
    JRHQueryManager *theQM = [JRHQueryManager sharedInstance];
    NSArray *theUsers = [theQM getRemoteUsers:locationId];
    NSMutableArray *userList = [[NSMutableArray alloc] init];;
    
    if ([theUsers count] < 1)
        return;
    
    NSEnumerator *e = [theUsers objectEnumerator];
    NSDictionary *theDict;
    while (theDict = [e nextObject])
    {
        NSString *theUser = [theDict objectForKey:@"username"];
        NSString *thePass = [theDict objectForKey:@"passhash"];
        // Save the list of users, since we're going to delete all users not in this list.
        [userList addObject:theUser];
        
        // Get password from keychain (if it exists)
        NSData *passwordData = [self searchKeychainCopyMatching:theUser];
        // If there is a match, the user exists.  Either everything is good, or we need to update the password.
        if (passwordData)
        {
            NSString *password = [[NSString alloc] initWithData:passwordData
                                                       encoding:NSUTF8StringEncoding];
            
            // We got a password, now compare the array value to the keychain value
            if ([password isEqualToString:thePass])
            {
                // Everything checks out, but update the database on the chance that other fields differ, or to clear legacy data
                [self updateDatabase:theDict];
            }
            else
            {
                // Mismatch.  Update the keychain password with the one downloaded.
                [self updateKeychainValue:thePass forIdentifier:theUser];
                [self updateDatabase:theDict];
            }
        }
        // If there was no match, we need to add the user.
        else
        {
            [self createKeychainValue:thePass forIdentifier:theUser];
            [self updateDatabase:theDict];
            
            // Now test it:
            NSData *roundTwo = [self searchKeychainCopyMatching:theUser];
            NSString *password2 = [[NSString alloc] initWithData:roundTwo encoding:NSUTF8StringEncoding];
        }
    }
    return;
}
@end
