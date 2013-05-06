#import "LUAPIRequest.h"
#import "LUCauseCategory.h"
#import "LUCauseJSONFactory.h"
#import "LUCauseRequestFactory.h"

@implementation LUCauseRequestFactory

#pragma mark - Public Methods

+ (LUAPIRequest *)requestForAllFeaturedCauses {
  return [self requestForCausesWithParameters:@{@"featured" : @YES}];
}

+ (LUAPIRequest *)requestForCausesInCategory:(LUCauseCategory *)causeCategory page:(NSUInteger)page {
  return [self requestForCausesWithParameters:@{@"category_ids" : causeCategory.causeCategoryID, @"page" : @(page)}];
}

+ (LUAPIRequest *)requestForCausesNearLocation:(CLLocation *)location page:(NSUInteger)page {
  return [self requestForCausesWithParameters:@{@"lat" : @(location.coordinate.latitude), @"lng" : @(location.coordinate.longitude), @"page" : @(page)}];
}

+ (LUAPIRequest *)requestForCausesOnPage:(NSUInteger)page {
  return [self requestForCausesWithParameters:@{@"page" : @(page)}];
}

#pragma mark - Private Methods

+ (LUAPIRequest *)requestForCausesWithParameters:(NSDictionary *)parameters {
  return [LUAPIRequest apiRequestWithMethod:@"GET"
                                       path:@"causes"
                                 apiVersion:LUAPIVersion13
                                 parameters:parameters
                               modelFactory:[LUCauseJSONFactory factory]];
}

@end
