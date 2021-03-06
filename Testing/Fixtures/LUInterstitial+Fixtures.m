/*
 * Copyright (C) 2014 SCVNGR, Inc. d/b/a LevelUp
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "LUInterstitial+Fixtures.h"
#import "LUInterstitialClaimAction.h"
#import "LUInterstitialFeedbackAction.h"
#import "LUInterstitialShareAction.h"
#import "LUInterstitialURLAction.h"

@implementation LUInterstitial (Fixtures)

+ (LUInterstitial *)fixtureWithClaimAction {
  LUInterstitialClaimAction *action = [[LUInterstitialClaimAction alloc] initWithCampaignCode:@"code"];
  return [self fixtureWithAction:action actionType:LUInterstitialActionTypeClaim];
}

+ (LUInterstitial *)fixtureWithFeedbackAction {
  LUInterstitialFeedbackAction *action = [[LUInterstitialFeedbackAction alloc] initWithQuestionText:@"How was your experience at this merchant?"];
  return [self fixtureWithAction:action actionType:LUInterstitialActionTypeFeedback];
}

+ (LUInterstitial *)fixtureWithNoAction {
  return [self fixtureWithAction:nil actionType:LUInterstitialActionTypeNone];
}

+ (LUInterstitial *)fixtureWithShareAction {
  NSString *messageForEmailBody = @"Email body message";
  NSString *messageForEmailSubject = @"Email subject";
  NSString *messageForFacebook = @"Facebook message";
  NSString *messageForTwitter = @"Twitter message";
  NSURL *shareURLEmail = [NSURL URLWithString:@"http://example.com/email_campaign"];
  NSURL *shareURLFacebook = [NSURL URLWithString:@"http://example.com/facebook_campaign"];
  NSURL *shareURLTwitter = [NSURL URLWithString:@"http://example.com/twitter_campaign"];

  LUInterstitialShareAction *action = [[LUInterstitialShareAction alloc] initWithMessageForEmailBody:messageForEmailBody
                                                                              messageForEmailSubject:messageForEmailSubject
                                                                                  messageForFacebook:messageForFacebook
                                                                                   messageForTwitter:messageForTwitter
                                                                                       shareURLEmail:shareURLEmail
                                                                                    shareURLFacebook:shareURLFacebook
                                                                                     shareURLTwitter:shareURLTwitter];
  return [self fixtureWithAction:action actionType:LUInterstitialActionTypeShare];
}

+ (LUInterstitial *)fixtureWithURLAction {
  LUInterstitialURLAction *action = [[LUInterstitialURLAction alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]];
  return [self fixtureWithAction:action actionType:LUInterstitialActionTypeURL];
}

+ (LUInterstitial *)fixtureWithUnknownAction {
  return [self fixtureWithAction:nil actionType:LUInterstitialActionTypeUnknown];
}

#pragma mark - Private Methods

+ (LUInterstitial *)fixtureWithAction:(id)action actionType:(LUInterstitialActionType)actionType {
  NSString *calloutText;
  NSString *title;

  switch (actionType) {
    case LUInterstitialActionTypeNone:
    case LUInterstitialActionTypeClaim:
    case LUInterstitialActionTypeURL:
      calloutText = @"Get $1";
      title = @"$1 at Test Merchant";
      break;
    case LUInterstitialActionTypeFeedback:
      calloutText = @"Give us Feedback";
      title = @"Give us Feedback";
      break;
    case LUInterstitialActionTypeShare:
      calloutText = @"Give Money to Friends";
      title = @"$1 at Test Merchant";
      break;
    case LUInterstitialActionTypeUnknown:
    default:
      break;
  }

  return [[LUInterstitial alloc] initWithAction:action
                                     actionType:actionType
                                    calloutText:calloutText
                                descriptionHTML:@"<p>Grab $1.00 to spend on anything at Test Merchant. Enjoy!</p>"
                                       imageURL:[NSURL URLWithString:@"https://api.thelevelup.com/v14/campaigns/1/image"]
                                          title:title];
}

@end
