//
//  ZCMsgDetailCell.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/20.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCMsgDetailCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIImageTools.h"
#import "ZCLibSatisfaction.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"
#import "ZCMLEmojiLabel.h"

@interface ZCMsgDetailCell()<ZCMLEmojiLabelDelegate>
{
    ZCRecordListModel *tempModel;// 临时的变量
}

@property (nonatomic,strong) UIImageView * timeIcon; // 时间图标

@property (nonatomic,strong) UILabel * timeLab;

@property (nonatomic,strong) UIImageView * statusIcon; // 受理状态图标

@property (nonatomic,strong) UILabel * statusLab;

@property (nonatomic,strong) UILabel * replyLab; // 问题回复

@property (nonatomic,strong) ZCMLEmojiLabel * replycont;// 回复内容

@property (nonatomic,strong) UIView * lineView; // 竖线条

@property (nonatomic,strong) UIButton * serviceBtn; // 评价btn

@property (nonatomic,strong) UILabel * starLab;// 评级星级

@property (nonatomic,strong) UILabel * starMsg;// 星评描述

@property (nonatomic,strong) UILabel * serviceConLab; // 评价内容

@property (nonatomic,strong) UILabel * feedbackLab;// 评价反馈

@property (nonatomic,strong) UIView *infoCardView;//图片卡片显示

@property (nonatomic,strong) UIView *infoCardLineView;//图片卡片白线

@property (nonatomic,strong) UIButton * detailBtn;//跳转webview显示详情的按钮

@property(nonatomic,strong) void (^btnClickBlock)(ZCRecordListModel *model);//评价按钮点击回调

@property(nonatomic,strong) void (^detailClickBlock)(ZCRecordListModel *model,NSString *urlStr);//显示详细按钮点击回调

@end

@implementation ZCMsgDetailCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
//        self.contentView.backgroundColor = UIColorFromRGB(0xF0F0F0);
        _timeIcon = [[UIImageView alloc]init];
        [self.contentView addSubview:_timeIcon];
        
        _timeLab = [[UILabel alloc]init];
        _timeLab.textColor = UIColorFromRGB(recordTimeTextColor);
        _timeLab.font = DetGoodsFont;
        [self.contentView addSubview:_timeLab];
        
        _statusIcon = [[UIImageView alloc]init];
        [self.contentView addSubview:_statusIcon];
        
        _statusLab = [[UILabel alloc]init];
        _statusLab.font = VoiceButtonFont;
        [self.contentView addSubview:_statusLab];
        
        _replyLab = [[UILabel alloc]init];
        _replyLab.font = DetGoodsFont;
        _replyLab.text = @"客服回复";
        [self.contentView addSubview:_replyLab];
        
        _infoCardView = [[UIView alloc] init];
        _infoCardView.backgroundColor = UIColorFromRGB(0xEFF3FA);
        _infoCardView.layer.cornerRadius = 4.0;
        _infoCardView.layer.masksToBounds = YES;
        [self.contentView addSubview:_infoCardView];
        
        _infoCardLineView = [[UIView alloc] init];
        _infoCardLineView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        [self.contentView addSubview:_infoCardLineView];
        
        _replycont =  [[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
        _replycont.textColor = UIColorFromRGB(TextRecordDetailColor);
        _replycont.font = DetGoodsFont;
        _replycont.numberOfLines = 0;
        _replycont.delegate = self;
        [self.contentView addSubview:_replycont];
        
        _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailBtn.titleLabel.font = DetGoodsFont;
        _detailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_detailBtn setTitle:@"点击查看详情" forState:UIControlStateNormal];
        [_detailBtn setTitleColor:UIColorFromRGB(0x45B2E6) forState:UIControlStateNormal];
        [_detailBtn addTarget:self action:@selector(showDetailAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_detailBtn];
        _detailBtn.hidden = YES;
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = UIColorFromRGB(BgTitleColor);
        [self.contentView addSubview:_lineView];
        
        _serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _serviceBtn.titleLabel.font = DetGoodsFont;
        [_serviceBtn setTitle:@"评价本次服务" forState:UIControlStateNormal];
        [_serviceBtn setTitle:@"评价本次服务" forState:UIControlStateHighlighted];
        [_serviceBtn setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(0x0DAEAF)] forState:UIControlStateNormal];
        [_serviceBtn setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(0x0DAEAF)] forState:UIControlStateHighlighted];
        [_serviceBtn addTarget:self action:@selector(addServiceAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_serviceBtn];
        _serviceBtn.hidden = YES;
        
        _starLab = [[UILabel alloc]init];
        _starLab.textColor = UIColorFromRGB(TextRecordTitleColor);
        _starLab.font = DetGoodsFont;
        _starLab.text = @"评价星级：";
        [self.contentView addSubview:_starLab];
        _starLab.hidden = YES;
        
        
        _starMsg = [[UILabel alloc]init];
        _starMsg.font = DetGoodsFont;
        _starMsg.textColor = UIColorFromRGB(TextRecordDetailColor);
        _starMsg.text = @"非常满意，完美（5星）";
        [self.contentView addSubview:_starMsg];
        _starMsg.hidden = YES;
        
        _serviceConLab = [[UILabel alloc]init];
        _serviceConLab.textColor = UIColorFromRGB(TextRecordTitleColor);
        _serviceConLab.text = @"评价反馈：";
        _serviceConLab.font = DetGoodsFont;
        [self.contentView addSubview:_serviceConLab];
        _serviceConLab.hidden = YES;
        
        _feedbackLab = [[UILabel alloc]init];
        _feedbackLab.textColor = UIColorFromRGB(TextRecordDetailColor);
        _feedbackLab.font = DetGoodsFont;
        _feedbackLab.text = @"lkajdslkfjlakjdlfkjlaksjdlfkjalksdjlfkjlajsdlfkjlaksd";
        [self.contentView addSubview:_feedbackLab];
        _feedbackLab.hidden = YES;
        
    }
    
    return self;
}

-(void)setShowDetailClickCallback:(void (^)(ZCRecordListModel *model,NSString *urlStr))detailClickBlock{
    [self setDetailClickBlock:detailClickBlock];
}


-(void)setString:(NSString *)string withlLabel:(UILabel *)label {
    
    [ZCHtmlCore filterHtml:string result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        
        if (text1.length > 0 && text1 != nil) {
            label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromRGB(TextWordOrderListTextColor) textFont:label.font linkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }else{
            label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }
        
    }];
    
}


-(void)addServiceAction:(UIButton *)sender{
    //
    if (self.btnClickBlock) {
        self.btnClickBlock(tempModel);
    }
}

-(void)showDetailAction:(UIButton *)btn{
    
    if (self.detailClickBlock) {
        self.detailClickBlock(tempModel,nil);
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initWithData:(ZCRecordListModel *)model IndexPath:(NSInteger)row btnClick:(void (^)(ZCRecordListModel *model ))btnClickBlock{
    tempModel = model;
    [self setBtnClickBlock:btnClickBlock];
    // 回执
    _timeLab.text = @"";
    _timeIcon.image = nil;
    _statusLab.text = @"";
    _statusIcon.image = nil;
    _replyLab.text = @"";
    _replycont.text = @"";
    
    _serviceBtn.hidden = YES; // 评价btn
    
    _starLab.hidden = YES;// 评级星级
    
    _starMsg.hidden = YES;// 星评描述
    
    _serviceConLab.hidden = YES; // 评价内容
    
    _feedbackLab.hidden = YES;// 评价反馈
    
    _lineView.frame = CGRectMake(0, 0, 0, 0);
    
    _timeIcon.image =  [ZCUITools zcuiGetBundleImage:@"zcicon_time_new"];
    _timeIcon.frame = CGRectMake(ZCNumber(15), ZCNumber(8), ZCNumber(16), ZCNumber(16));
    
    _timeLab.frame = CGRectMake(CGRectGetMaxX(_timeIcon.frame) + ZCNumber(15), _timeIcon.frame.origin.y -ZCNumber(2), 160, ZCNumber(20));
    _timeLab.text = zcLibConvertToString(model.timeStr);  //@"2018-04-11 22:22:22";
    
    _statusIcon.image = [ZCUITools zcuiGetBundleImage:@"zcicon_point_new"];
    _statusIcon.frame = CGRectMake(ZCNumber(15), CGRectGetMaxY(_timeLab.frame) + ZCNumber(13), ZCNumber(16), ZCNumber(16));
    
    _statusLab.frame = CGRectMake(CGRectGetMaxX(_statusIcon.frame) + ZCNumber(15), _statusIcon.frame.origin.y -ZCNumber(3), 160, ZCNumber(20));
    _statusLab.text = @"已创建";
    
    _replyLab.frame = CGRectMake(_timeLab.frame.origin.x, CGRectGetMaxY(_statusLab.frame) + ZCNumber(8), 160, ZCNumber(20));
    _replyLab.text = @"客服回复";
    _replyLab.textColor = UIColorFromRGB(TextRecordTitleColor);
    
    
    NSString *tmp = zcLibConvertToString(model.replyContent);
    
    BOOL isCardView = [self isContaintImage:tmp];
    
    // 过滤标签 改为过滤图片
    tmp = [self filterHtmlImage:tmp];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    
    
    //1 创建了  2 受理了 3 关闭了
    switch (model.flag) {
        case 1:
             _statusLab.text = @"已创建";
            _replycont.text = @"";
             _replyLab.frame = CGRectMake(_timeLab.frame.origin.x, CGRectGetMaxY(_statusLab.frame) + ZCNumber(8), 160, ZCNumber(0));
            break;
        case 2:
             _statusLab.text = @"受理中";
            _replycont.text = @"客服已经成功收到您的问题，请耐心等待";
            _timeLab.text = [self getTimeTextStr:zcLibConvertToString(model.replyTime)];
           
//            _timeLab.text = zcLibConvertToString(model.replyTime);// 时间戳由服务端处理
            if (model.startType == 0) {
                _replyLab.text = @"客服回复";
                if (model.replyContent.length > 0) {
                    
                    [self setString:tmp withlLabel:_replycont];
//                    _replycont.text = tmp;
                }
            }else if (model.startType == 1){
                _replyLab.frame = CGRectMake(_timeLab.frame.origin.x, CGRectGetMaxY(_statusLab.frame) + ZCNumber(8), 160, ZCNumber(0));
                _statusLab.text = @"客户回复";
                if (model.replyContent.length > 0) {
                    
                    [self setString:tmp withlLabel:_replycont];

//                    _replycont.text = tmp;
                }else{
                    _replycont.text = @"无";
                }
            }
            break;
        case 3:{
             _statusLab.text = @"已完成";
            NSString *tmps = zcLibConvertToString(model.content);
            isCardView = [self isContaintImage:tmps];
            tmps = [self filterHtmlImage:tmps];
            // 过滤标签
            tmps = [tmps stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
            tmps = [tmps stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
            tmps = [tmps stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
            tmps = [tmps stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
            tmps = [tmps stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
            tmps = [tmps stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
            tmps = [tmps stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
            tmps = [tmps stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
            while ([tmps hasPrefix:@"\n"]) {
                tmps=[tmps substringWithRange:NSMakeRange(1, tmps.length-1)];
            }
            [self setString:tmps withlLabel:_replycont];
//            _replycont.text = tmps;
        }
            break;
        default:
            break;
    }
    
    CGFloat layoutBottom = CGRectGetMaxY(_replyLab.frame);
    
    CGFloat replycontTop = CGRectGetMaxY(_replyLab.frame) + ZCNumber(5);
    CGFloat replycontWidth = ScreenWidth- ZCNumber(60);
    CGFloat replycontX = _timeLab.frame.origin.x;

    CGFloat recordTop = replycontTop;
    CGFloat recordWidth = replycontWidth;
    CGFloat recordX = replycontX;
    
    if (isCardView) {
        self.infoCardView.hidden = NO;
        self.infoCardLineView.hidden = NO;
        self.detailBtn.hidden = NO;
        self.infoCardLineView.hidden = NO;

        replycontTop =  replycontTop + ZCNumber(15);
        replycontWidth = replycontWidth - ZCNumber(30);
        replycontX = replycontX + ZCNumber(15);

    }else{
        self.infoCardView.hidden = YES;
        self.infoCardLineView.hidden = YES;
        self.detailBtn.hidden = YES;
        self.infoCardLineView.hidden = YES;

    }
    
    // 计算文本内容的高度
    _replycont.frame = CGRectMake(replycontX, replycontTop, replycontWidth, ZCNumber(20));
//    _replycont.frame = CGRectMake(_timeLab.frame.origin.x, CGRectGetMaxY(_replyLab.frame) + ZCNumber(5), ScreenWidth- ZCNumber(60), ZCNumber(20));
    
    CGRect CC = CGRectMake(0, 0, 0, 0);
    
    CGRect RF = [self getTextRectWith: _replycont.attributedText WithMaxWidth:replycontWidth WithlineSpacing:4 AddLabel:_replycont];
    
    layoutBottom = CGRectGetMaxY(_replycont.frame) ;
    
    if (isCardView) {

        layoutBottom = layoutBottom + ZCNumber(15);

        self.infoCardView.frame = CGRectMake(recordX, recordTop , recordWidth, CGRectGetHeight(_replycont.frame) + ZCNumber(30) + ZCNumber(40));

        self.infoCardLineView.frame = CGRectMake(recordX, layoutBottom, recordWidth, 1);
        
        self.detailBtn.frame = CGRectMake(replycontX, CGRectGetMaxY(self.infoCardLineView.frame), ZCNumber(100), 39);
        
        layoutBottom = CGRectGetMaxY(self.infoCardView.frame);
        
    }
    
    
    if (row == 0) {
        _timeLab.textColor = UIColorFromRGB(BgTitleColor);
        _statusLab.textColor = UIColorFromRGB(BgTitleColor);
        _replyLab.textColor = UIColorFromRGB(BgTitleColor);
        
        CC = RF;
        _lineView.backgroundColor = UIColorFromRGB(BgTitleColor);
    }else{
        _timeLab.textColor = UIColorFromRGB(recordTimeTextColor);
//        _statusLab.text = @"受理中";
        _statusLab.textColor = UIColorFromRGB(TextRecordTitleColor);
//        _replycont.text = @"客服已经成功收到您的问题，请耐心等待";
        CC = _replycont.frame;
        _lineView.backgroundColor = UIColorFromRGB(recordLineColor);
        [_timeIcon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_time_old"]];
        [_statusIcon setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_point_old"]];
    }
    //cell大小控制
    self.contentView.frame = CGRectMake(0, 0, ScreenWidth, layoutBottom + ZCNumber(10));
//    self.contentView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(_replycont.frame) + ZCNumber(5));
    self.frame = self.contentView.frame;
     _lineView.frame = CGRectMake(ZCNumber(22.5), CGRectGetMaxY(_statusLab.frame) + ZCNumber(8), 1, CGRectGetHeight(self.frame) -(CGRectGetMaxY(_statusLab.frame) + ZCNumber(10)));
    if (model.flag == 1) {
        _lineView.hidden = YES;
    }else{
         _lineView.hidden = NO;
    }
    
#pragma mark --当 flag == 3
    if (model.flag == 3 && model.isOpen == 1) {
        // 开启了评价
        if (model.isEvalution == 1) {
            //显示评价结果
            _starLab.frame = CGRectMake(CGRectGetMaxX(_lineView.frame) + ZCNumber(15), CGRectGetMaxY(_replycont.frame) + ZCNumber(10), 56, 20);
            [_starLab sizeToFit];
            _starLab.hidden = NO;
            _starMsg.frame = CGRectMake(CGRectGetMaxX(_starLab.frame) + ZCNumber(5), self.starLab.frame.origin.y, ZCNumber(260), 20);
            _starMsg.hidden = NO;
            static  NSString * sting ;
            __weak ZCMsgDetailCell * saveSelf = self;

            [model.ticketScoreInfooList enumerateObjectsUsingBlock:^(ZCLibSatisfaction * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.score == [model.score intValue]) {
                    sting = [NSString stringWithFormat:@"%@ (%@星)",obj.scoreExplain,model.score];
                    saveSelf.starMsg.text = sting;
                }
            }];
            _serviceConLab.frame = CGRectMake(CGRectGetMaxX(_lineView.frame)+ZCNumber(15), CGRectGetMaxY(_starLab.frame) + ZCNumber(5), 56, 20);
            [_serviceConLab sizeToFit];
            _serviceConLab.hidden = NO;
            
            _feedbackLab.hidden = NO;
            _feedbackLab.frame = CGRectMake(CGRectGetMaxX(_serviceConLab.frame) + ZCNumber(5), CGRectGetMaxY(_starLab.frame) +ZCNumber(5), ZCNumber(260), 20);
            // 计算文本高度
            _feedbackLab.text = zcLibConvertToString(model.remark);
            CGRect RF = [self getTextRectWith: _feedbackLab.text WithMaxWidth:ZCNumber(260) WithlineSpacing:6 AddLabel:_feedbackLab];

            _feedbackLab.frame = RF;
            if (_feedbackLab.text.length == 0) {
                _serviceConLab.hidden = YES;
                _feedbackLab.hidden = YES;
            }
            //cell大小控制
            self.contentView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(_feedbackLab.frame) + ZCNumber(10));
            self.frame = self.contentView.frame;
            _lineView.frame = CGRectMake(ZCNumber(22.5), CGRectGetMaxY(_statusLab.frame) + ZCNumber(8), 1, CGRectGetHeight(self.frame) -(CGRectGetMaxY(_statusLab.frame) + ZCNumber(10)));
            
            
        }else if (model.isEvalution == 0){
            // 未评价,显示评价按钮
            _serviceBtn.hidden = NO;
//            _serviceBtn.frame = CGRectMake(CGRectGetMaxX(_lineView.frame) + ZCNumber(15), CGRectGetMaxY(_replycont.frame)+5, 120, 36);
            _serviceBtn.frame = CGRectMake(CGRectGetMaxX(_lineView.frame) + ZCNumber(15), layoutBottom+5, 120, 36);
            //cell大小控制
            self.contentView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(_serviceBtn.frame) + ZCNumber(10));
            self.frame = self.contentView.frame;
            _lineView.frame = CGRectMake(ZCNumber(22.5), CGRectGetMaxY(_statusLab.frame) + ZCNumber(8), 1, CGRectGetHeight(self.frame) -(CGRectGetMaxY(_statusLab.frame) + ZCNumber(10)));
        }
        
    }
    
}

#pragma mark -- 计算文本高度
-(CGRect)getTextRectWith:(NSString *)str WithMaxWidth:(CGFloat)width  WithlineSpacing:(CGFloat)LineSpacing AddLabel:(UILabel *)label{
    if ([str isKindOfClass:[NSAttributedString class]]) {
        label.attributedText = (NSAttributedString *)str;
    }else{
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:str];
        NSMutableParagraphStyle * parageraphStyle = [[NSMutableParagraphStyle alloc]init];
        [parageraphStyle setLineSpacing:LineSpacing];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:parageraphStyle range:NSMakeRange(0, [str length])];
        [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, str.length)];
        
        label.attributedText = attributedString;

    }
    
    CGSize size = [self autoHeightOfLabel:label with:width];
    
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    
    
    return labelF;
}



/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];// 返回最佳的视图大小
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}




//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:NO];
//
//    // Configure the view for the selected state
//}

-(NSString *)getTimeTextStr:(NSString *)time{
    // iOS 生成的时间戳是10位
    NSTimeInterval interval    = [time doubleValue];
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString       = [formatter stringFromDate: date];
    return  dateString;
}


-(NSString *)filterHtmlImage:(NSString *)srcString{
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img.*?/>" options:0 error:nil];
    srcString  = [regularExpression stringByReplacingMatchesInString:srcString options:0 range:NSMakeRange(0, srcString.length) withTemplate:@"[图片]"];
    return srcString;
    
}

-(BOOL)isContaintImage:(NSString *)srcString{
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img.*?/>" options:0 error:nil];
    NSArray *result = [regularExpression matchesInString:srcString options:NSMatchingReportCompletion range:NSMakeRange(0, srcString.length)];
    
    return result.count;
    
    
}

#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
//    NSLog(@"url:%@  url.absoluteString:%@",url,url.absoluteString);
    if (self.detailClickBlock) {
        self.detailClickBlock(nil,url.absoluteString);
    }
}

@end
