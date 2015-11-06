# Configuring the SimpleCaptureDemo application.

To run this demo with your own configuration:

1. Find janrain-config-default.plist
2. Copy it to janrain-config.plist
3. Edit the settings in the copy to reflect your Social Login and Registration Settings.
4. Edit the settings to include the correct form names as found in your flow file.
5. If you want to support/try the Native Authentication buttons (Facebook, Google+,Twitter) then you will need to follow these steps:
  * ###Facebook
    1. Download the Facebook SDK for iOS from this link:  https://developers.facebook.com/docs/ios
    2. Follow *ALL* of the steps on this page *EXCEPT* for Step 2 (Create a Facebook App): https://developers.facebook.com/docs/ios/getting-started/  In order for the Janrain Social Login Server to validate the provided Facebook oAuth token, the token must be provisioned from the same Facebook application that is configured for the Janrain Social Login application.  In most cases, the developer would simply add an iOS App Settings configuration to the existing Facebook App.
    3.  Use this page as a starting point for implementing native Facebook Login:  https://developers.facebook.com/docs/facebook-login/ios/v2.4
    4. Update the "SimpleCaptureDemo-Info.plist" file to use your Facebook App ID in the recommended places.  This should match the Facebook App ID that was used for configuring the Facebook provider in the Social Login Dashboard. 
    5.  Make sure that the Permissions requested in the `logInWithReadPermissions` method include the required permissions.  In most cases these permissions need to mirror the Facebook app permissions configuration of the Engage Social Login application that is configured in the Janrain Social Login Dashboard.
    6.  Refer to the `RootViewControoler.m` file for an example of how this was done with the SimpleCaptureDemo application.
 
  * ###Google+
    1. Download the Google+ SDK from this link: https://developers.google.com/+/mobile/ios/getting-started
    2. Follow *ALL* of the steps on this page that involve the XCode project configuration and Google+ app configuration: https://developers.google.com/+/mobile/ios/getting-started  In order for the Janrain Social Login Server to validate the provided Google+ oAuth token, the token must be provisioned from the same Google+ application that is configured for the Janrain Social Login application.  In most cases, the developer would simply add an iOS App Client ID configuration to the existing Google+ App. 
    3. Update the "SimpleCaptureDemo-Info.plist" file to use your Google+ App ID in the recommended places.  This should match the Google+ App ID that was used for configuring the Google+ provider in the Social Login Dashboard. 
    4. Update the Google+ "GoogleService-Info.plist" file with your Google+ App Client ID and reversed Client ID.
    5. Update the "Classes/RootViewController.m" file to use your Google Client ID (Line 56).
    6. In the case of the SimpleCaptureDemo application the integration steps were implemented in the `RootViewControoler` files with minimal changes from the examples provided by Google at this link: https://developers.google.com/identity/sign-in/ios/sign-in
    7. Make sure that the Scopes requested by the `GPPSignIn` singleton includes the required scopes.  In most cases these scopes need to mirror the Google+ app permissions configuration of the Engage Social Login application that is configured in the Janrain Social Login Dashboard.
    8. Refer to the `RootViewControoler.m` file for an example of how this was done with the SimpleCaptureDemo application.
 
  * ###Twitter
    1. Download the Fabric SDK from this link: https://get.fabric.io/ and include TwitterKit 
    2. Configure your Twitter App: http://docs.fabric.io/ios/twitter/configure-twitter-app.html  In order for the Janrain Social Login Server to validate the provided Twitter oAuth token, the token must be provisioned from the same Twitter application that is configured for the Janrain Social Login application.  In most cases, the developer would simply add an iOS App Client ID configuration to the existing Twitter App. 
    3. Update the "SimpleCaptureDemo-Info.plist" file to use your Fabric API Key and Twitter OAuth Client ID and Client Secret in the recommended places.  This should match the Twitter App ID that was used for configuring the Twitter provider in the Social Login Dashboard. 
    4. Edit the "Classes/AppDelegate.m" file to update the application with your Twitter Consumer Key and Consumer Secret. (Line 99)
    5. In the case of the SimpleCaptureDemo application the integration steps were implemented in the `RootViewControoler` files with minimal changes from the examples provided by Twitter at this link: http://docs.fabric.io/ios/twitter/authentication.html
    6. NOTE: In most default cases Twitter will not return an email address for an end user. This may cause account merging or linking issues if your Registration user experience relies heavily on merged social profiles.  This use-case is typically addressed by forcing Twitter account holders to use the "Account Linking" functionality of the SDK.  Customer's may choose to work with Twitter to get their application white-listed so it will attempt to return an email address from a user profile.  However, email addresses are not "required" for Twitter accounts, subsequently there is still no guarantee that an email address will be returned.
    7. Refer to the `RootViewControoler.m` file for an example of how this was done with the SimpleCaptureDemo application.

