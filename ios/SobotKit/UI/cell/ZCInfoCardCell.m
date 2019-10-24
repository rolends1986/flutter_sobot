//
//  ZCInfoCardCell.m
//  SobotKit
//
//  Created by lizhihui on 2019/4/24.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCInfoCardCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUIImageView.h"
#import "ZCStoreConfiguration.h"
#import "ZCUICore.h"

@interface ZCInfoCardCell(){
    ZCLibMessage * tempModel;// 临时存储
}

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,strong) UILabel * tipLab;

@property (nonatomic,strong) ZCUIImageView   *imgPhoto;

@property (nonatomic,strong) UIButton * jumpBtn;

@end




@implementation ZCInfoCardCell

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if(self){
//        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
//        tapG.delegate = self;
//        [self.ivBgView addGestureRecognizer:tapG];
//    }
//    return self;
//}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
//        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendMessageToUser)];
//        tapG.delegate = self;
        self.ivBgView.userInteractionEnabled = YES;
//        [self.ivBgView addGestureRecognizer:tapG];
        
        _imgPhoto = [[ZCUIImageView alloc] init];
        [_imgPhoto setBackgroundColor:[UIColor clearColor]];
        [_imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
        _imgPhoto.layer.masksToBounds=YES;
        _imgPhoto.layer.borderColor = UIColorFromRGB(LineGoodsImageColor).CGColor;
        _imgPhoto.layer.borderWidth = 1.0f;
        
        [self.contentView addSubview:_imgPhoto];
        
        
        // title
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_titleLab setTextAlignment:NSTextAlignmentLeft];
        [_titleLab setFont:[ZCUITools zcgetTitleGoodsFont]];
        [_titleLab setTextColor:[ZCUITools zcgetRightChatTextColor]];
        [_titleLab setBackgroundColor:[UIColor clearColor]];
        _titleLab.numberOfLines = 2;
        _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLab];
        
        // 标签
        _tipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_tipLab setTextAlignment:NSTextAlignmentLeft];
        [_tipLab setFont:[ZCUITools zcgetTitleGoodsFont]];
        [_tipLab setBackgroundColor:[UIColor clearColor]];
        [_tipLab setTextColor:UIColorFromRGB(BgDotRedColor)];
        _tipLab.numberOfLines = 1;
        _tipLab.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_tipLab];
        
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
//        self.contentView.userInteractionEnabled = YES;
//        self.userInteractionEnabled = YES;
//        self.imgPhoto.userInteractionEnabled = YES;
//        self.titleLab.userInteractionEnabled = YES;
//        self.tipLab.userInteractionEnabled = YES;
//        [self.imgPhoto addGestureRecognizer:tapG];
//        [self.titleLab addGestureRecognizer:tapG];
//        [self.tipLab addGestureRecognizer:tapG];
        
        
        _jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _jumpBtn.backgroundColor = [UIColor clearColor];
        [_jumpBtn addTarget:self action:@selector(sendMessageToUser) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_jumpBtn];
        
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
    
//    if (![NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]) {
//        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
//            [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:[self getZCproductInfo].link];
//        }
//    }
    return YES;
}




//- (ZCProductInfo *)getZCproductInfo{
//    ZCProductInfo * productInfo = [ZCUICore getUICore].kitInfo.productInfo;
//    productInfo.desc = @"";
//    return productInfo;
//}

- (ZCProductInfo *)getZCproductInfo{
    ZCProductInfo * productInfo = nil;
    if(self.tempModel.richModel.msg!=nil){
        @try {
            NSError * err;
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:[zcLibConvertToString(self.tempModel.richModel.msg) dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];
            if (!err) {
                productInfo = [ZCProductInfo new];
                productInfo.thumbUrl = zcLibConvertToString(dict[@"thumbnail"]);
                productInfo.title = zcLibConvertToString(dict[@"title"]);
                productInfo.desc = zcLibConvertToString(dict[@"desc"]);
                productInfo.label = zcLibConvertToString(dict[@"label"]);
                productInfo.link = zcLibConvertToString(dict[@"link"]);
                if (!productInfo.link.length){
                    productInfo.link = zcLibConvertToString(dict[@"url"]);
                }
            }else{
                productInfo = [ZCUICore getUICore].kitInfo.productInfo;
            }
            
        } @catch (NSException *exception) {
            productInfo = [ZCUICore getUICore].kitInfo.productInfo;
        } @finally {
            
        }
        
    }
    
    
    productInfo.desc = @"";
    return productInfo;
}

-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    CGFloat bgY=[super InitDataToView:model time:showTime];
    [_titleLab setText:@""];
    [_tipLab setText:@""];
    
    tempModel = model;
    
    for (UIView *v in self.ivBgView.subviews) {
        [v removeFromSuperview];
    }
    
    
    // 图片隐藏
    CGFloat maxWidth = self.viewWidth - 160;
    
    CGFloat msgX = 0;
    CGRect bgF = CGRectMake(0, 0, 0, 100);
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx=self.viewWidth - maxWidth - 30 -50;
        msgX = rx;
        bgF.origin.x = rx - 8;
        bgF.origin.y = bgY;
        bgF.size.width = maxWidth + 28;
        [self.ivBgView setFrame:bgF];
    }else{
        msgX = 78;
        bgF.origin.x = 58;
        bgF.origin.y = bgY;
        bgF.size.width = maxWidth + 33;
        [self.ivBgView setFrame:bgF];
    }
    
    [_imgPhoto setFrame:CGRectMake(msgX, bgY + 10, 80, 80)];
    
    if (model.miniPageDic && model.isHistory) {
        [_imgPhoto loadWithURL:[NSURL URLWithString:zcLibConvertToString(model.miniPageDic[@"thumbnail"])] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]  showActivityIndicatorView:NO];
    }else{
        [_imgPhoto loadWithURL:[NSURL URLWithString:zcLibConvertToString([self getZCproductInfo].thumbUrl)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]  showActivityIndicatorView:NO];
    }
    
    
    _imgPhoto.hidden = NO;
    
    
    CGFloat textX = msgX + 80 + 10;
    
    
    // 有图片
    [_titleLab setFrame:CGRectMake(textX, bgY + 10, maxWidth - 90, 40)];
    if (model.miniPageDic && model.isHistory) {
        _titleLab.text = zcLibConvertToString(model.miniPageDic[@"title"]);
    }else{
        _titleLab.text = zcLibConvertToString([self getZCproductInfo].title);
    }
    
    
    CGSize size = [_titleLab.text boundingRectWithSize:CGSizeMake(_titleLab.frame.size.width, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ZCUITools zcgetTitleGoodsFont]} context:nil].size;
    [_titleLab setFrame:CGRectMake(textX, bgY + 10, self.maxWidth - 90, size.height)];
    
    
    // 标签
     if ((zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label]) || (model.miniPageDic && model.isHistory && zcLibConvertToString(model.miniPageDic[@"label"]).length >0 )) {
         [_tipLab setFrame:CGRectMake(textX, CGRectGetMaxY(_titleLab.frame) +10, self.maxWidth - 100, 21)];
        //    [_lblTextTip setText:zcLibConvertToString(model.richModel.stripe)];
        _tipLab.hidden = NO;
         if (model.miniPageDic && model.isHistory) {
           _tipLab.text = zcLibConvertToString(model.miniPageDic[@"label"]);
         }else{
           _tipLab.text = zcLibConvertToString([self getZCproductInfo].label);
         }
         
     }
    
    
    [self setSendStatus:self.ivBgView.frame];
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    [_jumpBtn setFrame:self.ivBgView.frame];
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, 100+bgY + 10)];
    return 100 + bgY + 10;
}


//给UILabel设置行间距和字间距
-(void)setLabelSpace:(UILabel*)label withValue:(NSString*)str {
    
    NSMutableAttributedString *strAttr = [[NSMutableAttributedString alloc] initWithString:str];
    UIColor *color = [ZCUITools zcgetGoodsTextColor];
    [strAttr addAttribute:NSForegroundColorAttributeName value:color range:[str rangeOfString:@"售价：￥"]];
    
    //    NSAttributedString *strAttr = [[NSAttributedString alloc] initWithString:str attributes:dic];
    label.attributedText = strAttr;
}


- (void)sendMessageToUser{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
        
        NSString * link = @"";
        if (tempModel.miniPageDic && tempModel.isHistory) {
            link = zcLibConvertToString(tempModel.miniPageDic[@"url"]);
        }else{
            link = zcLibConvertToString([self getZCproductInfo].link);
        }
        [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:link];
    }
}

-(void)resetCellView{
    [super resetCellView];
    
    [self.lblNickName setText:@""];
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellheith = [super getCellHeight:model time:showTime viewWith:width];
    
    return 100 + cellheith + 10;
}


- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
