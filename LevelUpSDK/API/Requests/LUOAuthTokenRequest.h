@class LUAPIRequest;
@class LUOAuthToken;

@interface LUOAuthTokenRequest : NSObject

+ (LUAPIRequest *)createOAuthToken:(LUOAuthToken *)oauthToken;

@end
