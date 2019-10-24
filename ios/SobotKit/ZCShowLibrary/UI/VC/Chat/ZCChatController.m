//
//  ZCChatController.m
//  SobotKit
//
//  Created by zhangxy on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCChatController.h"

#import "ZCLIbGlobalDefine.h"
#import "ZCUIKeyboardDelegate.h"
#import "ZCUIImageTools.h"
#import "ZCUICore.h"
#import "ZCLibServer.h"
#import "ZCAutoListView.h"

#define MinViewWidth 320
#define MinViewHeight 540

@interface ZCChatController ()<ZCChatViewDelegate>{
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}

@property (nonatomic,strong) ZCChatView * chatView;
@property (nonatomic,assign) BOOL  isArtificial;

@end

@implementation ZCChatController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_chatView beginAniantions];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        [self setNavigationBarStyle];
    }

//    self.extendedLayoutIncludesOpaqueBars = true;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [ZCAutoListView getAutoListView].isAllowShow = YES;

}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    [ZCAutoListView getAutoListView].isAllowShow = NO;

}

- (BOOL)shouldAutorotate {
    if ([ZCUICore getUICore].kitInfo.isShowPortrait) {
        return NO;
    }else{
        return YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([ZCUICore getUICore].kitInfo.isShowPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// 横竖屏切换
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        CGFloat c = viewWidth;
        if(viewWidth > viewHeigth){
            viewWidth = viewHeigth;
            viewHeigth = c;
        }
    }else{
        CGFloat c = viewHeigth;
        if(viewWidth < viewHeigth){
            viewHeigth = viewWidth;
            viewWidth = c;
        }
    }
    // 切换的方法必须调用
    [self viewDidLayoutSubviews];
}


//**************************项目中的导航栏一部分是自定义的View,一部分是系统自带的NavigationBar*********************************
- (void)setNavigationBarStyle{
    NSString * img ;
    NSString * selImg;
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg).length >0) {
        img = zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg);
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg).length >0) {
        selImg = zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg);
    }
    
    //12 * 19
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn.titleLabel setFont:[ZCUITools zcgetTitleFont]];
    btn.frame = CGRectMake(0, 0, 44,44) ;
    if (img) {
        [btn setImage:[ZCUITools zcuiGetBundleImage:img] forState:UIControlStateNormal];
    }else{
        btn.frame = CGRectMake(0, 0, 44, 44);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
    }
    if (selImg) {
        [btn setImage:[ZCUITools zcuiGetBundleImage:selImg] forState:UIControlStateHighlighted];
    }else{
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_pressed"] forState:UIControlStateHighlighted];
    }
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = Btn_BACK ;
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateDisabled];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackNolColor] && [ZCUICore getUICore].kitInfo.topBackNolColor != nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackNolColor] forState:UIControlStateNormal];
    }
    if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackSelColor] && [ZCUICore getUICore].kitInfo.topBackSelColor !=nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
    
    CGRect lf = btn.frame;
    lf.size.width=60;
    [btn setFrame:lf];
    [btn setTitle:ZCSTLocalString(@"返回") forState:UIControlStateNormal];
    if ([ZCUICore getUICore].kitInfo.topBackTitle != nil) {
        [btn setTitle:[ZCUICore getUICore].kitInfo.topBackTitle forState:UIControlStateNormal];
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    //    self.navigationItem.leftBarButtonItem = item;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
    /**
     width为负数时，相当于btn向右移动width数值个像素，由于按钮本身和  边界间距为5pix，所以width设为-5时，间距正好调整为0；width为正数 时，正好相反，相当于往左移动width数值个像素
     */
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, item, nil];
    
    
   
   [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(self.view.frame.size.width-74, NavBarHeight-44, 74, 44)];
    [rightBtn.imageView setContentMode:UIViewContentModeRight];
    [rightBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [rightBtn setContentEdgeInsets:UIEdgeInsetsZero];
    [rightBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [rightBtn setAutoresizesSubviews:YES];    
    [rightBtn setTitle:@"" forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [rightBtn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [rightBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
    [rightBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg).length >0) {
        [rightBtn setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg)]  forState:UIControlStateNormal];
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg).length >0) {
        [rightBtn setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg)]  forState:UIControlStateHighlighted];
    }
    rightBtn.tag = Btn_MORE;
    [rightBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    
    NSArray *itemsArr = nil;
    if ([ZCUICore getUICore].kitInfo.isShowEvaluation || [ZCUICore getUICore].kitInfo.isShowTelIcon) {
        
        [rightBtn setFrame:CGRectMake(self.view.frame.size.width-44, NavBarHeight-44, 44, 44)];
//        self.titleLabel.frame = CGRectMake(100, NavBarHeight-44, self.frame.size.width- 80*2.5, 44);
        UIButton * evaluationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [evaluationBtn setFrame:CGRectMake(self.view.frame.size.width-44*2, NavBarHeight-44, 44, 44)];
        [evaluationBtn.imageView setContentMode:UIViewContentModeRight];
        [evaluationBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [evaluationBtn setContentEdgeInsets:UIEdgeInsetsZero];
        [evaluationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [evaluationBtn setAutoresizesSubviews:YES];
//        [evaluationBtn setTitle:@"评价" forState:UIControlStateNormal];
        [evaluationBtn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
        [evaluationBtn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        if ([ZCUICore getUICore].kitInfo.isShowEvaluation) {
            [evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_evaluate"] forState:UIControlStateNormal];
            [evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_evaluate"] forState:UIControlStateHighlighted];
            evaluationBtn.tag = Btn_EVALUATION;
        }
        if([ZCUICore getUICore].kitInfo.isShowTelIcon){
            [evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_call_icon"] forState:UIControlStateNormal];
            [evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_call_icon"] forState:UIControlStateHighlighted];
            evaluationBtn.tag = BUTTON_TEL;
        }
        [evaluationBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * rightItem1 = [[UIBarButtonItem alloc]initWithCustomView:evaluationBtn];
        
    }
    if([ZCUICore getUICore].kitInfo.isShowClose){
        
        [rightBtn setFrame:CGRectMake(self.view.frame.size.width-44*2, NavBarHeight-44, 44, 44)];
        //12 * 19
        UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClose.titleLabel setFont:[ZCUITools zcgetTitleFont]];
        [btnClose addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnClose setFrame:CGRectMake(self.view.frame.size.width-44, NavBarHeight-44, 44, 44)];
        
//        [btnClose setImage:[ZCUITools zcuiGetBundleImage:@"icon_video_close"] forState:UIControlStateNormal];
//        [btnClose setImage:[ZCUITools zcuiGetBundleImage:@"icon_video_close"] forState:UIControlStateHighlighted];
        [btnClose addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btnClose.tag = Btn_CLOSE ;
        [btnClose setTitle:ZCSTLocalString(@"关闭") forState:UIControlStateNormal];
        [btnClose setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        [btnClose setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateHighlighted];
        [btnClose setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateDisabled];
        [btnClose setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        
        if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackNolColor] && [ZCUICore getUICore].kitInfo.topBackNolColor != nil) {
            [btnClose setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackNolColor] forState:UIControlStateNormal];
        }
        if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackSelColor] && [ZCUICore getUICore].kitInfo.topBackSelColor !=nil) {
            [btnClose setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
        }
        
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithCustomView:btnClose];
        if (self.isArtificial) {
            itemsArr = @[item1,rightItem];
        }else{
            itemsArr = @[rightItem];
        }
        
    }
    
    if(itemsArr!=nil){
        self.navigationItem.rightBarButtonItems = itemsArr;
    }else{
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetDynamicColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
        [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    viewWidth = self.view.frame.size.width;
    
    viewHeigth = self.view.frame.size.height;

    self.view.userInteractionEnabled = YES;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        if (self.navigationController.navigationBar.translucent) {
         self.navigationController.navigationBar.translucent = NO;
        }

    }
    if (self.navigationController.navigationBarHidden ) {
        if (self.navigationController.navigationBar.translucent) {
            self.navigationController.navigationBar.translucent = NO;
        }
    }
    
    
    
    if (!self.navigationController.navigationBarHidden || self.navigationController.navigationBar.translucent) {
        [self setNavigationBarStyle];
    }
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

    self.view.backgroundColor = [UIColor whiteColor];
    
//    CGRect VF = CGRectMake(0, NavBarHeight, viewWidth, viewHeigth - NavBarHeight);
    
    CGFloat startY = 0;
    CGFloat chatHeight = viewHeigth;
    
    if (!self.navigationController.navigationBarHidden) {
        // 使用系统导航栏的时候
        if(self.navigationController.navigationBar.translucent){
            startY = NavBarHeight;
            chatHeight = viewHeigth - NavBarHeight ;
        }else{
            startY = 0;
            chatHeight = viewHeigth -NavBarHeight ;
        }
    }
    
    if (ZC_iPhoneX) {
        chatHeight = chatHeight - 34;
    }

    
    // 创建聊天视图
    _chatView = [[ZCChatView alloc]initWithFrame:CGRectMake(0, startY, viewWidth, chatHeight) WithSuperController:self customNav:!self.navigationController.navigationBarHidden];
    _chatView.autoresizesSubviews = YES;
    _chatView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleBottomMargin ;
    _chatView.delegate = self;
//    _chatView.hideTopViewNav = !self.navigationController.navigationBarHidden;
    if (!self.navigationController.navigationBarHidden) {
        _chatView.nacTranslucent = self.navigationController.navigationBar.translucent;
    }
    if (self.chatdelegate && [_chatdelegate respondsToSelector:@selector(openLeaveMsgClick:)]) {
        _chatView.isJumpCustomLeaveVC = YES;
    }

    [self.view addSubview:_chatView];
    [_chatView showZCChatView:[ZCUICore getUICore].kitInfo];
    

}



-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == Btn_BACK) {
        // 点击返回，清理数据
        [self.chatView confimGoBackWithType:ZCChatViewGoBackType_normal];
        
    }else if (sender.tag == Btn_CLOSE) {
        // 点击关闭，离线用户
        [self.chatView confimGoBackWithType:ZCChatViewGoBackType_close];
        
    }else if (sender.tag == Btn_MORE){
        // 点击清理数据事件
        [self.chatView cleanHistoryMessage];
    }else if (sender.tag == Btn_EVALUATION){
        // 去评价
        [self.chatView goEvaluation];
    }
    
}

//-(void)didMoveToParentViewController:(UIViewController *)parent{
//    NSLog(@"滑动返回了");
//}


/**
 监听顶部点击事件，返回/ 更多(清空历史记录)

 @param Tag
 */
-(void)topViewBtnClick:(ZCBtnClickTag)Tag{
    if (Tag == Btn_BACK) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_chatView dismissZCChatView];
            _chatView = nil;
        });
        if (self.navigationController && _isPush) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }else if (Tag == Btn_MORE){
//        NSLog(@"删除数据");
    }
}


/**
 点击到留言

 @param tipMsg
 */
-(void)onLeaveMsgClick:(NSString *)tipMsg{
    // 通过代理通知外部留言点击了
    if(_chatdelegate && [_chatdelegate respondsToSelector:@selector(openLeaveMsgClick:)]){
        [_chatdelegate openLeaveMsgClick:tipMsg];
    }
    if ([ZCUICore getUICore].PageLoadBlock) {
        [ZCUICore getUICore].PageLoadBlock(tipMsg, ZCPageBlockLeave);
    }
}



/**
 更换标题

 @param title
 */
-(void)onTitleChanged:(NSString *)title{
    // 如果是使用系统导航，更换标题
    if(!self.navigationController.navigationBarHidden){
       self.title = zcLibConvertToString(title);
    }
}

- (void)onPageStatusChange:(BOOL)isArtificial{
    if(self.isArtificial == isArtificial){
        return;
    }
        
    self.isArtificial = isArtificial;
    
    [self setNavigationBarStyle];
    
}

/**
 横竖屏切换时，刷新页面布局
 */
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGRect vf = self.chatView.frame;
    vf.size.height = viewHeigth;
    
    CGFloat startY = 0;
    CGFloat chatHeight = viewHeigth;
    
    if (!self.navigationController.navigationBarHidden) {
        // 使用系统导航栏的时候
        if(self.navigationController.navigationBar.translucent){
            startY = NavBarHeight;   // 设置了透明度 添加子视图的 （0，0）点坐标是从 导航栏的下标开始计算的 chatView的0点坐标 就是相对chatVC （0，NavBarHeight）
            chatHeight = viewHeigth - NavBarHeight ;
        }else{
            startY = 0; // 不设置透明度 添加子视图的坐标 （0，0） 同chatVC的（0，0）一致
            chatHeight = viewHeigth -NavBarHeight ;
        }
    }
    
    if (ZC_iPhoneX) {
        chatHeight = chatHeight - 34;
    }
    vf.origin.y = startY;
    vf.size.height = chatHeight;
    _chatView.frame = vf;
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


//-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
////    UIView * view = [super hitTest:point withEvent:event];
//    if (view == nil) {
//        CGPoint staitionPoint = [self.chatView convertPoint:point fromView:self];
//        if (CGRectContainsPoint(self.chatView.bounds, staitionPoint)) {
//            view = self.chatView;
//        }
//    }
//}
-(id)initWithInitInfo:(ZCKitInfo *)info{
    self=[super init];
    if(self){
        if(info !=nil && !zcLibIs_null([ZCLibClient getZCLibClient].libInitInfo) && !zcLibIs_null([ZCLibClient getZCLibClient].libInitInfo.appKey)){
//            self.zckitInfo=info;
        }else{
//            self.zckitInfo=[ZCKitInfo new];
        }
        [ZCUICore getUICore].kitInfo = info;
    }
    return self;
}


-(void)dealloc{
//    NSLog(@" zcchatVC 释放了");
}

@end
