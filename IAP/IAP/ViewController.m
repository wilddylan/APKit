//
//  ViewController.m
//  IAP
//
//  Created by Dylan on 15/9/24.
//  Copyright (c) 2015年 Dylan. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>
#import "SVProgressHUD.h"
#import "NSData+DLExtension.h"

@interface ViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate,

// 内购需要
SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    
    NSString * productID;
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray * detailArray;
@property (nonatomic, strong) NSMutableArray * productIDArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.dataArray addObject:@"余额6元套餐"];
    [self.dataArray addObject:@"余额18元套餐"];
    [self.dataArray addObject:@"余额30元套餐"];
    [self.dataArray addObject:@"余额68元套餐"];
    [self.dataArray addObject:@"余额98元套餐"];
    [self.dataArray addObject:@"余额163元套餐"];
    
    [self.detailArray addObject:@"花费6元购买套餐以供使用"];
    [self.detailArray addObject:@"花费18元购买套餐以供使用"];
    [self.detailArray addObject:@"花费30元购买套餐以供使用"];
    [self.detailArray addObject:@"花费68元购买套餐以供使用"];
    [self.detailArray addObject:@"花费98元购买套餐以供使用"];
    [self.detailArray addObject:@"花费163元购买套餐以供使用"];
    
    [self.productIDArray addObject:@"99997"];
    [self.productIDArray addObject:@"99998"];
    [self.productIDArray addObject:@"100000"];
    [self.productIDArray addObject:@"99999"];
    [self.productIDArray addObject:@"100001"];
    [self.productIDArray addObject:@"100002"];
    
    // 内购需要
    
    // 添加购买监听
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    
}

- (NSMutableArray *)productIDArray {
    
    if (!_productIDArray) {
        
        _productIDArray = [NSMutableArray arrayWithCapacity:1];
    }
    
    return _productIDArray;
}

- (NSMutableArray *)detailArray {
    
    if (!_detailArray) {
        
        _detailArray = [NSMutableArray arrayWithCapacity:1];
    }
    
    return _detailArray;
}

- (NSMutableArray *)dataArray {
    
    if (!_dataArray) {
        
        _dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    
    return _dataArray;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"money"];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.detailTextLabel.text = self.detailArray[indexPath.row];
    
    UIButton * buy = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.frame) - 30, 0, 40, 25)];
    CGPoint center = buy.center;
    center.y = cell.center.y;
    buy.center = center;
    
    buy.layer.borderWidth = .6;
    buy.layer.borderColor = [UIColor blueColor].CGColor;
    
    [buy setTitle:@"购买" forState:UIControlStateNormal];
    [buy setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [cell addSubview:buy];
    
    buy.layer.masksToBounds = YES;
    buy.layer.cornerRadius = 3;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * string = [NSString stringWithFormat:@"您将要购买 %@", self.dataArray[indexPath.row]];
    
    // 设置商品ID
    
    productID = self.productIDArray[indexPath.row];
    
    [[[UIAlertView alloc] initWithTitle:@"提示信息" message:string delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        // 检测是否允许内购
        
        if([SKPaymentQueue canMakePayments]){
            
            [self requestProductData:productID];
        }else{
            
            NSLog(@"不允许程序内付费");
        }  
    }
}

#pragma mark - 内购的核心部分

//请求商品
- (void)requestProductData:(NSString *)type{
    
    NSLog(@"请求商品");
    
    [SVProgressHUD showWithStatus:@"正在请求商品信息" maskType:SVProgressHUDMaskTypeGradient];
    
    NSArray *product = [[NSArray alloc] initWithObjects:type, nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    
    // 请求动作
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"收到了请求反馈");
    
    NSArray *product = response.products;
    if([product count] == 0){
        
        NSLog(@"没有这个商品");
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    
    NSLog(@"产品付费数量:%ld",[product count]);
    
    
    SKProduct *p = nil;
    
    // 所有的商品, 遍历招到我们的商品
    
    for (SKProduct *pro in product) {
        
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString:productID]) {
            p = pro;
        }
    }
    
    SKPayment * payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    
    [SVProgressHUD showWithStatus:@"正在发送购买请求" maskType:SVProgressHUDMaskTypeGradient];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"商品信息请求错误:%@", error);
    
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"请求结束");
    
    [SVProgressHUD dismiss];
}

//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction {
    
    for(SKPaymentTransaction *tran in transaction){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                
                [SVProgressHUD showSuccessWithStatus:@"交易完成"];
                
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                [SVProgressHUD showWithStatus:@"正在请求付费信息" maskType:SVProgressHUDMaskTypeGradient];
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                
                [SVProgressHUD showErrorWithStatus:@"已经购买过商品"];
                
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                
                [SVProgressHUD showErrorWithStatus:@"交易失败, 请重试"];
                
                break;
            default:
                
                [SVProgressHUD dismiss];
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    
    [SVProgressHUD dismiss];
    
    NSString * productIdentifier = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    NSString * receipt = [[productIdentifier dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    
    if ([productIdentifier length] > 0) {
        // 向自己的服务器验证购买凭证
        
  //      https://sandbox.itunes.apple.com/verifyReceipt
 //       receipt-data
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)dealloc{
    
    // 移除监听
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
