//
//  ZCCacheCore.h
//  SobotKit
//

//  Created by zhangxy on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
缓存处理
如：
 缓存数据(状态、消息、逻辑条件参数)
 获取缓存数据(读取、缓存解析)
 电商版本数据存储
 */
@interface ZCCacheCore : NSObject

+(ZCCacheCore *) getCacheCore;

-(void)clear;

@end
