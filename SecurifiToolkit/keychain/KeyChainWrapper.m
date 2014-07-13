//
//  KeyChainWrapper.m
//
// KeyChain wrapper by Stephen Anderson is licensed under 
// a Creative Commons Attribution-ShareAlike 3.0 Unported License.
// Permissions beyond the scope of this license may be available at 
// ruralcoder.com.

#import "KeyChainWrapper.h"
#import "SecurifiCloudResources-Prefix.pch"


@implementation KeyChainWrapper

+ (NSString *)keyChainErrorToString:(OSStatus)status {
    switch (status) {
        case errSecSuccess:
            return @"errSecSuccess: No error";

        case errSecUnimplemented:
            return @"errSecUnimplemented: Function or operation not implemented.";

        case errSecParam:
            return @"errSecParam: One or more parameters passed to the function were not valid.";

        case errSecAllocate:
            return @"errSecAllocate: Failed to allocate memory.";

        case errSecNotAvailable:
            return @"errSecNotAvailable: No trust results are available.";

        case errSecDuplicateItem:
            return @"errSecDuplicateItem: The item already exists.";

        case errSecItemNotFound:
            return @"errSecItemNotFound: The item cannot be found.";

        case errSecInteractionNotAllowed:
            return @"errSecInteractionNotAllowed: Interaction with the Security Server is not allowed.";

        case errSecDecode:
            return @"errSecDecode: Unable to decode the provided data.";

        default:
            return @"Unknown error from KeyChain services.";
    }
}


+ (NSMutableDictionary *)createSearchQueryForUser:(NSString *)userEmail forService:(NSString *)service {
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];

    query[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;
    query[(__bridge id) kSecAttrService] = service;
    query[(__bridge id) kSecAttrAccount] = userEmail;

    return query;
}


+ (void)printAttributes:(NSDictionary *)attributes {
    NSArray *keys = [attributes allKeys];
    for (NSString *key in keys) {
        NSLog(@"    %@ = %@", key, [attributes objectForKey:key]);
    }
}


+ (NSDictionary *)searchForUserEmail:(NSString *)userEmail forService:(NSString *)service {
    NSMutableDictionary *searchQuery = [KeyChainWrapper createSearchQueryForUser:userEmail forService:service];
    searchQuery[(__bridge id) kSecReturnAttributes] = (id) kCFBooleanTrue;
    searchQuery[(__bridge id) kSecMatchLimit] = (__bridge id) kSecMatchLimitOne;

    CFDataRef searchResults = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, (CFTypeRef *)&searchResults);

    if (status != errSecSuccess) {
        DLog(@"%s: userEmail: '%@'  service: '%@'", __PRETTY_FUNCTION__, userEmail, service);
        DLog(@"    KeyChain status: %@", [KeyChainWrapper keyChainErrorToString:status]);
        return nil;
    }

    NSDictionary *results = [NSDictionary dictionaryWithDictionary:(__bridge NSDictionary*) searchResults];
    CFRelease(searchResults);
    return results;
}


+ (BOOL)createEntryForUser:(NSString *)userEmail entryValue:(NSString *)entryValue forService:(NSString *)service {
    NSDictionary *searchResults = [KeyChainWrapper searchForUserEmail:userEmail forService:service];

    if (searchResults != nil) {
        [KeyChainWrapper removeEntryForUserEmail:userEmail forService:service];
    }

    NSData *encodedValue = [entryValue dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableDictionary *searchQuery = nil;
    searchQuery = [KeyChainWrapper createSearchQueryForUser:userEmail forService:service];
    searchQuery[(__bridge id) kSecValueData] = encodedValue;
    searchQuery[(__bridge id) kSecAttrAccessible] = (__bridge id) kSecAttrAccessibleWhenUnlockedThisDeviceOnly;

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) searchQuery, NULL);
    if (status != errSecSuccess) {
        DLog(@"%s: userEmail: '%@'  service: '%@'", __PRETTY_FUNCTION__, userEmail, service);
        DLog(@"    KeyChain status: %@", [KeyChainWrapper keyChainErrorToString:status]);
        [self printAttributes:searchQuery];
    }

    return (status == errSecSuccess);
}


+ (NSString *)retrieveEntryForUser:(NSString *)userEmail forService:(NSString *)service {
    NSMutableDictionary *searchQuery = [KeyChainWrapper createSearchQueryForUser:userEmail forService:service];
    searchQuery[(__bridge id) kSecReturnData] = (id) kCFBooleanTrue;

    CFTypeRef entryDataRef = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) searchQuery, &entryDataRef);

    if (status != errSecSuccess) {
        DLog(@"%s: userEmail: '%@'  service: '%@'", __PRETTY_FUNCTION__, userEmail, service);
        DLog(@"    KeyChain status: %@", [KeyChainWrapper keyChainErrorToString:status]);
        return nil;
    }

    NSData *data = (__bridge_transfer NSData*) entryDataRef;
    NSString *decodedValue = [[NSString alloc] initWithBytes:[data bytes]
                                                      length:[data length]
                                                    encoding:NSUTF8StringEncoding];

    return decodedValue;
}


+ (BOOL)isEntryStoredForUserEmail:(NSString *)userEmail forService:(NSString *)service {
    NSMutableDictionary *searchQuery = [KeyChainWrapper createSearchQueryForUser:userEmail forService:service];
    searchQuery[(__bridge id) kSecReturnData] = (id) kCFBooleanTrue;

    CFTypeRef entryDataRef = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, &entryDataRef);

    if (status != errSecSuccess && status != errSecItemNotFound) {
        DLog(@"%s: userEmail: '%@'  service: '%@'", __PRETTY_FUNCTION__, userEmail, service);
        DLog(@"    KeyChain status: %@", [KeyChainWrapper keyChainErrorToString:status]);
        [self printAttributes:searchQuery];
    }

    if (entryDataRef) {
        CFRelease(entryDataRef);
    }

    return (status == errSecSuccess);
}


+ (BOOL)removeEntryForUserEmail:(NSString *)userEmail forService:(NSString *)service {
    NSMutableDictionary *searchQuery = [KeyChainWrapper createSearchQueryForUser:userEmail forService:service];
    [searchQuery removeObjectForKey:(__bridge id) kSecValueData];

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) searchQuery);

    if (status != errSecSuccess && status != errSecItemNotFound) {
        DLog(@"%s: userEmail: '%@'  service: '%@'", __PRETTY_FUNCTION__, userEmail, service);
        DLog(@"KeyChain status: %@", [KeyChainWrapper keyChainErrorToString:status]);
        [self printAttributes:searchQuery];
    }

    return (status == errSecSuccess);
}


@end
