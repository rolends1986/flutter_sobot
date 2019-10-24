//
//  ZCMsgDetailCell.h
//  SobotKit
//
//  Created by lizhihui on 2019/2/20.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCRecordListModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface ZCMsgDetailCell : UITableViewCell


-(void)initWithData:(ZCRecordListModel *)model IndexPath:(NSUInteger)row btnClick:(void (^)(ZCRecordListModel *model ))btnClickBlock;

-(void)setShowDetailClickCallback:(void (^)(ZCRecordListModel *model ,NSString *urlStr))detailClickBlock;

@end

NS_ASSUME_NONNULL_END
