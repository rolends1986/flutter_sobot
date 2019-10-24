//
//  ZCMsgRecordCell.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCMsgRecordCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"

@interface ZCMsgRecordCell(){
    
}

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,strong) UILabel * picLab;

@property (nonatomic,strong) UILabel * statusLab;

@property (nonatomic,strong) UILabel * conLab;// content

@property (nonatomic,strong) UILabel * timeLab;

@property (nonatomic,strong) UILabel * orderIdLab;// 工单编号

@property (nonatomic,strong) UIView * bgView;

@property (nonatomic,strong) UIView * lineView;


@end

@implementation ZCMsgRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.contentView.backgroundColor = UIColorFromRGB(TextRecordBgColor);
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_bgView];
        _bgView.layer.cornerRadius = 3.5f;
        _bgView.layer.masksToBounds = YES;
        
        
        _titleLab = [[UILabel alloc]init];
        [_titleLab setFont:DetGoodsFont];
        [_titleLab setTextColor:UIColorFromRGB(TextRecordTitleColor)];
        [_titleLab setNumberOfLines:0];
        [_bgView addSubview:_titleLab];
        
        _picLab = [[UILabel alloc]init];
        _picLab.text = @"New";
        _picLab.textColor = UIColorFromRGB(TextTopColor);
        _picLab.font = [UIFont systemFontOfSize:10];
        _picLab.backgroundColor = [UIColor redColor];
        _picLab.textAlignment = NSTextAlignmentCenter;
        _picLab.layer.masksToBounds = YES;
        _picLab.layer.cornerRadius = 3.0f;
        [_bgView addSubview:_picLab];
        
        _statusLab = [[UILabel alloc]init];
        _statusLab.textAlignment = NSTextAlignmentCenter;
        _statusLab.textColor = UIColorFromRGB(TextTopColor);
        _statusLab.backgroundColor = UIColorFromRGB(BgTitleColor);
        _statusLab.font = DetGoodsFont;
        _statusLab.layer.cornerRadius = ZCNumber(10);
        _statusLab.layer.masksToBounds = YES;
        [_bgView addSubview:_statusLab];
        
        _conLab = [[UILabel alloc]init];
        [_conLab setNumberOfLines:2];
        _conLab.textColor = UIColorFromRGB(TextRecordDetailColor);
        _conLab.font = DetGoodsFont;
        [_bgView addSubview:_conLab];
        
        
        _timeLab = [[UILabel alloc]init];
        _timeLab.textAlignment = NSTextAlignmentRight;
        _timeLab.textColor = UIColorFromRGB(TextRecordOrderIdColor);
        _timeLab.font = [UIFont systemFontOfSize:11];
        [_bgView addSubview:_timeLab];
        
        _orderIdLab = [[UILabel alloc]init];

        _orderIdLab.textColor = UIColorFromRGB(TextRecordOrderIdColor);
        _orderIdLab.font = [UIFont systemFontOfSize:11];
        _orderIdLab.textAlignment = NSTextAlignmentLeft;
        [_bgView addSubview:_orderIdLab];
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(recordLineColor);
        [_bgView addSubview:_lineView];
        
    }
    
    return self;
}


-(void)initWithDict:(ZCRecordListModel*)model{
    
    _bgView.frame = CGRectMake(ZCNumber(10), 0, ScreenWidth - ZCNumber(20), ZCNumber(125));
    _bgView.backgroundColor = UIColorFromRGB(TextTopColor);
    
    _titleLab.text = zcLibConvertToString(model.content); //@"问题描述lsakl阿里速度快缴费拉卡掉了金风科技埃里克森的家乐福卡拉伸的开发";
    _titleLab.frame = CGRectMake(ZCNumber(10), ZCNumber(12), CGRectGetWidth(_bgView.frame) -ZCNumber(120), ZCNumber(20));
    
    // 计算文本的宽度
    CGSize titleSize = [self sizeWithText:_titleLab.text withFont:_titleLab.font];
    if (titleSize.width < _titleLab.frame.size.width) {
        [_titleLab sizeToFit];
    }
    
    // 显示最新处理过的工单编号 new
    _picLab.frame = CGRectMake(CGRectGetMaxX(_titleLab.frame)+ZCNumber(6), _titleLab.frame.origin.y+ZCNumber(2), ZCNumber(25), ZCNumber(15));
    _picLab.hidden = YES;
    if (model.newFlag == 2) {
        _picLab.hidden = NO;
    }
    
//    [_picLab sizeToFit];
    
    _statusLab.frame = CGRectMake(CGRectGetWidth(_bgView.frame) - ZCNumber(70), _titleLab.frame.origin.y, ZCNumber(60), ZCNumber(20));
    
    _statusLab.text = @"待受理";
    
    switch (model.flag) {
        case 1:
            _statusLab.text =  @"待受理";
            _statusLab.backgroundColor = UIColorFromRGB(0xD8D8D8);
            break;
        case 2:
            _statusLab.text =  @"受理中";
            _statusLab.backgroundColor = UIColorFromRGB(0xF6AF38);
            break;
        case 3:
            _statusLab.text =  @"已完成";
            _statusLab.backgroundColor = UIColorFromRGB(BgTitleColor);
            break;
        default:
            break;
    }
    
    
    _conLab.frame = CGRectMake(ZCNumber(10), CGRectGetMaxY(_titleLab.frame) +ZCNumber(13), CGRectGetWidth(_bgView.frame) - ZCNumber(20), ZCNumber(40));
    
    _conLab.text = @"";//@"手机号不变更问题-由于近期些地方拉开接待来访控件的拉看电视剧了父控件拉开的设计费拉拉伸的开发就拉开的设计费老款就阿里山的开发拉卡世纪东方老卡机拉开的设计费老卡机的斯洛伐克就拉开大姐夫了卡上的缴费了拉开到健身房拉卡拉的控件";
    
    _lineView.frame = CGRectMake(ZCNumber(10), CGRectGetMaxY(_conLab.frame) + ZCNumber(6), CGRectGetWidth(_bgView.frame)-ZCNumber(20), 0.5);
    
    _orderIdLab.frame = CGRectMake(ZCNumber(10), CGRectGetMaxY(_lineView.frame)+ ZCNumber(6), CGRectGetWidth(_conLab.frame)/2, ZCNumber(15));
   
    _orderIdLab.text = [NSString stringWithFormat:@"工单号：%@",model.ticketCode];// @"工单号：390876677443";
    
    _timeLab.frame = CGRectMake(CGRectGetMaxX(_orderIdLab.frame), CGRectGetMaxY(_lineView.frame) + ZCNumber(6), CGRectGetWidth(_orderIdLab.frame), CGRectGetHeight(_orderIdLab.frame));
    _timeLab.text = zcLibConvertToString(model.timeStr);// @"2019年01月11日 22:10";
    
}


#pragma mark -- 获取文本的宽度
/**
 
 计算单行文字的size
 
 @parms  文本
 
 @parms  字体
 
 @return  字体的CGSize
 
 */
-(CGSize)sizeWithText:(NSString *)text withFont:(UIFont *)font{
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    
    return size;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
