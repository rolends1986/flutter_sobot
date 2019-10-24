//
//  ZCGoodsCell.m
//  SobotKit
//
//  Created by zhangxy on 16/3/18.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCGoodsCell.h"

#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUIImageView.h"
#import "ZCStoreConfiguration.h"
#import "ZCUIConfigManager.h"
#import "ZCUICore.h"
@implementation ZCGoodsCell{
    // 商品图片
    ZCUIImageView   *_imgPhoto;
    
    // 标题
    UILabel         *_lblTextTitle;
    
    // 发送
    UIButton        *_btnSendMsg;
    
    // 摘要
    UILabel         *_lblTextDet;
    
    // 标签
    UILabel         *_lblTextTip;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _imgPhoto = [[ZCUIImageView alloc] init];
        [_imgPhoto setBackgroundColor:[UIColor clearColor]];
        [_imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
        _imgPhoto.layer.masksToBounds=YES;
        _imgPhoto.layer.borderColor = UIColorFromRGB(LineGoodsImageColor).CGColor;
        _imgPhoto.layer.borderWidth = 1.0f;
      
        [self.contentView addSubview:_imgPhoto];
        
        
        // title
        _lblTextTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextTitle setTextAlignment:NSTextAlignmentLeft];
        [_lblTextTitle setFont:[ZCUITools zcgetTitleGoodsFont]];
        [_lblTextTitle setTextColor:[ZCUITools zcgetGoodsTextColor]];
        [_lblTextTitle setBackgroundColor:[UIColor clearColor]];
        _lblTextTitle.numberOfLines = 2;
        _lblTextTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_lblTextTitle];
        
        // 摘要
        _lblTextDet = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextDet setTextAlignment:NSTextAlignmentLeft];
        [_lblTextDet setFont:[ZCUITools zcgetDetGoodsFont]];
        [_lblTextDet setTextColor:[ZCUITools zcgetGoodsDetColor]];
        [_lblTextDet setBackgroundColor:[UIColor clearColor]];
        _lblTextDet.numberOfLines = 2;
        _lblTextDet.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_lblTextDet];
        
        
        // 标签
        _lblTextTip = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextTip setTextAlignment:NSTextAlignmentLeft];
        [_lblTextTip setFont:[ZCUITools zcgetTitleGoodsFont]];
        [_lblTextTip setBackgroundColor:[UIColor clearColor]];
        [_lblTextTip setTextColor:[ZCUITools zcgetGoodsTipColor]];
        _lblTextTip.numberOfLines = 1;
        _lblTextTip.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_lblTextTip];
        
        
        // 发送
        _btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSendMsg setBackgroundColor:[UIColor clearColor]];
        [_btnSendMsg setTitle:ZCSTLocalString(@"发送") forState:UIControlStateNormal];
        [_btnSendMsg setTitleColor:[ZCUITools zcgetGoodsSendColor] forState:UIControlStateNormal];
        
        _btnSendMsg.titleLabel.font = [ZCUITools zcgetTitleGoodsFont];
        [_btnSendMsg setBackgroundColor:[ZCUITools zcgetGoodSendBtnColor]];
        [_btnSendMsg setFrame:CGRectMake(0, 0,70, 26)];
        [_btnSendMsg setUserInteractionEnabled:YES];
        [_btnSendMsg addTarget:self action:@selector(sendMessageToUser) forControlEvents:UIControlEventTouchUpInside];
        _btnSendMsg.layer.cornerRadius = 4;
        _btnSendMsg.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_btnSendMsg];
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.contentView addGestureRecognizer:tap];
        
        self.userInteractionEnabled = YES;
        self.contentView.userInteractionEnabled = YES;
        _imgPhoto.userInteractionEnabled = YES;
        _lblTextTip.userInteractionEnabled = YES;
        _lblTextTitle.userInteractionEnabled = YES;
        [_imgPhoto addGestureRecognizer:tap];
        [_lblTextTitle addGestureRecognizer:tap];
        [_lblTextTip addGestureRecognizer:tap];
        
    }
    return self;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
//        //判断如果点击的是tableView的cell，就把手势给关闭了
//        return NO;//关闭手势
//    }
//    //否则手势存在
//    return YES;
    
    if (![NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
            [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:[self getZCproductInfo].link];
        }
    }
    return YES;
}


-(void)tapAction:(UITapGestureRecognizer*)sender{
    if ([@"" isEqualToString:zcLibConvertToString([self getZCproductInfo].link)]) {
        return;
    }
    if (zcLibConvertToString([self getZCproductInfo].link).length == 0) {
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
        [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:[self getZCproductInfo].link];
    }
}

- (ZCProductInfo *)getZCproductInfo{
//    ZCProductInfo *productInfo  = [ZCUIConfigManager getInstance].kitInfo.productInfo;
    ZCProductInfo * productInfo = [ZCUICore getUICore].kitInfo.productInfo;
    productInfo.desc = @"";
    return productInfo;
}


// 2.7.5版本开始 高度固定 图片固定 标题两行 摘要不显示
-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    [self resetCellView];
    
    // 时间
    CGFloat cellHeight = 22;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        [self.lblTime setText:showTime];
        [self.lblTime setFrame:CGRectMake(0, 0, self.viewWidth, 30)];
        self.lblTime.hidden=NO;
        cellHeight = cellHeight + 30 ;
    }
    
//    CGFloat BY = cellHeight;
    
    
    // 图片隐藏
    _imgPhoto.hidden = YES;
    _lblTextDet.hidden = YES;
    _lblTextTip.hidden = YES;
    
    self.maxWidth = self.viewWidth - 20 -28;
    CGFloat textX = 10;
    
//    if([self getZCproductInfo].thumbUrl!=nil  && ![@"" isEqualToString:[self getZCproductInfo].thumbUrl]){
        [_imgPhoto setFrame:CGRectMake(10+14, cellHeight, 80, 80)];
 
        [_imgPhoto loadWithURL:[NSURL URLWithString:[self getZCproductInfo].thumbUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]  showActivityIndicatorView:YES];
        _imgPhoto.hidden = NO;
        self.maxWidth = self.viewWidth - 113 - 28;
        textX = 103+ 14;
        
//    }
    
    // 有图片
    [_lblTextTitle setFrame:CGRectMake(textX, cellHeight, self.maxWidth, 40)];
    
    _lblTextTitle.text = zcLibConvertToString([self getZCproductInfo].title);
    [_lblTextTitle sizeToFit];
    
    
    // 获取 添加标题之后的商品cell
    cellHeight = CGRectGetMaxY(_lblTextTitle.frame) + 10 ;
  
    // 摘要  2.7.5 去掉此项
    if (zcLibConvertToString([self getZCproductInfo].desc)!=nil && ![@"" isEqualToString:[self getZCproductInfo].desc]) {
         [_lblTextDet setFrame:CGRectMake(textX, cellHeight , self.maxWidth, 0)];
        _lblTextDet.hidden = NO;
    
        _lblTextDet.text = zcLibConvertToString([self getZCproductInfo].desc);
        // 获取摘要的内容大小
        CGRect textDetF = _lblTextDet.frame;
        if (zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label]) {
            textDetF.size.height = 44;
            textDetF.origin.y = cellHeight - 10;
            
            cellHeight = CGRectGetMaxY(textDetF);
        }else{
            CGSize size = [_lblTextDet.text boundingRectWithSize:CGSizeMake(_lblTextDet.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont]} context:nil].size;
            textDetF.origin.y = cellHeight;
            textDetF.size.height = size.height;
            
            cellHeight = CGRectGetMaxY(textDetF) + 10;
        }
        _lblTextDet.frame = textDetF;
        
    }
    
    // 标签
    if (zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label]) {
        [_lblTextTip setFrame:CGRectMake(textX, cellHeight, ZCNumber(150), 18)];
        _lblTextTip.hidden = NO;
        
        _lblTextTip.text = zcLibConvertToString([self getZCproductInfo].label);
        cellHeight = CGRectGetMaxY(_lblTextTip.frame) +15;
    }
    
    
    // 发送按钮（计算发送按钮的在这8中商品展示的位置）
    CGRect bf = _btnSendMsg.frame;
    bf.origin.x = self.viewWidth - _btnSendMsg.frame.size.width -10-14;
//    if(textX>10 && ((BY + 90)- cellHeight) > 31){
//        bf.origin.y = BY + 90 - 26;
//    }else{
    
        bf.origin.y = 100-26;
//    }
    [_btnSendMsg setFrame:bf];
    
    cellHeight = CGRectGetMaxY(_btnSendMsg.frame) +12;
    
    // 时间的显示这里需要在处理一下
    if (!self.lblTime.hidden) {
        [self.ivBgView setFrame:CGRectMake(14, 40, self.viewWidth-28, cellHeight - 40)];
    }else{
        [self.ivBgView setFrame:CGRectMake(14, 10, self.viewWidth-28, cellHeight - 10)];
    }
    [self.ivBgView setBackgroundColor:[UIColor whiteColor]];
    
    // 12为增加的间隙(气泡和整个frame)
    self.frame = CGRectMake(0, 0, self.viewWidth, cellHeight +12);
    
    return cellHeight + 24;
}

- (void)sendMessageToUser{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeSendGoosText obj:[self getZCproductInfo]];
    }
}

-(void)resetCellView{
    [super resetCellView];
    
    [self.lblNickName setText:@""];
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
//    CGFloat cellHeight = 12;
//    if(![@"" isEqual:zcLibConvertToString(showTime)]){
//        cellHeight = cellHeight + 30;
//    }
//
//     ZCProductInfo *productInfo = [ZCUIConfigManager getInstance].kitInfo.productInfo;
//    productInfo.desc = nil;
//    CGFloat maxWidth = width - 20 - 28;
//    CGFloat imgHeight = cellHeight;
////    if (productInfo.thumbUrl !=nil && ![@"" isEqualToString:productInfo.thumbUrl]) {
//        maxWidth = width - 113 -28;
//        imgHeight = imgHeight + 90;
////    }
//
//     CGFloat  textX = 103+ 14;
//
//
//     UILabel * lblTextTitle = [[UILabel alloc]initWithFrame:CGRectMake(textX, cellHeight, maxWidth, 40)];
//
//    [lblTextTitle setTextAlignment:NSTextAlignmentLeft];
//    [lblTextTitle setFont:[ZCUITools zcgetTitleGoodsFont]];
//    [lblTextTitle setTextColor:[ZCUITools zcgetGoodsTextColor]];
//    [lblTextTitle setBackgroundColor:[UIColor clearColor]];
//    lblTextTitle.numberOfLines = 2;
//    lblTextTitle.lineBreakMode = NSLineBreakByTruncatingTail;
//    lblTextTitle.text = zcLibConvertToString(productInfo.title);
//    [lblTextTitle sizeToFit];
//
//    // 标题的高度
//    cellHeight = cellHeight + CGRectGetHeight(lblTextTitle) + 10;
//
//    // 摘要
//    if (zcLibConvertToString(productInfo.desc)!=nil && ![@"" isEqualToString:productInfo.desc]) {
//
//        if (zcLibConvertToString(productInfo.label)!=nil && ![@"" isEqualToString:productInfo.label]) {
//            cellHeight = cellHeight +34;
//        }
//        else{
//            // 获取摘要的内容大小
//            CGSize size = [zcLibConvertToString(productInfo.desc) boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont]} context:nil].size;
//
//            cellHeight = cellHeight + size.height + 10;
//        }
//    }
//
//
//    // 标签
//    if (zcLibConvertToString(productInfo.label)!=nil && ![@"" isEqualToString:productInfo.label]) {
//        cellHeight = cellHeight + 18 +10;
//    }
//
//
//    // 发送按钮（计算发送按钮的在这8中商品展示的位置）
//    if((imgHeight- cellHeight) > 31){
//        cellHeight = imgHeight + 12;
//    }else{
//        cellHeight = cellHeight + 5 + 26 + 12;
//    }
//
//
//    return cellHeight + 24;
    
    return 124;
}


- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}


@end
