//
//  ZCHorizontalRollCell.m
//  SobotKit
//
//  Created by lizhihui on 2017/11/13.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCHorizontalRollCell.h"
#import "ZCCollectionViewCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCMLEmojiLabel.h"
#import "ZCPlatformTools.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

@interface ZCHorizontalRollCell()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ZCMLEmojiLabelDelegate>{
    
}

@property (nonatomic,strong) UICollectionView * collectionView;

@property (nonatomic,strong) NSMutableArray * listArray;

@property (nonatomic,strong)  ZCMLEmojiLabel * titleLab;

@property (nonatomic,assign) BOOL  isHistoryMsg;
@end

@implementation ZCHorizontalRollCell


-(ZCMLEmojiLabel *)titleLab{
    if(!_titleLab){
        _titleLab = [ZCMLEmojiLabel new];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [ZCUITools zcgetKitChatFont];
        _titleLab.delegate = self;
        _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab.textColor = [ZCUITools zcgetLeftChatTextColor];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.isNeedAtAndPoundSign = NO;
        _titleLab.disableEmoji = NO;
        _titleLab.lineSpacing = 3.0f;
        _titleLab.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_titleLab];
        
    }
    return _titleLab;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
     [self setupView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _isHistoryMsg = NO;
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    _collectionView = ({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(128, 210);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 10;
        
        // 12的间隙为 item 到 消息
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 12, ScreenWidth,188) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[ZCCollectionViewCell class] forCellWithReuseIdentifier:kZCCollectionViewCellID];
        [self.contentView addSubview:collectionView];
        collectionView;
    });
}

#pragma mark -- 父类的方法
-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    [_collectionView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_collectionView removeFromSuperview];
    [self setupView];
    CGFloat cellHeight = [super InitDataToView:model time:showTime];
    _isHistoryMsg = model.richModel.multiModel.isHistoryMessages;
#pragma mark  -- 提示语
    CGFloat rw = 0;
    CGFloat height = 0;
    NSString * text = model.richModel.multiModel.msg;
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (self.isRight) {
            if (text1 != nil && text1.length > 0) {
                [self titleLab].attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:[self titleLab] textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
            }else{
                [self titleLab].attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
        }else{
            if (text1 != nil && text1.length > 0) {
                 [self titleLab].attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:[self titleLab] textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                 [self titleLab].attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
           
        }
    }];
    
    
//    // 处理换行
//    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
//    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//    while ([text hasPrefix:@"\n"]) {
//        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//    }
//
//    NSMutableDictionary *dict = [self.titleLab getTextADict:text];
//    if(dict){
//        text = dict[@"text"];
//    }
//    _titleLab.text = text;
//    
//    if(dict){
//        NSArray *arr = dict[@"arr"];
//        //    [_emojiLabel setText:tempText];
//        for (NSDictionary *item in arr) {
//            NSString *text = item[@"htmlText"];
//            int loc = [item[@"realFromIndex"] intValue];
//            
//            // 一定要在设置text文本之后设置
//            [_titleLab addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
//        }
//    }
    
    CGSize size = [self.titleLab preferredSizeWithMaxWidth:self.maxWidth];
    CGRect msgF;
    msgF = CGRectMake(GetCellItemX(self.isRight), 10, size.width, size.height);
    [[self titleLab] setFrame:msgF];
    height = height + size.height +10 + Spaceheight;  //添加完提示语后的cell的高度加间距
    
//    cellHeight = cellHeight + height;// 添加完提示语后的高度，下部分为item的高度
    
    rw = size.width;
    
    CGFloat msgX = 0;
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx=self.viewWidth-rw-30 -50;
        msgX = rx;
        [self.ivBgView setFrame:CGRectMake(rx-8, cellHeight, rw+28, height + 5)];
    }else{
        msgX = 78;
        [self.ivBgView setFrame:CGRectMake(58, cellHeight, rw+33, height + 5)];
    }
    
    
    if (zcLibConvertToString(model.richModel.multiModel.msg).length == 0) {
        [self.ivBgView setBackgroundColor:[UIColor clearColor]];
    }else{
        if (self.isRight) {
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
        }else{
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
        }
    }
    
    msgF.origin.x = msgX;
    msgF.origin.y = msgF.origin.y + cellHeight;
    
    [self.titleLab setFrame:msgF];
    
    // 设置collectionView 的frame
    CGRect CF = _collectionView.frame;
    CF.origin.y = CGRectGetMaxY(self.titleLab.frame) + 15;
    [_collectionView setFrame:CF];
    

    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];

    
    // 水平滑动的样式是固定的高度 188  间隙 10
    self.frame = CGRectMake(0, 0, self.viewWidth, 210 + cellHeight + height);
    self.backgroundColor = [UIColor redColor];
    
    _listArray = [NSMutableArray arrayWithCapacity:0];
    
    _listArray = model.richModel.multiModel.interfaceRetList;
    
    cellHeight = cellHeight + 210  + height + 5;
    return cellHeight  ;
    
}

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellHeight = [super getCellHeight:model time:showTime viewWith:width];
//    CGFloat cellHeight = 22;
    CGFloat maxWidth = ScreenWidth - 160;
//    if(![@"" isEqual:zcLibConvertToString(showTime)]){
//        cellHeight = cellHeight + 30;
//    }
    
    static ZCMLEmojiLabel *titleLab = nil;
    if (!titleLab) {
        titleLab = [ZCMLEmojiLabel new];
        titleLab.numberOfLines = 0;
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLab.textColor = [UIColor whiteColor];
        titleLab.isNeedAtAndPoundSign = YES;
        titleLab.disableEmoji = NO;
        titleLab.lineSpacing = 3.0f;
        titleLab.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
    }
    
    NSString * text = model.richModel.multiModel.msg;
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
//        if (self.isRight) {
        if (text1 != nil && text1.length > 0) {
            titleLab.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:titleLab textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            titleLab.attributedText =  [[NSAttributedString alloc] initWithString:@""];
        }
        

    }];
    
    // 处理换行
//    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
//    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//    while ([text hasPrefix:@"\n"]) {
//        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//    }
//
//    NSMutableDictionary *dict = [titleLab getTextADict:text];
//    if(dict){
//        text = dict[@"text"];
//    }
//    titleLab.text = text;
    CGSize msgSize = [titleLab preferredSizeWithMaxWidth:maxWidth];
    
    
    // 水平滑动的样式是固定的高度 188  间隙 10   20为距下一cell的间隙
    return  cellHeight + 210 + msgSize.height +10 + Spaceheight + 5 +10 + 5;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listArray.count;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);//分别为上、左、下、右
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [collectionView dequeueReusableCellWithReuseIdentifier:kZCCollectionViewCellID forIndexPath:indexPath];
}

// 点击发送消息
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
//    NSLog(@" 点击水平 item的 事件 %@",indexPath);
//    NSDictionary * model = _listArray[indexPath.row];
    
    ZCMultiwheelModel *pm = self.tempModel.richModel.multiModel;
    NSDictionary *detail = [pm.interfaceRetList objectAtIndex:indexPath.row];
    
    if (pm.endFlag) {
        // 最后一轮会话，有外链，点击跳转外链
        if (![@"" isEqualToString: zcLibConvertToString(detail[@"anchor"])]) {
            // 点击超链跳转
            if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]) {
                [self.delegate cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:zcLibConvertToString(detail[@"anchor"])];
            }
        }
        return;
    }
    
    
    if (_isHistoryMsg) {
        return;
    }
    
// 发送点击消息
    NSString * title = zcLibConvertToString(detail[@"title"]);
    NSDictionary * dict = @{@"requestText":[pm getRequestText:detail],
                            @"question":[pm getQuestion:detail],
                            @"questionFlag":@"2",
                            @"title":title,@"ishotguide":@"0"
                            };
    if ([self getCurConfig].isArtificial) {
        dict = @{@"title":title,@"ishotguide":@"0"};
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionSendMsg obj:dict];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * model = _listArray[indexPath.row];
    
    [(ZCCollectionViewCell *)cell configureCellWithPostURL:model WithIsHistory:_isHistoryMsg];
}



-(void)resetCellView{
    [super resetCellView];
//    [self.lblNickName setText:@""];
    
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
