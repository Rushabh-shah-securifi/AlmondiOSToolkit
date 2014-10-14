//
//  SFIPasswordValidator.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 13/10/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SFICredentialsValidator.h"

@implementation SFICredentialsValidator

#pragma mark - Password validation

- (PasswordStrengthType)validatePassword:(NSString *)strPassword {
    NSInteger len = strPassword.length;
    //will contains password strength
    int strength = 0;
    
    if (len == 0) {
        return PasswordStrengthTypeTooShort;
    }
    else if (len < PWD_MIN_LENGTH) {
        return PasswordStrengthTypeTooShort;
    }
    else if (len > PWD_MAX_LENGTH) {
        return PasswordStrengthTypeTooLong;
    }
    else if (len <= 9) {
        strength += 1;
    }
    else {
        strength += 2;
    }
    
    strength += [self validateString:strPassword withPattern:REGEX_PASSWORD_ONE_UPPERCASE caseSensitive:YES];
    strength += [self validateString:strPassword withPattern:REGEX_PASSWORD_ONE_LOWERCASE caseSensitive:YES];
    strength += [self validateString:strPassword withPattern:REGEX_PASSWORD_ONE_NUMBER caseSensitive:YES];
    strength += [self validateString:strPassword withPattern:REGEX_PASSWORD_ONE_SYMBOL caseSensitive:YES];
    
    if (strength < 3) {
        return PasswordStrengthTypeWeak;
    }
    else if (3 <= strength && strength < 6) {
        return PasswordStrengthTypeModerate;
    }
    else {
        return PasswordStrengthTypeStrong;
    }
}

// Validate the input string with the given pattern and
// return the result as a boolean
- (int)validateString:(NSString *)string withPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:((caseSensitive) ? 0 : NSRegularExpressionCaseInsensitive) error:&error];
    
    NSAssert(regex, @"Unable to create regular expression");
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:textRange];
    
    BOOL didValidate = 0;
    
    // Did we find a matching range
    if (matchRange.location != NSNotFound) {
        didValidate = 1;
    }
    
    return didValidate;
}

#pragma mark - Email validation
- (BOOL)validateEmail:(NSString *)emailString {
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:REGEX_EMAIL options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    if (regExMatches == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

@end
