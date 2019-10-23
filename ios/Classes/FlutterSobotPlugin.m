#import "FlutterSobotPlugin.h"
#import <flutter_sobot/flutter_sobot-Swift.h>
#import <UIKit/UIKit.h>
#import <SobotKit/SobotKit.h>

@implementation FlutterSobotPlugin

static NSString * SobotAppkey;
static NSString * SobotPartnerId;

+ (void)initSdk{
    // 错误日志收集
    [ZCLibClient setZCLibUncaughtExceptionHandler];
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
    [[ZCLibClient getZCLibClient] initSobotSDK:SobotAppkey];
}

+(void) start{
    // 启动
    if([ZCLibClient getZCLibClient].libInitInfo == nil){
        [ZCLibClient getZCLibClient].libInitInfo = [ZCLibInitInfo new];
    }
    ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
    // 企业编号 必填
    initInfo.appKey = SobotAppkey;
    initInfo.serviceMode=2;
    initInfo.receptionistId=SobotPartnerId;
    
   // NSString *userId = [[NSUUID UUID] UUIDString];
    // 用户id，用于标识用户，建议填写 (注意：userId不要写死比如0，123456，不要设置默认值，否则获取的历史记录相同)
   // initInfo.userId = userId;
    //配置UI
    ZCKitInfo *uiInfo=[ZCKitInfo new];
    // 是否显示转人工按钮
    uiInfo.isShowTansfer = NO;
    uiInfo.isOpenActiveUser=NO;
    //设置启动参数
    [[ZCLibClient getZCLibClient] setLibInitInfo:initInfo];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    [ZCSobot startZCChatVC:uiInfo with:window.rootViewController target:nil pageBlock:^(id object, ZCPageBlockType type) {
                    // 点击返回
                    if(type==ZCPageBlockGoBack){
    //                    NSLog(@"点击了关闭按钮");
                    }
                    
                    // 页面UI初始化完成，可以获取UIView，自定义UI
                    if(type==ZCPageBlockLoadFinish){
    //                    NSLog(@"页面加载完成");
                    }
        } messageLinkClick:nil];

   
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    [FlutterSobotPlugin initSdk];
    [SwiftFlutterSobotPlugin registerWithRegistrar:registrar];
}

@end
