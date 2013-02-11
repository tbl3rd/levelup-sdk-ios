#import "BraintreeEncryption.h"
#import "LUAPIClient.h"
#import "LUAPIRequest.h"
#import "LUCreditCard.h"
#import "LUCreditCardRequestBuilder.h"

SPEC_BEGIN(LUCreditCardRequestBuilderSpec)

describe(@"LUCreditCardRequestBuilder", ^{
  // Public Methods

  __block LUAPIRequest *request;

  describe(@"requestForCreditCards", ^{
    beforeEach(^{
      [[LUAPIClient sharedClient] stub:@selector(currentUserId) andReturn:@1];

      request = [LUCreditCardRequestBuilder requestForCreditCards];
    });

    it(@"returns a GET request", ^{
      [[request.method should] equal:@"GET"];
    });

    it(@"returns a request to the path 'users/<userid>/credit_cards'", ^{
      [[request.path should] equal:@"users/1/credit_cards"];
    });

    it(@"returns a request with no parameters", ^{
      [request.parameters shouldBeNil];
    });
  });

  describe(@"requestToCreateCreditCard:", ^{
    __block LUCreditCard *creditCard;
    __block BraintreeEncryption *braintree;

    beforeEach(^{
      braintree = [BraintreeEncryption mock];
      [BraintreeEncryption stub:@selector(alloc) andReturn:braintree];
      [braintree stub:@selector(initWithPublicKey:) andReturn:braintree];
      [(KWMock *)braintree stub:@selector(encryptString:) withBlock:^(NSArray *params) {
        return [NSString stringWithFormat:@"Encrypted: %@", params[0]];
      }];

      creditCard = [[LUCreditCard alloc] init];
      creditCard.cvv = @"123";
      creditCard.expirationMonth = @12;
      creditCard.expirationYear = @15;
      creditCard.number = @"4111111111111111";
      creditCard.postalCode = @"01234";

      [[LUAPIClient sharedClient] stub:@selector(currentUserId) andReturn:@1];

      request = [LUCreditCardRequestBuilder requestToCreateCreditCard:creditCard];
    });

    it(@"returns a POST request", ^{
      [[request.method should] equal:@"POST"];
    });

    it(@"returns a request to the path 'users/<userid>/credit_cards'", ^{
      [[request.path should] equal:@"users/1/credit_cards"];
    });

    it(@"request a request with encrypted parameters for the credit card", ^{
      NSDictionary *expectedParams = @{
        @"credit_card" : @{
            @"cvv" : [braintree encryptString:creditCard.cvv],
            @"expiration_month" : [braintree encryptString:[creditCard.expirationMonth stringValue]],
            @"expiration_year" : [braintree encryptString:[creditCard.expirationYear stringValue]],
            @"number" : [braintree encryptString:creditCard.number],
            @"postal_code" : [braintree encryptString:creditCard.postalCode]
        }
      };

      [[request.parameters should] equal:expectedParams];
    });
  });

  describe(@"requestToDeleteCreditCardWithId:", ^{
    beforeEach(^{
      request = [LUCreditCardRequestBuilder requestToDeleteCreditCardWithId:@1];
    });

    it(@"returns a DELETE request", ^{
      [[request.method should] equal:@"DELETE"];
    });

    it(@"returns a request to the path 'credit_cards/<id>'", ^{
      [[request.path should] equal:@"credit_cards/1"];
    });

    it(@"returns a request with no parameters", ^{
      [request.parameters shouldBeNil];
    });
  });

  describe(@"requestToPromoteCreditCardWithId:", ^{
    beforeEach(^{
      request = [LUCreditCardRequestBuilder requestToPromoteCreditCardWithId:@1];
    });

    it(@"returns a PUT request", ^{
      [[request.method should] equal:@"PUT"];
    });

    it(@"returns a request to the path 'credit_cards/<id>/promote'", ^{
      [[request.path should] equal:@"credit_cards/1/promote"];
    });

    it(@"returns a request with no parameters", ^{
      [request.parameters shouldBeNil];
    });
  });
});

SPEC_END
