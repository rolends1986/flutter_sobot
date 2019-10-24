//
//  ZCTopView.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//



#import "ZCTopView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCActionSheet.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"


/**ZCPageBlockType回调类型*/
typedef NS_ENUM(NSInteger,ZCPageBlockType) {
    ZCPageBlockGoBack     = 1,// 点击返回
    ZCPageBlockLoadFinish = 2,// 加载界面完成，可对UI进行修改
};




@interface ZCTopView()<ZCActionSheetDelegate>{
    
}

@end

@implementation ZCTopView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColor.lightGrayColor;
        [self setUI];
    }
    return self;
}

-(void)setUI{
    
    // 用户自定义背景图片
    self.topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, NavBarHeight)];
    [self.topImageView setBackgroundColor:[UIColor clearColor]];
    
    // 如果用户传图片就添加，否则取导航条的默认颜色。
    if ([ZCUITools zcuiGetBundleImage:@"zcicon_navcbgImage"]) {
        [self.topImageView setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_navcbgImage"]];
        [_topImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
        self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_topImageView setAutoresizesSubviews:YES];
    }
    //    [self.topView addSubview:self.topImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, NavBarHeight-44, self.frame.size.width- 80*2, 44)];
    [self.titleLabel setFont:[ZCUITools zcgetTitleFont]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[ZCUITools zcgetTopViewTextColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.titleLabel setAutoresizesSubviews:YES];
    
    [self addSubview:self.titleLabel];
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(0, NavBarHeight-44, 64, 44)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_pressed"] forState:UIControlStateHighlighted];
    [self.backButton setBackgroundColor:[UIColor clearColor]];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.backButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.backButton setAutoresizesSubviews:YES];
    [self.backButton setTitle:ZCSTLocalString(@"返回") forState:UIControlStateNormal];
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.backButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.backButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self addSubview:self.backButton];
    self.backButton.tag = Btn_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(self.frame.size.width-74, NavBarHeight-44, 74, 44)];
    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.moreButton setAutoresizesSubviews:YES];
    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setTitle:@"" forState:UIControlStateNormal];
    [self.moreButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.moreButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
    [self addSubview:self.moreButton];
    self.moreButton.tag = Btn_MORE;
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
//    NSLog(@"%@",NSStringFromCGRect(self.frame));
    self.titleLabel.frame = CGRectMake(80, NavBarHeight-44, self.frame.size.width- 80*2, 44);
    self.moreButton.frame = CGRectMake(self.frame.size.width-74, NavBarHeight-44, 74, 44);
    self.backButton.frame = CGRectMake(0, NavBarHeight-44, 64, 44);
    
}

// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    
    if(sender.tag == Btn_MORE){
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"清空聊天记录"), nil];
        mysheet.selectIndex = 1;
        [mysheet show];
        
    }else if(sender.tag == Btn_BACK){
        if (_btnClickBlock) {
            _btnClickBlock((int)Btn_BACK);
        }
    }
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (_btnClickBlock) {
            _btnClickBlock((int)Btn_MORE);
        }
    }
}

-(void)btnClick:(UIButton*)sender{
//    NSLog(@"点击了");
    if (_btnClickBlock) {
        _btnClickBlock((int)sender.tag);
    }
}
@end
