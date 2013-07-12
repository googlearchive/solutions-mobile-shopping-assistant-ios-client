/* Copyright (c) 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <CoreLocation/CoreLocation.h>
#import "ExtraPropertyUITableViewCell.h"
#import "GTLShoppingassistant.h"
#import "GTLService.h"
#import "GTMHTTPFetcher.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTMOAuth2Authentication.h"
#import "OffersTableViewController.h" 
#import "ShopsTableViewController.h"
#import "ViewHelper.h"


@interface ShopsTableViewController()
@property(nonatomic, strong) GTLServiceShoppingassistant *service;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *currentLocation;
@end

@implementation ShopsTableViewController
NSString *const kKeyChainName = @"mobileAssistant";
NSString *const kKeyClientID = @"{{{ INSERT ID }}}";
NSString *const kKeyClientSecret = @"{{{ INSERT SECREET }}}";
NSString *const kShopToOfferSequeID = @"Show Discount List";
NSString *const kShopTableCellID = @"Shop with Address";

@synthesize shops = _shops;
@synthesize service = _service;
@synthesize auth = _auth;
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;

- (IBAction)pressSignout {
  [self unAuthenticateUser];
  [ViewHelper showSigninToolBarButtonForViewController:self];
}

- (IBAction)pressSignin {
  [self authenticateUser];
  [ViewHelper showSignoutToolBarButtonForViewController:self];
}

#pragma mark - Customized setters and getters

- (void)setShops:(NSArray *)list {
  if (_shops != list) {
    _shops = list;

    if (self.tableView.window) {
      [self.tableView reloadData];

      if (self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = nil;
      }
    }
  }
}

- (GTLServiceShoppingassistant *)service {
  if (!_service) {
    _service = [[GTLServiceShoppingassistant alloc] init];

    _service.shouldFetchNextPages = YES;
    _service.retryEnabled = YES;
  }

  return _service;
}

#pragma mark - Authentication model

// Show user login view
- (void)showUserLoginView {
  NSUInteger id = [kKeyClientID rangeOfString:@"{{{ INSERT ID }}}"].location;
  assert(id == NSNotFound);
  NSUInteger secret =
      [kKeyClientSecret rangeOfString:@"{{{ INSERT SECREET }}}"].location;
  assert(secret == NSNotFound);

  GTMOAuth2ViewControllerTouch *oauthViewController;
  oauthViewController =
      [[GTMOAuth2ViewControllerTouch alloc]
             initWithScope:@""
                  clientID:kKeyClientID
              clientSecret:kKeyClientSecret
          keychainItemName:kKeyChainName
                  delegate:self
          finishedSelector:@selector(viewController:finishedWithAuth:error:)];

  [self presentViewController:oauthViewController animated:YES completion:nil];
}

- (void)authenticateUser {
  if (!self.auth) {
    // Instance doesn't have an authentication object, attempt to fetch from
    // keychain.  This method call always returns an authentication object.
    // If nothing is returned from keychain, this will return an invalid
    // authentication
    self.auth = [GTMOAuth2ViewControllerTouch
                    authForGoogleFromKeychainForName:kKeyChainName
                                            clientID:kKeyClientID
                                        clientSecret:kKeyClientSecret];
  }

  // Now instance has an authentication object, check if it's valid
  if ([self.auth canAuthorize]) {
    // Looks like token is good, reset instance authentication object
    [self resetAccessTokenForCloudEndpoint];
    NSLog(@"%@", self.auth);
  } else {
    // If there is some sort of error when validating the previous
    // authentication, reset the authentication and force user to login
    self.auth = nil;
    [self showUserLoginView];
  }
}

// Reset access token value for authentication object for Cloud Endpoint.
- (void)resetAccessTokenForCloudEndpoint {
  GTMOAuth2Authentication *auth = self.auth;
  if (auth) {
    self.auth.authorizationTokenKey = @"id_token";
    [self.service setAuthorizer:auth];

    // Add a sign out button
    [ViewHelper showSignoutToolBarButtonForViewController:self];

    // Reload the table if it's on screen
    if (self.tableView.window) {
      [self.tableView reloadData];
      if (self.navigationItem.rightBarButtonItem && self.shops) {
        self.navigationItem.rightBarButtonItem = nil;
      }
    }
  }
}

// Callback method after user finished the login.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)oauthViewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];

  if (error) {
    [ViewHelper showPopup:@"Error"
                  message:@"Failed to authenticate user"
                   button:@"OK"];
    NSLog(@"%@", error);
  } else {
    self.auth = auth;
    [self resetAccessTokenForCloudEndpoint];
    NSLog(@"%@",self.auth);
  }
}

// Signing user out and revoke token
- (void)unAuthenticateUser {
  [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeyChainName];
  [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
}

#pragma mark - View first loaded

- (void)viewDidLoad {
  // Turn on logging
  [GTMHTTPFetcher setLoggingEnabled:YES];

  // Show the spinner
  [ViewHelper showToolbarSpinnerForViewController:self];

  // Authenticate user if needed
  [self authenticateUser];

  // Get current location
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  [self.locationManager startUpdatingLocation];
}

#pragma mark - Prepare Segue from "Shops" screen to "Goodies" screen

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier
    sender:(ExtraPropertyUITableViewCell *)sender {
  if ([identifier isEqual:kShopToOfferSequeID]) {
    if ([self.navigationItem.leftBarButtonItem.title isEqual:@"Sign out"]) {
      return YES;
    } else {
      [ViewHelper showPopup:@"Warning"
                    message:@"Please sign in first before checkin"
                     button:@"OK"];
    }
  }

  return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(ExtraPropertyUITableViewCell *)sender {
  // Prepare the offers/recommendations list for display from "Shops" screen
  // to "Goodies" screen
  if ([segue.identifier isEqual:kShopToOfferSequeID]) {
    OffersTableViewController *nextController =
        segue.destinationViewController;

    // Set the store name
    nextController.storeName = sender.textLabel.text;

    // Check in first, which will then pull all offers and recommendations
    [self checkIn:sender.databaseID nextController:nextController];

    // Set a spinner for the in the goodies controller
    [ViewHelper showToolbarSpinnerForViewController:nextController];
  }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  NSLog(@"locationManager:didFailWithError: %@", error);

  [ViewHelper showPopup:@"Error"
                message:@"Failed to get current location"
                 button:@"OK"];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  // Update location once receive the GPS update from the phone
  self.currentLocation = newLocation;
  NSLog(@"current location: %@", self.currentLocation);
  [self.locationManager stopUpdatingLocation];

  // Go get all the shops from backend only when the current location is set
  [self getAllShops];
}

#pragma mark - UITableView data source for shops

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return [self.shops count];
}

- (ExtraPropertyUITableViewCell *)tableView:(UITableView *)tableView
                      cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *CellIdentifier = kShopTableCellID;
  ExtraPropertyUITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                      forIndexPath:indexPath];
  if (!cell) {
    cell = [[ExtraPropertyUITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle
               reuseIdentifier:kShopTableCellID];
  }

  GTLShoppingassistantPlaceInfo *place =
      [self.shops objectAtIndex:indexPath.row];

  cell.textLabel.text = place.name;
  cell.textLabel.textColor =
      [UIColor colorWithRed:0.8 green:0.22 blue:0.68 alpha:1.0];
  cell.detailTextLabel.numberOfLines = @2;

  float distance = [place.distanceInKilometers floatValue];
  NSString *unit = @"km";
  if (! [NSLocaleMeasurementSystem isEqual:@"Metric"]) {
    static float kmToMileRatio = 0.621371;
    distance = distance * kmToMileRatio;
    unit = @"mi";
  }

  cell.detailTextLabel.text =
      [NSString stringWithFormat:@"Distance: %.1f%@\n%@", distance, unit,
          place.address];

  cell.databaseID = place.placeId;

  UIImage *image = [UIImage imageNamed:@"logo.png"];
  CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
  CGSize desiredSize = CGSizeMake(kDefaultCellImageWidth, height);
  cell.imageView.image = [ViewHelper resizedImageWithImage:image
                                               toSize:desiredSize];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableview
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kDefaultCellHeight + kDetailTitleHeightPerLine;
}

#pragma mark - Shops Model

- (void)getAllShops {
  CLLocationCoordinate2D location = self.currentLocation.coordinate;
  if (CLLocationCoordinate2DIsValid(location)) {
    NSString *latitude = [NSString stringWithFormat:@"%.8f", location.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%.8f",
                              location.longitude];

    GTLQueryShoppingassistant *query =
        [GTLQueryShoppingassistant queryForPlaceEndpointListWithCount:100
             distanceInKm:100
                 latitude:latitude
                longitude:longitude];

    [self.service executeQuery:query
             completionHandler:^(GTLServiceTicket *ticket,
                                 GTLShoppingassistantPlaceInfoCollection *object,
                                 NSError *error) {
                 if (error) {
                   [ViewHelper showPopup:@"Error"
                                 message:@"Unable to query a list of shops"
                                  button:@"OK"];
                   NSLog(@"%@", error);
                 } else {
                   self.shops = [object items];
                   NSLog(@"%@", self.shops);
                 }
             }];
  } else {
    NSLog(@"Current location is invalid: %.8f, %.8f",
        location.latitude, location.longitude);
  }
}

#pragma mark - Checkin Model

- (void)checkIn:(NSString *)placeId
    nextController:(OffersTableViewController *)nextController {
  GTLShoppingassistantCheckIn *checkIn =
      [[GTLShoppingassistantCheckIn alloc] init];
  checkIn.placeId = placeId;
  GTLQueryShoppingassistant *checkinQuery =
      [GTLQueryShoppingassistant queryForCheckInEndpointInsertWithObject:checkIn];

  [self.service executeQuery:checkinQuery
           completionHandler:^(GTLServiceTicket *ticket,
                               id object,
                               NSError *error) {
               if (error) {
                 [ViewHelper showPopup:@"Error"
                               message:@"Unable to check in, try again."
                                button:@"OK"];
                 NSLog(@"%@", error);
                 // Reauthenticate the user
                 [self authenticateUser];

               } else {
                 // Get a list of offers if it's not pulled before
                 if (!nextController.offers) {
                   [self getAllOffers:placeId
                       nextController:nextController];
                 }

                 // Get a list of recommendations if it's not pulled before
                 if (!nextController.recommendations) {
                   [self getAllRecommendations:placeId
                                nextController:nextController];
                 }
               }
           }];
}

#pragma mark - Offer Model

- (void)getAllOffers:(NSString *)placeId
      nextController:(OffersTableViewController *)nextController {
  GTLQueryShoppingassistant *query =
      [GTLQueryShoppingassistant queryForOfferEndpointListWithPlaceId:placeId];

  [self.service executeQuery:query
           completionHandler:^(GTLServiceTicket *ticket,
                               GTLShoppingassistantOfferCollection *object,
                               NSError *error) {
               if (error) {
                 [ViewHelper showPopup:@"Error"
                               message:@"Retrieving offers failed."
                                button:@"OK"];
                 NSLog(@"%@", error);
               } else {
                 nextController.offers = [object items];
                 NSLog(@"%@", nextController.offers);
               }
           }];
}

#pragma mark - Recommendation Model

- (void)getAllRecommendations:(NSString *)placeId
    nextController:(OffersTableViewController *)nextController {
  GTLQueryShoppingassistant *query =
      [GTLQueryShoppingassistant
          queryForRecommendationEndpointListWithPlaceId:placeId];

  [self.service executeQuery:query
           completionHandler:
      ^(GTLServiceTicket *ticket,
        GTLShoppingassistantRecommendationCollection *object,
        NSError *error) {
          if (error) {
            [ViewHelper showPopup:@"Error"
                          message:@"Retrieving recommendations failed."
                           button:@"OK"];
            NSLog(@"%@", error);
          } else {
            nextController.recommendations = [object items];
            NSLog(@"%@", nextController.recommendations);
          }
      }];
}

@end
