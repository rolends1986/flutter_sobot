//
//  ZCImageChatCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/16.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCImageChatCell.h"
#import "ZCUIXHImageViewer.h"
#import "ZCLibCommon.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIToastTools.h"
#import "ZCActionSheet.h"
#import "ZCPieChartView.h"
#import "ZCVideoPlayer.h"
#import "ZCToolsCore.h"

@interface ZCImageChatCell()<ZCUIXHImageViewerDelegate,ZCActionSheetDelegate>{
    ZCPieChartView *_pieChartView;
    
    UIButton *_playButton;
    NSString *_coderURLStr;
    ZCUIXHImageViewer *_imageViewer;
}

@end

@implementation ZCImageChatCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _ivSingleImage = [[ZCUIImageView alloc] init];
        [_ivSingleImage setContentMode:UIViewContentModeScaleAspectFit];
        [_ivSingleImage.layer setMasksToBounds:YES];
        [_ivSingleImage setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_ivSingleImage];
        _ivSingleImage.hidden=YES;
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_video_play"] forState:0];
        [_playButton setFrame:CGRectMake(0, 0, 30, 30)];
        [_playButton setBackgroundColor:UIColor.clearColor];
        [_playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_playButton];
        _playButton.hidden = YES;
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        _ivSingleImage.userInteractionEnabled=YES;
        [_ivSingleImage addGestureRecognizer:tapGesturer];

    }
    return self;
}


-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat height = [super InitDataToView:model time:showTime];
    _ivSingleImage.hidden=NO;
    if(model.sendStatus != 1 && _pieChartView){
        [_pieChartView removeFromSuperview];
        _pieChartView = nil;
        _ivSingleImage.userInteractionEnabled = YES;// 开启交互
    }
    
    if (model.richModel.msgType == ZCMsgTypeVideo) {
        if(self.isRight){
            [_ivSingleImage setFrame:CGRectMake(self.viewWidth-100-8-50, height, 100, 160)];
        }else{
            [_ivSingleImage setFrame:CGRectMake(58, height, 100, 160)];
        }
    }else{
        if(self.isRight){
            [_ivSingleImage setFrame:CGRectMake(self.viewWidth-175-8-50, height, 175, ImageHeight)];
        }else{
            [_ivSingleImage setFrame:CGRectMake(58, height, 175, ImageHeight)];
        }
    }
    
   
    [self.ivBgView setImage:nil];
    [self.ivBgView setBackgroundColor:[UIColor clearColor]];
    
    [_ivSingleImage setContentMode:UIViewContentModeScaleAspectFill];
    // 判断图片来源，本地或网络
    if(zcLibCheckFileIsExsis(model.richModel.msg)){
        UIImage *localImage=[UIImage imageWithContentsOfFile:model.richModel.msg];
        //发送状态，1 开始发送，2发送失败，0，发送完成
        if(model.sendStatus == 1){
            [self pieChartView];
            [_pieChartView updatePercent:model.progress*100 animation:NO];
            _ivSingleImage.userInteractionEnabled = NO;
        }
        [_ivSingleImage setImage:localImage];
    }else{
        [_ivSingleImage loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.richModel.msg)] placeholer:nil showActivityIndicatorView:YES];
    }
    if(model.richModel.msgType == ZCMsgTypeVideo && _pieChartView == nil){
        
        _playButton.hidden = NO;
        _playButton.center = _ivSingleImage.center;
    }else{
        _playButton.hidden = YES;
    }
    
    
    
    
    CGFloat sh = [self setSendStatus:self.ivSingleImage.frame];
    
    // 设置尖角
    [self.ivLayerView setFrame:_ivSingleImage.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    _ivSingleImage.layer.mask = layer;
    [_ivSingleImage setNeedsDisplay];
    
    height=height + ((model.richModel.msgType == ZCMsgTypeVideo) ? 160: ImageHeight) +20  + sh;
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height)];
    return height;
}


-(void)playVideo:(UIButton *)btn{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:[NSURL URLWithString:self.tempModel.richModel.richmoreurl] Image:_ivSingleImage.image];
    [player showControlsView];
    
}

// 点击查看大图
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer{
    if(self.tempModel.richModel.msgType == ZCMsgTypeVideo){
        [self playVideo:nil];
        return;
    }
//    [ZCLogUtils logHeader:LogHeader debug:@"查看大图：%@",self.tempModel.richModel.msg];
    UIImageView *_picView = (UIImageView*)recognizer.view;
    
    CALayer *calayer = _picView.layer.mask;
    [_picView.layer.mask removeFromSuperlayer];
    
    
    __block ZCUIXHImageViewer *xh = [[ZCUIXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    } didDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
        
        selectedView.layer.mask = calayer;
        [selectedView setNeedsDisplay];
        
        // 点击大图关闭
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageNO obj:xh];
            //            [self.delegate touchLagerImageView:xh with:NO];
        }
    } didChangeToImageViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
    }];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:_picView];
    
    xh.delegate = self;
    xh.disableTouchDismiss = NO;
    _imageViewer = xh;
    [xh showWithImageViews:photos selectedView:_picView];
    
    // 放大图片
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES obj:xh];
        //            [self.delegate touchLagerImageView:xh with:NO];
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
    NSString *str = [[ZCToolsCore getToolsCore] coderURLStrDetectorWith:_ivSingleImage.image];
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
         UIImageWriteToSavedPhotosAlbum(_ivSingleImage.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
    }
    else if (buttonIndex == 2 && actionSheet.tag == 100){
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
        [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:_ivSingleImage position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
    }
    
}
#pragma mark - Getters & Setters
- (ZCPieChartView *)pieChartView{
    if (!_pieChartView) {
        _pieChartView = [[ZCPieChartView alloc]initWithFrame:_ivSingleImage.bounds];
        [_pieChartView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        [_ivSingleImage addSubview:_pieChartView];
    }
    return _pieChartView;
}


-(void)resetCellView{
    [super resetCellView];
    [_ivSingleImage setImage:nil];
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
    
    height = height + ((model.richModel.msgType == ZCMsgTypeVideo) ? 160 : ImageHeight) + 20;
    return height;
}

@end
