
///----------------------------------
///  @name 二进制数据扩展操作
///----------------------------------

#import <Foundation/Foundation.h>

@interface NSData (DLExtension)

- (NSData *)MD5;
- (NSString *)MD5String;
- (NSString *)UTF8String;

+ (NSData *)dataFromBase64String:(NSString *)base64String;
- (id)initWithBase64String:(NSString *)base64String;
- (NSString *)base64EncodedString;

- (NSString *)APNSToken;

@end
