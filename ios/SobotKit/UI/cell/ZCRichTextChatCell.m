//
//  ZCTextChatCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCRichTextChatCell.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUIImageView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCActionSheet.h"
#import "ZCUIToastTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCIMChat.h"
#import "ZCHtmlCore.h"
#import "ZCLocalStore.h"
#import "ZCToolsCore.h"


#define MidImageHeight 110
@interface ZCRichTextChatCell()<ZCMLEmojiLabelDelegate,ZCUIXHImageViewerDelegate,ZCActionSheetDelegate>{
    NSString    *callURL;
    ZCMLEmojiLabel *_lblTextMsg;
    ZCUIImageView *_middleImageView; // 图片
    ZCMLEmojiLabel *_lookMoreLabel; // 查看更多
    UIView       * _lineView; // 线条
    
    UIMenuController *menuController;
    NSString *_coderURLStr;
    ZCUIXHImageViewer *_imageViewer;
}

@end


@implementation ZCRichTextChatCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        tapG.delegate = self;
        [self.ivBgView addGestureRecognizer:tapG];
        
        
    }
    return self;
}


- (void)tap
{
//    NSLog(@"tapped");
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![self.emojiLabel containslinkAtPoint:[touch locationInView:self.emojiLabel]];
}

#pragma mark - getter
- (ZCMLEmojiLabel *)emojiLabel // 中间的消息体
{
    if (!_lblTextMsg) {
        _lblTextMsg = [ZCMLEmojiLabel new];
        _lblTextMsg.numberOfLines = 0;
        _lblTextMsg.font = [ZCUITools zcgetKitChatFont];
        _lblTextMsg.delegate = self;
        _lblTextMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblTextMsg.textColor = [UIColor whiteColor];
        _lblTextMsg.backgroundColor = [UIColor clearColor];

//        _lblTextMsg.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _lblTextMsg.isNeedAtAndPoundSign = NO;
        _lblTextMsg.disableEmoji = NO;
        
        _lblTextMsg.lineSpacing = 3.0f;
        
        _lblTextMsg.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_lblTextMsg];
    }
    return _lblTextMsg;
}

-(ZCUIImageView *)middleImageView{
    if(!_middleImageView){
        _middleImageView=[[ZCUIImageView alloc] init];
        [_middleImageView setBackgroundColor:[UIColor clearColor]];
        [_middleImageView setContentMode:UIViewContentModeScaleAspectFill];
        _middleImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:_middleImageView];
    }
    return _middleImageView;
}

- (ZCMLEmojiLabel *)lookMoreLabel
{
    if (!_lookMoreLabel) {
        _lookMoreLabel = [ZCMLEmojiLabel new];
        _lookMoreLabel.numberOfLines = 0;
        _lookMoreLabel.font = [ZCUITools zcgetKitChatFont];
        _lookMoreLabel.delegate = self;
        _lookMoreLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _lookMoreLabel.textColor = [UIColor whiteColor];
        _lookMoreLabel.backgroundColor = [UIColor clearColor];
        //        _sugguestLabel.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _lookMoreLabel.isNeedAtAndPoundSign = NO;
        _lookMoreLabel.disableEmoji = NO;
        _lookMoreLabel.lineSpacing = 3.0f;
        
//        _lookMoreLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_lookMoreLabel];
    }
    return _lookMoreLabel;
}


#pragma mark -- 长按复制
- (void)doLongPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    [self didChangeBgColorWithsIsSelect:YES];
    
    [self becomeFirstResponder];
    menuController = [UIMenuController sharedMenuController];
    UIMenuItem *copyItem = [[UIMenuItem alloc]initWithTitle:ZCSTLocalString(@"复制") action:@selector(doCopy)];
    [menuController setMenuItems:@[copyItem]];
    [menuController setArrowDirection:(UIMenuControllerArrowDefault)];
    // 设置frame cell的位置
    CGRect tf     = _lblTextMsg.frame;
    CGRect rect = CGRectMake(tf.origin.x, tf.origin.y, tf.size.width, 1);
    
    [menuController setTargetRect:rect inView:self];
    
    [menuController setMenuVisible:YES animated:YES];
}

- (void)willHideEditMenu:(id)sender{
    [self didChangeBgColorWithsIsSelect:NO];
}

- (void)didChangeBgColorWithsIsSelect:(BOOL)isSelected{

    if (isSelected) {
        if (self.isRight) {
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatSelectdeColor]];
        }else{
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatSelectedColor]];
        }
    }else{
        if (self.isRight) {
            // 右边气泡绿色
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
        }else{
            // 左边的气泡颜色
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
        }
       [menuController setTargetRect:CGRectMake(0, 0, 0, 0) inView:nil];
    }
    [self.ivBgView setNeedsDisplay];
    
}

//复制
-(void)doCopy{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.tempModel.richModel.msg];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeShowToast obj:nil];
    }
    [self didChangeBgColorWithsIsSelect:NO];
}


#pragma mark - UIMenuController 必须实现的两个方法
- (BOOL)canBecomeFirstResponder{
    return YES;
}

/*
 *  根据action,判断UIMenuController是否显示对应aciton的title
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(doCopy) ) {
        return YES;
    }
    return NO;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat bgY=[super InitDataToView:model time:showTime];
    
    
    [self emojiLabel].text = @"";
    
    if (model.richModel.msgType == 0) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doLongPress:)];
        
        [self.emojiLabel addGestureRecognizer:longPress];
        
        // 添加复制框消失的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideEditMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    
    CGFloat rw = self.maxWidth;
    CGFloat height = 0;
    
    
    CGRect msgF = CGRectZero;
    CGRect imgF = CGRectZero;
    CGRect lineF = CGRectZero;
    CGRect moreF = CGRectZero;
    
    if ([ZCChatBaseCell getStatusHeight:model] >0) {
        // 显示顶踩 固定最大宽度
        rw = self.maxWidth;
    }
    
    for (UIView *v in self.ivBgView.subviews) {
        [v removeFromSuperview];
    }
    
    if(model.richModel.msgType == 15 && model.richModel.multiModel.msgType == 3){
        NSMutableDictionary * detailDict = model.richModel.multiModel.interfaceRetList.firstObject; // 多个
        model.richModel.richpricurl = zcLibConvertToString(detailDict[@"thumbnail"]);
        model.richModel.richmoreurl = zcLibConvertToString(detailDict[@"anchor"]);
    }
    
#pragma mark  -- 图片
    // 处理图片  当前的图片高度固定110
    if(model.richModel.msgType>0 && !zcLibIs_null(model.richModel.richpricurl)){
        [[self middleImageView] loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.richModel.richpricurl)] placeholer:nil showActivityIndicatorView:YES];
        [self middleImageView].hidden=NO;
        
        [self middleImageView].userInteractionEnabled=YES;
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        [[self middleImageView] addGestureRecognizer:labelTapGestureRecognizer];
        imgF = CGRectMake(GetCellItemX(self.isRight), height, rw, MidImageHeight);
        [self.middleImageView setFrame:imgF];
        height = height + MidImageHeight + 10 + Spaceheight;
    }else{
        height = height + 10;
    }

    
#pragma mark 标题+内容
    NSString *text = zcLibConvertToString([model getModelDisplayText]);
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (self.isRight) {
            if (text1 != nil && text1.length > 0) {
                _lblTextMsg.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:_lblTextMsg textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
            }else{
                _lblTextMsg.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
        }else{
            if (text1 != nil && text1.length > 0) {
                 _lblTextMsg.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:_lblTextMsg textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                _lblTextMsg.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
           
        }
    }];
    
    
    CGSize size = [self.emojiLabel preferredSizeWithMaxWidth:self.maxWidth];
    if (zcLibIs_null(model.richModel.richmoreurl) && zcLibIs_null(model.richModel.richpricurl)  && [ZCChatBaseCell getStatusHeight:model] == 0) {
        rw = size.width;
    }
    
    // 如果显示图片，文本最多显示3行
    if(model.richModel.msgType>0 && !zcLibIs_null(model.richModel.richpricurl)){
        // 有标题的需要显示4行，不带标题最多显示3行
        if (zcLibConvertToString(model.richModel.question).length > 0) {
            if (size.height > 110) {
                size.height = 110;
            }
        }else{
            if(size.height>70){
                size.height = 70;
            }
        }
    }
    
    msgF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
    [[self emojiLabel] setFrame:msgF];

    height = height + size.height +10 + Spaceheight;
    
#pragma mark -- 查看更多
    //设置线条
    if (!zcLibIs_null(model.richModel.richmoreurl)) {
        // 设置最大宽度
        rw = self.maxWidth;
        // 清理内部控件
        [[self lookMoreLabel].subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // 添加线条
        _lineView  = [[UIView alloc]init];
        lineF = CGRectMake(GetCellItemX(self.isRight), height, rw, 1);
        [_lineView setFrame:lineF];
        _lineView.backgroundColor = [ZCUITools zcgetLineRichColor];
        [self.contentView addSubview:_lineView];
        _lineView.hidden = NO;
        height = height + 10 + Spaceheight + 1;
        
        if (self.isRight) {
            [self.lookMoreLabel setTextColor:[ZCUITools zcgetRightChatTextColor]];
            [self.lookMoreLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            [self.lookMoreLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
            [self.lookMoreLabel setTextColor:[ZCUITools zcgetLeftChatTextColor]];
        }
        self.lookMoreLabel.hidden = NO;
        NSString *linkText = ZCSTLocalString(@"查看详情>>");
        
        if([model.richModel.richmoreurl isEqual:@"zc_refresh_newdata"]){
            linkText = ZCSTLocalString(@"换一组");
            UIImageView *img = [[UIImageView alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_refreshbar_new"] ];

            [img setFrame:CGRectMake(self.maxWidth/2 + ZCNumber(30), 3.5, 13, 13)];
            [[self lookMoreLabel] addSubview:img];
            [[self lookMoreLabel] setTextAlignment:NSTextAlignmentCenter];
        }else{
            [[self lookMoreLabel] setTextAlignment:NSTextAlignmentRight];
        }
        self.lookMoreLabel.text = linkText;
        // 一定要在设置text文本之后设置
        [[self lookMoreLabel] addLinkToURL:[NSURL URLWithString:model.richModel.richmoreurl] withRange:NSMakeRange(0, linkText.length)];
        CGSize size = [[self lookMoreLabel]preferredSizeWithMaxWidth:self.maxWidth];
        moreF = CGRectMake(GetCellItemX(self.isRight), height, self.maxWidth, size.height);

        [[self lookMoreLabel] setFrame:moreF];
        
        height = height + size.height + 5 + Spaceheight;
    }
    
    CGFloat msgX = 0;
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx=self.viewWidth-rw-30 -50;
        msgX = rx;
        if (!zcLibIs_null(model.richModel.richpricurl)) {
           [self.ivBgView setFrame:CGRectMake(rx-8, bgY, rw+28, height + 10)];
        }else{
             [self.ivBgView setFrame:CGRectMake(rx-8, bgY, rw+28, height)];
        }
    }else{
        msgX = 78;
        if (!zcLibIs_null(model.richModel.richpricurl)) {
            [self.ivBgView setFrame:CGRectMake(58, bgY, rw+33, height +10)];
        }else{
            [self.ivBgView setFrame:CGRectMake(58, bgY, rw+33, height)];
        }
        
    }
    
    imgF.origin.y = imgF.origin.y + bgY;
    msgF.origin.y = msgF.origin.y + bgY;
    lineF.origin.y = lineF.origin.y + bgY;
    moreF.origin.y = moreF.origin.y + bgY;
    
    
    msgF.origin.x = msgX;
    imgF.origin.x = msgX;
    lineF.origin.x = msgX;
    
    if ([model.richModel.richmoreurl isEqual:@"zc_refresh_newdata"]) {
        moreF.origin.x = msgX - ZCNumber(13);
    }else{
      moreF.origin.x = msgX;
    }
    
    self.middleImageView.frame = imgF;
     [[self emojiLabel] setFrame:msgF];
    _lineView.frame = lineF;
    self.lookMoreLabel.frame = moreF;
    
    CGFloat sh = [self setSendStatus:self.ivBgView.frame];
    
    [self isAddBottomBgView:self.ivBgView.frame];
    
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height+bgY + sh + 10)];
    return height+bgY + 10 + sh;
}

#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    NSString *textStr = label.text;

    if (label.text) {
        if(url.absoluteString && [url.absoluteString hasPrefix:@"sobot:"]){
            int index = [[url.absoluteString stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.richModel.suggestionArr.count>=index){
                textStr = [self.tempModel.richModel.suggestionArr objectAtIndex:index-1][@"question"];
            }
        }
        
    }
    
    
    [self doClickURL:url.absoluteString text:textStr];
}

// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}


// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        // 用户引导说辞的分类的点击事件
        if([url hasPrefix:@"sobot:"]){
            int index = [[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            
            if(index > 0 && self.tempModel.richModel.suggestionArr.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
                }
                return;
            }
            
            if(index > 0 && self.tempModel.richModel.multiModel.interfaceRetList.count>=index){
                
                // 单独处理对象
                NSDictionary * dict = @{@"requestText": self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],
                                        @"question":[self getQuestion:self.tempModel.richModel.multiModel.interfaceRetList[index-1]],
                                        @"questionFlag":@"2",
                                        @"title":self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],
                                        @"ishotguide":@"0"
                                        };
                if ([self getZCLibConfig].isArtificial) {
                    dict = @{@"title":self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],@"ishotguide":@"0"};
                }
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemGuide obj: dict];
                }
            }
            
            
        }else if ([url hasPrefix:@"robot:"]){
            // 处理 机器人回复的 技能组点选事件
            int index = [[url stringByReplacingOccurrencesOfString:@"robot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.richModel.groupArr.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeGroupItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
                }
            }
        }else if([url hasPrefix:@"zc_refresh_newdata"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup obj:url];
            }
        }else{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:htmlText type:ZCChatCellClickTypeOpenURL obj:url];
            }
        }
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){
        if(buttonIndex==1){
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
        }
    } else if(alertView.tag==2){
        if(buttonIndex == 1){
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeReSend obj:nil];
//                [_delegate itemOnClick:_tempModel clickType:SobotCellClickReSend];
            }
        }
    }else if(alertView.tag==3){
        if(buttonIndex==1){
            // 打电话
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
            [self openQQ:callURL];
            callURL=@"";
        }
    }
}

-(BOOL)openQQ:(NSString *)qq{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",qq]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://wpa.qq.com/msgrd?v=3&uin=%@&site=qq&menu=yes",qq]]];
        return YES;
    }
}


// 点击查看大图
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UIImageView *_picView=(UIImageView*)recognizer.view;
    
    CALayer *calayer = _picView.layer.mask;
    [_picView.layer.mask removeFromSuperlayer];
    __weak ZCRichTextChatCell *weakSelf = self;
    ZCUIXHImageViewer *xh=[[ZCUIXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    } didDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
        selectedView.layer.mask = calayer;
        [selectedView setNeedsDisplay];
        
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
            [weakSelf.delegate cellItemClick:weakSelf.tempModel type:ZCChatCellClickTypeTouchImageNO obj:self];
//                        [self.delegate touchLagerImageView:xh with:NO];
        }
    } didChangeToImageViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    }];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:_picView];
    
    xh.delegate = self;
    xh.disableTouchDismiss = NO;
    _imageViewer = xh;

    [xh showWithImageViews:photos selectedView:_picView];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
//        [self.delegate touchLagerImageView:xh with:YES];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES obj:xh];
    }
    
    // 添加长按手势，保存图片
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [xh addGestureRecognizer:longPress];
    
}

#pragma mark -- 保存图片到相册
- (void)longPressAction:(UILongPressGestureRecognizer*)longPress{
//    NSLog(@"长按保存");
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    NSString *str = [[ZCToolsCore getToolsCore] coderURLStrDetectorWith:_middleImageView.image];
    if (str) {
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"保存图片"),@"识别二维码", nil];
        mysheet.tag = 100;
        _coderURLStr = str;
        [mysheet show];
    }else{
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"保存图片"), nil];
        [mysheet show];
    }
    
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(_middleImageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
    else if (buttonIndex == 2){
        [_imageViewer dismissWithAnimate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:_coderURLStr];
            }
        });
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil;
    if (error != NULL) {
//        msg = @"保存失败";
    }else{
        msg = ZCSTLocalString(@"已保存到系统相册");
        [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:_middleImageView position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
    }
    
}


-(void)resetCellView{
    [super resetCellView];
    
    _lblTextMsg.text = @"";
//    _sugguestLabel = nil;
    [_middleImageView setHidden:YES];
    _lineView.hidden = YES;
    [_lookMoreLabel setHidden:YES];
    
}



+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    CGFloat cellheith = [super getCellHeight:model time:showTime viewWith:viewWidth];
    CGFloat maxWidth = viewWidth - 160;
    
    static ZCMLEmojiLabel *tempLabel = nil;
    if (!tempLabel) {
        tempLabel = [ZCMLEmojiLabel new];
        tempLabel.numberOfLines = 0;
        tempLabel.font = [ZCUITools zcgetKitChatFont];
        tempLabel.backgroundColor = [UIColor clearColor];
        tempLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        tempLabel.textColor = [UIColor whiteColor];
        tempLabel.isNeedAtAndPoundSign = YES;
        tempLabel.disableEmoji = NO;
        tempLabel.lineSpacing = 3.0f;
        tempLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        //        tempLabel.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }

    tempLabel.font = [ZCUITools zcgetKitChatFont];
    
    [ZCHtmlCore filterHtml:[model getModelDisplayText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (text1 != nil && text1.length > 0) {
            tempLabel.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:tempLabel textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }else{
            tempLabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }
    }];
    
    
    cellheith = cellheith + 12;
    
    // 文本高度
    CGSize msgSize = [tempLabel preferredSizeWithMaxWidth:maxWidth];
    
    // 如果图片不为空 先放置图片
    if (model.richModel.msgType >0 && !zcLibIs_null(model.richModel.richpricurl)) {
        
        cellheith = cellheith + MidImageHeight + 10 + Spaceheight;
        
        // 如果显示图片，文本最多显示3行
        if(!zcLibIs_null(model.richModel.richpricurl)){
            // 有标题的需要显示4行，不带标题最多显示3行
            if (zcLibConvertToString(model.richModel.question).length > 0) {
                if (msgSize.height > 110) {
                    msgSize.height = 110;
                }
            }else{
                if(msgSize.height>70){
                    msgSize.height = 70;
                }
            }
        }
    }
    
    cellheith = cellheith + msgSize.height + 10 + Spaceheight;
    
    // 多轮会话的富文本，消息解析错误，需要转换一次
    if(model.richModel.msgType == 15 && model.richModel.multiModel.msgType == 3){
        NSMutableDictionary * detailDict = model.richModel.multiModel.interfaceRetList.firstObject; // 多个
        model.richModel.richpricurl = zcLibConvertToString(detailDict[@"thumbnail"]);
        model.richModel.richmoreurl = zcLibConvertToString(detailDict[@"anchor"]);
    }
    
    
    // 阅读全文
    if(!zcLibIs_null(model.richModel.richmoreurl)){

        // 线条的高度
        cellheith = cellheith + 5 + Spaceheight + 1;
        
        tempLabel.font = [ZCUITools zcgetKitChatFont];
        tempLabel.text = ZCSTLocalString(@"查看详情>>");
        CGSize sugguestSize = [tempLabel preferredSizeWithMaxWidth:maxWidth];
        cellheith = cellheith + sugguestSize.height +10 + Spaceheight;
    }
    
    cellheith=cellheith + 10;
    
    //////////////////////////////////////
    // 可能添加40
    cellheith = cellheith +  [ZCChatBaseCell getStatusHeight:model];;
    //////////////////////////////////////
    

    return cellheith;
}



-(NSString *)getQuestion:(NSDictionary *)model{
    if(model){
        NSMutableDictionary *recDict = [NSMutableDictionary dictionaryWithDictionary:model];
        [recDict removeObjectForKey:@"title"];
        return [ZCLocalStore DataTOjsonString:recDict];
    }
    return @"";
}

-(ZCLibConfig *) getZCLibConfig{
//    return [ZCIMChat getZCIMChat].config;
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

@end
