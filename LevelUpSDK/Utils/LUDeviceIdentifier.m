#import <CommonCrypto/CommonDigest.h>
#import "LUDeviceIdentifier.h"
#import "LUKeychainAccess.h"

@implementation LUDeviceIdentifier

#pragma mark - Public Methods

+ (NSString *)deviceIdentifier {
  static NSString * const DeviceIdentifierKey = @"LUDeviceIdentifier";

  NSString *deviceIdentifier = [LUKeychainAccess stringForKey:DeviceIdentifierKey];

  if (deviceIdentifier == nil) {
    deviceIdentifier = [self generateUUID];

    [LUKeychainAccess saveString:deviceIdentifier forKey:DeviceIdentifierKey];
  }

  return deviceIdentifier;
}

#pragma mark - Private Methods

+ (NSString *)generateUUID {
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);

  NSString *rawUUIDStr = [NSString stringWithString:(__bridge NSString *)uuidString];
  CFRelease(uuidString);

  // MD5 hash the UUID
  unsigned char digest[CC_MD5_DIGEST_LENGTH];

  CC_MD5((__bridge const void *)([rawUUIDStr dataUsingEncoding:NSASCIIStringEncoding]), [rawUUIDStr length], digest);
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [output appendFormat:@"%02x", digest[i]];
  }

  return [NSString stringWithString:output];
}

@end