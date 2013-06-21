#import "Kiwi.h"
#import "LUAPIClient.h"
#import "LUAPIRequest.h"
#import "LUAPIStub.h"
#import "LUAPIStubFactory.h"
#import "LUCauseAffiliation.h"
#import "LUCoreDataStack.h"
#import "LUKeychainAccess.h"
#import "LULocationCacheUpdater.h"
#import "NSDate+StringFormats.h"

NSString * const LUDeviceIdentifier = @"abcdefg";

@implementation LUAPIStubFactory

#pragma mark - Public Methods

+ (LUAPIStub *)stubToClaimLegacyLoyaltyWithID:(NSString *)loyaltyID campaignID:(NSNumber *)campaignID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[NSString stringWithFormat:@"loyalties/legacy/%@/claims", [campaignID stringValue]]
                           HTTPMethod:@"POST"
                        authenticated:NO
                         responseData:[self responseDataFromFile:@"legacy_loyalty_claim"]];
}

+ (LUAPIStub *)stubToCreateClaimForCohortCode:(NSString *)code {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion13
                                            path:@"users/1/claims"
                                      HTTPMethod:@"POST"
                                   authenticated:YES
                                    responseData:[self responseDataFromFile:@"claim"]];
  stub.requestBodyJSON = @{@"claim" : @{ @"cohort_code" : code } };
  return stub;
}

+ (LUAPIStub *)stubToCreateCreditCardWithNumber:(NSString *)number
                                            cvv:(NSString *)cvv
                                expirationMonth:(NSNumber *)expirationMonth
                                 expirationYear:(NSNumber *)expirationYear
                                     postalCode:(NSString *)postalCode {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion14
                                            path:@"credit_cards"
                                      HTTPMethod:@"POST"
                                   authenticated:YES
                                    responseData:[self responseDataFromFile:@"credit_card"]];
  stub.requestBodyJSON = @{
    @"credit_card" : @{
      @"encrypted_cvv" : cvv,
      @"encrypted_expiration_month" : [expirationMonth stringValue],
      @"encrypted_expiration_year" : [expirationYear stringValue],
      @"encrypted_number" : number,
      @"postal_code" : postalCode
    }
  };
  return stub;
}

+ (LUAPIStub *)stubToCreateGlobalClaimForCohortCode:(NSString *)code {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion13
                                            path:@"users/1/claims"
                                      HTTPMethod:@"POST"
                                   authenticated:YES
                                    responseData:[self responseDataFromFile:@"claim_global"]];
  stub.requestBodyJSON = @{@"claim" : @{ @"cohort_code" : code } };
  return stub;
}

+ (LUAPIStub *)stubToCreateTicket:(NSString *)body {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion13
                                            path:@"users/1/tickets"
                                      HTTPMethod:@"POST"
                                   authenticated:YES
                                    responseData:[self responseDataFromFile:@"ticket"]];
  stub.requestBodyJSON = @{ @"ticket" : @{ @"body" : body } };
  return stub;
}

+ (LUAPIStub *)stubToCreateUserWithFacebookAccessToken:(NSString *)facebookAccessToken {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion14
                                            path:@"users"
                                      HTTPMethod:@"POST"
                                   authenticated:NO
                                    responseData:[self responseDataFromFile:@"new_user"]];

  [self setDeviceIdentifier];

  stub.requestBodyJSON = @{
    @"client_id" : [LUAPIClient sharedClient].apiKey,
    @"user" : @{
      @"device_identifier" : LUDeviceIdentifier,
      @"facebook_access_token" : facebookAccessToken
    }
  };

  return stub;
}

+ (LUAPIStub *)stubToCreateUserWithFirstName:(NSString *)firstName
                                    lastName:(NSString *)lastName
                                       email:(NSString *)email
                                    password:(NSString *)password {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion14
                                            path:@"users"
                                      HTTPMethod:@"POST"
                                   authenticated:NO
                                    responseData:[self responseDataFromFile:@"new_user"]];

  [self setDeviceIdentifier];

  // Stub out the date formatter so that termsAcceptedAt will always return the same string (otherwise we'll get
  // intermittent errors if the times are off.
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter stub:@selector(stringFromDate:) andReturn:@"2012-12-24T17:58:04-04:00"];
  [NSDate stub:@selector(iso8601DateTimeFormatter) andReturn:dateFormatter];

  stub.requestBodyJSON = @{
    @"client_id" : [LUAPIClient sharedClient].apiKey,
    @"user" : @{
      @"device_identifier" : LUDeviceIdentifier,
      @"email" : email,
      @"first_name" : firstName,
      @"last_name" : lastName,
      @"password" : password,
      @"terms_accepted_at" : [[NSDate date] iso8601DateTimeString]
    }
  };

  return stub;
}

+ (LUAPIStub *)stubToDeleteCreditCardWithID:(NSNumber *)creditCardID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:[@"credit_cards/" stringByAppendingString:[creditCardID stringValue]]
                           HTTPMethod:@"DELETE"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"credit_card"]];
}

+ (LUAPIStub *)stubToFacebookConnectWithFacebookAccessToken:(NSString *)facebookAccessToken {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion13
                                            path:@"users/1/facebook_connections"
                                      HTTPMethod:@"POST"
                                   authenticated:YES
                                    responseData:[self responseDataFromFile:@"facebook_connected_user"]];
  stub.requestBodyJSON = @{ @"facebook_access_token" : facebookAccessToken };
  return stub;
}

+ (LUAPIStub *)stubToFacebookDisconnect {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:@"users/1/facebook_connections"
                           HTTPMethod:@"DELETE"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"current_user"]];
}

+ (LUAPIStub *)stubToGetCampaignWithID:(NSNumber *)campaignID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[@"campaigns/" stringByAppendingString:[campaignID stringValue]]
                           HTTPMethod:@"GET"
                        authenticated:NO
                         responseData:[self responseDataFromFile:@"campaign"]];
}

+ (LUAPIStub *)stubToGetCategories {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:@"categories"
                           HTTPMethod:@"GET"
                        authenticated:NO
                         responseData:[self responseDataFromFile:@"categories"]];
}

+ (LUAPIStub *)stubToGetCohort:(NSString *)code {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[@"cohorts/" stringByAppendingString:code]
                           HTTPMethod:@"GET"
                        authenticated:NO
                         responseData:[self responseDataFromFile:@"cohort"]];
}

+ (LUAPIStub *)stubToGetCohortNotFound:(NSString *)code {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion13
                                            path:[@"cohorts/" stringByAppendingString:code]
                                      HTTPMethod:@"GET"
                                   authenticated:NO
                                    responseData:[self responseDataFromFile:@"cohort_not_found"]];
  stub.responseCode = 404;
  return stub;
}

+ (LUAPIStub *)stubToGetCreditCardsOneResult {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:@"credit_cards"
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"credit_cards-1"]];
}

+ (LUAPIStub *)stubToGetCreditCardsTwoResults {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:@"credit_cards"
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"credit_cards-2"]];
}

+ (LUAPIStub *)stubToGetCurrentUser {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:@"users/1"
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"current_user"]];
}

+ (LUAPIStub *)stubToGetLocationSummariesFirstPage {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion14
                                            path:@"locations?first"
                                      HTTPMethod:@"GET"
                                   authenticated:NO
                                    responseData:[self responseDataFromFile:@"location_summaries"]];

  NSString *baseLocationsURLString = [NSString stringWithFormat:@"%@%@/locations", [[LUAPIClient sharedClient].baseURL description], LUAPIVersion14];
  [LUCoreDataStack setMetadataString:[baseLocationsURLString stringByAppendingString:@"?first"] forKey:LUNextPageURLKey];
  stub.responseHeaders = @{@"Link" : [NSString stringWithFormat:@"<%@?last>; rel=\"next\"", baseLocationsURLString]};

  return stub;
}

+ (LUAPIStub *)stubToGetLocationSummariesLastPage {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:@"locations?last"
                           HTTPMethod:@"GET"
                        authenticated:NO
                         responseData:nil];
}

+ (LUAPIStub *)stubToGetLocationsWithMerchantID:(NSNumber *)merchantID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[NSString stringWithFormat:@"merchants/%@/locations", merchantID]
                           HTTPMethod:@"GET"
                        authenticated:NO
                         responseData:[self responseDataFromFile:@"merchant_locations"]];
}

+ (LUAPIStub *)stubToGetLocationWithID:(NSNumber *)locationID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[@"locations/" stringByAppendingString:[locationID stringValue]]
                           HTTPMethod:@"GET"
                        authenticated:NO
                         responseData:[self responseDataFromFile:@"location"]];
}

+ (LUAPIStub *)stubToGetLoyaltyForMerchantWithID:(NSNumber *)merchantID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:[NSString stringWithFormat:@"merchants/%@/loyalty", [merchantID stringValue]]
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"loyalty"]];
}

+ (LUAPIStub *)stubToGetLoyaltyNoCreditForMerchantWithID:(NSNumber *)merchantID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:[NSString stringWithFormat:@"merchants/%@/loyalty", [merchantID stringValue]]
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"loyalty_no_credit"]];
}

+ (LUAPIStub *)stubToGetMerchantWithID:(NSNumber *)merchantID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[@"merchants/" stringByAppendingString:[merchantID stringValue]]
                           HTTPMethod:@"GET"
                        authenticated:NO
                         responseData:[self responseDataFromFile:@"merchant"]];
}

+ (LUAPIStub *)stubToGetNewUser {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:@"users/1"
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"new_user"]];
}

+ (LUAPIStub *)stubToGetOrderWithID:(NSNumber *)orderID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[@"orders/" stringByAppendingString:[orderID stringValue]]
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"order"]];
}

+ (LUAPIStub *)stubToGetOrdersOnPage:(NSNumber *)page {
  NSData *responseData;
  if ([page integerValue] == 1) {
    responseData = [self responseDataFromFile:@"orders_page-1"];
  } else if ([page integerValue] == 2) {
    responseData = [self responseDataFromFile:@"orders_page-2"];
  }

  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[@"users/1/orders?page=" stringByAppendingString:[page stringValue]]
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:responseData];
}

+ (LUAPIStub *)stubToGetOrdersWithMerchantID:(NSNumber *)merchantID page:(NSNumber *)page {
  NSData *responseData;
  if ([page integerValue] == 1) {
    responseData = [self responseDataFromFile:@"orders_page-1"];
  } else if ([page integerValue] == 2) {
    responseData = [self responseDataFromFile:@"orders_page-2"];
  }

  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:[NSString stringWithFormat:@"users/1/orders?merchant_ids=%@&page=%@", [merchantID stringValue], [page stringValue]]
                           HTTPMethod:@"GET"
                        authenticated:YES
                         responseData:responseData];
}

+ (LUAPIStub *)stubToGetPaymentToken {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:@"payment_token"
                           HTTPMethod:@"GET"
                        authenticated:NO
                         responseData:[self responseDataFromFile:@"payment_token"]];

}

+ (LUAPIStub *)stubToLogInWithEmail:(NSString *)email password:(NSString *)password {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion14
                                            path:@"access_tokens"
                                      HTTPMethod:@"POST"
                                   authenticated:NO
                                    responseData:[self responseDataFromFile:@"oauth_access_token"]];

  [self setDeviceIdentifier];
  stub.requestBodyJSON = @{
    @"access_token" : @{
      @"client_id" : [LUAPIClient sharedClient].apiKey,
      @"device_identifier" : LUDeviceIdentifier,
      @"password" : password,
      @"username" : email
    }
  };

  return stub;
}

+ (LUAPIStub *)stubToLogInWithFacebookAccessToken:(NSString *)facebookAccessToken {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion14
                                            path:@"access_tokens"
                                      HTTPMethod:@"POST"
                                   authenticated:NO
                                    responseData:[self responseDataFromFile:@"oauth_access_token"]];

  [self setDeviceIdentifier];
  stub.requestBodyJSON = @{
    @"access_token" : @{
      @"client_id" : [LUAPIClient sharedClient].apiKey,
      @"device_identifier" : LUDeviceIdentifier,
      @"facebook_access_token" : facebookAccessToken
    }
  };

  return stub;
}

+ (LUAPIStub *)stubToPromoteCreditCardWithID:(NSNumber *)creditCardID {
  return [LUAPIStub apiStubForVersion:LUAPIVersion14
                                 path:[@"credit_cards/" stringByAppendingString:[creditCardID stringValue]]
                           HTTPMethod:@"PUT"
                        authenticated:YES
                         responseData:[self responseDataFromFile:@"credit_card"]];
}

+ (LUAPIStub *)stubToResetPasswordRequest {
  return [LUAPIStub apiStubForVersion:LUAPIVersion13
                                 path:@"users/forgot_password"
                           HTTPMethod:@"POST"
                        authenticated:NO
                         responseData:nil];
}

+ (LUAPIStub *)stubToSetCauseAffiliation:(LUCauseAffiliation *)causeAffiliation {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion13
                                            path:@"cause_affiliation"
                                      HTTPMethod:@"POST"
                                   authenticated:YES
                                    responseData:nil];
  stub.requestBodyJSON = @{ @"cause_id" : causeAffiliation.causeID, @"percent_donation" : causeAffiliation.percentDonation };
  return stub;
}

+ (LUAPIStub *)stubToUpdateProfileWithFirstName:(NSString *)firstName
                                       lastName:(NSString *)lastName
                                          email:(NSString *)email
                                    newPassword:(NSString *)newPassword
                                       birthday:(NSDate *)birthday
                                         gender:(NSString *)gender {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion14
                                            path:@"users/1"
                                      HTTPMethod:@"PUT"
                                   authenticated:YES
                                    responseData:[self responseDataFromFile:@"current_user"]];

  [self setDeviceIdentifier];
  stub.requestBodyJSON = @{
    @"user" : @{
      @"born_at" : [birthday iso8601DateTimeString],
      @"custom_attributes" : @{},
      @"device_identifier" : LUDeviceIdentifier,
      @"email" : email,
      @"first_name" : firstName,
      @"gender" : gender,
      @"last_name" : lastName,
      @"new_password" : newPassword
    }
  };

  return stub;
}

+ (LUAPIStub *)stubToUpdateAdditionalInfoWithFirstName:(NSString *)firstName
                                              lastName:(NSString *)lastName
                                                 email:(NSString *)email
                                                gender:(NSString *)gender
                                              birthday:(NSDate *)birthday {
  LUAPIStub *stub = [LUAPIStub apiStubForVersion:LUAPIVersion14
                                            path:@"users/1"
                                      HTTPMethod:@"PUT"
                                   authenticated:YES
                                    responseData:[self responseDataFromFile:@"current_user"]];

  [self setDeviceIdentifier];
  stub.requestBodyJSON = @{
    @"user" : @{
       @"born_at" : [birthday iso8601DateTimeString],
       @"custom_attributes" : @{},
       @"device_identifier" : LUDeviceIdentifier,
       @"email" : email,
       @"first_name" : firstName,
       @"gender" : gender,
       @"last_name" : lastName
    }
  };

  return stub;
}

#pragma mark - Private Methods

+ (NSData *)responseDataFromFile:(NSString *)file {
  NSString *responseFile = [[NSBundle bundleForClass:[self class]] pathForResource:file ofType:@"json"];
  return [NSData dataWithContentsOfFile:responseFile];
}

+ (void)setDeviceIdentifier {
  [[LUKeychainAccess standardKeychainAccess] setString:LUDeviceIdentifier forKey:@"LUDeviceIdentifier"];
}

@end