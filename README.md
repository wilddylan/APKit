##APKit

[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)

###### How to use

The under code block only for OS X:

```objective-c
if ( ![NSData dataWithContentsOfURL:[NSBundle mainBundle].appStoreReceiptURL] ) {
  exit(173);
}
```

Can be used in Objective-C or swift:

```ruby
pod 'APKit', '~> 0.3.1'
```

run command `pod update --no-repo-update`.

In`AppDelegate.m`：

```objective-c
#import <StoreKit/StoreKit.h>
#import <APKit/APKit.h>
```

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#warning Add transaction observer
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[APStoreObserver sharedInstance]];
    
    return YES;
}
```

```objective-c
- (void)applicationWillTerminate:(UIApplication *)application {
#warning Remove transaction observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver: [APStoreObserver sharedInstance]];
}
```

Set result listener：

```objective-c
- (instancetype)init {
    self = [super init];
    if ( self ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleProductRequestNotification:)
                                                     name:APProductRequestNotification
                                                   object:[APProductManager sharedInstance]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handlePurchasesNotification:)
                                                     name:APPurchaseNotification
                                                   object:[APStoreObserver sharedInstance]];
    }
    return self;
}
```

`handleProductRequestNotification`will be fired when get response for product.

`handlePurchasesNotification` will be fired when get response for purchase.

Request product with identifier:

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *productIdentifiers = @[
                                    @"1994101101",
                                    @"1994101102",
                                    @"1994101103"
                                    ];
    
    APProductManager *productManager = [APProductManager sharedInstance];
    [productManager
     fetchProductInformationForIds:productIdentifiers];
}
```

```objective-c
-(void)handleProductRequestNotification: (NSNotification *)notification {
    APProductManager *productRequestNotification = (APProductManager*)notification.object;
    APProductRequestStatus result = (APProductRequestStatus)productRequestNotification.status;
    
    if (result == APProductRequestSuccess) {
        NSLog(@"VALID: %@", productRequestNotification.availableProducts);
        NSLog(@"INVALID: %@", productRequestNotification.invalidProductIds);
    }
}
```

![](http://ocef2grmj.bkt.clouddn.com/productResult)

1994101103 is an invalid product identifier.

Purchase：

```objective-c
NSArray *productArray = productRequestNotification.availableProducts;
if ( productArray.count > 0 ) {
    SKProduct *product_1 = productArray.firstObject;
  
    APStoreObserver *storeObs = [APStoreObserver sharedInstance];
    [storeObs buy:product_1];
}
```

```objective-c
#pragma mark - Handle purchase notification

-(void)handlePurchasesNotification: (NSNotification *)notification {
    APStoreObserver *purchasesNotification = (APStoreObserver *)notification.object;
    APPurchaseStatus status = (APPurchaseStatus)purchasesNotification.status;
    
    switch ( status ) {
#pragma - Purchase
        case APPurchaseSucceeded: {
            NSLog(@"Purchase-Success: %@", purchasesNotification.productsPurchased);
            // Verify receipts step.
            [self verifyReceipts];
            break;
        }
        case APPurchaseFailed: {
            NSLog(@"Purchase-Failed %@", purchasesNotification.errorMessage);
            break;
        }
        case APPurchaseCancelled: {
            NSLog(@"Purchase-Cancelled!");
            break;
        }
#pragma - Restore
        case APRestoredSucceeded: {
            NSLog(@"Restored-Success: %@", purchasesNotification.productsRestored);
            break;
        }
        case APRestoredFailed: {
            NSLog(@"Restored-Failed %@", purchasesNotification.errorMessage);
            break;
        }
        case APRestoredCancelled: {
            NSLog(@"Restored-Cancelled!");
            break;
        }
        default:
            break;
    }
}
```

Watch for line 12, ` [self verifyReceipts];` it's important.

Verify receipt：

If you get some error, try to use [SKReceiptRefreshRequest](https://developer.apple.com/reference/storekit/skreceiptrefreshrequest)。

```objective-c
NSURL *localReceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
NSData *data = [NSData dataWithContentsOfURL:localReceiptURL];
NSString *receiptStr = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
```

send `receiptStr`to your server.

About local receipt verify [local verify your receipt](https://github.com/WildDylan/iap-local-receipt).

or use [go-iap-verify-receipt](https://github.com/awa/go-iap)

###### Release note

- 0.3.2: Update comments and add some documents, update license, remove unused files and folders.

- 0.3.0, 0.3.1: Clean workspace, format code with 2 indent.
- 0.2.0: Download Hosted content.
- 0.1.0: basic features develope, initialized repo.

###### ReadMe in cdn

[APKit introduction](http://blog.devdylan.cn/APKit/)

###### License

MIT. 
