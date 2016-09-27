##APKit

###### SDK更新记录:
0.2.0: 增加Host content下载相关的内容，并提出质疑： 按照苹果官方所说，收到内容下载失败的结果后，不应当结束交易，建议在结束前重试，但是我认为APKit不应当控制下载重试的等待时间，
由使用者自己控制比较灵活，所以0.2.0中只提供一次下载，当外界收到成功的通知后，理应自己查看交易（交易全部存在于`productsPurchased`，`productsRestored`数组中）是否存在下载内容，进行状态的判断与下载重试。
0.1.0: 基础购买与恢复购买功能全部可以使用

前言: 应用内支付（IAP）一直是苹果**尽力强迫**大家使用的在线支付方式, 用以获利。

直接进入主题, 如何将IAP继承至自己的应用中。

#### 准备

In-App Purchase， 简称IAP，允许在iOS app与macOS app中出售商品，如果你想将IAP加入自己的应用中，需要在集成之前做一些配置，下边将会一步一步的教大家配置相关的信息。

首先我们应了解，IAP在iOS 3.0 和 macOS 10.7之后有效。

###### Agreements, Tax, and Banking Information

在接入IAP之前，必须完成以下步骤：

1. 在创建IAP之前必须要先同意最近的开发者协议（Developer Program License Agreement）。
2. 完成一些必须的信息：协议、税务、银行信息。[获得更多关于协议、税务、银行的信息](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/ManagingContractsandBanking.html#//apple_ref/doc/uid/TP40011225-CH21-SW1)

第一步，打开 [https://developer.apple.com/account](https://developer.apple.com/account)，如果协议有更新的话, 需要先同意最新的协议。

![](http://ocef2grmj.bkt.clouddn.com/UpdateLicences)

第二部，打开[https://itunesconnect.apple.com](https://itunesconnect.apple.com)，点击协议、税务与银行，编辑并完成信息

![](http://ocef2grmj.bkt.clouddn.com/Banking)

All中，通常我们对Contact info，Bank info，Tax info进行编辑，我这里已经有了合同号，新用户打开界面后，没记错的话合同号应该是空白的。完善这一部分信息比较杂，而本文的重点还是在集成，所以协议税务和银行这里大家参考[配置协议、税务、银行的信息](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/ManagingContractsandBanking.html#//apple_ref/doc/uid/TP40011225-CH21-SW1)来完成，相信官方文档。

###### Certificates, Identifiers & Profiles

接下来配置IAP应用的App ID与描述文件，必须完成以下步骤：

1. 注册一个新的App ID（这一部分对于iOS开发者来说应该不需要赘述，小白看一下[官网关于这一部分的介绍](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingProfiles/MaintainingProfiles.html)）。

我们现在去注册一个App ID为`com.hack.app`的应用，已经有App ID的应用直接用当前的就可以。现在创建的App ID默认是勾选了。接下来注册，完成就结束了这一步的操作。

![](http://ocef2grmj.bkt.clouddn.com/AppIdSelect)

###### iTunes Connect

为了后续测试IAP，需要创建商品以及测试帐号，`iTunes Connect`提供了这些操作，需要完成以下步骤：

1. 创建测试账户

苹果提供了测试环境，被称为沙箱（sandbox），可以用来对IAP应用进行测试，模拟真实交易流程。不明真像的吃瓜群众可以看一下[如何创建Sandbox tester](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/SettingUpUserAccounts.html#//apple_ref/doc/uid/TP40011225-CH25-SW9)。

1. 创建IAP商品

手先创建一个App，然后才可以为该App创建内购商品。依旧，小白用户看一下如何[创建内购商品](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnectInAppPurchase_Guide/Chapters/CreatingInAppPurchaseProducts.html)。

再次动手实践：

步骤1： 打开[iTunes Connect](https://itunesconnect.apple.com)，点击用户和职能，Tab栏点击沙箱技术测试员，点击`+`号添加；

![](http://ocef2grmj.bkt.clouddn.com/SandBoxTester)

千万别用我的邮箱干什么坏事，比较坑的事是已经注册成为苹果用户的邮箱帐号在这里会被显示为占用。

步骤2：创建新的App，并且创建新的内购商品；

建议先读一下[内购商品的区别与创建](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnectInAppPurchase_Guide/Chapters/CreatingInAppPurchaseProducts.html#//apple_ref/doc/uid/TP40013727-CH3-SW8)这篇官方文档。

![](http://ocef2grmj.bkt.clouddn.com/createApp)

套装ID选择我们刚创建的App ID，SKU是一个你希望的唯一App的标识，不会出现在AppStore中。

创建成功之后，Tab选择功能，默认选中的项目就是App内购项目，点击添加之后，会先弹窗告诉你内购商品的4中类型的特性，选择一种，一般游戏币充值类似的选择消耗类；游戏场景开通类似的选择非消耗类；陌陌会员类似的选择自动续订，每月自动扣费；VPN年限内有效类似的选择非续订。

选择创建消耗类项目，进入创建界面后，每一个项目后边都有一个查看提示信息的问号。审核信息以及审核信息暂时不需要配置，在提交App审核之前，需要先提交内购商品审核，那个时候再上传截图也可以。产品的ID一般存储与服务器中，App从服务器获取到商品列表之后进行选择购买。

![](http://ocef2grmj.bkt.clouddn.com/ProductList)

创建2个商品供我们未来测试购买。

至此，准备工作告一段落，接下来进入集成工作。

#### 集成

完成以下步骤

1. 创建新的Xcode工程，这里依旧使用OC进行开发语言的选择。
2. 修改bundleIdentifier为我们创建的App ID。
3. 配置需要的证书以及描述文件，但是在Xcode8中为了测试便捷，自动管理。
4. 打开IAP功能支持。
5. 编码前须知。

完成步骤1，2，3：

![](http://ocef2grmj.bkt.clouddn.com/XcodeAppConfig)

这里我使用的Xcode8，Xcode7.3界面与稍有区别。

完成步骤4：

![](http://ocef2grmj.bkt.clouddn.com/openInApp)

步骤5，须知：

注：macOS开发需在didFinishLaunch要先获取一下凭证

```objective-c
if ( ![NSData dataWithContentsOfURL:[NSBundle mainBundle].appStoreReceiptURL] ) {
  exit(173);
}
```

如果不存在的话直接让程序退掉就好了。

注：测试之前，先退出当前登录的AppStore帐号，选择真机测试，需要支付的时候登录配置好的测试帐号。

#### 编码

工程目录下，`pod init`，Podfile中加入

```ruby
pod "APKit"
```

执行`pod update --no-repo-update`，如果是第一次使用，`pod install --no-repo-update`。

###### STEP1

打开`AppDelegate.m`配置`APKit`接收商店购买回调：

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

设置与移除监听，要在购买操作之前。

###### STEP2

设置商品获取与商品购买结果监听（这里是测试，所以放到了一起）：

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

第一个监听会在收到iTunes Connect商品获取成功之后，第二个监听是支付或者恢复购买的结果。

###### SETP3

请求商品，这里建议从服务器获取商品唯一标识，然后请求。这里测试写的是上边创建的ID，并写了一个不存在的商品标识以供测试（01， 02存在，03不存在）。

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

`fetchProductInformationForIds`即根据商品唯一标识获取商品信息。在通知里我们可以收到一些信息：

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

VALID: 可以使用的数组

INVALID：不正确的商品标识

![](http://ocef2grmj.bkt.clouddn.com/productResult)

1994101103不是正确的标识。

###### STEP4

发起购买请求：

```objective-c
NSArray *productArray = productRequestNotification.availableProducts;
if ( productArray.count > 0 ) {
    SKProduct *product_1 = productArray.firstObject;
  
    APStoreObserver *storeObs = [APStoreObserver sharedInstance];
    [storeObs buy:product_1];
}
```

使用`buy`方法轻松的开始购买商品，要注意的是，一定要先设置APStoreObserver为IAP的处理（在AppDelegate.m中的设置，当然也可以在你需要的位置），并设置结果监听（在上边的init方法中）。

在通知里我们可以收到一些信息：

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

这些枚举值都很清晰的表达了意思，不做赘述。需要注意的是第12行` [self verifyReceipts];`，这个是很重要的一步，用于验证凭证（验证是否合法的完成的购买）。

###### STEP5

凭证验证：

在macOS中，凭证有可能丢失

```objective-c
NSURL *localReceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
```

URL是否存在的判断，在文章准备工作的步骤5中有提到过。

目前，在iPhone非越狱设备下，我没有碰到过凭证丢失的情况（我们直接抛弃了越狱用户）。所以文中不做赘述。

凭证校验出错可以使用`SKReceiptRefreshRequest`刷新，[阅读SKReceiptRefreshRequest官方文档](https://developer.apple.com/reference/storekit/skreceiptrefreshrequest)。

获得凭证：

```objective-c
NSURL *localReceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
NSData *data = [NSData dataWithContentsOfURL:localReceiptURL];
NSString *receiptStr = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
```

将`receiptStr`发送到服务器，由服务器与苹果通信进行验证。

这里提供2种验证路径：

1. 通过与苹果通信进行验证，还没有了解过的开发小伙伴[阅读一下验证相关的文档](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573)。
2. 服务器做本地验证，实现苹果验证的规则，没有了解过的小伙伴[了解一下用python做本地凭证校验](https://github.com/WildDylan/iap-local-receipt)。这种校验方式是可以直接用到生产环境的，某知名公司已经在使用了，这是取来的经，放心尝试吧。我把它Fork到了自己的仓库里，希望各路的服务端大牛可以依据思路贡献多个版本的本地验证库，我也会抽时间用Node.js实现一遍以供使用。

#### 结语

至此，IAP开发结束了，感谢大家的阅读。

2016-9-23 @dylan.
