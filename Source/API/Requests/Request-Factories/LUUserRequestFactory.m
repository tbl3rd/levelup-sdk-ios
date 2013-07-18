#import "LUAccessTokenJSONFactory.h"
#import "LUAPIClient.h"
#import "LUAuthenticatedAPIRequest.h"
#import "LUDeviceIdentifier.h"
#import "LUUser.h"
#import "LUUserJSONFactory.h"
#import "LUUserParameterBuilder.h"
#import "LUUserRequestFactory.h"

@implementation LUUserRequestFactory

#pragma mark - Public Methods

+ (LUAPIRequest *)requestForCurrentUser {
  NSString *path = [NSString stringWithFormat:@"users/%@", [LUAPIClient sharedClient].currentUserID];

  return [LUAuthenticatedAPIRequest apiRequestWithMethod:@"GET"
                                                    path:path
                                              apiVersion:LUAPIVersion14
                                              parameters:nil
                                            modelFactory:[LUUserJSONFactory factory]];
}

+ (LUAPIRequest *)requestToConnectToFacebookWithAccessToken:(NSString *)facebookAccessToken {
  return [LUAuthenticatedAPIRequest apiRequestWithMethod:@"POST"
                                                    path:@"facebook_connections"
                                              apiVersion:LUAPIVersion14
                                              parameters:@{@"user" : @{@"facebook_access_token" : facebookAccessToken} }
                                            modelFactory:nil];
}

+ (LUAPIRequest *)requestToCreateUser:(LUUser *)user {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  params[@"client_id"] = [LUAPIClient sharedClient].apiKey;
  params[@"user"] = [LUUserParameterBuilder parametersForUser:user];

  return [LUAPIRequest apiRequestWithMethod:@"POST"
                                       path:@"users"
                                 apiVersion:LUAPIVersion14
                                 parameters:params
                               modelFactory:[LUUserJSONFactory factory]];
}

+ (LUAPIRequest *)requestToCreateUserWithFacebookAccessToken:(NSString *)facebookAccessToken {
  if (facebookAccessToken.length == 0) return nil;

  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  params[@"client_id"] = [LUAPIClient sharedClient].apiKey;
  params[@"user"] = [NSMutableDictionary dictionary];

  if ([LUDeviceIdentifier deviceIdentifier]) {
    params[@"user"][@"device_identifier"] = [LUDeviceIdentifier deviceIdentifier];
  }

  params[@"user"][@"facebook_access_token"] = facebookAccessToken;

  return [LUAPIRequest apiRequestWithMethod:@"POST"
                                       path:@"users"
                                 apiVersion:LUAPIVersion14
                                 parameters:params
                               modelFactory:[LUUserJSONFactory factory]];
}

+ (LUAPIRequest *)requestToDisconnectFromFacebook {
  return [LUAuthenticatedAPIRequest apiRequestWithMethod:@"DELETE"
                                                    path:@"facebook_connections"
                                              apiVersion:LUAPIVersion14
                                              parameters:nil
                                            modelFactory:nil];
}

+ (LUAPIRequest *)requestToResetPasswordWithEmail:(NSString *)email {
  return [LUAuthenticatedAPIRequest apiRequestWithMethod:@"POST"
                                                    path:@"users/forgot_password"
                                              apiVersion:LUAPIVersion13
                                              parameters:@{@"user" : @{@"email" : email}}
                                            modelFactory:nil];
}

+ (LUAPIRequest *)requestToUpdateUser:(LUUser *)user {
  NSString *path = [NSString stringWithFormat:@"users/%@", [LUAPIClient sharedClient].currentUserID];

  return [LUAuthenticatedAPIRequest apiRequestWithMethod:@"PUT"
                                                    path:path
                                              apiVersion:LUAPIVersion14
                                              parameters:@{@"user" : [LUUserParameterBuilder parametersForUser:user]}
                                            modelFactory:[LUUserJSONFactory factory]];
}

@end
