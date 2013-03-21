#import "LUAPIModel.h"

/**
 `LUUserAddress` represents an address for a user, such as home or work.
 */
@interface LUUserAddress : LUAPIModel

/**
 The type of address, such as home, work or other.
 */
@property (nonatomic, copy) NSString *addressType;

/**
 An optional extended address, such as an apartment number.
 */
@property (nonatomic, copy) NSString *extendedAddress;

/**
 A town or city.
 */
@property (nonatomic, copy) NSString *locality;

/**
 The address's postal/zip code.
 */
@property (nonatomic, copy) NSString *postalCode;

/**
 The address's region, such as a state or province.
 */
@property (nonatomic, copy) NSString *region;

/**
 The street address, such as "123 Main St.".
 */
@property (nonatomic, copy) NSString *streetAddress;

/**
 Specifies if this address is of the type "home".
 */
- (BOOL)isHomeAddress;

/**
 Specifies if this address is of the type "other".
 */
- (BOOL)isOtherAddress;

/**
 Specifies if this address is of the type "work".
 */
- (BOOL)isWorkAddress;

@end