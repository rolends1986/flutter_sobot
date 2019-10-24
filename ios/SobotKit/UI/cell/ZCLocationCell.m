//
//  ZCLocationCell.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCLocationCell.h"
#import "ZCUIImageView.h"
#import "ZCLIbGlobalDefine.h"
#define LocationHeight 130
@interface ZCLocationCell(){
    ZCUIImageView *_imgLocation;
    UILabel *_labFileName;
    UILabel *_labFileAddress;
    UIButton * cancelBtn;// 取消发送；
    ZCLibMessage *_model;
}

@end

@implementation ZCLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _imgLocation = [[ZCUIImageView alloc] init];
        [_imgLocation setContentMode:UIViewContentModeScaleAspectFill];
        [_imgLocation.layer setMasksToBounds:YES];
        [_imgLocation setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_imgLocation];
        
        _labFileName=[[UILabel alloc] init];
        [_labFileName setTextAlignment:NSTextAlignmentLeft];
        [_labFileName setFont:[ZCUITools zcgetTitleGoodsFont]];
        [_labFileName setTextColor:[ZCUITools zcgetGoodsTextColor]];
        [_labFileName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_labFileName];
        
        _labFileAddress=[[UILabel alloc] init];
        [_labFileAddress setTextAlignment:NSTextAlignmentLeft];
        [_labFileAddress setFont:[ZCUITools zcgetDetGoodsFont]];
        [_labFileAddress setTextColor:[ZCUITools zcgetTimeTextColor]];
        [_labFileAddress setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_labFileAddress];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        self.ivBgView.userInteractionEnabled=YES;
        [self.ivBgView addGestureRecognizer:tapGesturer];
    }
    return self;
}


-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat height=[super InitDataToView:model time:showTime];
    _model = model;
    self.ivBgView.backgroundColor = UIColor.whiteColor;
    
    [_imgLocation loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.richModel.richmoreurl)] placeholer:nil showActivityIndicatorView:YES];
    [_labFileName setText:model.richModel.localName];
    [_labFileAddress setText:model.richModel.localLabel];
    if (model.isHistory) {
        model.progress = 1.0;
    }
    
    self.ivBgView.hidden = NO;
    
    CGSize size = CGSizeMake(self.maxWidth, LocationHeight);
    CGFloat msgX = 0;
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx=self.viewWidth-size.width-ZCNumber(30) -ZCNumber(50);
        msgX = rx;
        
        [_labFileName setFrame:CGRectMake(msgX, height + 10, size.width, 17)];
        [_labFileAddress setFrame:CGRectMake(msgX, height + 31, size.width, 18)];
        [_imgLocation setFrame:CGRectMake(msgX-8, height + 32 + 17, size.width +ZCNumber(28 -8), ZCNumber(85))];
        
        [self.ivBgView setFrame:CGRectMake(rx-8, height, size.width+ZCNumber(28) , size.height)];
    }else{
        msgX = 78;
        
        [_labFileName setFrame:CGRectMake(msgX, height + 10, size.width, 17)];
        [_labFileAddress setFrame:CGRectMake(msgX, height + 31, size.width, 18)];
        [_imgLocation setFrame:CGRectMake(58, height + 32+17, size.width + ZCNumber(33-8), ZCNumber(85))];
        
        [self.ivBgView setFrame:CGRectMake(58, height, size.width+33, size.height )];
    }
    height=size.height+12;
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    
    [self.ivBgView setNeedsDisplay];
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height)];
    
    //    NSLog(@"_progressView.progress ==++++++++%f",_progressView.progress);
    if (self.isRight && model.progress < 1) {
        CGSize size = CGSizeMake(self.maxWidth, 60);
        int rx = self.viewWidth - size.width - 30 - 50 -18 -19;
        cancelBtn.frame = CGRectMake(rx, CGRectGetMaxY(_labFileName.frame) -5, 19, 19);
        cancelBtn.hidden = NO;
    }else{
        cancelBtn.hidden = YES;
    }
    
    return height;
}





// 点击查看大图
-(void) tap:(UITapGestureRecognizer *)recognizer{
//    [ZCLogUtils logHeader:LogHeader debug:@"查看大图：%@",self.tempModel.richModel.richmoreurl];
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemOpenLocation obj:nil];
    }
}


-(void)resetCellView{
    //    cancelBtn = nil;
    [super resetCellView];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat height = [super getCellHeight:model time:showTime viewWith:width];
    
    height=height+LocationHeight +12;
    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
