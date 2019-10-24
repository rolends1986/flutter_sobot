#import "FlutterSobotPlugin.h"
#import <flutter_sobot/flutter_sobot-Swift.h>
#import <UIKit/UIKit.h>
//#import "SobotKit.h"
#import <SobotKit/SobotKit.h>
 
@implementation FlutterSobotPlugin

static NSString * SobotAppkey;
static NSString * SobotPartnerId;

+ (void)initSdk{
    //错误日志收集
    NSDictionary<NSString *, id> *infoDictionary= NSBundle.mainBundle.infoDictionary;
    if([infoDictionary.allKeys containsObject:@"SobotAppkey"]){
        SobotAppkey=[infoDictionary valueForKey:@"SobotAppkey"];
    }
    if([infoDictionary.allKeys containsObject:@"SobotPartnerId"]){
        SobotPartnerId=[infoDictionary valueForKey:@"SobotPartnerId"];
    }
    if(SobotAppkey==nil || SobotPartnerId==nil){
        NSLog(@"===========请在plist填入SobotAppkey和SobotPartnerId================");
    }
    [ZCLibClient setZCLibUncaughtExceptionHandler];
    [[ZCLibClient getZCLibClient] initSobotSDK:SobotAppkey result:nil];
    [ZCLibClient getZCLibClient].platformUnionCode = @"1001";
}

+(void) start{
    
     UIWindow *window = [[UIApplication sharedApplication].delegate window];
     //初始化配置信息
     ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
     //initInfo.appKey = @"1ff3e4ff91314f5ca308e19570ba24bb";
     //initInfo.userId = @"请输入用户的ID";
     ////自定义用户参数
     //[self customUserInformationWith:initInfo];
        
     ZCKitInfo *uiInfo=[ZCKitInfo new];
     [[ZCLibClient getZCLibClient] setLibInitInfo:initInfo];
        
     //智齿SDK初始化启动事例
     [ZCSobot startZCChatVC:uiInfo with:window.rootViewController target:nil  pageBlock:^(id object, ZCPageBlockType type) {} messageLinkClick:^BOOL(NSString *link) {   return NO; }];
 
   
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [FlutterSobotPlugin initSdk];
    [SwiftFlutterSobotPlugin registerWithRegistrar:registrar];
}

 

@end
