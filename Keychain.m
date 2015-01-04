//
// Keychain.h
//
// Based on code by Michael Mayo at http://overhrd.com/?p=208
//
// Created by Frank Kim on 1/3/11.
//

#import "Keychain.h"
#import <Security/Security.h>
//#import "SyncplicityLog.h"

//#define KEYCHAIN_IDENTIFIER @"VMMS9Z6ZQC.com.syncplicity.ios.syncplicity"
#define KEYCHAIN_IDENTIFIER @"PYR923S5V2.com.pavan.dev"

@implementation Keychain

+ (void)saveString:(NSString *)inputString forKey:(NSString	*)account {
	NSAssert(account != nil, @"Invalid account");
	NSAssert(inputString != nil, @"Invalid string");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[query setObject:account forKey:(id)kSecAttrAccount];
	[query setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
	
	OSStatus error = SecItemCopyMatching((CFDictionaryRef)query, NULL);
	if (error == errSecSuccess) {
		// do update
        NSDictionary *attributesToUpdate = [NSDictionary dictionaryWithObject:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
        
//        @{(id)kSecValueData: [inputString dataUsingEncoding:NSUTF8StringEncoding],
//          (id)kSecAttrAccessGroup: (id)KEYCHAIN_IDENTIFIER};
        
       // [NSDictionary dictionaryWithObject:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
		
        
        [query setObject:KEYCHAIN_IDENTIFIER forKey:(id)kSecAttrAccessGroup];
        
		error = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributesToUpdate);
		NSAssert1(error == errSecSuccess, @"SecItemUpdate failed: %ld", error);
	} else if (error == errSecItemNotFound) {
		// do add
		[query setObject:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
        [query setObject:KEYCHAIN_IDENTIFIER forKey:(id)kSecAttrAccessGroup];
        
		error = SecItemAdd((CFDictionaryRef)query, NULL);
		NSAssert1(error == errSecSuccess, @"SecItemAdd failed: %ld", error);
	} else {
		NSAssert1(NO, @"SecItemCopyMatching failed: %ld", error);
	}
}

+ (NSString *)getStringForKey:(NSString *)account {
	NSAssert(account != nil, @"Invalid account");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[query setObject:account forKey:(id)kSecAttrAccount];
	[query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [query setObject:KEYCHAIN_IDENTIFIER forKey:(id)kSecAttrAccessGroup];
    
	NSData *dataFromKeychain = nil;
    
	OSStatus error = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&dataFromKeychain);
	
	NSString *stringToReturn = nil;
	if (error == errSecSuccess) {
		stringToReturn = [[[NSString alloc] initWithData:dataFromKeychain encoding:NSUTF8StringEncoding] autorelease];
	}
	
	[dataFromKeychain release];
	
	return stringToReturn;
}

+ (void)deleteStringForKey:(NSString *)account {
	NSAssert(account != nil, @"Invalid account");
    
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[query setObject:account forKey:(id)kSecAttrAccount];
    
	OSStatus status = SecItemDelete((CFDictionaryRef)query);
	if (status != errSecSuccess) {
		NSLog(@"SecItemDelete for %@ failed: %ld", account, status);
	}
}

+ (NSString *)bundleSeedID {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess)
        return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    CFRelease(result);
    return bundleSeedID;
}

+ (NSArray *)getAllKeys {
    
    NSString *bundleSeedId = [Keychain bundleSeedID];
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(id)kSecClass] = (id)kSecClassGenericPassword;
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;
    query[(id)kSecMatchLimit] = (id)kSecMatchLimitAll;
    query[(id)kSecAttrAccessGroup] = (id)KEYCHAIN_IDENTIFIER;
    
//    [query setObject:KEYCHAIN_IDENTIFIER forKey:(id)kSecAttrAccessGroup];
    
    // get search results
    CFArrayRef result = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef*)&result);
    if (status == -25300) return @[]; // nothing found
    if (status != 0) {
        //At the next step we will get the crash. Let's put as many debug info as possible. As per Anand hiding the crash may provide unexpected behavior
        NSLog(@"****** ERROR to investigate*****");
//        NSLog(@"OS version is %@", [UIDevice currentDevice].systemVersion);
        NSLog(@"Status = %i", status);
        NSLog(@"Error happened for query: %@", query);
        NSLog(@"Call stack: %@", [NSThread callStackSymbols]);
        NSLog(@"Result array: %@", result);
        
        //Now let's just try it again to provide some additional info
        result = nil;
        status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef*)&result);
        NSLog(@"We just tried it again and got these results");
        NSLog(@"Status = %i", status);
        NSLog(@"Result array: %@", result);
    }
    assert(status == 0);
    
    return (NSArray*)result;
}

+ (void)deleteAllKeys {
	NSArray *allItems = [self getAllKeys];
    NSMutableArray *keysToDelete = [NSMutableArray arrayWithCapacity:[allItems count]];
    for (NSDictionary *item in allItems) {
        NSLog(@"%@", item);
        [keysToDelete addObject:[item[@"acct"] copy]];
    }
    
    for (NSString *key in keysToDelete) {
        [self deleteStringForKey:key];
    }
}

+ (BOOL)key:(NSString*)key startsWith:(NSString*)begin {
    NSRange r = [key rangeOfString:begin];
    return (r.location == 0);
}

+ (void)deleteCredentialKeys {
	NSArray *allItems = [self getAllKeys];
    NSMutableArray *keysToDelete = [NSMutableArray arrayWithCapacity:[allItems count]];
    for (NSDictionary *item in allItems) {
        NSLog(@"%@", item);
        [keysToDelete addObject:[item[@"acct"] copy]];
    }
    
//    for (NSString *key in keysToDelete) {
//        if ([self key:key startsWith:kUserSettings[kSettingMachineToken]] || // Syncplicity
//            [self key:key startsWith:kUserSettings[kSettingEmailAddress]] || // Syncplicity
//            [self key:key startsWith:@"credentialtoken|"] || // Sharepoint
//            [self key:key startsWith:@"sessiontoken|"] || // Sharepoint
//            [self key:key startsWith:@"token|"] || // RAN
//            [self key:key startsWith:@"password|"] // RAN
//            ) {
//            [self deleteStringForKey:key];
//        }
//    }
}
@end