//
//  ZCAutoListView.h
//  SobotKit
//
//  Created by zhangxy on 2018/1/22.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZCAutoListView : UIView

//控制网络回调延迟后的显示时机
@property (nonatomic,assign)BOOL isAllowShow;

+(ZCAutoListView *) getAutoListView;


@property(nonatomic,copy) void(^CellClick)(NSString * text) ;

-(void)showWithText:(NSString *) searchText rect:(CGRect) f isHiddNav:(BOOL)isNavcHide isTranslucent:(BOOL)nacTranslucent;

-(void)dissmiss;

@end
