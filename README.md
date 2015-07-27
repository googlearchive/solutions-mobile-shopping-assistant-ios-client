![status: inactive](https://img.shields.io/badge/status-inactive-red.svg)

This project is no longer actively developed or maintained.  

For new work on this check out [MobileShoppingAssistant](https://github.com/GoogleCloudPlatform/MobileShoppingAssistant-sample)

# Mobile Shopping Assistant iOS Client

## Copyright
Copyright 2013 Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Disclaimer
This sample application is not an official Google product.

## Support Platform and Versions
This sample source code and project is designed to work with Xcode 4.6.  The application is tested on iOS 6.1.

## Overview
Mobile Shopping Assistant iOS Client demonstrates how to build an iOS client that mirrors the functionality of the Android client by leveraging the same [Mobile Shopping Assistant Java Backend](https://github.com/GoogleCloudPlatform/solutions-mobile-shopping-assistant-backend-java) with the help of [Google APIs Client Library for Objective-C](https://code.google.com/p/google-api-objectivec-client).

## Download
After downloading this [iOS client sample](https://github.com/GoogleCloudPlatform/solutions-mobile-shopping-assistant-ios-client), unzip the package to extract the files in a directory of your choice.  Note that this client sample has dependency on the Mobile Shopping Assistant Java Backend, the following section will provide instruction on how to set up the backend.

## Developer Guide
This section provides a step-by-step guide so you can get the sample up and running in Xcode.

### Prerequisites
1. Download and install [Xcode 4.6](https://developer.apple.com/xcode/) on your Mac computer if you don't have it installed.

2. Download [Mobile Shopping Assistant Java Backend](https://github.com/GoogleCloudPlatform/solutions-mobile-shopping-assistant-backend-java).  Follow the README.md and deploy the backend to Google App Engine.  Note that the Bundle ID for this iOS client is `com.google.sample.MobileAssistantIOS`.

3. Follow steps in README.md in [MobileAssistant-Data directory](https://github.com/GoogleCloudPlatform/solutions-mobile-shopping-assistant-backend-java/tree/master/MobileAssistant-Data) to import sample data to the deployed backend if you have not already done so.

### Set up Mobile Assistant iOS Client Xcode Project

#### Open MobileAssistantIOS project in Xcode
1. Open a new Finder window and navigate to the directory you have extracted the Mobile Assistant iOS Client.  Double click on the MobileAssistantIOS.xcodeproj file. It will  open the project in Xcode automatically.

#### Configure Mobile Assistant Backend to Recognize the iOS Client App
1. The Mobile Assistant Backend was configured to use a particular *IOS_CLIENT_ID* in step 2 of the Prerequisites.

2. Look up the client secret, that corresponds to the *IOS_CLIENT_ID* in the backend, from [Google API Console](http://code.google.com/apis/console), update the following constants in the `ShopsTableViewController.m` file in the MobileAssistantIOS project:

  * kKeyClientID (in line 36)
  * kKeyClientSecret (in line 37)

3. In the MobileAssistantIOS/API/GTLServiceShoppingassistant.m file, replace the string "{{{YOUR APP ID}}}" with the Application ID where the Mobile Assistant Backend was deployed.

### Build and Execute the MobileAssistantIOS Project
1. On the top left corner of the toolbar in Xcode, select `MobileAssistantIos > iPhone 6.1 Simulator`.  Click the `Run` button to execute the app.

2. Switch to the `iOS Simulator` application from Xcode.  You can now interact with the MobileAssistantIOS Client App.

  * Since this application is location-sensitive, to work with existing data in the Mobile Assistant Backend, set the location to `{Latitude: 37.785834, Longtitude: -122.406417}` via the menu `Debug > Location > Custom Location…`
  * If prompted, click "OK" to allow MobileAssitantIOS app to access your current location.
  * The application may ask for your Google Account information. Sign in and consent to allow the application to `view your email address` and `know who you are on Google`.
  * On the first screen, click any store location.  On the next screen, the application will display different recommendations and offers based on different store location.

### Take a Closer Look at MobileAssistantIOS Client App
In `ShopsTableViewController.m` file, set breakpoints to the following methods:

* getAllShops
* getAllOffers
* getAllRecommendations

These methods are responsible for making the requests to the Mobile Assistant Backend via the Google APIs Client Library for Objective-C.

### Optional Reference
1. Click [here](https://developers.google.com/appengine/docs/java/endpoints/consume_ios#configuring-your-web-app) to learn more about generating iOS client library for Google Cloud Endpoint.
