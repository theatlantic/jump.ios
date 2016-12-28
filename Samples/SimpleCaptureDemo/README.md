# Configuring the SimpleCaptureDemo application.

##IMPORTANT##
Please read the Docs/Upgrade Guide.md and RELEASE_NOTES before attempting to run these applications.  There are important configuration steps that must be taken before these apps will run.


####To run this demo with your own configuration:####

1. Find janrain-config-default.plist
2. Copy it to janrain-config.plist
3. Edit the settings in the copy to reflect your Social Login and Registration Settings.
4. Edit the settings to include the correct form names as found in your flow file.
5. Make sure you have the OpenID AppAuth for iOS Libraries implemented/installed:

The OpenID AppAuth for iOS libraries (version 0.7.1 tested) can be installed using CocoaPods or as an Xcode Workspace library.  Please refer to this link for additional information on installing the OpenID AppAuth for iOS libraries: http://openid.github.io/AppAuth-iOS/ Make sure your project's "Linked Frameworks and Libraries" includes a reference to the OpenID AppAuth for iOS Library ("libAppAuth.a")

If you are linking to the OpenID AppAuth Library repo and not using CocoaPods you may need to add the OpenID AppAuth library source code location to your Xcode project's Build Settings -> Search Paths -> Header Search Paths value: example: `/GitHub/OpenIDAppAuth/AppAuth-iOS/Source` (use the "recursive" option if needed).

The sample applications provided as part of the Janrain Mobile Libraries repository have been updated to use the Xcode Workspace library implementation method.  This may require re-linking of the libraries for your build environement. *NOTE:* You may have to convert your Xcode project to a workspace project if you do not want to use CocoaPods.


###Typical Misconfiguration Errors###

*Error*:
`Undefined symbols for architecture x86_64:
"_OBJC_CLASS_$_JROpenIDAppAuth", referenced from:
objc-class-ref in JREngage.o
objc-class-ref in JRProvidersController.o`

*Resolution*: Delete the "Janrain" folder reference from your project and re-add the folder reference linking to the latest files.  New files have been added to the Janrain Libraries and they are not being referenced in your project.

*Error*:
`/jump.ios/Janrain/JREngage/Classes/JROpenIDAppAuthGoogle.m:28:9: 'AppAuth.h' file not found`

*Resolution*: Please follow the steps outlined above and include the OpenID AppAuth library to your workspace.

*Error*:
`/jump.ios/Janrain/JREngage/Classes/JROpenIDAppAuthGoogle.m:53:59: Property 'googlePlusRedirectUri' not found on object of type 'AppDelegate *`

*Resolution*: Add the following to your AppDelegate.h file (see the Sample Application code for additional context):
`@property(nonatomic) NSString *googlePlusRedirectUri;`


*Error*:
`/jump.ios/Janrain/JREngage/Classes/JROpenIDAppAuthGoogle.m:74:80: Property 'googlePlusClientId' not found on object of type 'AppDelegate *'`

*Resolution*: Add the following to your AppDelegate.h file (see the Sample Application code for additional context):
`@property(nonatomic) NSString *googlePlusClientId;`


*Error*:
`/jump.ios/Janrain/JREngage/Classes/JROpenIDAppAuthGoogle.m:87:25: Property 'openIDAppAuthAuthorizationFlow' not found on object of type 'AppDelegate *'`

*Resolution*: Add the following to your AppDelegate.h file (see the Sample Application code for additional context):
`@property(nonatomic, strong) id<OIDAuthorizationFlowSession> openIDAppAuthAuthorizationFlow;`

*Error*:
`/jump.ios/Samples/SimpleCaptureDemo/SimpleCaptureDemo/Classes/AppDelegate.h:76:33: No type or protocol named 'OIDAuthorizationFlowSession'`

*Resolution*: Add the following to your AppDelegate.h file (see the Sample Application code for additional context):
`@protocol OIDAuthorizationFlowSession;`

*Errors*:
`(null): "_OBJC_CLASS_$_OIDAuthState", referenced from:`,
`(null): "_OBJC_CLASS_$_OIDAuthorizationRequest", referenced from:`,
`(null): "_OIDResponseTypeCode", referenced from:`,
`(null): "_OBJC_CLASS_$_OIDAuthorizationService", referenced from:`,
`(null): "_OIDScopeOpenID", referenced from:`,
`(null): "_OIDScopeProfile", referenced from:`

*Resolution*: Make sure your project's "Linked Frameworks and Libraries" includes a reference to the OpenID AppAuth for iOS Library ("libAppAuth.a")

*Errors*:
/jump.ios/Samples/SimpleCaptureDemoNative/SimpleCaptureDemoNative/Classes/AppDelegate.m:135:33: Use of undeclared identifier 'googlePlusClientId'; did you mean '_googlePlusClientId'?
/jump.ios/Samples/SimpleCaptureDemoNative/SimpleCaptureDemoNative/Classes/AppDelegate.m:136:36: Use of undeclared identifier 'googlePlusRedirectUri'; did you mean '_googlePlusRedirectUri'?

*Resolution*:
Make sure you are reading the data from your app's info.plist in your AppDelegate.m file, example:
`@synthesize googlePlusClientId;` and
`@synthesize googlePlusRedirectUri;` and
`if ([cfg objectForKey:@"googlePlusClientId"])
        self.googlePlusClientId = [cfg objectForKey:@"googlePlusClientId"];
if ([cfg objectForKey:@"googlePlusRedirectUri"])
    self.googlePlusRedirectUri = [cfg objectForKey:@"googlePlusRedirectUri"];`

