// Copyright 2013 SCVNGR, Inc., D.B.A. LevelUp. All rights reserved.

#import "LUWebLocations+Fixtures.h"

@implementation LUWebLocations (Fixtures)

+ (LUWebLocations *)fixture {
  return [[LUWebLocations alloc] initWithFacebookAddress:@"http://facebook.com/pizza"
                                          foodlerAddress:@"http://foodler.com/pizza"
                                             menuAddress:@"http://pizza.com/menu"
                                       newsletterAddress:@"http://pizza.com/newsletter"
                                        opentableAddress:@"http://opentable.com/pizza"
                                          twitterAddress:@"http://twitter.com/pizza"
                                             yelpAddress:@"http://yelp.com/pizza"];
}

@end