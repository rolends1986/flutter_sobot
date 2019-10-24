//
//  ZCUIAskCityController.h
//  SobotKit
//
//  Created by lizhihui on 2018/1/4.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "SobotKit.h"
#import "ZCLibTicketTypeModel.h"

#import "ZCAddressModel.h"
@interface ZCUIAskCityController : ZCUIBaseController

@property (nonatomic,assign) int  levle; // 1 省  2 市  3 县 区

@property(nonatomic,weak) NSString *pageTitle;

@property (nonatomic,copy) NSString * proviceId;

@property (nonatomic,copy) NSString * proviceName;

@property (nonatomic,copy) NSString * cityId;

@property (nonatomic,copy) NSString * cityName;

@property (nonatomic,copy) NSString * areaId;

@property (nonatomic,copy) NSString * areaName;


@property(nonatomic,weak) UIViewController *parentVC;


@property (nonatomic, strong)  void(^orderTypeCheckBlock) (ZCAddressModel *model);

@property(nonatomic,strong)NSMutableArray   *listArray;

@end
