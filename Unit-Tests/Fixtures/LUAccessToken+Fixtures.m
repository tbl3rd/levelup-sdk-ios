#import "LUAccessToken+Fixtures.h"

@implementation LUAccessToken (Fixtures)

+ (NSDictionary *)fullJSONObject {
  return @{
    @"token" : @"access-token",
    @"user_id" : @1
  };
}

@end