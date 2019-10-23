//
//  ZCHotGuideModel.h
//  SobotKit
//
//  Created by lizhihui on 2018/1/11.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCHotGuideModel : NSObject

/** 热点引导 的图片 */
@property (nonatomic,copy) NSString * icon;

/** 问题ID*/
@property (nonatomic,copy) NSString * itemId;

/** 点击询问机器人的问题*/
@property (nonatomic,copy) NSString * question;

/** 热点引导的标题*/
@property (nonatomic,copy) NSString * title;

/** URL链接*/
@property (nonatomic,copy) NSString * url;

/**
 *  对象封装
 *
 *  @param dict 获取数据解析后的数据
 *
 *  @return ZCLibConfig
 */
-(id)initWithMyDict:(NSDictionary *)dict;

@end
