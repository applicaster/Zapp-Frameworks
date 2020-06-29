//
//  Keychain.m
//  OpenStack
//
//  Based on KeychainWrapper in BadassVNC by Dylan Barrie
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Keychain.h"
@import Security;
@import ZappCore;

@implementation Keychain

+ (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key {
	if (string == nil || key == nil) {
		return NO;
	}
    
    key = [NSString stringWithFormat:@"%@ - %@", [Keychain bundleIdentifier], key];
    
	// First check if it already exists, by creating a search dictionary and requesting that 
    // nothing be returned, and performing the search anyway.
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	[existsQueryDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[existsQueryDictionary setObject:(id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(id)kSecAttrAccessible];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(id)kSecAttrAccount];
    
	OSStatus res = SecItemCopyMatching((CFDictionaryRef)existsQueryDictionary, NULL);
	if (res == errSecItemNotFound) {
		NSMutableDictionary *addDict = existsQueryDictionary;
		[addDict setObject:data forKey:(id)kSecValueData];
		
		res = SecItemAdd((CFDictionaryRef)addDict, NULL);
		NSAssert1(res == errSecSuccess, @"Recieved %ld from SecItemAdd!", (long)res);
	} else if (res == errSecSuccess) {
		// Modify an existing one
		// Actually pull it now of the keychain at this point.
		NSDictionary *attributeDict = [NSDictionary dictionaryWithObject:data forKey:(id)kSecValueData];
        
		res = SecItemUpdate((CFDictionaryRef)existsQueryDictionary, (CFDictionaryRef)attributeDict);
		NSAssert1(res == errSecSuccess, @"SecItemUpdated returned %ld!", (long)res);
	} else {
		NSAssert1(NO, @"Received %ld from SecItemCopyMatching!", (long)res);
	}
	
	return YES;
}

+ (BOOL)deleteStringForKey:(NSString *)key {
	if (key == nil) {
		return NO;
	}
    
    key = [NSString stringWithFormat:@"%@ - %@", [Keychain bundleIdentifier], key];
    
	// First check if it already exists, by creating a search dictionary and requesting that 
    // nothing be returned, and performing the search anyway.
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	
	[existsQueryDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[existsQueryDictionary setObject:(id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(id)kSecAttrAccessible];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(id)kSecAttrAccount];
    
	OSStatus res = SecItemCopyMatching((CFDictionaryRef)existsQueryDictionary, NULL);
	if (res == errSecSuccess) {
		res = SecItemDelete((CFDictionaryRef)existsQueryDictionary);
		NSAssert1(res == errSecSuccess, @"SecItemDelete returned %ld!", (long)res);
	} else if (res != errSecItemNotFound) {
		// If the item hasn't been found this won't occur.
		NSAssert1(NO, @"Received %ld from SecItemCopyMatching!", (long)res);
	}
	
	return YES;
}

+ (NSString *)getStringForKey:(NSString *)key {
    key = [NSString stringWithFormat:@"%@ - %@", [Keychain bundleIdentifier], key];
    
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	
	[existsQueryDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[existsQueryDictionary setObject:(id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(id)kSecAttrAccessible];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(id)kSecAttrAccount];
	
	// We want the data back!
	[existsQueryDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
    
    CFTypeRef dataTypeRef = NULL;
    OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)existsQueryDictionary, &dataTypeRef);
    NSData *data = (__bridge NSData *)dataTypeRef;
    
    if (res == errSecSuccess) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        NSAssert1(res == errSecItemNotFound, @"SecItemCopyMatching returned %ld!", (long)res);
    }
    
	
	return nil;
}

+ (BOOL)setObject:(id)object forKey:(NSString *)key
{
    key = [NSString stringWithFormat:@"%@ - %@", [Keychain bundleIdentifier], key];
    
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionary];
    [keychainQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [keychainQuery setObject:@"service" forKey:(id)kSecAttrService];
    [keychainQuery setObject:key forKey:(id)kSecAttrAccount];
    
    OSStatus res = SecItemCopyMatching((CFDictionaryRef)keychainQuery, NULL);
    if (res == errSecItemNotFound) {
        NSMutableDictionary *addDict = keychainQuery;
        [addDict setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:(id)kSecValueData];
        res = SecItemAdd((CFDictionaryRef)addDict, NULL);
        NSAssert1(res == errSecSuccess, @"Recieved %ld from SecItemAdd!", (long)res);
    }
    else if (res == errSecSuccess) {
        NSDictionary *attributeDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:(id)kSecValueData];
        SecItemUpdate((CFDictionaryRef)keychainQuery, (CFDictionaryRef)attributeDict);
        NSAssert1(res == errSecSuccess, @"SecItemUpdated returned %ld!", (long)res);
    }
    else {
        NSAssert1(NO, @"Received %ld from SecItemCopyMatching!", (long)res);
    }
    
    return YES;
}

+ (id)objectForKey:(NSString *)key
{
    key = [NSString stringWithFormat:@"%@ - %@", [Keychain bundleIdentifier], key];
    
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionary];
    [keychainQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [keychainQuery setObject:@"service" forKey:(id)kSecAttrService];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:key forKey:(id)kSecAttrAccount];
    
    CFTypeRef dataTypeRef = NULL;
    OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, &dataTypeRef);
    NSData *data = (__bridge NSData *)dataTypeRef;
    
    
    if (res == errSecSuccess) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else {
        NSAssert1(res == errSecItemNotFound, @"SecItemCopyMatching returned %ld!", (long)res);
    }
    
    return nil;
}

+ (BOOL)removeValueForKey:(NSString *)key
{
    key = [NSString stringWithFormat:@"%@ - %@", [Keychain bundleIdentifier], key];
    
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionary];
    [keychainQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [keychainQuery setObject:@"service" forKey:(id)kSecAttrService];
    [keychainQuery setObject:key forKey:(id)kSecAttrAccount];
    
    OSStatus res = SecItemDelete((CFDictionaryRef)keychainQuery);
    
    if (res != errSecSuccess) {
        NSAssert1(NO, @"Received %ld from SecItemCopyMatching!", (long)res);
    }
    
    return YES;
}

@end
