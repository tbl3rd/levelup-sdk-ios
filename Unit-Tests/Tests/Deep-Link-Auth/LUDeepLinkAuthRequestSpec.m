// Copyright 2014 SCVNGR, Inc., D.B.A. LevelUp. All rights reserved.

#import "LUDeepLinkAuthRequest.h"
#import "LUOneTimePad.h"
#import "NSData+LUAdditions.h"
#import "NSError+LUAdditions.h"
#import "NSURL+LUAdditions.h"

SPEC_BEGIN(LUDeepLinkAuthRequestSpec)

describe(@"LUDeepLinkAuthRequest", ^{
  __block LUDeepLinkAuthRequest *request;

  NSString *appID = @"1";
  LUOneTimePad *oneTimePad = [LUOneTimePad fixture];
  NSArray *permissions = @[@"create_orders", @"read_user_basic_info"];
  NSString *returnURLScheme = @"testapp";

  // Object Lifecycle Methods

  describe(@"initWithURL:", ^{
    beforeEach(^{
      NSDictionary *params = @{
        LUDeepLinkAuthAppIDURLParam: appID,
        LUDeepLinkAuthOneTimePadURLParam: [oneTimePad base64Encoding],
        LUDeepLinkAuthPermissionsURLParam: permissions,
        LUDeepLinkAuthReturnURLSchemeURLParam: returnURLScheme
      };
      NSURL *URL = [NSURL lu_URLWithScheme:@"targetapp"
                                      host:LUDeepLinkAuthRequestHost
                                      path:@"/"
                           queryParameters:params];

      request = [[LUDeepLinkAuthRequest alloc] initWithURL:URL];
    });

    it(@"pulls the app ID from the URL", ^{
      [[request.appID should] equal:appID];
    });

    it(@"pulls the one-time pad as a Base64 encoded string from the URL", ^{
      [[request.oneTimePad should] equal:oneTimePad];
    });

    it(@"pulls the permissions from the URL", ^{
      [[request.permissions should] equal:permissions];
    });

    it(@"pulls the return URL scheme from the URL", ^{
      [[request.returnURLScheme should] equal:returnURLScheme];
    });
  });

  describe(@"requestWithPermissions:", ^{
    beforeEach(^{
      [LUAPIClient setupWithAppID:appID APIKey:@"api-key"];
      [LUOneTimePad stub:@selector(saveNewOneTimePad) andReturn:oneTimePad];

      request = [LUDeepLinkAuthRequest requestWithPermissions:permissions
                                              returnURLScheme:returnURLScheme];
    });

    it(@"uses the app's ID", ^{
      [[request.appID should] equal:appID];
    });

    it(@"uses a new one-time pad", ^{
      [[request.oneTimePad should] equal:oneTimePad];
    });

    it(@"uses the given permissions", ^{
      [[request.permissions should] equal:permissions];
    });

    it(@"uses the given return URL scheme", ^{
      [[request.returnURLScheme should] equal:returnURLScheme];
    });
  });

  // Public Methods

  describe(@"URL", ^{
    __block NSURL *URL;

    beforeEach(^{
      [LUAPIClient setupWithAppID:@"1" APIKey:@"api-key"];
      URL = [[[LUDeepLinkAuthRequest alloc] initWithAppID:appID oneTimePad:oneTimePad
                                              permissions:permissions returnURLScheme:returnURLScheme] URL];
    });

    it(@"has scheme deepLinkAuthURLScheme", ^{
      [[[URL scheme] should] equal:[LUAPIClient sharedClient].deepLinkAuthURLScheme];
    });

    it(@"has host LUDeepLinkRequestHost", ^{
      [[[URL host] should] equal:LUDeepLinkAuthRequestHost];
    });

    describe(@"query parameters", ^{
      __block NSDictionary *params;

      beforeEach(^{
        params = [URL lu_queryDictionary];
      });

      it(@"contains the appID", ^{
        [[params[LUDeepLinkAuthAppIDURLParam] should] equal:appID];
      });

      it(@"contains the oneTimePad Base64 encoded", ^{
        [[params[LUDeepLinkAuthOneTimePadURLParam] should] equal:[oneTimePad base64Encoding]];
      });

      it(@"contains the permissions", ^{
        [[params[LUDeepLinkAuthPermissionsURLParam] should] equal:permissions];
      });

      it(@"contains the return URL scheme", ^{
        [[params[LUDeepLinkAuthReturnURLSchemeURLParam] should] equal:returnURLScheme];
      });
    });
  });

  describe(@"validateProperties", ^{
    context(@"when there is no appID", ^{
      beforeEach(^{
        request = [[LUDeepLinkAuthRequest alloc] initWithAppID:nil oneTimePad:oneTimePad
                                                   permissions:permissions returnURLScheme:returnURLScheme];
      });

      it(@"returns an LUDeepLinkAuthErrorAppIDRequired error", ^{
        [[theValue([[request validateProperties] code]) should] equal:theValue(LUDeepLinkAuthErrorAppIDRequired)];
      });
    });

    context(@"when there is no one-time pad", ^{
      beforeEach(^{
        request = [[LUDeepLinkAuthRequest alloc] initWithAppID:appID oneTimePad:nil
                                                   permissions:permissions returnURLScheme:returnURLScheme];
      });

      it(@"returns an LUDeepLinkAuthErrorOneTimePadRequired error", ^{
        [[theValue([[request validateProperties] code]) should] equal:theValue(LUDeepLinkAuthErrorOneTimePadRequired)];
      });
    });

    context(@"when there are no permissions", ^{
      beforeEach(^{
        request = [[LUDeepLinkAuthRequest alloc] initWithAppID:appID oneTimePad:oneTimePad
                                                   permissions:nil returnURLScheme:returnURLScheme];
      });

      it(@"returns an LUDeepLinkAuthErrorPermissionsRequired error", ^{
        [[theValue([[request validateProperties] code]) should] equal:theValue(LUDeepLinkAuthErrorPermissionsRequired)];
      });
    });

    context(@"when there is no returnURLScheme", ^{
      beforeEach(^{
        request = [[LUDeepLinkAuthRequest alloc] initWithAppID:appID oneTimePad:oneTimePad
                                                   permissions:permissions returnURLScheme:nil];
      });

      it(@"returns an LUDeepLinkAuthErrorReturnURLSchemeRequired error", ^{
        [[theValue([[request validateProperties] code]) should] equal:theValue(LUDeepLinkAuthErrorReturnURLSchemeRequired)];
      });
    });

    context(@"when all parameters are present", ^{
      beforeEach(^{
        [UIApplication stub:@selector(sharedApplication) andReturn:[UIApplication nullMock]];
        request = [[LUDeepLinkAuthRequest alloc] initWithAppID:appID oneTimePad:oneTimePad
                                                   permissions:permissions returnURLScheme:returnURLScheme];
      });

      it(@"returns nil", ^{
        [[[request validateProperties] should] beNil];
      });
    });
  });

  describe(@"validateURL", ^{
    beforeEach(^{
      [UIApplication stub:@selector(sharedApplication) andReturn:[UIApplication nullMock]];
      request = [[LUDeepLinkAuthRequest alloc] initWithAppID:appID oneTimePad:oneTimePad
                                                 permissions:permissions returnURLScheme:returnURLScheme];
    });

    context(@"when there is an error with the properties", ^{
      __block NSError *error;

      beforeEach(^{
        error  = [NSError lu_deepLinkAuthErrorWithCode:LUDeepLinkAuthErrorAppIDRequired description:@"error"];
        [request stub:@selector(validateProperties) andReturn:error];
      });

      it(@"returns the property error", ^{
        [[[request validateURL] should] equal:error];
      });
    });

    context(@"when there is no error with the properties", ^{
      beforeEach(^{
        [request stub:@selector(validateProperties) andReturn:nil];
      });

      context(@"and the application can open the request's URL", ^{
        beforeEach(^{
          [[UIApplication sharedApplication] stub:@selector(canOpenURL:)
                                        andReturn:theValue(YES)
                                    withArguments:[request URL]];
        });

        it(@"returns nil", ^{
          [[[request validateURL] should] beNil];
        });
      });

      context(@"and the application can't open the request's URL", ^{
        beforeEach(^{
          [[UIApplication sharedApplication] stub:@selector(canOpenURL:)
                                        andReturn:theValue(NO)
                                    withArguments:[request URL]];
        });

        it(@"returns an LUDeepLinkAuthErrorAppNotInstalled error", ^{
          [[theValue([[request validateURL] code]) should] equal:theValue(LUDeepLinkAuthErrorAppNotInstalled)];
        });
      });
    });
  });
});

SPEC_END
