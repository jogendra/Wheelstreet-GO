//
//  PGTransactionViewController.h
//  PaymentsSDK
//
//  Copyright (c) 2012-2015 Paytm Mobile Solutions Ltd. All rights reserved.

#import <UIKit/UIKit.h>

#import "PGMerchantConfiguration.h"
#import "PGServerEnvironment.h"

@class PGOrder;
@class PGTransactionViewController;

typedef enum {
    kCASVerificationStatusUndefined = 0,
    kCASVerificationStatusSuccess = 1,
    kCASVerificationStatusFailed = 2
}PGMerchantVerificationStatus;


#define kContactingMessage @"Contacting Server…"
#define kPleaseWaitMessage @"Please wait…"

//========================================PGTransactionDelegate==========================================================

@protocol PGTransactionDelegate <NSObject>

@required
//Called when a transaction has completed. response dictionary will be having details about Transaction.

-(void)didFinishedResponse:(PGTransactionViewController *)controller response:(NSString *)responseString;

//Called when a user has been cancelled the transaction.

-(void)didCancelTrasaction:(PGTransactionViewController *)controller;

//Called when a required parameter is missing.

-(void)errorMisssingParameter:(PGTransactionViewController *)controller error:(NSError *) error;

@end


//========================================PGTransactionViewController==========================================================

@interface PGTransactionViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

/*
 Simpler form of transaction creation. This will take only the dynamic "PGOrder" object which can be created with currrent order details
 and will take the rest from the merchant configuration.
 */
- (id)initTransactionForOrder:(PGOrder *)order;

/*
 A delegate object should be set to handle the responses coming during the transaction
 */

@property (nonatomic, weak) id<PGTransactionDelegate> delegate;

/*
 Indicates that the transaction should happen on the staging server. If this is false then all transactions will happen on the production server.
 During development you can set this to true to ensure that the transactions are happening on the staging server and not on the actual production.
 */
@property (nonatomic, assign) BOOL useStaging;

/*
 Set this to true to enable the logging of the communication
 */
@property (nonatomic, assign, setter=setLoggingEnabled:) BOOL loggingEnabled;

/*
 Set a server Type on which the transaction should run
 */
@property (nonatomic, assign)   ServerType serverType;

/*
 Set the merchant configuration for the transaction
 */
@property (nonatomic, strong)   PGMerchantConfiguration *merchant;

/*
 Set to true if you want to pass all the params from checksum to the PG. Default is false which will send only the CHECKSUMHASH
 */
@property (nonatomic, assign) BOOL sendAllChecksumResponseParamsToPG;

/*
 Set the TopBar for customisation. by default navigation bar will be shown.
 It is mandatory to set cancelButton if topBar will set by Application.
 */
@property (nonatomic, strong)   UIView *topBar;

@property (nonatomic, strong)   UIButton *cancelButton;
@end

