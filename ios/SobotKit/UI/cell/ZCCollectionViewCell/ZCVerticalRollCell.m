//
//  ZCVerticalRollCell.m
//  SobotKit
//
//  Created by lizhihui on 2017/11/13.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCVerticalRollCell.h"
#import "ZCCollectionViewCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCMLEmojiLabel.h"
#import "ZCPlatformTools.h"
#import "ZCButton.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"



@interface ZCVerticalRollCell()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ZCMLEmojiLabelDelegate>{
}

@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UILabel *tempLabel;
@property(nonatomic,strong)NSMutableArray  *listArray;
@property(nonatomic,strong)ZCMLEmojiLabel * titleLab;

@property (nonatomic,assign) BOOL  isHistoryMsg;
@property (nonatomic,strong) ZCButton * moreBtn;// 展开更多

@property (nonatomic,assign) int  moreCount ; // 当前展开的个数
@property (nonatomic,assign) int  allMoreCount;// 实际个数

@property (nonatomic,strong) ZCLibMessage * currtModel;//记录当前的model
@end

@implementation ZCVerticalRollCell

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

-(ZCButton *)moreBtn{
    if (!_moreBtn) {
        _moreBtn = [ZCButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.backgroundColor = [UIColor whiteColor];
        _moreBtn.type = 2;
        _moreBtn.layer.cornerRadius = 13;
        _moreBtn.layer.masksToBounds = YES;
        [_moreBtn setTitle:@"展开更多" forState:UIControlStateNormal];
        [_moreBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_down"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(openMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtn setTitleColor:[ZCUITools zcgetOpenMoreBtnTextColor] forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = DetGoodsFont;
        [self.contentView addSubview:_moreBtn];
        _moreBtn.hidden = YES;
    }
    return _moreBtn;
}

-(void)openMoreAction:(UIButton*)sender{
   
    // 最大值 回复最小值3
    if (self.moreCount == self.allMoreCount) {
        self.moreCount = 3;
        self.currtModel.richModel.multiModel.moreCurrtCount = self.moreCount;
//        self.tempModel.richModel.multiModel.moreCurrtCount = self.moreCount;
        [_moreBtn setTitle:@"展开更多" forState:UIControlStateNormal];
        [_moreBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_down"] forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
            [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionBtnSend obj:nil];
        }
        return;
    }
    
    self.moreCount = self.moreCount + 3;
    if (self.moreCount >self.allMoreCount) {
        self.moreCount = self.allMoreCount;
    }
    

    self.currtModel.richModel.multiModel.moreCurrtCount = self.moreCount;
//    self.tempModel.richModel.multiModel.moreCurrtCount = self.moreCount;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionBtnSend obj:nil];
    }
    
    if (self.allMoreCount<4) {
        self.moreBtn.hidden = YES;
    }
 
   
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setupView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupView];
    }
    return self;
}


-(void)setupView{
    _collectionView = ({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(ScreenWidth - 30, 54);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(15, 0, ScreenWidth - 30,0) collectionViewLayout:layout];
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


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listArray.count;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
     CGFloat collectionH = 0;
    ZCMultiwheelModel *pm = self.tempModel.richModel.multiModel;
    NSDictionary *detail = [pm.interfaceRetList objectAtIndex:indexPath.row];
    NSString * detalab = zcLibConvertToString(detail[@"summary"]);
    NSString * img = zcLibConvertToString(detail[@"thumbnail"]);
//    CGFloat LW = ScreenWidth - 30;
//
//    UILabel * templab = [[UILabel alloc]init];
//    templab.text = zcLibConvertToString(detalab);
//    templab.numberOfLines = 3;
//    templab.font = [UIFont systemFontOfSize:14];
//    CGSize tempSize;
//    if ([@"" isEqualToString:img]) {
//        // 没有图片 宽度为 LW - 80
//        templab.frame = CGRectMake(10, 27, LW - 80, 17);
//     tempSize = [self autoHeightOfLabel:templab with:LW - 80];
//
//    }else{
//        // 有图片 宽度为 LW - 64 - 80
//        templab.frame = CGRectMake(64, 27, LW - 64 - 80, 17);
//      tempSize = [self autoHeightOfLabel:templab with:LW - 64 - 80];
//    }
//
//    CGRect labelF = templab.frame;
//    labelF.size.height = tempSize.height;
//    templab.frame = labelF;
//
//     // 当前使用固定大小
//    if (templab.frame.size.height >17) {
//        CGFloat height = templab.frame.size.height;
//        if (height >51) {
//            height = 51;
//        }
//        return CGSizeMake(ScreenWidth - 30, 54 + height -17);
//    }else{
//        return CGSizeMake(ScreenWidth - 30 , 54);
//    }

    
    CGFloat collectionViewHeight = 0;
    UILabel * templab = [[UILabel alloc]init];
    templab.text = zcLibConvertToString(detalab);
    templab.numberOfLines = 3;
    templab.font = [UIFont systemFontOfSize:12];
    CGSize tempSize;
    
    CGFloat titleTextWidth = 0; // 记录 计算标题文本的宽度 最大宽度
    CGFloat detailTextWidth = 0;// 记录 计算详情文本的宽度 最大宽度
    CGFloat deatilY = 0;// 详情的Y
    CGFloat deatilX = 0;
    //        collectionViewHeight = 34 ;// 默认高度
    // 图片
    if (![@"" isEqualToString:zcLibConvertToString(img)]) {
        titleTextWidth = ScreenWidth - 30 - 54 -10;
        detailTextWidth = ScreenWidth - 30 - 54 - 10;
        deatilX = 54;
        //            collectionViewHeight = 54;
    }else{
        titleTextWidth = ScreenWidth - 30 - 10 - 10;
        detailTextWidth = ScreenWidth - 30 - 10 - 10;
        deatilX = 10;
    }
    
    // 标签  标签的宽度 90 间距
    if (![@"" isEqualToString:zcLibConvertToString(detail[@"tag"])]) {
        titleTextWidth = ScreenWidth - 30 - 54 -10 - 100;
    }
    // 标题
    if (![@"" isEqualToString:zcLibConvertToString(detail[@"tag"])] || ![@"" isEqualToString:zcLibConvertToString(detail[@"title"])]) {
        deatilY = 32;
    }else if ([@"" isEqualToString:zcLibConvertToString(detail[@"title"])] && [@"" isEqualToString:zcLibConvertToString(detail[@"tag"])]){
        deatilY = 10;
    }
    
    if (![@"" isEqualToString:zcLibConvertToString(detail[@"summary"])]) {
        templab.frame = CGRectMake(deatilX, deatilY, detailTextWidth, 17);
        tempSize = [self autoHeightOfLabel:templab with:detailTextWidth];
    }
    
    CGRect labelF = templab.frame;
    labelF.size.height = tempSize.height;
    // 当前使用固定大小  详情的实际大小
    if (templab.frame.size.height >51) {
        labelF.size.height = 51;
    }
    templab.frame = labelF;
    
    if (![@"" isEqualToString:zcLibConvertToString(detail[@"thumbnail"])]) {
        if (CGRectGetMaxY(templab.frame) > 44) {
            collectionViewHeight = CGRectGetMaxY(templab.frame) + 10;
        }else{
            collectionViewHeight = 54;
        }
    }else {
        if ([@"" isEqualToString:zcLibConvertToString(detail[@"summary"])]) {
            collectionViewHeight = 34;
        }else {
            collectionViewHeight = CGRectGetMaxY(templab.frame) +10;
            if (collectionViewHeight <34) {
                collectionViewHeight = 34;
            }
        }
        
    }
    
    collectionH = collectionH + collectionViewHeight;
    
    return CGSizeMake(ScreenWidth -30, collectionH);
    
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [collectionView dequeueReusableCellWithReuseIdentifier:kZCCollectionViewCellID forIndexPath:indexPath];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
   
//    NSLog(@"点击纵向的item");
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
    
    ZCCollectionViewCell *vcell = (ZCCollectionViewCell *)cell;
    vcell.collectionCellType = CollectionCellType_Vertical;
//    vcell.bottomLineView.hidden = NO;
//    [vcell configureCellWithPostURL:@{@"imageURL":@"postImage.jpg",@"row":[NSString stringWithFormat:@"%zd",indexPath.row],@"desc":_listArray[indexPath.row]}];
    [vcell configureCellWithPostURL:model WithIsHistory:_isHistoryMsg];
//    CGFloat LW = ScreenWidth - 30;
    [vcell.labTag setFont:ListDetailFont];
    [vcell.labTag setTextColor:UIColorFromRGB(0x8B98AD)];
    
    vcell.labTag.textAlignment = NSTextAlignmentRight;
    vcell.labDesc.numberOfLines = 3;
    // 重新计算高度
    CGSize tempSize;
    
    CGFloat titleTextWidth = 0; // 记录 计算标题文本的宽度 最大宽度
    CGFloat detailTextWidth = 0;// 记录 计算详情文本的宽度 最大宽度
    CGFloat deatilY = 0;// 详情的Y
    CGFloat deatilX = 0;
    CGFloat titleX = 0;
    
   
    
    if([@"" isEqualToString:zcLibConvertToString(model[@"thumbnail"])]){
        // 没图片
        titleTextWidth = ScreenWidth - 30 - 10 - 10;
        detailTextWidth = ScreenWidth - 30 - 10 - 10;
        deatilX = 10;
        titleX = 10;
        vcell.posterView.hidden = YES;
//        [vcell.labTitle setFrame:CGRectMake(10, 10, LW - 80, 17)];
//        [vcell.labDesc setFrame:CGRectMake(10, 27, LW - 80, 17)];
//        [vcell.labTag setFrame:CGRectMake(LW - 110, 10, 100, 12)];
//        tempSize = [self autoHeightOfLabel:vcell.labDesc with:LW - 80];
    }else{
        // 有图片
        vcell.posterView.hidden = NO;
        [vcell.posterView setFrame:CGRectMake(10, 10, 34, 34)];
        titleTextWidth = ScreenWidth - 30 - 54 -10;
        detailTextWidth = ScreenWidth - 30 - 54 - 10;
        deatilX = 54;
        titleX = 54;
        
        
//        [vcell.labTitle setFrame:CGRectMake(54, 10, LW - 64 - 80, 17)];
//        [vcell.labDesc setFrame:CGRectMake(64, 27, LW - 64 - 80, 17)];
//        tempSize = [self autoHeightOfLabel:vcell.labDesc with:LW - 64 - 80];
//        [vcell.labTag setFrame:CGRectMake(LW - 110, 10, 100, 12)];
        [vcell.posterView loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model[@"thumbnail"])] placeholer:nil showActivityIndicatorView:YES];

    }
    // 标签  标签的宽度 90 间距
    if (![@"" isEqualToString:zcLibConvertToString(model[@"tag"])]) {
        titleTextWidth = ScreenWidth - 30 - 54 -10 - 100;
    }
    
    // 标题
    if (![@"" isEqualToString:zcLibConvertToString(model[@"tag"])] || ![@"" isEqualToString:zcLibConvertToString(model[@"title"])]) {
        deatilY = 32;
        
    }else if ([@"" isEqualToString:zcLibConvertToString(model[@"title"])] && [@"" isEqualToString:zcLibConvertToString(model[@"tag"])]){
        deatilY = 10;
    }
    
    
    // 最后赋值
    
    // 标题
    if (![@"" isEqualToString:zcLibConvertToString(model[@"title"])]) {
        [vcell.labTitle setFrame:CGRectMake(titleX, 10, titleTextWidth, 15)];
    }
    
    // 标签
    if (![@"" isEqualToString:zcLibConvertToString(model[@"tag"])]) {
         [vcell.labTag setFrame:CGRectMake(ScreenWidth -35 -90 - 10, 10, 90, 12)];
    }
    
    // 详情
    if (![@"" isEqualToString:zcLibConvertToString(model[@"summary"])]) {
        [vcell.labDesc setFrame:CGRectMake(deatilX, deatilY, detailTextWidth, 17)];
        tempSize = [self autoHeightOfLabel:vcell.labDesc with:detailTextWidth];
    
        // 当前使用固定大小  详情的实际大小
        if (tempSize.height >51) {
            tempSize.height = 51;
        }
        [vcell.labDesc setFrame:CGRectMake(deatilX, deatilY, detailTextWidth, tempSize.height)];
    }
 
}


#pragma mark -- 父类的方法

-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    
    [_collectionView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_collectionView removeFromSuperview];
    [self setupView];
    if (self.currtModel == nil) {
        self.currtModel = model;
    }else{
        model = self.currtModel;
    }
    
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
    
    msgF.origin.x = msgX;
    msgF.origin.y = msgF.origin.y + cellHeight;
    [self.titleLab setFrame:msgF];
    
    // 设置collcetionView
    CGRect CF = _collectionView.frame;
    CF.origin.x = 15;
    CF.origin.y = CGRectGetMaxY(self.titleLab.frame) + 15;
    
//    CF.size.height = model.richModel.multiModel.interfaceRetList.count * 54;
#pragma mark -- 每个item的高度不固定
/**
 *   每个元素都可以为空 当所有元素为空显示大白块 高度34
 *   详情和标签高度不能出现相同Y值的情况
 *   标题和详情的间距 6PX
 *   标题和标签同Y值
 *   图片的间距 上 左 右 10PX
 */
    // 循环便利每一个item的最终高度，相加，得到_collectionView的高度 。。。
   
    CGFloat collectionH = 0;
    self.allMoreCount = (int)model.richModel.multiModel.interfaceRetList.count;
    
    if (model.richModel.multiModel.moreCurrtCount > 0) {
        self.moreCount = model.richModel.multiModel.moreCurrtCount;
    }
    
    if (self.moreCount == 0 ) {
        self.moreCount = 3;
    }
    if (self.allMoreCount <=3) {
        self.moreCount = self.allMoreCount;
    }else if (self.moreCount>self.allMoreCount){
        self.moreCount = (int)model.richModel.multiModel.interfaceRetList.count;
    }

    model.richModel.multiModel.moreCurrtCount = self.moreCount;
    
    if (model.isHistory) {
        if (self.moreCount>3) {
            self.moreCount = 3;
        }
    }
    
    for (int i = 0; i<self.moreCount; i++) {
        CGFloat collectionViewHeight = 0;
        UILabel * templab = [[UILabel alloc]init];
        templab.text = zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"summary"]);
        templab.numberOfLines = 3;
        templab.font = [UIFont systemFontOfSize:12];
        CGSize tempSize;
        
        CGFloat titleTextWidth = 0; // 记录 计算标题文本的宽度 最大宽度
        CGFloat detailTextWidth = 0;// 记录 计算详情文本的宽度 最大宽度
        CGFloat deatilY = 0;// 详情的Y
        CGFloat deatilX = 0;
//        collectionViewHeight = 34 ;// 默认高度
        // 图片
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"thumbnail"])]) {
            titleTextWidth = ScreenWidth - 30 - 54 -10;
            detailTextWidth = ScreenWidth - 30 - 54 - 10;
            deatilX = 54;
//            collectionViewHeight = 54;
        }else{
            titleTextWidth = ScreenWidth - 30 - 10 - 10;
            detailTextWidth = ScreenWidth - 30 - 10 - 10;
            deatilX = 10;
        }
        
        // 标签  标签的宽度 90 间距
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"tag"])]) {
            titleTextWidth = ScreenWidth - 30 - 54 -10 - 100;
        }
        // 标题
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"tag"])] || ![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"title"])]) {
            deatilY = 32;
        }else if ([@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"title"])] && [@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"tag"])]){
            deatilY = 10;
        }
        
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"summary"])]) {
             templab.frame = CGRectMake(deatilX, deatilY, detailTextWidth, 17);
            tempSize = [self autoHeightOfLabel:templab with:detailTextWidth];
        }
        
        CGRect labelF = templab.frame;
        labelF.size.height = tempSize.height;
        // 当前使用固定大小  详情的实际大小
        if (templab.frame.size.height >51) {
            labelF.size.height = 51;
        }
        templab.frame = labelF;
    
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"thumbnail"])]) {
            if (CGRectGetMaxY(templab.frame) > 44) {
                collectionViewHeight = CGRectGetMaxY(templab.frame) + 10;
            }else{
                collectionViewHeight = 54;
            }
        }else {
            if ([@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"summary"])]) {
                collectionViewHeight = 34;
            }else {
                collectionViewHeight = CGRectGetMaxY(templab.frame) +10;
                if (collectionViewHeight <34) {
                    collectionViewHeight = 34;
                }
            }
            
        }
        
        collectionH = collectionH + collectionViewHeight;
    }
    CF.size.height = collectionH;
    CF.size.width = ScreenWidth - 30;
    [_collectionView setFrame:CF];
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    
  
//    _listArray = model.richModel.multiModel.interfaceRetList;
    
    if (_listArray!= nil) {
        [_listArray removeAllObjects];
    }else{
       _listArray = [NSMutableArray new];
    }
    
    for (int i = 0; i< self.moreCount; i++) {
        [_listArray addObject:model.richModel.multiModel.interfaceRetList[i]];
    }
    
    [_collectionView reloadData];
  
    
    if (self.allMoreCount>3 && !model.isHistory) {
        self.moreBtn.hidden = NO;
        [self.moreBtn setFrame:CGRectMake(self.viewWidth/2 - 45, CGRectGetMaxY(_collectionView.frame) +10, 90, 26)];
        [self setFrame:CGRectMake(0, 0, self.viewWidth, CGRectGetMaxY(_moreBtn.frame) +10)];
        height = height + CGRectGetMaxY(_moreBtn.frame) +10;
        // 当前是 以增加到最大值
        if (self.moreCount == self.allMoreCount && self.allMoreCount>3) {
            [_moreBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_up"] forState:UIControlStateNormal];
            [_moreBtn setTitle:@"收起全部" forState:UIControlStateNormal];
        }
    }else{
        self.moreBtn.hidden = YES;
        [self setFrame:CGRectMake(0, 0, self.viewWidth, CGRectGetMaxY(_collectionView.frame) +10)];
        height = height + CGRectGetMaxY(_collectionView.frame) +10;
    }

    cellHeight = cellHeight + height;
    return  cellHeight ;
    
}

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellHeight = [super getCellHeight:model time:showTime viewWith:width];

    CGFloat maxWidth = ScreenWidth - 160;

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
             titleLab.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }
       
        //        }else{
        //            titleLab.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:titleLab textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
        //        }
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
    
    // 循环便利每一个item的最终高度，相加，得到_collectionView的高度 。。。
    
//    CGFloat LW = ScreenWidth - 30;
     CGFloat collectionH = 0;
    
    
    // 获取个数
    int allMoreCount = (int)model.richModel.multiModel.interfaceRetList.count;
    int currtMoreCount = 0;
    
    if (model.richModel.multiModel.moreCurrtCount != 0) {
        currtMoreCount = model.richModel.multiModel.moreCurrtCount;
    }
    
    if (currtMoreCount == 0 ) {
        currtMoreCount = 3;
    }
    if (allMoreCount <=3) {
        currtMoreCount = allMoreCount;
    }else if (currtMoreCount > allMoreCount){
        currtMoreCount = (int)model.richModel.multiModel.interfaceRetList.count;
    }
    
    model.richModel.multiModel.moreCurrtCount = currtMoreCount;
    
//    BOOL isHistoryMsg = model.richModel.multiModel.isHistoryMessages;
    if (model.isHistory) {
        if (currtMoreCount >3) {
            currtMoreCount = 3;
        }
    }
    
    for (int i = 0; i< currtMoreCount; i++) {
        CGFloat collectionViewHeight = 0;
        UILabel * templab = [[UILabel alloc]init];
        templab.text = zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"summary"]);
        templab.numberOfLines = 3;
        templab.font = [UIFont systemFontOfSize:12];
        CGSize tempSize;
        
        CGFloat titleTextWidth = 0; // 记录 计算标题文本的宽度 最大宽度
        CGFloat detailTextWidth = 0;// 记录 计算详情文本的宽度 最大宽度
        CGFloat deatilY = 0;// 详情的Y
        CGFloat deatilX = 0;
        //        collectionViewHeight = 34 ;// 默认高度
        // 图片
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"thumbnail"])]) {
            titleTextWidth = ScreenWidth - 30 - 54 -10;
            detailTextWidth = ScreenWidth - 30 - 54 - 10;
            deatilX = 54;
            //            collectionViewHeight = 54;
        }else{
            titleTextWidth = ScreenWidth - 30 - 10 - 10;
            detailTextWidth = ScreenWidth - 30 - 10 - 10;
            deatilX = 10;
        }
        
        // 标签  标签的宽度 90 间距
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"tag"])]) {
            titleTextWidth = ScreenWidth - 30 - 54 -10 - 100;
        }
        // 标题
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"tag"])] || ![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"title"])]) {
            deatilY = 32;
        }else if ([@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"title"])] && [@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"tag"])]){
            deatilY = 10;
        }
        
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"summary"])]) {
            templab.frame = CGRectMake(deatilX, deatilY, detailTextWidth, 17);
            tempSize = [ZCVerticalRollCell autoHeightOfLabel:templab with:detailTextWidth];
        }
        
        CGRect labelF = templab.frame;
        labelF.size.height = tempSize.height;
        
       
        // 当前使用固定大小  详情的实际大小
        if (templab.frame.size.height >51) {
            labelF.size.height = 51;
        }
        templab.frame = labelF;
        
        if (![@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"thumbnail"])]) {
            if (CGRectGetMaxY(templab.frame) > 44) {
                collectionViewHeight = CGRectGetMaxY(templab.frame) + 10;
            }else{
                collectionViewHeight = 54;
            }
        }else {
            if ([@"" isEqualToString:zcLibConvertToString(model.richModel.multiModel.interfaceRetList[i][@"summary"])]) {
                collectionViewHeight = 34;
            }else {
                collectionViewHeight = CGRectGetMaxY(templab.frame) +10;
                if (collectionViewHeight <34) {
                    collectionViewHeight = 34;
                }
            }
            
        }
        
        collectionH = collectionH + collectionViewHeight;
        
    }


    
    if (model.richModel.multiModel.interfaceRetList.count >3 && !model.isHistory) {
        // collection
        cellHeight = cellHeight + msgSize.height +15 + collectionH + 20 + 36; // 36 为moreBtn高度和间隙
    }else{
        // collection
        cellHeight = cellHeight + msgSize.height +15 + collectionH + 20;
    }
    
    
    
    return  cellHeight  ;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width,FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}

+ (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width,FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}


-(UILabel *)tempLabel{
    if(!_tempLabel){
        UILabel *lab = [UILabel new];
        [lab setTextColor:UIColor.grayColor];
        [lab setFont:[UIFont systemFontOfSize:14]];
        lab.numberOfLines = 0;
        _tempLabel = lab;
    }
    return _tempLabel;
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}


@end
