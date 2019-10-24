//
//  ZCChatBaseCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCChatBaseCell.h"
#import "ZCLibCommon.h"
#import "ZCUITools.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIXHImageViewer.h"
#import "ZCIMChat.h"
#import "ZCStoreConfiguration.h"
#import "ZCLibClient.h"
#import "ZCPlatformTools.h"
#import "ZCUIColorsDefine.h"
@interface ZCChatBaseCell(){
   
    
    UIView * topline;
    
    UIView  * leftLine;
    
    UIView  * midLine;
    
    UIView  * rightLine;
}

@end

@implementation ZCChatBaseCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _lblTime=[[UILabel alloc] init];
        [_lblTime setTextAlignment:NSTextAlignmentCenter];
        [_lblTime setFont:[ZCUITools zcgetListKitTimeFont]];
        [_lblTime setTextColor:[ZCUITools zcgetTimeTextColor]];
        [_lblTime setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblTime];
        _lblTime.hidden=YES;
        
        
        _lblNickName =[[UILabel alloc] init];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [_lblNickName setTextAlignment:NSTextAlignmentLeft];
        [_lblNickName setFont:[ZCUITools zcgetListKitDetailFont]];
        [_lblNickName setTextColor:[ZCUITools zcgetServiceNameTextColor]];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblNickName];
        _lblNickName.hidden=YES;
        
        _ivHeader = [[ZCUIImageView alloc] init];
        [_ivHeader setContentMode:UIViewContentModeScaleAspectFit];
        [_ivHeader.layer setMasksToBounds:YES];
        [_ivHeader setBackgroundColor:[UIColor clearColor]];
        _ivHeader.layer.cornerRadius=4.0f;
        _ivHeader.layer.masksToBounds=YES;
        _ivHeader.layer.borderWidth = 0.5f;
        _ivHeader.layer.borderColor = [ZCUITools zcgetBackgroundColor].CGColor;
        [self.contentView addSubview:_ivHeader];
        

        _ivBgView = [[UIImageView alloc] init];
        [_ivBgView setContentMode:UIViewContentModeScaleAspectFit];
        [_ivBgView.layer setMasksToBounds:YES];
        [_ivBgView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_ivBgView];
        
        
        _btnReSend =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnReSend setBackgroundColor:[UIColor clearColor]];
        _btnReSend.layer.cornerRadius=3;
        _btnReSend.layer.masksToBounds=YES;
        [self.contentView addSubview:_btnReSend];
        _btnReSend.hidden=YES;
        
        // 2.7.4新增
        _leaveIcon = [[ZCUIImageView alloc] init];
        [_leaveIcon setContentMode:UIViewContentModeScaleAspectFit];
        [_leaveIcon.layer setMasksToBounds:YES];
        [_leaveIcon setBackgroundColor:[UIColor clearColor]];
        _leaveIcon.layer.cornerRadius=10.0f;
        _leaveIcon.layer.masksToBounds=YES;
//        _leaveIcon.layer.borderWidth = 0.5f;
        _leaveIcon.layer.borderColor = [ZCUITools zcgetBackgroundColor].CGColor;
        [self.contentView addSubview:_leaveIcon];
        _leaveIcon.hidden = YES;
        
        // 2.6.5新增
        _bottomBgView = [[UIView alloc]init];
        [_bottomBgView.layer setMasksToBounds:YES];
        [_bottomBgView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_bottomBgView];
        
        _btnTurnUser =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnTurnUser setBackgroundColor:[UIColor clearColor]];
        [_btnTurnUser setTitle:@"转人工" forState:UIControlStateNormal];
        _btnTurnUser.tag = ZCChatCellClickTypeConnectUser;
//        [_btnTurnUser setTitleColor:[ZCUITools zcgetTurnServerBtnColor] forState:UIControlStateNormal];
//        _btnTurnUser.layer.borderColor = [ZCUITools zcgetTurnServerBtnColor].CGColor;
//        _btnTurnUser.layer.borderWidth = 0.75f;
//        _btnTurnUser.layer.cornerRadius = 3.0f;
//        _btnTurnUser.layer.masksToBounds = YES;
        [_btnTurnUser.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [_btnTurnUser addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBgView addSubview:_btnTurnUser];
        _btnTurnUser.hidden=YES;
        
        
        _btnStepOn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnStepOn setBackgroundColor:[UIColor clearColor]];
        _btnStepOn.layer.cornerRadius=3;
        _btnStepOn.layer.masksToBounds=YES;

        [_btnStepOn setTitle:@"无用" forState:UIControlStateNormal];
        _btnStepOn.tag = ZCChatCellClickTypeStepOn;
        [_btnStepOn.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [_btnStepOn setContentMode:UIViewContentModeRight];
        [_btnStepOn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_nonsupport_icon"] forState:UIControlStateNormal];
        [_btnStepOn addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBgView addSubview:_btnStepOn];
        _btnStepOn.hidden=YES;
        
        _btnTheTop =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnTheTop setBackgroundColor:[UIColor clearColor]];
        [_btnTheTop setContentMode:UIViewContentModeRight];
        [_btnTheTop.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        _btnTheTop.layer.cornerRadius=3;
        _btnTheTop.layer.masksToBounds=YES;
        [_btnTheTop setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_zan_icon"] forState:UIControlStateNormal];
        [_btnTheTop setTitle:@"有用" forState:UIControlStateNormal];
        _btnTheTop.tag = ZCChatCellClickTypeTheTop;
        [_btnTheTop addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBgView addSubview:_btnTheTop];
        _btnTheTop.hidden=YES;
        
        // 2.6.5改版 不在显示 当前控件 使用tost 显示
        _lblRobotCommentResult =[[UILabel alloc] init];
        [_lblRobotCommentResult setBackgroundColor:[UIColor clearColor]];
        [_lblRobotCommentResult setTextAlignment:NSTextAlignmentLeft];
        [_lblRobotCommentResult setFont:[ZCUITools zcgetListKitDetailFont]];
        [_lblRobotCommentResult setTextColor:[ZCUITools zcgetTimeTextColor]];
        [_lblRobotCommentResult setBackgroundColor:[UIColor clearColor]];
//        [self.contentView addSubview:_lblRobotCommentResult];
        _lblRobotCommentResult.hidden=YES;
        
        
        
        _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.hidden=YES;
        [_btnReSend addSubview:_activityView];
        
        
        _ivLayerView = [[UIImageView alloc] init];
        
        self.userInteractionEnabled=YES;
    }
    return self;
}
-(ZCLibConfig *)getCurConfig{
//    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
    return [ZCIMChat getZCIMChat].config;
}


-(CGFloat)InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    self.maxWidth=self.viewWidth-160;
    
    CGFloat cellHeight=0;
    
    [self resetCellView];
    
    _tempModel=model;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        [_lblTime setText:showTime];
        [_lblTime setFrame:CGRectMake(0, 0, self.viewWidth, 30)];
        _lblTime.hidden=NO;
        cellHeight = 30 ;
    }
    
    cellHeight=cellHeight+10;
    
    _lblNickName.hidden=NO;
    _ivHeader.hidden = NO;
    
    UIImage *bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_left_normal"];
    
    // 0,自己，1机器人，2客服
    if(model.senderType==0){
        _isRight = YES;
        [_lblNickName setFrame:CGRectZero];

        //  nickName 用户的昵称 对应传给后台的字段为“uname”
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.nickName)]) {

            [_lblNickName setFrame:CGRectMake(10, cellHeight, self.viewWidth - 77, 16)];
        }else{
            [_lblNickName setText:@""];
            [_lblNickName setFrame:CGRectMake(10, cellHeight, self.viewWidth -77, 0)];
        }
        [_ivHeader setFrame:CGRectMake(self.viewWidth - 50, cellHeight, 40, 40)];

        _lblNickName.textAlignment = NSTextAlignmentRight;
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.nickName)]) {
            // 设置内容的Y坐标
            cellHeight=cellHeight+20;
        }


        // 用户的昵称长度为14个字后面拼接“...”
        if ([ZCLibClient getZCLibClient].libInitInfo.nickName.length >14) {
            NSString * nickSub = [[ZCLibClient getZCLibClient].libInitInfo.nickName substringToIndex:14];
            NSString * nickStr = [nickSub stringByAppendingString:@"..."];
            [_lblNickName setText:nickStr];
        }else{
            [_lblNickName setText:[NSString stringWithFormat:@"%@",[ZCLibClient getZCLibClient].libInitInfo.nickName]];
        }

        if ([ZCLibClient getZCLibClient].libInitInfo.avatarUrl.length > 0) {
            // 设置用户的头像 (这里的头像取 用户自定义的不用重服务器拉取)
            [_ivHeader loadWithURL:[NSURL URLWithString:zcUrlEncodedString([ZCLibClient getZCLibClient].libInitInfo.avatarUrl)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_useravatar_nol"] showActivityIndicatorView:NO];
        }else{
            [_ivHeader setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_useravatar_nol"]];
        }


        // 右边气泡背景图片
        bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(30, 5, 5, 15)];
        // 右边气泡绿色
        [_ivBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];

    }else{
        _isRight = NO;

        [_ivHeader setFrame:CGRectMake(10, cellHeight, 40, 40)];
        [_lblNickName setFrame:CGRectMake(67, cellHeight, self.viewWidth-77, 16)];

        // 设置内容的Y坐标
        cellHeight=cellHeight+20;

        if(model.senderType==1){

            // 机器人
            // 昵称长度为14个字后面拼接“...”
            if (model.senderName.length >14) {
                NSString * nickSub = [model.senderName substringToIndex:14];
                NSString * nickStr = [nickSub stringByAppendingString:@"..."];
                [_lblNickName setText:nickStr];
            }else{
                [_lblNickName setText:[NSString stringWithFormat:@"%@",model.senderName]];
            }
            [_ivHeader loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.senderFace)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_avatar_robot"] showActivityIndicatorView:NO];
        }else{
            // 客服
            if([@"" isEqual:zcLibConvertToString(model.senderName)]){
//                model.senderName = [ZCIMChat getZCIMChat].libConfig.companyName;
                model.senderName = [self getCurConfig].companyName;
            }
            if (model.senderName.length >14) {
                NSString * nickSub = [model.senderName substringToIndex:14];
                NSString * nickStr = [nickSub stringByAppendingString:@"..."];
                [_lblNickName setText:nickStr];
            }else{
               [_lblNickName setText:[NSString stringWithFormat:@"%@",model.senderName]];
            }
            // 设置客服的头像
            if ([@"" isEqual:zcLibConvertToString(model.senderFace)]) {
//                model.senderFace = [ZCIMChat getZCIMChat].libConfig.senderFace;
                model.senderFace =[self getCurConfig].senderFace;
            }
            [_ivHeader loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.senderFace)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_avatar_customerservice"] showActivityIndicatorView:NO];
        }

        _lblNickName.textAlignment = NSTextAlignmentLeft;
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 5, 5)];

        [_ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }
    //设置尖角
    [_ivLayerView setImage:bgImage];
    
    return cellHeight;
}

-(CGFloat)setSendStatus:(CGRect )backgroundF{
    _leaveIcon.hidden = YES;
    // 自己、设置发送状态
    if(_tempModel.senderType==0){
        if(_tempModel.sendStatus==0){
            self.btnReSend.hidden=YES;
        }else if(_tempModel.sendStatus==1){
            if(_tempModel.richModel.msgType == 1){
                // 发送图片时，不显示发送的动画，由发送进度代替
                [self.btnReSend setHidden:YES];
                return 0;
            }
            [self.btnReSend setHidden:NO];
            [self.btnReSend setBackgroundColor:[UIColor clearColor]];
            [self.btnReSend setImage:nil forState:UIControlStateNormal];
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x-34, backgroundF.origin.y+8, 24, 24)];
            
            self.activityView.hidden=NO;
            _activityView.center=CGPointMake(12, 12);
            [_activityView startAnimating];
        }else if(_tempModel.sendStatus==2){
            [self.btnReSend setHidden:NO];
            [self.btnReSend setBackgroundColor:[UIColor clearColor]];
            [self.btnReSend setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_send_fail"] forState:UIControlStateNormal];
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x-34, backgroundF.origin.y+8, 20, 20)];
            [self.btnReSend addTarget:self action:@selector(clickReSend:) forControlEvents:UIControlEventTouchUpInside];
            
            _activityView.hidden=YES;
            [_activityView stopAnimating];
        }
        
        // 是否是用户发送的 留言转离线消息
        if (_tempModel.leaveMsgFlag == 1) {
            _leaveIcon.hidden = NO;
            [self.leaveIcon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_msgLeavepic"]];
            [self.leaveIcon setFrame:CGRectMake(backgroundF.origin.x-34, backgroundF.origin.y+8, 24, 24)];
        }
    }else{
        // 设置未读状态
        if(_tempModel.isRead){
            [self.btnReSend setHidden:NO];
            [self.btnReSend setImage:nil forState:UIControlStateNormal];
            
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x+backgroundF.size.width+10, backgroundF.origin.y+10, 6, 6)];
        }
    }
    
    CGFloat showheight = 0;
    
    // 机器人回复，判断是否显示“顶、踩、转人工”
    if(_tempModel.senderType == 1){
        if([self getCurConfig].isArtificial){
            self.tempModel.showTurnUser = NO;
        }
        showheight = [ZCChatBaseCell getStatusHeight:self.tempModel];
    }
    return showheight;
}

-(BOOL)isAddBottomBgView:(CGRect )backgroundF{
    self.btnTurnUser.hidden = YES;
    self.btnStepOn.hidden = YES;
    self.btnTheTop.hidden = YES;
    self.bottomBgView.hidden = YES;
    if (self.isRight) {
       [self.bottomBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
    }else{
        [self.bottomBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }
    
    
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    
    CGFloat showheight = 0;
    
    // 机器人回复，判断是否显示“顶、踩、转人工”
    if(_tempModel.senderType == 1){
        if([self getCurConfig].isArtificial){
            self.tempModel.showTurnUser = NO;
        }
        
        int temptype = [self getCurConfig].type ;
        
        if ([ZCLibClient getZCLibClient].libInitInfo.serviceMode >0 ) {
            temptype = [ZCLibClient getZCLibClient].libInitInfo.serviceMode;
        }
        
        NSString * easyui = @"0";
        if (self.tempModel.commentType == 4) {
            easyui = @"1";
        }
        
        
        if(_tempModel.showTurnUser && ![self getCurConfig].isArtificial &&  temptype != 1){
            
     
            NSDictionary * dict1 = @{@"title":@"转人工",
                                     @"selImg":@"zcicon_turnserver_nol",
                                     @"nolImg":@"zcicon_turnserver_nol",
                                     @"status":@"0",
                                     @"isEnabled":@"1",
                                     @"easyui":easyui
                                     };
            [arr addObject:dict1];
            self.btnTurnUser.hidden = NO;
            self.bottomBgView.hidden = NO;
            showheight = 40.0f;
        }
        
        if(self.tempModel.commentType > 0){
            self.btnTheTop.hidden = NO;
            self.btnStepOn.hidden = NO;
            self.bottomBgView.hidden = NO;
            
            self.btnTheTop.enabled = YES;
            self.btnStepOn.enabled = YES;
            
            if(self.tempModel.commentType == 1){
               
                NSDictionary * dict2 = @{@"title":@"有用",
                                         @"selImg":@"zcicon_useful_sel",
                                         @"nolImg":@"zcicon_useful_nol",
                                         @"status":@"0",
                                         @"isEnabled":@"1",
                                         @"easyui":easyui
                                         };
                
                NSDictionary * dict3 = @{@"title":@"无用",
                                         @"selImg":@"zcicon_useless_sel",
                                         @"nolImg":@"zcicon_useless_nol",
                                         @"status":@"0",
                                         @"isEnabled":@"1",
                                         @"easyui":easyui
                                         };
                
                [arr addObject:dict2];
                [arr addObject:dict3];
            }else{
               // 已赞
                if(self.tempModel.commentType == 2){
                    NSDictionary * dict2 = @{@"title":@"有用",
                                             @"selImg":@"zcicon_useful_sel",
                                             @"nolImg":@"zcicon_useful_nol",
                                             @"status":@"1",
                                             @"isEnabled":@"0",
                                             @"easyui":easyui
                                             };
                    
                    NSDictionary * dict3 = @{@"title":@"无用",
                                             @"selImg":@"zcicon_useless_sel",
                                             @"nolImg":@"zcicon_useless_nol",
                                             @"status":@"0",
                                             @"isEnabled":@"0",
                                             @"easyui":@"1"
                                             };
                    
                    [arr addObject:dict2];
                    [arr addObject:dict3];
                    self.btnTheTop.enabled = NO;
                    self.btnStepOn.enabled = NO;
                }else if(self.tempModel.commentType == 3){// 已踩
                    NSDictionary * dict2 = @{@"title":@"有用",
                                             @"selImg":@"zcicon_useful_sel",
                                             @"nolImg":@"zcicon_useful_nol",
                                             @"status":@"0",
                                             @"isEnabled":@"0",
                                             @"easyui":@"1"
                                             };
                    
                    NSDictionary * dict3 = @{@"title":@"无用",
                                             @"selImg":@"zcicon_useless_sel",
                                             @"nolImg":@"zcicon_useless_nol",
                                             @"status":@"1",
                                             @"isEnabled":@"0",
                                             @"easyui":@"0"
                                             };
                    self.btnTheTop.enabled = NO;
                    self.btnStepOn.enabled = NO;
                    [arr addObject:dict2];
                    [arr addObject:dict3];
                }else if (self.tempModel.commentType == 4){
                    NSDictionary * dict2 = @{@"title":@"有用",
                                             @"selImg":@"zcicon_useful_sel",
                                             @"nolImg":@"zcicon_useful_nol",
                                             @"status":@"0",
                                             @"isEnabled":@"0",
                                             @"easyui":easyui
                                             };
                    
                    NSDictionary * dict3 = @{@"title":@"无用",
                                             @"selImg":@"zcicon_useless_sel",
                                             @"nolImg":@"zcicon_useless_nol",
                                             @"status":@"0",
                                             @"isEnabled":@"0",
                                             @"easyui":easyui
                                             };
                    self.btnTheTop.enabled = NO;
                    self.btnStepOn.enabled = NO;
                    [arr addObject:dict2];
                    [arr addObject:dict3];
                }
            }
            
            showheight = 40.0f;
        }
        
        // 要显示顶踩 和转人工
        if (showheight >0) {
            
    
            self.bottomBgView.frame = CGRectMake(0, 0, self.maxWidth, 40);
            
            CGRect BF = self.bottomBgView.frame;
            BF.origin.x = self.ivBgView.frame.origin.x + 8;
            BF.origin.y = CGRectGetMaxY(self.ivBgView.frame);
            BF.size.width = CGRectGetWidth(self.ivBgView.frame) -8;
            self.bottomBgView.frame = BF;
            
            CGFloat W = CGRectGetWidth(self.bottomBgView.frame);
            
            
            if (leftLine != nil) {
                [leftLine removeFromSuperview];
                leftLine = nil;
            }
            if (midLine != nil) {
                [midLine removeFromSuperview];
                midLine = nil;
            }
            if (rightLine != nil) {
                [rightLine removeFromSuperview];
                rightLine = nil;
            }
            
            topline = [[UIView alloc]initWithFrame:CGRectMake(0, 0, W, 0.5)];
            topline.backgroundColor = UIColorFromRGB(bottomBgViewLineColor);
            [self.bottomBgView addSubview:topline];
            
            leftLine = [[UIView alloc]initWithFrame:CGRectZero];
            leftLine.backgroundColor = UIColorFromRGB(bottomBgViewLineColor);
            [self.bottomBgView addSubview:leftLine];

            midLine = [[UIView alloc]initWithFrame:CGRectZero];
            midLine.backgroundColor = UIColorFromRGB(bottomBgViewLineColor);
            [self.bottomBgView addSubview:midLine];

            rightLine = [[UIView alloc]initWithFrame:CGRectZero];
            rightLine.backgroundColor = UIColorFromRGB(bottomBgViewLineColor);
            [self.bottomBgView addSubview:rightLine];
            
            
            
            // 布局 bottomBGView
            if (arr.count == 1) {
                // 只有 转人工
                self.btnTurnUser.frame = CGRectMake( W/2 - (W/3)/2, 12, W/3 , 18);
                NSDictionary * dict = arr[0];
                [self.btnTurnUser setTitleColor:[ZCUITools zcgetTopBtnNolColor] forState:UIControlStateNormal];
                [self.btnTurnUser setImage:[ZCUITools zcuiGetBundleImage:dict[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnTurnUser setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateHighlighted];
                if ([dict[@"easyui"] intValue] ==1) {
                    [self.btnTurnUser setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                
            }else if (arr.count == 2){
                // 只有顶踩
                self.btnTheTop.frame = CGRectMake(W/4 - (W/3)/2 , 12, W/3-1, 18);
                NSDictionary * dict = arr[0];

                midLine.frame = CGRectMake(W/2 - 1, 12, 1, 18);
                [self.btnTheTop setTitleColor:[ZCUITools zcgetTopBtnNolColor] forState:UIControlStateNormal];
                [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateHighlighted];
                if ([dict[@"easyui"] intValue] ==1) {
                    [self.btnTheTop setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                // 选中
                if ([dict[@"status"] intValue] == 1) {
                    [self.btnTheTop setTitleColor:[ZCUITools zcgetTopBtnSelColor] forState:UIControlStateNormal];
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateNormal];
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateHighlighted];
                }
                
                
                
                self.btnStepOn.frame = CGRectMake(W/4*3 - (W/3)/2 , 12, W/3-1, 18);
                NSDictionary * dict1 = arr[1];
                [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnNolColor] forState:UIControlStateNormal];
                [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateHighlighted];
                
                if ([dict1[@"easyui"] intValue] ==1) {
                    [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                // 选中
                if ([dict1[@"status"] intValue] == 1) {
                    [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnSelColor] forState:UIControlStateNormal];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateNormal];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateHighlighted];
                }
                

                
            }else if (arr.count == 3){
                // 三者都有
                self.btnTurnUser.frame = CGRectMake( 0, 12, W/3-1 , 18);
                NSDictionary * dict = arr[0];
                [self.btnTurnUser setTitleColor:[ZCUITools zcgetTopBtnNolColor] forState:UIControlStateNormal];
                [self.btnTurnUser setImage:[ZCUITools zcuiGetBundleImage:dict[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnTurnUser setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateHighlighted];
                
                if ([dict[@"easyui"] intValue] ==1) {
                    [self.btnTurnUser setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                leftLine.frame = CGRectMake(W/3, 12, 1, 18);
                self.btnTheTop.frame = CGRectMake(W/2 - (W/3)/2 , 12, W/3-1, 18);
                NSDictionary * dict1 = arr[1];

                [self.btnTheTop setTitleColor:[ZCUITools zcgetTopBtnNolColor] forState:UIControlStateNormal];
                [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateHighlighted];
                
                if ([dict1[@"easyui"] intValue] ==1) {
                    [self.btnTheTop setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                // 选中
                if ([dict1[@"status"] intValue] == 1) {
                    [self.btnTheTop setTitleColor:[ZCUITools zcgetTopBtnSelColor] forState:UIControlStateNormal];
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateNormal];
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateHighlighted];
                }
                
                
                rightLine.frame = CGRectMake(W/3*2 - 1, 12, 1, 18);
                self.btnStepOn.frame = CGRectMake(W - (W/3-1), 12, W/3-1, 18);
                NSDictionary * dict2 = arr[2];
                [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnNolColor] forState:UIControlStateNormal];
                [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"selImg"]] forState:UIControlStateHighlighted];
                
                if ([dict2[@"easyui"] intValue] ==1) {
                    [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                // 选中
                if ([dict2[@"status"] intValue] == 1) {
                    [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnSelColor] forState:UIControlStateNormal];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"selImg"]] forState:UIControlStateNormal];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"selImg"]] forState:UIControlStateHighlighted];
                }
                
            }
        
        }
    }
          
    if(arr.count >0){
        return YES;
    }else{
        return NO;
    }
       
}

-(void)headerClick:(UITapGestureRecognizer *)gesture{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeHeader obj:nil];
    }
}

-(void)connectWithStepOnWithTheTop:(UIButton *) btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:btn.tag obj:nil];
    }

}


-(CGFloat) getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime{
    return 0;
}


// 重新发送
-(IBAction)clickReSend:(UIButton *)sender{
    //初始化AlertView
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:ZCSTLocalString(@"重新发送")
                                                   delegate:self
                                          cancelButtonTitle:ZCSTLocalString(@"取消")
                                          otherButtonTitles:ZCSTLocalString(@"发送"),nil];
    alert.tag=2;
    [alert show];
    
}


// 提示层回调
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){
        if(buttonIndex==1){
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_callURL]];
        }
    } else if(alertView.tag==2){
        if(buttonIndex == 1){
            if(_delegate && [_delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [_delegate cellItemClick:_tempModel type:ZCChatCellClickTypeReSend obj:nil];
            }
        }
        
    }
}


-(void)resetCellView{
    _lblTime.hidden=YES;
    [_lblTime setText:@""];
    
    _activityView.hidden=YES;
    
    _btnReSend.hidden=YES;
    
    [_activityView stopAnimating];
    [_activityView setHidden:YES];
    
    _ivBgView.hidden=NO;
    [_ivBgView.layer.mask removeFromSuperlayer];
  
    _ivHeader.image = nil;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    CGFloat cellheight = 0;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        cellheight = 30;
    }
    cellheight=cellheight+10;
    
    // 0,自己，1机器人，2客服
    if(model.senderType!=0){
        cellheight = cellheight + 20;
    }
    
    if (model.senderType ==0 ) {
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.nickName)]) {
            // 设置内容的Y坐标
            cellheight=cellheight+20;
        }
    }
    
    cellheight = cellheight + [self getStatusHeight:model];
    
    return cellheight;

}


+(CGFloat )getStatusHeight:(ZCLibMessage *) messageModel{
    CGFloat showheight = 0;
    // 机器人回复，判断是否显示“顶、踩、转人工”
    if(messageModel.senderType == 1){
        int temptype = [ZCIMChat getZCIMChat].config.type ;
        
        if ([ZCLibClient getZCLibClient].libInitInfo.serviceMode > 0 ) {
            temptype = [ZCLibClient getZCLibClient].libInitInfo.serviceMode;
        }
        
        // 显示转人工按钮，并且当前不是仅人工模式和人工接待状态
        if(messageModel.showTurnUser && ![ZCIMChat getZCIMChat].config.isArtificial &&  temptype != 1){
            showheight = 40.0f;
        }
        
        if(messageModel.commentType > 0){
            showheight = 40.0f;
        }
    }
    return showheight;
}


@end
