//
//  ZCSobot.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCSobot.h"
#import "ZCLibClient.h"
#import "ZCLogUtils.h"

#import "ZCIMChat.h"
#import "ZCUICore.h"

#import "ZCServiceCentreVC.h"
#import "ZCLocalStore.h"


@implementation ZCSobot



+(void)startZCChatVC:(ZCKitInfo *) info
                with:(UIViewController *) byController
              target:(id<ZCChatControllerDelegate>) delegate
           pageBlock:(void (^)(id object,ZCPageBlockType type))pageClick
    messageLinkClick:(BOOL (^)(NSString *link)) messagelinkBlock{
    
    if(byController==nil){
        
        return;
    }
    if(info == nil){
        return;
    }
    
    if ([@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.appKey)] && [@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customerCode)]) {
        return;
    }
   
    
    [[ZCUICore getUICore] setLinkClickBlock:messagelinkBlock];
    [[ZCUICore getUICore] setPageLoadBlock:pageClick];
    
    ZCChatController *chat=[[ZCChatController alloc] initWithInitInfo:info];
    chat.chatdelegate = delegate;
    chat.hidesBottomBarWhenPushed = YES;
    
    if(byController.navigationController==nil){
        chat.isPush = NO;
        UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: chat];
        // 设置动画效果
        [byController presentViewController:navc animated:YES completion:^{

        }];
    }else{
        chat.isPush = YES;
        [byController.navigationController pushViewController:chat animated:YES];
    }
    
    //清理过期日志 v2.7.9
    [ZCLogUtils cleanCache];
}

+(void)openZCServiceCentreVC:(ZCKitInfo *) info
                         with:(UIViewController *) byController
                       onItemClick:(void (^)(ZCUIBaseController *object,ZCOpenType type))itemClickBlock{
    
    if(byController==nil){
        return;
    }
    if(info == nil){
        return;
    }
    
    if ([@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.appKey)] && [@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customerCode)]) {
        return;
    }
    
//    [[ZCUICore getUICore] setLinkClickBlock:messagelinkBlock];
//    [[ZCUICore getUICore] setPageLoadBlock:pageClick];
    
    ZCServiceCentreVC *chat=[[ZCServiceCentreVC alloc] initWithInitInfo:info];
    [chat setOpenZCSDKTypeBlock:itemClickBlock];
    chat.hidesBottomBarWhenPushed = YES;
    chat.kitInfo = info;
    if(byController.navigationController==nil){
        chat.isPush = NO;
        UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: chat];
        // 设置动画效果
        [byController presentViewController:navc animated:YES completion:^{
            
        }];
    }else{
        chat.isPush = YES;
        [byController.navigationController pushViewController:chat animated:YES];
    }
}



+(void)startZCChatListView:(ZCKitInfo *)info with:(UIViewController *)byController onItemClick:(void (^)(ZCUIChatListController *object,ZCPlatformInfo *info))itemClickBlock{
    if(byController==nil){
        return;
    }
    if(info == nil){
        return;
    }
    ZCUIChatListController *chat=[[ZCUIChatListController alloc] init];
    chat.hidesBottomBarWhenPushed=YES;
    chat.kitInfo = info;
    [chat setOnItemClickBlock:itemClickBlock];
    chat.byController = byController;
    if(byController.navigationController==nil){
        chat.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;    // 设置动画效果
        [byController presentViewController:chat animated:YES completion:^{
            
        }];
    }else{
        [byController.navigationController pushViewController:chat animated:YES];
    }
}


+(void)sendLocation:(NSDictionary *)locations{
    [[ZCUICore getUICore] sendMessage:locations[@"file"] questionId:@"" type:ZCMessageTypeLocation duration:@"" dict:locations];
}

+(void)sendProductInfo:(ZCProductInfo *)pinfo{
    if(pinfo){
        
        NSMutableDictionary * contentDic = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString *contextStr = @"";
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.title)] forKey:@"title"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.desc)] forKey:@"description"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.label)] forKey:@"label"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.link)] forKey:@"url"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.thumbUrl)] forKey:@"thumbnail"];
        // 转json
        contextStr = [ZCLocalStore DataTOjsonString:contentDic];
        
        [[ZCUICore getUICore] sendMessage:contextStr questionId:@"" type:ZCMessageTypeCard duration:@""];
        
    }
}



+(void)sendeOrderMsg:(NSString *)orderMsg{
    [[ZCUICore getUICore] sendMessage:orderMsg questionId:@"" type:ZCMessageTypeText duration:@"" dict:nil Type:ZCCustomLinkClikTypeOrderMsg];
}



+(void)turnServiceWithGroupId:(NSString *)groupId  Obj:(id)obj KitInfo:(id)uiInfo ZCTurnType:(NSInteger)turnType Keyword:(NSString*)keyword KeywordId:(NSString*)keywordId{
    [[ZCUICore getUICore] customTurnServiceWithGroupId:groupId Obj:obj KitInfo:uiInfo ZCTurnType:turnType Keyword:keyword KeywordId:keywordId];
}


+(BOOL)getPlatformIsArtificialWithAppkey:(NSString *)appkey Uid:(NSString*)uid{
    if ([appkey isEqualToString:[ZCUICore getUICore].getLibConfig.appKey] && [uid isEqualToString:[ZCUICore getUICore].getLibConfig.uid]) {
        if ([ZCUICore getUICore].getLibConfig.isArtificial) {
            return YES;
        }
    }
    return NO;
}

+(NSString *)getVersion {
    return zcGetSDKVersion();
}


+(NSString *)getChannel{
    return zcGetAppChannel();
}

+(NSString *)getAppVersion{
    return zcGetAppVersion();
}

+(NSString *)getiphoneType{
    return zcGetIphoneType();
}


+(NSString *)getAppName{
    return zcGetAppName();
}

+(void)setShowDebug:(BOOL)isShowDebug{
     [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",isShowDebug] forKey:ZCKey_ISDEBUG];
}

+(NSString *)getsystorm{
    return zcGetSystemVersion();
}




@end
