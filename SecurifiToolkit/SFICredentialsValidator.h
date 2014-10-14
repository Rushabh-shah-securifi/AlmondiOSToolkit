//
//  SFIPasswordValidator.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 13/10/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PWD_MIN_LENGTH 6
#define PWD_MAX_LENGTH 32

#define REGEX_PASSWORD_ONE_UPPERCASE @"^(?=.*[A-Z]).*$"  //Should contains one or more uppercase letters
#define REGEX_PASSWORD_ONE_LOWERCASE @"^(?=.*[a-z]).*$"  //Should contains one or more lowercase letters
#define REGEX_PASSWORD_ONE_NUMBER @"^(?=.*[0-9]).*$"  //Should contains one or more number
#define REGEX_PASSWORD_ONE_SYMBOL @"^(?=.*[!@#$%&_]).*$"  //Should contains one or more symbol
#define REGEX_EMAIL @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$"

typedef enum {
    PasswordStrengthTypeTooShort,
    PasswordStrengthTypeTooLong,
    PasswordStrengthTypeWeak,
    PasswordStrengthTypeModerate,
    PasswordStrengthTypeStrong
} PasswordStrengthType;

@interface SFICredentialsValidator : NSObject

- (PasswordStrengthType)validatePassword:(NSString *)strPassword;
- (BOOL)validateEmail:(NSString *)emailString;

@end
