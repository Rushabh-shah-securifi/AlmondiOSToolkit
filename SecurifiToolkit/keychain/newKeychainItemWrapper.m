#import "KeychainItemWrapper.h"

@interface KeychainItemWrapper ()
@property(nonatomic, strong) NSMutableDictionary *genericPasswordQuery;
@property(nonatomic, strong) NSMutableDictionary *keychainItemData;
@end

/*

These are the default constants and their respective types,
available for the kSecClassGenericPassword Keychain Item class:

kSecAttrAccessGroup			-		CFStringRef
kSecAttrCreationDate		-		CFDateRef
kSecAttrModificationDate    -		CFDateRef
kSecAttrDescription			-		CFStringRef
kSecAttrComment				-		CFStringRef
kSecAttrCreator				-		CFNumberRef
kSecAttrType                -		CFNumberRef
kSecAttrLabel				-		CFStringRef
kSecAttrIsInvisible			-		CFBooleanRef
kSecAttrIsNegative			-		CFBooleanRef
kSecAttrAccount				-		CFStringRef
kSecAttrService				-		CFStringRef
kSecAttrGeneric				-		CFDataRef
 
See the header file Security/SecItem.h for more details.

*/

@implementation KeychainItemWrapper

- (id)initWithIdentifier:(NSString *)identifier accessGroup:(NSString *)accessGroup; {
    if (self = [super init]) {
        // Begin Keychain search setup. The genericPasswordQuery leverages the special user
        // defined attribute kSecAttrGeneric to distinguish itself between other generic Keychain
        // items which may be included by the same application.
        self.genericPasswordQuery = [[NSMutableDictionary alloc] init];

        self.genericPasswordQuery[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;
        self.genericPasswordQuery[(__bridge id) kSecAttrGeneric] = identifier;

        // The keychain access group attribute determines if this item can be shared
        // amongst multiple apps whose code signing entitlements contain the same keychain access group.
        if (accessGroup != nil) {
#if TARGET_IPHONE_SIMULATOR
			// Ignore the access group if running on the iPhone simulator.
			// 
			// Apps that are built for the simulator aren't signed, so there's no keychain access group
			// for the simulator to check. This means that all apps can see all keychain items when run
			// on the simulator.
			//
			// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
			// simulator will return -25243 (errSecNoAccessForItem).
#else
            self.genericPasswordQuery[(__bridge id) kSecAttrAccessGroup] = accessGroup;
#endif
        }

        // Use the proper search constants, return only the attributes of the first match.
        self.genericPasswordQuery[(__bridge id) kSecMatchLimit] = (__bridge id) kSecMatchLimitOne;
        self.genericPasswordQuery[(__bridge id) kSecReturnAttributes] = (__bridge id) kCFBooleanTrue;

        NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:self.genericPasswordQuery];

        CFTypeRef attributes = NULL;
        if (!SecItemCopyMatching((__bridge CFDictionaryRef) tempQuery, &attributes) == noErr) {
            // Stick these default values into keychain item if nothing found.
            [self resetKeychainItem];

            // Add the generic attribute and the keychain access group.
            self.keychainItemData[(__bridge id) kSecAttrGeneric] = identifier;
            if (accessGroup != nil) {
#if TARGET_IPHONE_SIMULATOR
				// Ignore the access group if running on the iPhone simulator.
				// 
				// Apps that are built for the simulator aren't signed, so there's no keychain access group
				// for the simulator to check. This means that all apps can see all keychain items when run
				// on the simulator.
				//
				// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
				// simulator will return -25243 (errSecNoAccessForItem).
#else
                self.keychainItemData[(__bridge id) kSecAttrAccessGroup] = accessGroup;
#endif
            }
        }
        else {
            // load the saved data from Keychain.
            NSDictionary *outDictionary = (__bridge NSDictionary*)attributes;
            self.keychainItemData = [self secItemFormatToDictionary:outDictionary];
        }
    }

    return self;
}

- (void)setObject:(id)inObject forKey:(id)key {
    if (inObject == nil) {return;}
    id currentObject = [self.keychainItemData objectForKey:key];
    if (![currentObject isEqual:inObject]) {
        self.keychainItemData[key] = inObject;
        [self writeToKeychain];
    }
}

- (id)objectForKey:(id)key {
    return self.keychainItemData[key];
}

- (void)resetKeychainItem {
    if (!self.keychainItemData) {
        self.keychainItemData = [[NSMutableDictionary alloc] init];
    }
    else if (self.keychainItemData) {
        NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:self.keychainItemData];

        OSStatus junk = SecItemDelete((__bridge CFDictionaryRef) tempDictionary);
        NSAssert(junk == noErr || junk == errSecItemNotFound, @"Problem deleting current dictionary.");
    }

    // Default attributes for keychain item.
    self.keychainItemData[(__bridge id) kSecAttrAccount] = @"";
    self.keychainItemData[(__bridge id) kSecAttrLabel] = @"";
    self.keychainItemData[(__bridge id) kSecAttrDescription] = @"";

    // Default data for keychain item.
    self.keychainItemData[(__bridge id) kSecValueData] = @"";
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert {
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for a SecItem.

    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

    // Add the Generic Password keychain item class attribute.
    [returnDictionary setObject:(__bridge id) kSecClassGenericPassword forKey:(__bridge id) kSecClass];

    // Convert the NSString to NSData to meet the requirements for the value type kSecValueData.
    // This is where to store sensitive data that should be encrypted.
    NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id) kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id) kSecValueData];

    return returnDictionary;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert {
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for the UI element.

    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

    // Add the proper search key and class attribute.
    returnDictionary[(__bridge id) kSecReturnData] = (__bridge id) kCFBooleanTrue;
    returnDictionary[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;

    // Acquire the password data from the attributes.
    CFTypeRef passwordData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef) returnDictionary, &passwordData) == noErr) {
        // Remove the search, class, and identifier key/value, we don't need them anymore.
        [returnDictionary removeObjectForKey:(__bridge id) kSecReturnData];

        // Add the password to the dictionary, converting from NSData to NSString.
        NSData *data = (__bridge NSData *)passwordData;
        NSString *password = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        returnDictionary[(__bridge id) kSecValueData] = password;
    }
    else {
        // Don't do anything if nothing is found.
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }

    return returnDictionary;
}

- (void)writeToKeychain {
    NSMutableDictionary *keychainData = [self dictionaryToSecItemFormat:self.keychainItemData];

    CFTypeRef attributes = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef) self.genericPasswordQuery, &attributes) == noErr) {
        // First we need the attributes from the Keychain.
        NSDictionary *dict = (__bridge NSDictionary*) attributes;
        NSMutableDictionary *updateItem = [NSMutableDictionary dictionaryWithDictionary:dict];
        // Second we need to add the appropriate search key/values.
        updateItem[(__bridge id) kSecClass] = self.genericPasswordQuery[(__bridge id) kSecClass];

        // Lastly, we need to set up the updated attribute list being careful to remove the class.
        NSMutableDictionary *tempCheck = keychainData;
        [tempCheck removeObjectForKey:(__bridge id) kSecClass];

#if TARGET_IPHONE_SIMULATOR
		// Remove the access group if running on the iPhone simulator.
		// 
		// Apps that are built for the simulator aren't signed, so there's no keychain access group
		// for the simulator to check. This means that all apps can see all keychain items when run
		// on the simulator.
		//
		// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
		// simulator will return -25243 (errSecNoAccessForItem).
		//
		// The access group attribute will be included in items returned by SecItemCopyMatching,
		// which is why we need to remove it before updating the item.
		[tempCheck removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif

        // An implicit assumption is that you can only update a single item at a time.

        OSStatus result = SecItemUpdate((__bridge CFDictionaryRef) updateItem, (__bridge CFDictionaryRef) tempCheck);
        NSAssert(result == noErr, @"Couldn't update the Keychain Item.");
    }
    else {
        // No previous item found; add the new one.
        OSStatus result = SecItemAdd((__bridge CFDictionaryRef) keychainData, NULL);
        NSAssert(result == noErr, @"Couldn't add the Keychain Item.");
    }
}

@end
