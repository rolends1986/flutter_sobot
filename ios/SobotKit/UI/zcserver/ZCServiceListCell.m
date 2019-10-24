//
//  ZCServiceListCell.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/28.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCServiceListCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageView.h"

@interface ZCServiceListCell(){
    
}

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,strong) ZCUIImageView * img;


@end

@implementation ZCServiceListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(15), ZCNumber(12), ScreenWidth - ZCNumber(80), 20)];
        _titleLab.textColor = UIColorFromRGB(robotListTextColor);
        _titleLab.font = ListTitleFont;
//        _titleLab.text = @"weriewr";
        [self.contentView addSubview:_titleLab];
        
        _img = [[ZCUIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - ZCNumber(15) -11 , ZCNumber(16), 12, 14)];
        _img.image = [ZCUITools zcuiGetBundleImage:@"zcicon_list_right_arrow"];
        [self.contentView addSubview:_img];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initWithModel:(ZCSCListModel *)model{
    _titleLab.text = zcLibConvertToString(model.questionTitle);
//    self.contentView.layer.borderColor = UIColorFromRGB(0xdedede).CGColor;
//    self.contentView.layer.borderWidth = 0.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
