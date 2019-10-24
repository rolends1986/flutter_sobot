//
//  ZCQuickEntryView.m
//  SobotKit
//
//  Created by lizhihui on 2018/5/25.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCQuickEntryView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCUIKeyboard.h"
#import "ZCUIImageTools.h"
@interface ZCQuickEntryView(){
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray * listArray;
    ZCUIKeyboard * _keyboardView;
    UIScrollView * _scrollView;
}

@end
@implementation ZCQuickEntryView

-(ZCQuickEntryView *)initCustomViewWith:(NSMutableArray *)array WithView:(UIView *)view{
    self = [super init];
    if (self) {
        viewWidth = view.frame.size.width;
        viewHeight = view.frame.size.height;
        listArray = array;
        
        if (!listArray) {
            listArray = [NSMutableArray array];
        }
        
        self.frame = CGRectMake(0, 0, viewWidth, 40);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        [self createSubviews];
    }
    
    return  self;
}

-(void)createSubviews{
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 40)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.backgroundColor = [ZCUITools zcgetBackgroundBottomColor];
    [self addSubview:_scrollView];
    
    
    CGFloat x = 10;
    for (int i = 0; i< listArray.count; i++) {
        UIButton * itemBtn = [self addItemView:listArray[i] withX:x withY:5 withW:60 withH:30];
//        [itemBtn setBackgroundColor:UIColorFromRGB(0xffffff)];
        itemBtn.userInteractionEnabled = YES;
        itemBtn.tag = i;
        [itemBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        itemBtn.layer.borderWidth = 0.5f;
//        itemBtn.layer.borderColor = UIColorFromRGB(TextUnPlaceHolderColor).CGColor;
        x = x + CGRectGetWidth(itemBtn.frame) + 10;
        
        [_scrollView addSubview:itemBtn];
    }
    [_scrollView setContentSize:CGSizeMake(x, 40)];
    
}


-(UIButton*)addItemView:(ZCLibCusMenu *)model withX:(CGFloat)x withY:(CGFloat) y withW:(CGFloat)w withH:(CGFloat)h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];

    itemView.titleLabel.numberOfLines = 1;
    itemView.titleLabel.font = DetGoodsFont;
//    NSLog(@"%@",model.title);
    [itemView setTitle:zcLibConvertToString(model.title) forState:UIControlStateNormal];
    [itemView setTitle:zcLibConvertToString(model.title) forState:UIControlStateHighlighted];
    itemView.titleLabel.textAlignment = NSTextAlignmentCenter;
    [itemView setBackgroundColor:[UIColor whiteColor]];
    [itemView setTitleColor:UIColorFromRGB(TextRecordOrderIdColor) forState:UIControlStateNormal];
    [itemView setTitleColor:UIColorFromRGB(TextRecordOrderIdColor) forState:UIControlStateHighlighted];
    itemView.layer.masksToBounds = YES;
    itemView.layer.cornerRadius = 15.0f;
    itemView.layer.borderColor = UIColorFromRGB(0xEFEFEF).CGColor;
    [itemView sizeToFit];
    CGRect itemViewF = itemView.frame;
    itemViewF.size.width = itemViewF.size.width + 16;
    itemView.frame = itemViewF;
    
    return itemView;
}

- (void)showInView:(UIView *)view{
    [view addSubview:self];
}

- (void)tappedCancel:(BOOL) isClose{
    
}

-(void)itemClick:(UIButton *)sender{
//    UIButton * btn = (UIButton*)sender;
//    NSLog(@"%@",btn.titleLabel.text);
    if (_quickClickBlock) {
        _quickClickBlock(listArray[sender.tag]);
    }
}

@end
