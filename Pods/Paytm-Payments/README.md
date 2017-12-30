# Paytm iOS Kit

Note: kindly add the dependency in your project **`SystemConfiguration.framework`**

## SDK Documentation
http://paywithpaytm.com/developer/paytm_sdk_doc/

## SDK work flow
http://paywithpaytm.com/developer/paytm_sdk_doc?target=how-paytm-sdk-works

## IOS Integration Flow
http://paywithpaytm.com/developer/paytm_sdk_doc?target=steps-for-ios-integration



# Checksum Utilities

## PHP
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_PHP

## Java
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_JAVA

## Python
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_Python

## Ruby
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_Ruby

## NodeJs
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_NodeJs

## .Net
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_DotNet



# Transaction Status API
http://paywithpaytm.com/developer/paytm_api_doc?target=txn-status-api

# Steps to configure via PODS
1. Pod init in the project Directory. It will create a Podfile.
2. Add source 'https://github.com/Paytm-Payments/Paytm_iOS_App_Kit.git' source 'https://github.com/CocoaPods/Specs.git' at the top of the podfile
3. Add pod 'Paytm-Payments' in the pod file.
4. Save and run pod install in the terminal
5. Open xcorkspace
6. Go to App Target -> Build Phases -> Link Binaries with libraries and add **SystemConfiguaration.framework**
7. Go to Pods Target -> Build Phases -> Link Binaries with libraries and add drag libPaymentsSDK.a there From Pods Resources
