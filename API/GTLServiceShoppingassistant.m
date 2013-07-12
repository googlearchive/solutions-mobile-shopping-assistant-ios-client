/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLServiceShoppingassistant.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   shoppingassistant/v1
// Description:
//   This is an API
// Classes:
//   GTLServiceShoppingassistant (0 custom class methods, 0 custom properties)

#import "GTLShoppingassistant.h"

@implementation GTLServiceShoppingassistant

#if DEBUG
// Method compiled in debug builds just to check that all the needed support
// classes are present at link time.
+ (NSArray *)checkClasses {
  NSArray *classes = [NSArray arrayWithObjects:
                      [GTLQueryShoppingassistant class],
                      [GTLShoppingassistantCheckIn class],
                      [GTLShoppingassistantCheckInCollection class],
                      [GTLShoppingassistantDeviceInfo class],
                      [GTLShoppingassistantDeviceInfoCollection class],
                      [GTLShoppingassistantGeoPt class],
                      [GTLShoppingassistantKey class],
                      [GTLShoppingassistantOffer class],
                      [GTLShoppingassistantOfferCollection class],
                      [GTLShoppingassistantPlace class],
                      [GTLShoppingassistantPlaceInfo class],
                      [GTLShoppingassistantPlaceInfoCollection class],
                      [GTLShoppingassistantRecommendation class],
                      [GTLShoppingassistantRecommendationCollection class],
                      nil];
  return classes;
}
#endif  // DEBUG

- (id)init {
  self = [super init];
  if (self) {
    // Version from discovery.
    self.apiVersion = @"v1";

    // From discovery.  Where to send JSON-RPC.
    // Turn off prettyPrint for this service to save bandwidth (especially on
    // mobile). The fetcher logging will pretty print.
    self.rpcURL = [NSURL URLWithString:@"https://{{{YOUR APP ID}}}.appspot.com/_ah/api/rpc?prettyPrint=false"];
  }
  return self;
}

@end