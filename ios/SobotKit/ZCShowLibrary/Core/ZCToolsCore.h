//
//  ZCToolsCore.h
//  SobotKit
//
//  Created by zhangxy on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 工具类
 如：
    图片处理
    获取图片地址
 
 */
@interface ZCToolsCore : NSObject

+(ZCToolsCore *)getToolsCore;

// 检测图片中的二维码,返回 一个URL 字符串，或者nil
-(id )coderURLStrDetectorWith:(UIImage *)image;

// 判断是不是 url
- (BOOL)isUrl:(NSString *)urlString;

-(void)clear;

@end
