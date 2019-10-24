//
//  ZCToolsCore.m
//  SobotKit
//
//  Created by zhangxy on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCToolsCore.h"

@implementation ZCToolsCore

static ZCToolsCore *_instance = nil;
static dispatch_once_t onceToken;
+(ZCToolsCore *)getToolsCore{
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [[ZCToolsCore alloc] initPrivate];
        }
    });
    return _instance;
}

-(id)initPrivate{
    self=[super init];
    if(self){
        
    }
    return self;
}

-(id)init{
    return [[self class] getToolsCore];
}



-(void)clear{
    onceToken=0;
    _instance = nil;
    
}


-(NSArray *)coderDetectorWith:(UIImage *)image {
    //    CIImage *detectImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeQRCode
    // 创建图形上下文
    CIContext * context = [CIContext contextWithOptions:nil];
    // 创建自定义参数字典
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    // 创建识别器对象
    CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:param];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSMutableArray *array = [NSMutableArray array];
    if (features.count == 0) {
        
        //        NSLog(@"暂未识别出扫描的二维码");
    } else {
        
        for (int index = 0; index < [features count]; index ++) {
            
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *resultStr = feature.messageString;
            //            NSLog(@"相册中读取二维码数据信息 - - %@", resultStr);
            [array addObject:resultStr];
        }
    }
    NSSet *set = [NSSet setWithArray:array];
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortSetArray = [set sortedArrayUsingDescriptors:sortDesc];
    return [sortSetArray copy];
}

// 检测图片中的二维码,返回 一个URL 字符串，或者nil
-(id )coderURLStrDetectorWith:(UIImage *)image{
    NSArray *urlStrArray = [self coderDetectorWith:image];
    if (urlStrArray.count == 1) {
        NSString *urlStr = urlStrArray.firstObject;
        return urlStr;
    }else{
        return nil;
    }
}

- (BOOL)isUrl:(NSString *)urlString{
    if(urlString == nil)
        return NO;
    NSString *url;
    if (urlString.length>4 && [[urlString substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",urlString];
        
    }else{
        url = urlString;
        
    }
//    NSString *urlRegex = @"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://((((25[0-5]|2[0-4]\\d|1?\\d?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1?\\d?\\d))|([0-9a-z_!~*'()-]*\\.?))([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.([a-z]{2,6})(:[0-9]{1,4})?([a-zA-Z/?_=]*)\\.\\w{1,5}";
    NSString*urlRegex =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    
    
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
    
}
@end
