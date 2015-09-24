//#import "NSData+DLExtension.h"
//#import <CommonCrypto/CommonDigest.h>
//
//@implementation NSData (DLExtension)
//
//- (NSData *)MD5
//{
//    unsigned char md5Result[CC_MD5_DIGEST_LENGTH + 1];
//    CC_MD5( [self bytes], (unsigned int)[self length], md5Result );
//    
//    NSMutableData * retData = [[NSMutableData alloc] init];
//    if ( nil == retData )
//        return nil;
//    
//    [retData appendBytes:md5Result length:CC_MD5_DIGEST_LENGTH];
//    return retData;
//}
//
//- (NSString *)MD5String
//{
//    NSData * value = [self MD5];
//    if ( value )
//    {
//        char			tmp[16];
//        unsigned char *	hex = (unsigned char *)malloc( 2048 + 1 );
//        unsigned char *	bytes = (unsigned char *)[value bytes];
//        unsigned long	length = [value length];
//        
//        hex[0] = '\0';
//        
//        for ( unsigned long i = 0; i < length; ++i )
//        {
//            sprintf( tmp, "%02X", bytes[i] );
//            strcat( (char *)hex, tmp );
//        }
//        
//        NSString * result = [NSString stringWithUTF8String:(const char *)hex];
//        free( hex );
//        return result;
//    }
//    else
//    {
//        return nil;
//    }
//}
//
//- (NSString *)detectImageSuffix
//{
//    uint8_t c;
//    NSString *imageFormat = @"";
//    [self getBytes:&c length:1];
//    
//    switch (c) {
//        case 0xFF:
//            imageFormat = @".jpg";
//            break;
//        case 0x89:
//            imageFormat = @".png";
//            break;
//        case 0x47:
//            imageFormat = @".gif";
//            break;
//        case 0x49:
//        case 0x4D:
//            imageFormat = @".tiff";
//            break;
//        case 0x42:
//            imageFormat = @".bmp";
//            break;
//        default:
//            break;
//    }
//    
//    return imageFormat;
//}
//
//- (NSString *)UTF8String
//{
//    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
//    return string;
//}
//
//+ (NSData *)dataFromBase64String:(NSString *)base64String
//{
//    NSData * charData = [base64String dataUsingEncoding: NSUTF8StringEncoding];
////    return ( b64_decode(charData) );
//}
//
//- (id)initWithBase64String:(NSString *)base64String
//{
//    NSData * charData = [base64String dataUsingEncoding: NSUTF8StringEncoding];
////    NSData * result = b64_decode(charData);
//    return ( result );
//}
//
//- (NSString *)base64EncodedString
//{
////    NSData * charData = b64_encode( self );
//    return ( [[NSString alloc] initWithData: charData encoding: NSUTF8StringEncoding] );
//}
//
//- (NSString *)APNSToken {
//    return [[[[self description]
//              stringByReplacingOccurrencesOfString: @"<" withString: @""]
//             stringByReplacingOccurrencesOfString: @">" withString: @""]
//            stringByReplacingOccurrencesOfString: @" " withString: @""];
//}
//
//@end
