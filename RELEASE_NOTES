v5.0.4
- Added code and examples to support the change password functionality of flow forms.  This includes a new method that allow the developer to build up a simple Map of flow form names and values and submit the form to any Janrain "oauth/" compatible endpoint.  This method does no validation that the submitted data is accurate for the flow form configuration.  All validation of the submitted data and error reporting will be done server-side.
```
/**
 * Posts the provided form data to the provided endpoint with the provided form name.
 * NOTE: This method does not validate the provided data contents - errors will be returned
 * from the server-side api and must be handled by the integration developer.
 */
+(void)postFormWithFormDataProvided:(JRCaptureUser *)user
                  toCaptureEndpoint: (NSString *)endpointUrl
                       withFormName:(NSString *)formName
                       andFieldData:(NSMutableDictionary *)fieldData
                           delegate:(id <JRCaptureDelegate>)delegate;
```
- Resolved bug where initiating the Link Account process would generate and store a new Refresh Secret and subsequently disrupt future token refresh attempts.
- Improved LinkAccount click behavior in the sample apps.
- Improved error message parsing in several areas.  NOTE: the `JRCaptureError.m` file's `errorFromResult` method will now initially use the "message" attribute from the Capture response and then fall back to the "error_description" attribute if no "message" data was found.  In general the "message" attribute provides a more user friendly and useful error message.

v5.0.3
- Resolved issue where optional `engageAppUrl` setting wasn't actually optional during native authentication causing native authentication to fail.
- Updated SimpleDemoNative app's AppDelegate to use
`- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation` for all URL redirection handlers instead of `- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options`
- Tested Sample apps with version 0.8.0 of the OpenID AppAuth iOS libraries.
- Tested the SimpleDemoNative sample app with the FacebookSDK version 4.20.2 and version 2.8.1 of TwitterKit

v5.0.2
 - Set the default scopes for Google OpenID AppAuth requests to include all available scopes.
 - Added an optional janrain-config.plist setting that allows you to define the OpenID Scopes that will be requested during the Google OpenID request process. Please refer to the Upgrade Guide for additional information.

v5.0.1
 - Resolved Cocoapods incompatibility.  Implemented JROpenIDAppAuthGoogleDelegate Protocol to remove reference to AppDelegate.h from JROpenIDAppAuthGoogle.m
 - Updated sample apps and documentation to demonstrate implementation of the JROpenIDAppAuthGoogleelegate protocol.

v5.0
 - Dropped support for iOS 7, now only supports iOS 8+
 - Implemented OpenID AppAuth Libraries(Required) to support Google WebView Deprecation.
 - Added support for non-standard Engage server url's
 - Added support for custom flow download location url's
 - Added support for Native Authentication using the WeChat application
 - Updated sample applications as needed to implement new changes.

v4.0
 - Dropped support for iOS 6, now only supports iOS 7+
 - Removed Native Authentication Provider (Facebook, Google, Twitter) SDK dependencies from the SDK.
 - Added example code to the SimpleCaptureDemo app for implementing the current releases of Native Authentication Provider's SDK's to retrieve provider authentication tokens and pass them to the SDK.
 - Added/Updated missing images for Instagram, Google+, PayPal OpenID Connect and a future provider.
 - Bugfix: Improved error handling in SimpleCaptureDemo app.
 - Added: updateProfileForUserWithForm:withEditProfileForm:delegate - convenience method for updating a user profile with any Registration configuration form that is compatible with the update_profile_native endpoint.
- NOTE:  Account Linking no longer integrates with Native Authentication.  Only webview based authentication is supported in the link account workflow.
 - Updated Native Provider documentation

v3.9.0
- iOS 8.3 compatibility

v3.8.0
 - iOS 8 Compatibility
 - Support for 64bit architectures
 - Improved ARC support in Capture model generation script

v3.7.2
 - Fixes bug that would replace plurals with an empty array when the array
   should be non-empty

v3.7.1
 - Added notification for when flow download succeeds or fails

v3.7.0
 - SDK now uses Automatic Reference Counting
 - Removed unused backplane support
 - Added icon support for Microsoft Account provider
 - User landing screen now uses square provider icons
 - Fixed bug with SMS URL shortening (Thanks hanvic)
 - Fixed crash when flow references field that does not exist in user record
 - User facing strings are now localizable

v3.6.1
 - Allow Capture Domain, Capture Client ID, and Engage App ID to be changed
   after initalization

v3.6.0
 - Dropped support for iOS 5, now only support iOS 6+
 - Added support for sign-in using the Google+ SDK
 - Added support for sign-in using iOS's Twitter accounts
 - Added ability to resend email verification email
 - Removed old Engage only sample apps

v3.5.1
 - Fixes display of Yahoo! login page. Input fields are visible in iPad.

v3.5.0
 - Support for Capture account linking and unlinking
 - Support for editing user profiles
 - Updated Phongap plugin for Phonegap 3
 - Improved iOS 7 Navigation Bar support

v3.4.1
 - New upgrade guides for the most commonly deployed versions

v3.4.0
 - iOS 7 Compatibility
 - Fixes a bug in SimpleCaptureDemo which prevented two step registration from working
   with the standard_flow
 - Support for initiating the Forgot Password Flow
 - Added Google+ & Tumblr icons
 - Updated Phonegap plugin for Phonegap 2.7.0
 - Added support for code_and_token response types

v3.3.9
 - Adds friendly fast failure for unsupported trad auth forms

v3.3.8
 - Updates traditional sign-in APIs to be compatible with Janrain's "standard
   user registration flow".
 - Traditional sign-in APIs now require a Capture app ID and flow name to be
   configured, so that a local copy of the flow can be downloaded by the SDK.

v3.3.7
 - Fixes a bug in native authentication, which rendered it incompatible with
   registration
 - Fixes a bug in native authentication flows subsequent to the first
 - Fixes a bug in native authnetication allowing a concurrent web-based auth

v3.3.6
 - Fixes an unitialized variable error which causes erroneous JSON parsing errors
 - Factors Capture delegate protocols into a separate class in SimpleCaptureDemo in
   order to clarify what delegate messages, exactly, need to be responded to.

v3.3.5
 - Adds additional debug logging for troubleshooting UI state transitions

v3.3.4
 - Fixes flow_version parameter passing for traditional authentication

v3.3.3
 - Fixes another state transition bug, enlarges cookie-clearing-conditions (to cover
   the direct-to-provider auth flows)

v3.3.2
 - Fixes some UI state transition bugs involving provider-direct authentication flows

v3.3.1
 - Fixes +[JRCaptureUser fetchCaptureUserFromServerForDelegate:context:], which had been
   broken in an earlier refactoring

v3.3.0
 - Adds support for Facebook native authentication, i.e. via the iOS Social and Accounts
   framework, or via the Facebook SDK. See 'Docs/Native Authentication Guide.md' for
   details.
 - Adds support for Key Value Coding to the JRCaptureUser record model.
 - Adds support for users having multiple active sharing sessions across separate iOS
   devices.

v3.2.13
 - Emits less logging, adds support for a JR_NO_RELEASE_LOGGING #define to disable
   error logging. Eliminates some compiler warnings from logging macros.

v3.2.12
 - Fixes flow name parameter name, previously had relied on defaul_flow_name setting in
   the dashboard for operation when a flow-name had been set.

v3.2.11
 - Fixes display of logged in user in sharing controller

v3.2.10
 - Fixes incorrect file organization, breaking Engage-only builds
   This fix requires removing and re-adding the Janrain project group in the Project
 - Adds minimum deployment target check (iOS 5.0 or above is required.)

v3.2.9
 - Fixes an uninitialized error return value, which can cause erroneous API errors

v3.2.8
 - Documentation bug fixes (symbol name updates)

v3.2.7
 - Fixes a bug causing a failed first attempt at authentication preventing a successful
   second attempt.
 - Add more backwards-compatibility for symbol renames
 - Fixes a bug related to some IDP session cookies and switching to a different identity
   on the same IDP.
 - Removes JSONkit dependency
 - Fixes a bug relating to new record model objects trying to update unchanged fields

v3.2.6
 - Fixes Engage library re-initialization bug

v3.2.5
 - Adds access token refresh support

v3.2.1
 - Fixes form validation failure recognition

v3.2.0
 - Adds new two-step social registration and tradtional registration support

v3.1.4
 - Fixes additional dictionary literal invalid values

v3.1.3
 - Fixes a crash involving dictionary literals and invalid values

v3.1.2
 - Fixes zPosition of the core animation layer used when modally presenting view controllers.

v3.1.1
 - Fixes social sharing dialog, social sharing demo

v3.1.0
 - Adds support for configuration of custom OpenID and Engage-supported SAML providers

v3.0.9
 - Bug fix to throttle back overzealous force-reauth flags which were triggering double-password-entry
   Facebook authentications

v3.0.8
 - Bug fix to tweak the UIWebView properties when rendering sign-in pages for Facebook on iPad
   This fix also sets the default modal dialog size to that of an iPhone 5, where it used to be
   an iPhone 4

v3.0.7
 - Bug fix to add Backplane channel parameter during sign-ins

v3.0.6
 - Fixes a build error with the Phonegap Plugin

v3.0.5
 - Updates to the user generator model to fix merging bug in new script feature

v3.0.4
 - Removes internal error string from the built-in traditional sign-in UI

v3.0.3
 - Updates Capture model generation script to auto-include reserved attrs

v3.0.2
 - Fixes for the display bugs in the example Capture "form" in SimpleCaptureDemo

v3.0.1
 - Regenerates SCD user model for new schema
 - Updated SCD schema to modern default schema to accomodate existing native flow config file
 - This resolves misidentified bug in merge flow

v3.0.0
 - Removes old JRCapture+setEngageAppId... signature in favor of new configuration signature
   covering new configuration parameters
 - Adds merge flow support
  - See developers.janrain.com Capture for iOS integration guide for usage
 - Uses new Capture flow-config-enabled endpoints
 - Removes legacy two-step social reg
 - Paves the way for new two-step social reg, trad reg

v2.5.2
 - Internal project file cleanup
 - Custom UINavigationController bug fix

v2.5.1
 - Adds PhoneGap 2.3.0 test project

v2.5.0
 - Fixes major modal dialog presentation on iPad bug
  - Now follows presentedViewController chain down from .rootViewController and presents from the end
 - Minor internal updates, including visibility fixes for previously over-visible helper funcs
 - Demo bug fix

v2.4.2
 - Guards against exceptions in a private test API
 - Minor internal changes

v2.4.1
 - Added image assets for two providers
 - Dead code elim, minor DRY up
 - Have a new pre-commit git hook to keep lib version changing, it will be one commit behind

v2.4.0
 - First release with release notes
 - most recent previous release was 2.3.1, but a bunch of interstitial commits had been pushed to master
 - Fix to reduce possibility of UIWebViewDelegate messages to JRWebViewController zombies
 - Internal code cleanup / debt reduction / maintenance / ring around the rosie
 - Adds support for configuration of a Backplane channel for Capture sign-ins.
 - Updates PhoneGap plugin for 2.3.0, now requires JR_ENABLE_CORDOVA_PLUGIN preprocessor symbol to be defined
 - Fixes for iOS 6 on iPad animations
  - Now requires QuartzCore framework
 - Culls some log fluff
 - Uses window.rootViewController to present dialogs from when available (e.g. when your host app sets it)
  - This improves the integrity of the first responder chain and allows dialogs to receive rotation events
    in some cases.
 - Updates to the UI of the samples for 4" screens and fixes some older display bug in the sampless

