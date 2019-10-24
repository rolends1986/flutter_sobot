//
//  ZCUIBaseController.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIBaseController.h"
#import "ZCLibGlobalDefine.h"
#import "ZCActionSheet.h"
#import "ZCUICore.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageTools.h"
@interface ZCUIBaseController ()<ZCActionSheetDelegate>

@end

@implementation ZCUIBaseController

//只支持竖屏
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return (NSUInteger)UIInterfaceOrientationMaskPortrait;
//}

//是否允许切换
-(BOOL)shouldAutorotate{
    return YES;
}

//只支持竖屏
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//
//    return UIInterfaceOrientationPortrait;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[ZCUITools zcgetBackgroundColor]];
}

-(void)createTitleViewWith:(int)type{
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, NavBarHeight)];
    
    [self.topView setBackgroundColor:[ZCUITools zcgetDynamicColor]];

    
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
        [self.topView setBackgroundColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
    [_topView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [_topView setAutoresizesSubviews:YES];
    [self.view addSubview:self.topView];
    
    
    // 用户自定义背景图片
    self.topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, NavBarHeight)];
    [self.topImageView setBackgroundColor:[UIColor clearColor]];
    
    // 如果用户传图片就添加，否则取导航条的默认颜色。
    if ([ZCUITools zcuiGetBundleImage:@"zcicon_navcbgImage"]) {
        [self.topImageView setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_navcbgImage"]];
        [_topImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
        self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_topImageView setAutoresizesSubviews:YES];
    }
    
    
    //    [self.topView addSubview:self.topImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, NavBarHeight-44, self.view.frame.size.width- 80*2, 44)];
    [self.titleLabel setFont:[ZCUITools zcgetTitleFont]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[ZCUITools zcgetTopViewTextColor]];
   
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.titleLabel setAutoresizesSubviews:YES];
    
    [self.topView addSubview:self.titleLabel];
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(0, NavBarHeight-44, 64, 44)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_pressed"] forState:UIControlStateHighlighted];
    
    
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg).length >0) {
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg)]  forState:UIControlStateNormal];
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg).length >0) {
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg)]  forState:UIControlStateHighlighted];
    }
    [self.backButton setBackgroundColor:[UIColor clearColor]];
    if ([ZCUICore getUICore].kitInfo.topBackNolColor != nil ) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor: [ZCUICore getUICore].kitInfo.topBackNolColor]  forState:UIControlStateNormal];
    }
    if ([ZCUICore getUICore].kitInfo.topBackSelColor != nil) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.backButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setAutoresizesSubviews:YES];
    [self.backButton setTitle:ZCSTLocalString(@"返回") forState:UIControlStateNormal];
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.backButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.backButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.topView addSubview:self.backButton];
    self.backButton.tag = BUTTON_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(self.view.frame.size.width-74, NavBarHeight-44, 74, 44)];
    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.moreButton setAutoresizesSubviews:YES];
    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setTitle:@"" forState:UIControlStateNormal];
    [self.moreButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.moreButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
    [self.topView addSubview:self.moreButton];
    self.moreButton.tag = BUTTON_MORE;
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (type == 1) {
        
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_scback_gray"] forState:UIControlStateNormal];
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_scback_gray"] forState:UIControlStateHighlighted];
        
        [self.topView setBackgroundColor:[ZCUITools zcgetscTopBgColor]];
        
        [self.titleLabel setFont:[ZCUITools zcgetscTopTextFont]];
        [self.titleLabel setTextColor:[ZCUITools zcgetscTopTextColor]];
        
        [self.backButton setTitleColor:[ZCUITools zcgetscTopBackTextColor] forState:UIControlStateNormal];
        [self.backButton.titleLabel setFont:[ZCUITools zcgetscTopBackTextFont]];
        
        self.bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, NavBarHeight -0.5, ScreenWidth, 0.5)];
        self.bottomLine.backgroundColor = UIColorFromRGB(0xACACAC);
        [self.topView addSubview:self.bottomLine];
        
    }
    
    
}

-(void)createTitleView{
    [self createTitleViewWith:0];
}


// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{

    if(sender.tag == BUTTON_MORE){
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"清空聊天记录"), nil];
        mysheet.selectIndex = 1;
        [mysheet show];
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
