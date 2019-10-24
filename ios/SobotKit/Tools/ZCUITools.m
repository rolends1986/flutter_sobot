//
//  ZCUITools.m
//  SobotKit
//
//  Created by zhangxy on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUITools.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "ZCUIConfigManager.h"
#import "zcuiColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCStoreConfiguration.h"
#import "ZCUICore.h"
@implementation ZCUITools


+(UIImage *)zcuiGetBundleImage:(NSString *)imageName{
    if(zcLibConvertToString(imageName).length == 0){
        return nil;
    }
//    NSString *bundlePath=[self zcuiFullBundlePath:imageName];
//    return [UIImage imageWithContentsOfFile:bundlePath];
    if([self getZCKitInfo].isUseImagesxcassets){
        if(![imageName hasSuffix:@".png"]){
            imageName = [imageName stringByAppendingString:@".png"];
        }
    }
    
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"SobotKit.bundle"];
    
    
    NSString *img_path = [[NSBundle bundleWithPath:bundlePath] pathForResource:imageName ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:img_path];
    
//    NSString *bundleName=[NSString stringWithFormat:@"SobotKit.bundle/%@",imageName];
//    UIImage *img = [UIImage imageNamed:bundleName];
    
    if(img){
        return img;
    }else{
        NSString *bundleName=[NSString stringWithFormat:@"SobotKit.bundle/%@",imageName];
        NSBundle *bundletest = [NSBundle bundleForClass:self.class];
        return [UIImage imageNamed:bundleName inBundle:bundletest compatibleWithTraitCollection:nil];
    }
}

+(UIImage *)zcuiGetExpressionBundleImage:(NSString *)imageName{
    //    NSString *bundlePath=[self zcuiFullBundlePath:imageName];
    //    return [UIImage imageWithContentsOfFile:bundlePath];
    
    if([self getZCKitInfo].isUseImagesxcassets){
        if(![imageName hasSuffix:@".png"]){
            imageName = [imageName stringByAppendingString:@".png"];
        }
    }
    

//    NSString *strReource = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
//    NSString *bundleName = [[NSBundle bundleWithPath:strReource] pathForResource:imageName ofType:nil inDirectory:@"emoji"];
//    UIImage *img = [UIImage imageNamed:bundleName];
    
    NSString * path = [NSBundle.mainBundle pathForResource:[NSString stringWithFormat:@"SobotKit.bundle/emoji/%@",imageName] ofType:nil];
    UIImage * img = [UIImage imageWithContentsOfFile:path];
    
    if(img){
        return img;
    }else{
        NSString *strReource = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
        NSString *bundleName = [[NSBundle bundleWithPath:strReource] pathForResource:imageName ofType:nil inDirectory:@"emoji"];
        
        NSBundle *bundletest = [NSBundle bundleForClass:self.class];
        return [UIImage imageNamed:bundleName inBundle:bundletest compatibleWithTraitCollection:nil];
    }
}


+ (NSArray *)allExpressionArray {
//    NSString *filePath =  [[NSBundle mainBundle] pathForResource:@"ZCEmojiExpression.bundle/expression.json" ofType:nil];
    NSString *strReource = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
    NSString *filePath = [[NSBundle bundleWithPath:strReource] pathForResource:@"expression.json" ofType:nil inDirectory:@"emoji"];
    if(filePath==nil){
        return nil;
    }
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    if(jdata == nil){
        return nil;
    }
    //格式化成json数据
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jdata options:NSJSONReadingMutableLeaves error:nil];
    return arr;
}

+ (NSString*) zcuiFullBundlePath:(NSString*)bundlePath{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundlePath];
}


+(ZCKitInfo *)getZCKitInfo{
//    if ([ZCUIConfigManager getInstance].kitInfo != nil) {
//        return [ZCUIConfigManager getInstance].kitInfo;
//    }else{
//        return [ZCUICore getUICore].kitInfo;
//    }
    return [ZCUICore getUICore].kitInfo;
}

+(BOOL) zcgetOpenRecord{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil) {
        return configModel.isOpenRecord;
    }
    return YES;
}


+(BOOL) zcgetPhotoLibraryBgImage{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil) {
        return configModel.isSetPhotoLibraryBgImage;
    }
    return NO;
}

+(UIFont *)zcgetTitleFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.titleFont!=nil){
        return configModel.titleFont;
    }
    return TitleFont;
}

+(UIFont *)zcgetTitleGoodsFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleFont) {
        return configModel.goodsTitleFont;
    }
    return DetGoodsFont;
}


+(UIFont *)zcgetDetGoodsFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsDetFont) {
        return configModel.goodsDetFont;
    }
    return DetGoodsFont;
}


+(UIFont *)zcgetListKitTitleFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listTitleFont!=nil){
        return configModel.listTitleFont;
    }
    return ListTitleFont;
}
+(UIFont *)zcgetListKitDetailFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listDetailFont!=nil){
        return configModel.listDetailFont;
    }
    return ListDetailFont;
}

+(UIFont *)zcgetCustomListKitDetailFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.customlistDetailFont!=nil){
        return configModel.customlistDetailFont;
    }
    return CustomListDetailFont;
}



+(UIFont *)zcgetListKitTimeFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listTimeFont!=nil){
        return configModel.listTimeFont;
    }
    return ListTimeFont;
}
+(UIFont *)zcgetKitChatFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatFont!=nil){
        return configModel.chatFont;
    }
    return ListTitleFont;
}

+(UIFont *)zcgetVoiceButtonFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.voiceButtonFont!=nil){
        return configModel.voiceButtonFont;
    }
    return VoiceButtonFont;
}

+(UIColor *)zcgetBackgroundColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.backgroundColor!=nil){
        return configModel.backgroundColor;
    }
    return UIColorFromRGB(BgSystemColor);
}

/**
 *  商品中发送按钮的背景色
 *
 *
 */
+(UIColor *)zcgetGoodSendBtnColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if(configModel!=nil && configModel.goodSendBtnColor!=nil){
        return configModel.goodSendBtnColor;
    }
    return UIColorFromRGB(BgTitleColor);
}

+(UIColor *) zcgetDynamicColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.customBannerColor!=nil){
        return configModel.customBannerColor;
    }
    return UIColorFromRGB(BgTitleColor);
}


+(UIColor *) zcgetTurnServerBtnColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.trunServerBtnColor!=nil){
        return configModel.trunServerBtnColor;
    }
    return UIColorFromRGB(BgTitleColor);
}

+(UIColor *) zcgetImagePickerBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.imagePickerColor!=nil){
        return configModel.imagePickerColor;
    }
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
        return [ZCUICore getUICore].kitInfo.topViewBgColor;
    }
    return UIColorFromRGB(BgTitleColor);
}



+( UIColor *) zcgetTopBtnNolColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topBtnNolColor!=nil){
        return configModel.topBtnNolColor;
    }
    return UIColorFromRGB(TextUnPlaceHolderColor);
}


+( UIColor *) zcgetTopBtnSelColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topBtnSelColor!=nil){
        return configModel.topBtnSelColor;
    }
    return UIColorFromRGB(MultLinkColor);
}


+( UIColor *) zcgetTopBtnGreyColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topBtnGreyColor!=nil){
        return configModel.topBtnGreyColor;
    }
    return UIColorFromRGB(topBtnTitleColor);
}


+(UIColor *)zcgetLeaveSubmitTextColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leaveSubmitBtnTextColor!=nil){
        return configModel.leaveSubmitBtnTextColor;
    }
    return UIColorFromRGB(TextTopColor);
}


+(UIColor *)zcgetLeaveSubmitImgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leaveSubmitBtnImgColor!=nil){
        return configModel.leaveSubmitBtnImgColor;
    }
    return UIColorFromRGB(BgTitleColor);
}


//+(UIColor *)zcgetsocketStatusButtonBgColor{
//    ZCKitInfo *configModel = [self getZCKitInfo];
//    if (configModel != nil && configModel.socketStatusButtonBgColor) {
//        return configModel.socketStatusButtonBgColor;
//    }
//    return  UIColorFromRGB(BgTitleColor);
//}


//+(UIColor *)zcgetsocketStatusButtonTitleColor{
//    ZCKitInfo *configModel = [self getZCKitInfo];
//    if (configModel != nil && configModel.socketStatusButtonTitleColor) {
//        return configModel.socketStatusButtonTitleColor;
//    }
//    return  UIColorFromRGB(TextTopColor);
//}


+(UIColor *)zcgetScoreExplainTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scoreExplainTextColor) {
        return configModel.scoreExplainTextColor;
    }
    return  UIColorFromRGB(ScoreExplainTextColor);
}


+(UIColor *)zcgetImagePickerTitleColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.imagePickerTitleColor!=nil){
        return configModel.imagePickerTitleColor;
    }
    if ([ZCUICore getUICore].kitInfo.topViewTextColor != nil) {
        return [ZCUICore getUICore].kitInfo.topViewTextColor;
    }
    return UIColorFromRGB(TextTopColor);
}

+(UIColor *)zcgetLeftChatColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatColor!=nil){
        return configModel.leftChatColor;
    }
    return [UIColor whiteColor];
}

+(UIColor *)zcgetRightChatColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatColor!=nil){
        return configModel.rightChatColor;
    }
    return UIColorFromRGB(BgTitleColor);
}

+(UIColor *)zcgetBackgroundBottomColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.backgroundBottomColor!=nil){
        return configModel.backgroundBottomColor;
    }
    return UIColorFromRGB(BgTextEditColor);
}



// 复制选中的背景色
+(UIColor *)zcgetRightChatSelectdeColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatSelectedColor!=nil){
        return configModel.rightChatSelectedColor;
    }
    return UIColorFromRGB(BgChatRightSelectedColor);
}


+(UIColor *)zcgetLeftChatSelectedColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatSelectedColor!=nil){
        return configModel.leftChatSelectedColor;
    }
    return UIColorFromRGB(BgChatLeftSelectedColor);
}






+(UIColor *)zcgetBackgroundBottomLineColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.bottomLineColor!=nil){
        return configModel.bottomLineColor;
    }
    return UIColorFromRGBAlpha(LineTextMenuColor, 0.7);
}

+(UIColor *)zcgetCommentButtonLineColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentOtherButtonBgColor!=nil){
        return configModel.commentOtherButtonBgColor;
    }
    //    return UIColorFromRGB(LineCommentLineColor);
    return [self zcgetDynamicColor];
}


+(UIColor *)zcgetCommentButtonBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentCommitButtonBgColor!=nil){
        return configModel.commentCommitButtonBgColor;
    }
    return [self zcgetDynamicColor];
}
+(UIColor *)zcgetCommentButtonBgHighColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentCommitButtonBgHighColor!=nil){
        return configModel.commentCommitButtonBgHighColor;
    }
    
    return UIColorFromRGBAlpha(0x089899, 0.95);
}

+(UIColor *)zcgetCommentCommitButtonColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentCommitButtonColor!=nil){
        return configModel.commentCommitButtonColor;
    }
    //    return UIColorFromRGB(BgTitleColor);
    return [self zcgetDynamicColor];
}


+(UIColor *)zcgetBgTipAirBubblesColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.BgTipAirBubblesColor!=nil){
        return configModel.BgTipAirBubblesColor;
    }
    return UIColorFromRGB(BgOffLineColor);
}

+(UIColor *)zcgetSubmitEvaluationButtonColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.submitEvaluationColor!=nil){
        return configModel.submitEvaluationColor;
    }
    return UIColorFromRGB(TextTopColor);
}


+(UIColor *)zcgetTopViewTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.topViewTextColor) {
        return configModel.topViewTextColor;
    }
    return  UIColorFromRGB(TextTopColor);
}


+(UIColor *)zcgetLeftChatTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.leftChatTextColor) {
        return configModel.leftChatTextColor;
    }
    return UIColorFromRGB(TextBlackColor);
}

+(UIColor *)zcgetOpenMoreBtnTextColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.openMoreBtnTextColor) {
        return configModel.openMoreBtnTextColor;
    }
    return  UIColorFromRGB(0x0daeaf);
}

+(UIColor*)zcgetGoodsTextColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleTextColor) {
        return configModel.goodsTitleTextColor;
    }
    return UIColorFromRGB(TextBlackColor);
}

+(UIColor *)zcgetGoodsDetColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsDetTextColor) {
        return configModel.goodsDetTextColor;
    }
    return UIColorFromRGB(TextGoodDetColor);
}

+(UIColor *)zcgetGoodsTipColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsTipTextColor) {
        return configModel.goodsTipTextColor;
    }
    return UIColorFromRGB(TextGoodsTipColot);
}


+(UIColor *)zcgetGoodsSendColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsSendTextColor) {
        return configModel.goodsSendTextColor;
    }
    return UIColorFromRGB(TextTopColor);
}



+(UIColor *)zcgetSatisfactionColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionTextColor) {
        return configModel.satisfactionTextColor;
    }
    return UIColorFromRGB(SatisfactionTextColor);
}


+(UIColor *)zcgetscTopTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopTextColor) {
        return configModel.scTopTextColor;
    }
    return UIColorFromRGB(robotListTextColor);
}


+(UIFont *)zcgetscTopTextFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopTextFont) {
        return configModel.scTopTextFont;
    }
    return [UIFont systemFontOfSize:17];
}


+(UIColor *)zcgetscTopBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopBgColor) {
        return configModel.scTopBgColor;
    }
    return UIColorFromRGB(0xFAFAFA);
}


+(UIColor *)zcgetscTopBackTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopBackTextColor) {
        return configModel.scTopBackTextColor;
    }
    return UIColorFromRGB(TextNetworkTipColor);
}

+(UIFont *)zcgetscTopBackTextFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopBackTextFont) {
        return configModel.scTopBackTextFont;
    }
    return VoiceButtonFont;
}


+(UIColor *)zcgetNoSatisfactionTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.noSatisfactionTextColor) {
        return configModel.noSatisfactionTextColor;
    }
    return UIColorFromRGB(NoSatisfactionTextColor);
}

+(UIColor *)zcgetSatisfactionTextSelectedColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionTextSelectedColor) {
        return configModel.satisfactionTextSelectedColor;
    }
    return UIColorFromRGB(TextTopColor);
}
+(UIColor *)zcgetSatisfactionBgSelectedColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionSelectedBgColor) {
        return configModel.satisfactionSelectedBgColor;
    }
    return UIColorFromRGB(BgTitleColor);
}



+(UIColor *)zcgetRightChatTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.rightChatTextColor) {
        return configModel.rightChatTextColor;
    }
    return UIColorFromRGB(TextTopColor);
}


+(UIColor *)zcgetTimeTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.timeTextColor) {
        return configModel.timeTextColor;
    }
    return UIColorFromRGB(TextTimeColor);
}


+(UIColor *)zcgetTipLayerTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.tipLayerTextColor) {
        return configModel.tipLayerTextColor;
    }
    return UIColorFromRGB(TextTopColor);
}


+(UIColor *)zcgetServiceNameTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.serviceNameTextColor) {
        return configModel.serviceNameTextColor;
    }
    return UIColorFromRGB(TextNameColor);
}

+(UIColor *)zcgetNickNameColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.nickNameTextColor) {
        return configModel.nickNameTextColor;
    }
    return UIColorFromRGB(RClabelNickColor);
}


+(UIColor *)zcgetChatLeftLinkColor{
    
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatLeftLinkColor) {
        return configModel.chatLeftLinkColor;
    }
    return  UIColorFromRGB(RCLabelLinkColor);
}

+(UIColor *)zcgetChatMultLinkColor{
    
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatLeftMultColor) {
        return configModel.chatLeftMultColor;
    }
    return  UIColorFromRGB(MultLinkColor);
}


+(UIColor *)zcgetChatRightlinkColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatRightLinkColor) {
        return configModel.chatRightLinkColor;
    }
    return  UIColorFromRGB(RCLabelRLinkColor);
}


+(UIColor *)zcgetChatRightVideoSelBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.videoCellBgSelColor) {
        return configModel.videoCellBgSelColor;
    }
    return  UIColorFromRGB(BgVideoCellSelColor);
}


+(UIColor *)zcgetLineRichColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.LineRichColor) {
        return configModel.LineRichColor;
    }
    return  UIColorFromRGB(LineRichColot);
}



+(UIColor *)getNotifitionTopViewBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewBgColor) {
        return configModel.notificationTopViewBgColor;
    }
    return  UIColorFromRGB(noticBgColor);
}


+(UIColor *)getNotifitionTopViewLabelColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewLabelColor) {
        return configModel.notificationTopViewLabelColor;
    }
    return  UIColorFromRGB(noticTextColor);
}


+(UIFont *)zcgetNotifitionTopViewFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewLabelFont) {
        return configModel.notificationTopViewLabelFont;
    }
    return ListTitleFont;
}

//+(NSString *)zcgetLinkColor:(BOOL) isRight{
//    if(isRight){
//        return RCLabelRLinkColor;
//    }
//    NSString *stringColor = [[ZCLibServer sharedZCLibServer] getZCLibConfig].color;
//    if (zcLibConvertToString(stringColor).length>4) {
//        return stringColor;
//    }
//    return RCLabelLinkColor;
//}



//检查是否有相册的权限
+(BOOL)isHasPhotoLibraryAuthorization{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        return NO;
    }
    return YES;
}
//检测是否有相机的权限
+(BOOL)isHasCaptureDeviceAuthorization{
    if (iOS7) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            return NO;
        }
        return YES;
    }else{
        return YES;
    }
}



/**
 war获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
//                                   [NSNumber numberWithFloat: 16000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt: 16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   nil];
    return recordSetting;
}

+(BOOL)isOpenVoicePermissions{
    __block BOOL isOpen = NO;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
      
        [avSession requestRecordPermission:^(BOOL available) {
            
            if (available) {
//                NSLog(@"语音权限开启");
                isOpen = YES;
            }
            else
            {
                isOpen = NO;
                
            }
        }];
        
    }

    return isOpen;
}

+ (UIColor *)getColor:(NSString *)hexColor
{
    if(hexColor!=nil && hexColor.length>6){
        hexColor=[hexColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}



+ (int)IntervalDay:(NSString *)filePath
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    // [ZCLogUtils logHeader:LogHeader debug:@"create date:%@",[attributes fileModificationDate]];
    NSString *dateString = [NSString stringWithFormat:@"%@",[attributes fileModificationDate]];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *formatterDate = [inputFormatter dateFromString:dateString];
    
    // 矫正时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: formatterDate];
    NSDate *localeDate = [formatterDate  dateByAddingTimeInterval: interval];
    
    unsigned int unitFlags = NSDayCalendarUnit;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *d = [cal components:unitFlags fromDate:localeDate toDate:[NSDate date] options:0];
    
    
    // [ZCLogUtils logHeader:LogHeader debug:@"%d,%d,%d,%d",[d year],[d day],[d hour],[d minute]];
    
    int result = (int)d.day;
    
    //	return 0;
    return result;
}


#define imageVALIDMINUTES 3
#define voiceVALIDMINUTES 3
+(BOOL)imageIsValid:(NSString *)filePath{
    if ([self IntervalDay:filePath] < imageVALIDMINUTES) { //VALIDDAYS = 有效时间分钟
        return YES;
    }
    return NO;
}

+(BOOL)videoIsValid:(NSString *)filePath{
    if ([self IntervalDay:filePath] < voiceVALIDMINUTES) { //VALIDDAYS = 有效时间分钟
        return YES;
    }
    return NO;
}


+ (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
    [view.layer addSublayer:border];
}

+ (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth andViewWidth:(CGFloat)viewWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, viewWidth, borderWidth);
    [view.layer addSublayer:border];
}

+ (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth withView:(UIView *) view {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}
+ (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth andViewWidth:(CGFloat)viewWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, viewWidth, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}
+ (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth  withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}

+ (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth  withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}

+(UIImage *) getFileIcon:(NSString * ) filePath fileType:(int) type{
    NSString *mimeType  = type>0 ? @"" : [ZCUITools mimeWithString:filePath];
    NSString *iconName = @"";
    if([@"application/msword" isEqual:mimeType] || type == 13 || [@"application/vnd.ms-works" isEqual:mimeType]){
        iconName = @"zcicon_file_word";
    }else if([@"application/vnd.ms-powerpoint" isEqual:mimeType] || type == 14){
        iconName = @"zcicon_file_ppt";
    }else if([@"application/vnd.ms-excel" isEqual:mimeType] || type == 15){
        iconName = @"zcicon_file_excel";
    }else if([@"application/pdf" isEqual:mimeType] || type == 16){
        iconName = @"zcicon_file_pdf";
    }else if([@"application/vnd.ms-excel" isEqual:mimeType] || type == 15){
        iconName = @"zcicon_file_excel";
    }else if([@"application/zip" isEqual:mimeType] || type == 19 || [@"application/rar" isEqual:mimeType]){
        iconName = @"zcicon_file_zip";
    }else if([mimeType hasPrefix:@"audio"] || type == 17){
        iconName = @"zcicon_file_mp3";
    }else if([mimeType hasPrefix:@"video"] || type == 18){
        iconName = @"zcicon_file_mp4";
    }else if([@"text/plain" isEqual:mimeType] || type == 20){
        iconName = @"zcicon_file_txt";
    }else{
        iconName = @"zcicon_file_unknow";
    }
    
    return [ZCUITools zcuiGetBundleImage:iconName];
}

+ (NSString *)mimeWithString:(NSString *)string
{
    // 先从参入的路径的出URL
    NSURL *url = [NSURL fileURLWithPath:string];
    if ([string hasPrefix:@"file:///"]){
        url = [NSURL URLWithString:string];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 只有响应头中才有其真实属性 也就是MIME
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    return response.MIMEType;
}


+(void)zcShakeView:(UIView*)viewToShake
{
    CGFloat t =2.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}


+ (NSString *)zcTransformString:(NSString *)originalStr{
    NSString *text = originalStr;
    
    //解析http://短链接
    NSString *regex_http = @"(http(s)?://|www)([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";//http://短链接正则表达式
    
//        NSString *regex_http = @"http(s)?://[^\\s()<>]+(?:\\([\\w\\d]+\\)|(?:[^\\p{Punct}\\s]|/))+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";
    // 识别 www.的链接
//    NSString *regex_http =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSString *regex_text=[NSString stringWithFormat:@"%@(?![^<]*>)(?![^>]*<)",regex_http];
    //    NSArray *array_http = [text componentsMatchedByRegex:regex_text];
    
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_text
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:originalStr options:0 range:NSMakeRange(0, [originalStr length])];
    
    NSInteger len = 0;
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        
        NSRange range = match.range;
        NSString* substringForMatch = [originalStr substringWithRange:range];
        
        //[ZCLogUtils logHeader:LogHeader debug:@"%@,%@",NSStringFromRange(range),substringForMatch];
        
        NSString *funUrlStr = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",substringForMatch, substringForMatch];
        text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location+len, substringForMatch.length) withString:funUrlStr];
        len = 15+substringForMatch.length;
    }
    
    
    
    //解析表情
    NSString *tempText = text;
    NSError *err = nil;
    // 替换掉atuser后的text
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]" options:0 error:&err];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    NSInteger mxLength = 0;
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = match.range;
        NSString  *key=[text substringWithRange:wordRange];
        if([[[ZCUIConfigManager getInstance] allExpressionDict] objectForKey:key]){
            NSString *imgText = [NSString stringWithFormat:@"<img src=%@.png>",[[[ZCUIConfigManager getInstance] allExpressionDict] objectForKey:key]];
            tempText = [tempText stringByReplacingOccurrencesOfString:key withString:imgText options:0 range:NSMakeRange(wordRange.location+mxLength, wordRange.length)];
            mxLength = mxLength + (imgText.length - key.length);
            
        }
    }
    text = tempText;
    
//    NSLog(@"%@",text);
    //返回转义后的字符串
    return text;
}

+ (NSString *)zcAddTransformString:(NSString *)contentText{
    NSString *text = contentText;
    // 识别 www.的链接
        NSString *regex_http = @"(http(s)?://|www)([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";//http://短链接正则表达式
    
     NSString *regex_text=[NSString stringWithFormat:@"%@(?![^<]*>)(?![^>]*<)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$^&*+?%%:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$^&*+?%%:_/=<>]*)?)",regex_http];
    
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_text
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:contentText options:0 range:NSMakeRange(0, [contentText length])];
    
    NSInteger len = 0;
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        
        NSRange range = match.range;
        NSString* substringForMatch = [contentText substringWithRange:range];
        
        [ZCLogUtils logHeader:LogHeader debug:@"%@,%@",NSStringFromRange(range),substringForMatch];

        
        NSString *funUrlStr = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",substringForMatch, substringForMatch];
        text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location+len, substringForMatch.length) withString:funUrlStr];
        len = 15+substringForMatch.length;
    }
    
    //    NSLog(@"%@",text);
    //解析表情
    NSString *tempText = text;
    NSError *err = nil;
    // 替换掉atuser后的text
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]" options:0 error:&err];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    NSInteger mxLength = 0;
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = match.range;
        NSString  *key=[text substringWithRange:wordRange];
        if([[[ZCUIConfigManager getInstance] allExpressionDict] objectForKey:key]){
            NSString *imgText = [NSString stringWithFormat:@"<img src=%@.png>",[[[ZCUIConfigManager getInstance] allExpressionDict] objectForKey:key]];
            tempText = [tempText stringByReplacingOccurrencesOfString:key withString:imgText options:0 range:NSMakeRange(wordRange.location+mxLength, wordRange.length)];
            mxLength = mxLength + (imgText.length - key.length);
            
        }
    }
    text = tempText;
//    NSLog(@"%@",text);
    
    //返回转义后的字符串
    return text;
}




@end
