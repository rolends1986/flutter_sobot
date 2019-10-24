//
//  ZCUISkillSetView.m
//  MyTextViews
//
//  Created by zhangxy on 16/1/21.
//  Copyright © 2016年 zxy. All rights reserved.
//

#import "ZCUISkillSetView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIChatKeyboard.h"
#import "ZCLibConfig.h"
#import "ZCUIConfigManager.h"

#import "ZCUIImageTools.h"

#import "ZCIMChat.h"
#import "ZCPlatformTools.h"
#import "ZCUIKeyboard.h"
@interface ZCUISkillSetView()

@property(nonatomic,strong) UIView *backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;

@end

@implementation ZCUISkillSetView{
    void(^SkillSetClickBlock)(ZCLibSkillSet *itemModel);
    void(^CloseBlock)();
    void(^ToRobotBlock)();
    
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray *listArray;
    
//    ZCUIChatKeyboard *_keyboardView;
    ZCUIKeyboard *_keyboardView;
}


- (ZCUISkillSetView *)initActionSheet:(NSMutableArray *)array withView:(UIView *)view{
    self=[super init];
    if(self){
        
        viewWidth = view.frame.size.width;
        viewHeight = view.frame.size.height;
        
        listArray = array;
        
        if(!listArray){
            listArray = [[NSMutableArray alloc] init];
        }
        
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromRGBAlpha(TextBlackColor, 0.6);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewDismiss:)];
        [self addGestureRecognizer:tapGesture];
        
        [self createSubviews];
    }
    return self;
}


- (void)createSubviews{
    CGFloat bw=viewWidth;
    
    
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - bw) / 2.0, viewHeight, bw, 0)];
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor = UIColorFromRGB(BgSystemColor);
//    [self.backGroundView.layer setCornerRadius:5.0f];
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bw, 40)];
    [titleLabel setText:ZCSTLocalString(@"选择咨询内容")];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:UIColorFromRGB(TextWhiteColor)];
    [titleLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [titleLabel setFont:ListTitleFont];
    [self.backGroundView addSubview:titleLabel];
    
    [ZCUITools addBottomBorderWithColor:UIColorFromRGB(LineGoodsImageColor) andWidth:1.0f withView:titleLabel];
    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, bw, 360-84)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.bounces = NO;
    [self.backGroundView addSubview:self.scrollView];
    
    CGFloat x=10;
    CGFloat y=10;
    
    CGFloat itemH = 50;
    CGFloat itemW = (bw-30)/2.0f;
    
    int index = listArray.count%2==0?round(listArray.count/2):round(listArray.count/2)+1;
    
    for (int i=0; i<listArray.count; i++) {
        UIButton *itemView = [self addItemView:listArray[i] withX:x withY:y withW:itemW withH:itemH];
        
        [itemView setBackgroundColor:[UIColor whiteColor]];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        if(i%2==1){
            x = 10;
            y = y + itemH + 10;
        }else if(i%2==0){
            x = itemW + 20;
        }
        [self.scrollView addSubview:itemView];
    }
    [self.scrollView setContentSize:CGSizeMake(bw, index*itemH + (index-1)*3)];
    
    
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(0, 360-44, bw,44)];
    [cannelButton.titleLabel setFont:ListTitleFont];
    [cannelButton setBackgroundColor:UIColorFromRGB(TextWhiteColor)];
    [cannelButton setTitle:ZCSTLocalString(@"取消") forState:UIControlStateNormal];
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [cannelButton setTitleColor:UIColorFromRGB(TextNetworkTipColor) forState:UIControlStateNormal];
    [self.backGroundView addSubview:cannelButton];
    
    [ZCUITools addTopBorderWithColor:UIColorFromRGB(LineGoodsImageColor) andWidth:1.0f withView:cannelButton];
    
    CGFloat iphonexxBtm = ZC_iPhoneX?34:0;
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(self.backGroundView.frame.origin.x, viewHeight-360-iphonexxBtm,self.backGroundView.frame.size.width, 360+iphonexxBtm)];
    } completion:^(BOOL finished) {
        
    }];
    
    // 注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoRobotChat:) name:@"closeSkillView" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoRobotChatAndLeavemeg:) name:@"gotoRobotChatAndLeavemeg" object:nil];
    
}
-(void)addBorderWithColor:(UIColor *)color isBottom:(BOOL) isBottom with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    if(isBottom){
        border.frame = CGRectMake(0, view.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    }else{
        border.frame = CGRectMake(view.frame.size.width - borderWidth,0, borderWidth, self.frame.size.height);
    }
    border.name=@"border";
    [view.layer addSublayer:border];
}

-(void)addBorderWithColor:(UIColor *)color with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}


-(UIButton *)addItemView:(ZCLibSkillSet *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(0xFFFFFF)] forState:UIControlStateHighlighted];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(0xf0f0f0)] forState:UIControlStateHighlighted];
    
    UILabel *_itemName = [[UILabel alloc] initWithFrame:CGRectZero];
    [_itemName setBackgroundColor:[UIColor clearColor]];
    [_itemName setTextAlignment:NSTextAlignmentCenter];
    [_itemName setTextColor:UIColorFromRGB(TextBlackColor)];
    [_itemName setText:model.groupName];
    [_itemName setFont:ListTitleFont];
    [itemView addSubview:_itemName];
    if(!model.isOnline){
        [_itemName setFrame:CGRectMake(0, (h-40)/2 , itemView.frame.size.width, 24)];
        
        UILabel *_itemStatus = [[UILabel alloc] initWithFrame:CGRectMake(0,(h-40)/2+24, itemView.frame.size.width, 16)];
        [_itemStatus setBackgroundColor:[UIColor clearColor]];
        [_itemStatus setTextAlignment:NSTextAlignmentCenter];
        [_itemStatus setFont:ListDetailFont];
        
        // [ZCIMChat getZCIMChat].libConfig.msgFlag == 0
        if ([[ZCPlatformTools sharedInstance] getPlatformInfo].config.msgFlag == 0) {
            [_itemStatus setText:ZCSTLocalString(@"留言")];
            [_itemStatus setTextColor:UIColorFromRGB(LineTextMenuColor)];
        }else{
            [_itemStatus setText:ZCSTLocalString(@"离线")];
            [_itemStatus setTextColor:UIColorFromRGB(UnOnlineTextColor)];
        }
        
        [itemView addSubview:_itemStatus];
    }else{
        [_itemName setFrame:CGRectMake(0, 0 , itemView.frame.size.width, h)];
    }
    
    return itemView;
}

- (void)itemClick:(UIButton *) view{
    ZCLibSkillSet *model =  listArray[view.tag];
    [ZCLogUtils logHeader:LogHeader info:@"%@",model.groupName];
    
    if(SkillSetClickBlock){
        SkillSetClickBlock(model);
    }
}

-(void)setItemClickBlock:(void (^)(ZCLibSkillSet *))block{
    SkillSetClickBlock = block;
}

-(void)setCloseBlock:(void (^)())closeBlock{
    CloseBlock = closeBlock;
}

- (void)closeSkillToRobotBlock:(void(^)()) toRobotBlock{
    ToRobotBlock = toRobotBlock;
}

- (void)gotoRobotChat:(NSNotification*)notification{

    [self tappedCancel];
}

/**
 *  显示弹出层
 *
 *  @param view
 */
- (void)showInView:(UIView *)view{
    [view addSubview:self];
}

// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.backGroundView.frame;
    
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self tappedCancel:YES];
    }
}


- (void)tappedCancel{
    [self tappedCancel:YES];
}
/**
 *  关闭弹出层
 */
- (void)tappedCancel:(BOOL) isClose{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            if(CloseBlock && isClose){
                CloseBlock();
            }
            [self removeFromSuperview];
        }
    }];
    // 点击取消的时候设置键盘样式 关闭加载动画
    [_keyboardView setKeyBoardStatus:ZCKeyboardStatusRobot];
//    [_keyboardView.zc_activityView stopAnimating];
}

- (void)gotoRobotChatAndLeavemeg:(NSNotification*)notifiation{
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (ToRobotBlock) {
            ToRobotBlock();
        }
            [self removeFromSuperview];
        
    }];
    // 点击取消的时候设置键盘样式 关闭加载动画
    [_keyboardView setKeyBoardStatus:ZCKeyboardStatusRobot];
//    [_keyboardView.zc_activityView stopAnimating];
}
@end
