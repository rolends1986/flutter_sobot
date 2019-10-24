//
//  ZCSelLeaveView.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCSelLeaveView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCUIKeyboard.h"
#import "ZCUIImageTools.h"

@interface ZCSelLeaveView(){
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray *listArray;
    ZCUIKeyboard *_keyboardView;
    int _msgId;
    NSInteger isExist;// 记录关闭留言的模式
}
@property (nonatomic,strong) UIView * backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;

@end


@implementation ZCSelLeaveView


-(ZCSelLeaveView*)initActionSheet:(NSMutableArray *)array WithView:(UIView *)view MsgID:(int)msgId IsExist:(NSInteger) isExist{
    self = [super init];
    if (self) {
        viewWidth = view.frame.size.width;
        viewHeight = view.frame.size.height;
        _msgId = msgId;
        
        if (!listArray) {
            listArray = [[NSMutableArray alloc]init];
        }
        listArray = array;
        
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
    [titleLabel setText:ZCSTLocalString(@"选择要留言的业务")];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:UIColorFromRGB(TextWhiteColor)];
    [titleLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [titleLabel setFont:ListTitleFont];
    [self.backGroundView addSubview:titleLabel];
    
    [ZCUITools addBottomBorderWithColor:UIColorFromRGB(LineGoodsImageColor) andWidth:1.0f withView:titleLabel];
    
    
    // 左上角的删除按钮
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(13, 13, 15,15)];
    [cannelButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    cannelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.backGroundView addSubview:cannelButton];
    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, bw, 360 - 40)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.bounces = NO;
    [self.backGroundView addSubview:self.scrollView];
    
    CGFloat x=10;
    CGFloat y=10;
    
    CGFloat itemH = 56;
    CGFloat itemW = (bw-30)/2.0f;
    
    
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
    [self.scrollView setContentSize:CGSizeMake(bw, y)];
    
    
    
    CGFloat iphonexxBtm = ZC_iPhoneX?34:0;
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(self.backGroundView.frame.origin.x, viewHeight-360-iphonexxBtm,self.backGroundView.frame.size.width, 360+iphonexxBtm)];
    } completion:^(BOOL finished) {
        
    }];
    
    
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


-(UIButton *)addItemView:(ZCWsTemplateModel *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(TextTopColor)] forState:UIControlStateNormal];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(BgTitleColor)] forState:UIControlStateHighlighted];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(BgTitleColor)] forState:UIControlStateSelected];
    // 设置文字长度 最多20个字 两行显示
    itemView.titleLabel.numberOfLines = 2;
    
    itemView.titleLabel.font = DetGoodsFont;
    itemView.titleLabel.textColor = UIColorFromRGB(robotListTextColor);
    
    [itemView setTitle:zcLibConvertToString(model.templateName) forState:UIControlStateNormal];
    [itemView setTitle:zcLibConvertToString(model.templateName) forState:UIControlStateHighlighted];
    itemView.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [itemView setTitleColor:UIColorFromRGB(robotListTextColor) forState:UIControlStateNormal];
    [itemView setTitleColor:UIColorFromRGB(TextTopColor) forState:UIControlStateHighlighted];
    [itemView setTitleColor:UIColorFromRGB(TextTopColor) forState:UIControlStateSelected];
    // 设置选中的状态
//    if ([zcLibConvertToString(model.robotFlag) intValue] == _msgId) {
//        itemView.selected = YES;
//    }
    
    return itemView;
}


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
    
//    [UIView animateWithDuration:0 animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished) {
            [self removeFromSuperview];
//        }
//    }];
    
//    if (_msgSetClickBlock) {
//        _msgSetClickBlock(nil);
//    }
    // 点击取消的时候设置键盘样式 关闭加载动画
//    [_keyboardView setKeyBoardStatus:ZCKeyboardStatusRobot];
}

-(void)itemClick:(UIButton *)sender{
    ZCWsTemplateModel * model = listArray[sender.tag];
    if (_msgSetClickBlock) {
        _msgSetClickBlock(model);
    }
    [self tappedCancel];
}


@end
