//
//  ZCChatView.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCChatView.h"
#import "ZCLIbGlobalDefine.h"

//#import "ZCLeaveMsgController.h"
#import "ZCUIAskTableController.h"

#import "SobotKit.h"


#import "ZCPlatformTools.h"
#import "ZCUICore.h"
#import "ZCUILoading.h"

#import "ZCUIColorsDefine.h"
#import "ZCChatBaseCell.h"
#import "ZCRichTextChatCell.h"
#import "ZCImageChatCell.h"
#import "ZCVoiceChatCell.h"
#import "ZCTipsChatCell.h"
#import "ZCGoodsCell.h"
#import "ZCHorizontalRollCell.h"
#import "ZCVerticalRollCell.h"
#import "ZCMultiItemCell.h"

#import "ZCActionSheet.h"
#import "ZCUILeaveMessageController.h"
#import "ZCDocumentLookController.h"
#import "ZCLibSkillSet.h"
#import "ZCSobotCore.h"
#import "ZCStoreConfiguration.h"
#import "ZCUIImageView.h"

#import "ZCSatisfactionCell.h"

#import "ZCPlatformTools.h"

#import "ZCMultiRichCell.h"

#import "ZCHotGuideCell.h"
#import "ZCFileCell.h"
#import "ZCLocationCell.h"
#import "ZCUIToastTools.h"
#import "ZCNoticeCell.h"
#import "ZCInfoCardCell.h"

#define cellCardCellIdentifier @"ZCInfoCardCell"
#define cellNoticeCellIdentifier @"ZCNoticeCell"
#define cellHotGuideIdentifier @"ZCHotGuideCell"


#define cellMultiRichIdentifier @"ZCMultiRichCell"
#define cellRichTextIdentifier @"ZCRichTextChatCell"
#define cellImageIdentifier @"ZCImageChatCell"
#define cellVoiceIdentifier @"ZCVoiceChatCell"
#define cellTipsIdentifier @"ZCTipsChatCell"
#define cellGoodsIndentifier @"ZCGoodsCell"
#define cellSatisfactionIndentifier @"ZCSatisfactionCell"
#define cellHorizontalRollIndentifier @"ZCHorizontalRollCell"
#define cellVerticalRollIndentifier @"ZCVerticalRollCell"
#define cellMultilItemIndentifier @"ZCMultiItemCell"
#define cellFileIndentifier @"ZCFileCell.h"
#define cellLocationIndentifier @"ZCLocationCell.h"


#import "ZCIMChat.h"
#import "ZCUIChatKeyboard.h"
#import "ZCUIKeyboard.h"
#import "ZCUICustomActionSheet.h"
#import "ZCUIWebController.h"
#import "ZCUIXHImageViewer.h"
#import "ZCLibServer.h"
#import "ZCUIVoiceTools.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCLibNetworkTools.h"

#import "ZCChatController.h"

#import "ZCTurnRobotView.h"
#import "ZCQuickEntryView.h"
#import "ZCButton.h"

#import "ZCUIImageTools.h"
#import "ZCTextGuideCell.h"
#define cellTextCellIdentifier @"ZCTextGuideCell"

#import "ZCSelLeaveView.h"
#import "ZCWsTemplateModel.h"
#import "ZCLeaveMsgVC.h"

#import "ZCToolsCore.h"

#define TableSectionHeight 44


#define MinViewWidth 320
#define MinViewHeight 540

#ifndef weakify
#if __has_feature(objc_arc)
#define weakify(self) autoreleasepool {} __attribute__((objc_ownership(weak))) __typeof__(self) weakSelf = (self)
#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)
#define strongify(self) try {} @finally {} _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wunused-variable\"") __attribute__((objc_ownership(strong))) __typeof__(self) self = weakSelf; _Pragma("clang diagnostic pop")
#endif
#endif

@interface ZCChatView()<ZCUICoreDelegate,UITableViewDelegate,UITableViewDataSource,ZCUIBackActionSheetDelegate,ZCChatCellDelegate,UIAlertViewDelegate,ZCUIVoiceDelegate,ZCActionSheetDelegate,UIAlertViewDelegate>{
    CGFloat viewWidth;
    CGFloat viewHeight;

    // 呼叫的电话号码
    NSString                    *callURL;
    // 旋转时隐藏查看大图功能
    ZCUIXHImageViewer           *xhObj;
    
    // 无网络提醒button
    UIButton                    *_newWorkStatusButton;
    
    //长连接显示情况
    UIButton                    *_socketStatusButton;
    
    CGFloat                     navHeight;
    
    BOOL                        isStartConnectSockt;
    
    // 点击了关闭按钮
    BOOL                        isClickCloseBtn;
    
    // 跑马灯label
    UILabel * titleLab;
    
    BOOL isScrollBtm;
    
    BOOL isOpenNotice;// 是否展开通告
}




@property (nonatomic,strong) ZCUIKeyboard * keyboardTools;

@property (nonatomic,weak) UIViewController * superController;

@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) UIButton *goUnReadButton;
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,assign) BOOL isNoMore;
// 通告view
@property (nonatomic,strong)  UIView           *notifitionTopView;

/***  评价页面 **/
@property (nonatomic,strong) ZCUICustomActionSheet *sheet;

/** 声音播放对象 */
@property (nonatomic,strong) ZCUIVoiceTools    *voiceTools;

/** 网络监听对象 */
@property (nonatomic,strong) ZCLibNetworkTools *netWorkTools;

/** 多机器人按钮*/
@property (nonatomic,strong) ZCButton * changeRobotBtn;

@property (nonatomic,strong) ZCQuickEntryView * quickEntryView;

@end

@implementation ZCChatView

-(instancetype)initWithFrame:(CGRect)frame WithSuperController:(UIViewController *)superController customNav:(BOOL)isCreated{
    self = [super initWithFrame:frame];
    if (self) {
        _superController = superController;
        _hideTopViewNav = !isCreated;
        self.backgroundColor = [ZCUITools zcgetBackgroundColor];
        [self setUI];
        self.userInteractionEnabled = YES;
        _voiceTools  = [[ZCUIVoiceTools alloc] init];
        _voiceTools.delegate = self;
        self.clipsToBounds=YES;
        _listTable.clipsToBounds = YES;
    }
    return self;
}

-(void)showZCChatView:(ZCKitInfo *)kitInfo{
//    [ZCUICore getUICore].chatView = self;
    __weak ZCChatView *safeSelf = self;
    [[ZCUICore getUICore] openSDKWith:[ZCLibClient getZCLibClient].libInitInfo uiInfo:kitInfo Delegate:self  blcok:^(ZCInitStatus code, NSMutableArray *arr, NSString *result) {
        if(code == ZCInitStatusLoading){
            // 开始初始化
            // 展示智齿loading
            [[ZCUILoading shareZCUILoading] showAddToSuperView:self];
        }
        if(code == ZCInitStatusLoadSuc){
            // 初始化完成

            
            // 智齿loading消失
            [[ZCUILoading shareZCUILoading] dismiss];
            [safeSelf configShowNotifion];
        }
       
    }];
}


/**
 页面改变事件

 @param status 判断事件处理关键
 @param message 事件相关联消息
 @param object  预留参数
 */
-(void)onPageStatusChanged:(ZCShowStatus)status message:(NSString *)message obj:(id)object{
     if (status == ZCShowStatusRefreshing) {
         ZCLibMessage *message = object;
         if(message.richModel.msgType != ZCMsgTypeFile){
             return;
         }
         
//         NSLog(@"-----更新下载进度%f==\n %d------ \n",message.progress,isScrollBtm);
         if(isScrollBtm){
             //  执行的代码
             NSInteger index =  [[ZCUICore getUICore].listArray indexOfObject:object];
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
             
             ZCFileCell *cell = (ZCFileCell *)[_listTable cellForRowAtIndexPath:indexPath];
             if(cell!=nil){
                 [cell setProgress:message.progress];
             }
         }
         return;
     }
    // 有新消息、消息列表改变
    if(status == ZCShowStatusAddMessage || status ==  ZCShowStatusMessageChanged || status == ZCInitStatusCompleteNoMore){
       
        if(status == ZCInitStatusCompleteNoMore){
            _isNoMore = YES;
        }
        
        [_listTable reloadData];
        if([self.refreshControl isRefreshing]){
            [self.refreshControl endRefreshing];
            isScrollBtm = true;
        }else{
            [self scrollTableToBottom];
        }
        return;
    }
    
    
    // 超过一定数量显示未读消息点击效果
    if(status == ZCShowStatusUnRead){
        [self.goUnReadButton setTitle:message forState:UIControlStateNormal];
        self.goUnReadButton.hidden = NO;
    }
    
    if (status == ZCShowStatusGoBack) {
        [self goBackIsKeep];
        return;
    }

    // 跳转到留言页面
    if (status == ZCShowStatusLeaveMsgPage) {
        
        if ([object integerValue] == 2 && [self getZCLibConfig].type == 2 && [self getZCLibConfig].msgFlag == 1) {
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];
            
            // 设置昵称
            [self setTitleName:ZCSTLocalString(@"暂无客服在线")];
            
        }else{
            
            // 是否直接退出SDK
            NSInteger isExit = [object integerValue];
            
            // 先处理是否显示 切换留言模板
            [self changeLeaveMsgType:isExit];
//            if ([self changeLeaveMsgType:isExit]){
//                [_keyboardTools hideKeyboard];
//            }else{
//                [self jumpNewPageVC:ZC_LeaveMsgPage IsExist:isExit isShowToat:NO tipMsg:@"" Dict:nil];
//            }
        }
        return;
    }
    
    if(status == ZCShowStatusChangedTitle){
        [self setTitleName:message];
    }
    
    if (status == ZCShowStatusSatisfaction) {
        [_keyboardTools hideKeyboard];
        
    }
    
    // 新会话
    if (status == ZCShowStatusReConnected) {
        // 新的会话要将上一次的数据清空全部初始化在重新拉取
        [_listTable reloadData];
//        _isHadLoadHistory = NO;
        _isNoMore = NO;
        [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];
        // 重新加载数据
        return;
    }
    
    //
    if (status == ZCShowStatusConnectingUser) {
        _keyboardTools.isConnectioning = YES;
        _keyboardTools.zc_turnButton.enabled = NO;
    }
    
    if (status == ZCShowStatusConnectFinished){
        _keyboardTools.zc_turnButton.enabled = YES;
        _keyboardTools.isConnectioning = NO;
        [[ZCUICore getUICore] dismissSkillSetView];
    }
    
    if (status == ZCShowCustomActionSheet) {
        // 回收键盘
        [_keyboardTools hideKeyboard];
//        [ZCUICore getUICore].chatView = self;
        [(ZCUICustomActionSheet*)object showInView:self];
        
    }
    
    // 设置键盘样式
    if (status == ZCSetKeyBoardStatus) {
        [_keyboardTools hideKeyboard];
        if ([@"ZCKeyboardStatusRobot" isEqualToString:message]) {
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusRobot];
        }else if ([@"ZCKeyboardStatusWaiting" isEqualToString:message]){
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusWaiting];
        }else if ([@"ZCKeyboardStatusUser" isEqualToString:message]){
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusUser];
        }else if ([@"ZCKeyboardStatusNewSession" isEqualToString:message]){
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];
        }else if (message == nil){
            [_keyboardTools setInitConfig:(ZCLibConfig *)object];
        }

    }
    
    if (status == ZCShowStatusUserStyle) {
        [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusUser];
    }
    
    if (status == ZCSetListTabelRoad) {
        [self.listTable reloadData];
    }
    // 仅人工模式 关闭技能组 直接退出SDK页面
    if (status == ZCInitStatusCloseSkillSet) {
        [[ZCUICore getUICore].listArray removeAllObjects];
        [_listTable reloadData];
        [self goBackIsKeep];
    }
    
    // 链接中。。
    if (status == ZCInitStatusConnecting) {
        if ([message intValue] == ZC_CONNECT_KICKED_OFFLINE_BY_OTHER_CLIENT) {
            if(self.superController.navigationController){
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self.window.rootViewController.view position:ZCToastPositionCenter];
            }else{
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self position:ZCToastPositionCenter];
            }
        }else{
          [self showSoketConentStatus:[message intValue]];
        }
        
    }
    
    // 智能转人工，转不成功也不提示
    if (status == ZCShowStatusMessageTurnServer) {
        [ZCUICore getUICore].isSmartTurnServer = YES;
        [[ZCUICore getUICore] turnUserService:nil object:object Msg:nil];
    }
    
    if (status == ZCTurnRobotFramChange) {
        // TODO 测试数据
        if ([self getZCLibConfig].robotSwitchFlag  == 1) {
            [self setTurnRobotBtnFram];
        }
        
        if ([self getZCLibConfig].quickEntryFlag == 1) {
            [self setQuickViewFrame];
        }
    }
    
    if (status == ZCShowTurnRobotBtn) {
        // 是否显示 多机器人按钮
        if ([self getZCLibConfig].robotSwitchFlag == 1) {
            
            if ([self getZCLibConfig].type != 2 && ![self getZCLibConfig].isArtificial && ![message isEqualToString:@"1"]) {
                _changeRobotBtn.hidden = NO;
            }else{
                _changeRobotBtn.hidden = YES;
            }
        }else{
            _changeRobotBtn.hidden = YES;
        }
    }
    
    
    if (status == ZCShowQuickEntryView) {
        if ([self getZCLibConfig].quickEntryFlag == 1) {
             NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
            [[ZCLibServer getLibServer] getLableInfoList:[self getZCLibConfig] start:^{
                
            } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
                @try{
                    if (dict) {
                        NSArray * listArr = dict[@"data"][@"list"];
                        if (listArr.count > 0) {
                            for (NSDictionary *Dic in listArr) {
                                ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:Dic];
                                [array addObject:model];
                            }
                            [self quickEntryViewWithArray:array];
                           
                            if ([self getZCLibConfig].quickEntryFlag == 1 && [message intValue] == 0) {
                                [self setFrameForListTable: [message intValue]];
                            }
                        }else{
                            if ([ZCUICore getUICore].kitInfo.cusMenuArray.count > 0 ) {
                                for (NSDictionary * Dic in [ZCUICore getUICore].kitInfo.cusMenuArray) {
                                    ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:Dic];
                                    [array addObject:model];
                                }
                                [self quickEntryViewWithArray:array];
                                if ([self getZCLibConfig].quickEntryFlag == 1 && [message intValue] == 0) {
                                    [self setFrameForListTable:[message intValue]];
                                }
                            }else{
                                [self getZCLibConfig].quickEntryFlag = 0;
                                return ;
                            }
                        }
                        
                    }
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
            } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
                
            }];
        }
        
    }
    
    if([self getZCIMConfig].isArtificial){
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChange:)]) {
            [self.delegate onPageStatusChange:YES];
        }
        self.closeButton.hidden = NO;
        if([ZCUICore getUICore].kitInfo.isShowEvaluation || [ZCUICore getUICore].kitInfo.isShowTelIcon){
            if ([ZCUICore getUICore].kitInfo.isShowClose) {
                self.moreButton.frame = CGRectMake(self.frame.size.width-44*3, NavBarHeight-44, 44, 44);
            }else{
                self.moreButton.frame = CGRectMake(self.frame.size.width-44, NavBarHeight-44, 44, 44);
            }
        }else {
            if ([ZCUICore getUICore].kitInfo.isShowClose) {
                self.moreButton.frame = CGRectMake(self.frame.size.width-44*2, NavBarHeight-44, 44, 44);
            }else{
                self.moreButton.frame = CGRectMake(self.frame.size.width-44, NavBarHeight-44, 44, 44);
            }
        }
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChange:)]) {
            [self.delegate onPageStatusChange:NO];
        }
        self.closeButton.hidden = YES;
        self.moreButton.frame = CGRectMake(self.frame.size.width-74, NavBarHeight-44, 74, 44);
    }
    
}

- (void)setQuickViewFrame{
    CGRect quickViewF = _quickEntryView.frame;
    quickViewF.origin.y =  CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame) - 41;
    _quickEntryView.frame = quickViewF;
}

-(void)setTurnRobotBtnFram{
    CGRect robotF = _changeRobotBtn.frame;
    
    CGFloat H = 20;
    if ([self getZCLibConfig].quickEntryFlag == 1) {
        H = 60;
    }
    robotF.origin.y = CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame) - 48 - H;
    _changeRobotBtn.frame = robotF;
}

-(void)jumpNewPageVC:(ZCPagesType)type IsExist:(LeaveExitType) isExist  isShowToat:(BOOL) isShow  tipMsg:(NSString *)msg  Dict:(NSDictionary*)dict Object:(id)obj{
    if (obj != nil) {
        if (type == ZC_AskTabelPage) {
            ZCUIAskTableController * askVC = [[ZCUIAskTableController alloc]init];
            askVC.dict = dict[@"data"];
            if (msg !=nil && [msg isEqualToString:@"clearskillId"]) {
                askVC.isclearskillId = YES;
            }
            askVC.isNavOpen = (self.superController.navigationController!=nil ? YES: NO);
            askVC.trunServerBlock = ^(BOOL isback) {
                if (isback && [[ZCUICore getUICore] getLibConfig].type == 2) {
                    // 返回当前页面 结束会话回到启动页面
                    [self goBackIsKeep];
                }else{
                    if (isback) {
                        return ;
                    }else{
                        // 去执行转人工的操作
                        [[ZCUICore getUICore] doConnectUserService:obj];
                    }
                    
                }
            };
            [self openNewPage:askVC];
            
        }
    }else{
        [self jumpNewPageVC:type IsExist:isExist isShowToat:isShow tipMsg:msg Dict:dict];
    }
}

-(void)jumpNewPageVC:(ZCPagesType)type IsExist:(LeaveExitType)isExist isShowToat:(BOOL)isShow tipMsg:(NSString *)msg Dict:(NSDictionary *)dict{
    if (type == ZC_AskTabelPage) {
        ZCUIAskTableController * askVC = [[ZCUIAskTableController alloc]init];
        askVC.dict = dict[@"data"];
        if (msg !=nil && [msg isEqualToString:@"clearskillId"]) {
            askVC.isclearskillId = YES;
        }
       askVC.isNavOpen = (self.superController.navigationController!=nil ? YES: NO);
        askVC.trunServerBlock = ^(BOOL isback) {
            if (isback && [[ZCUICore getUICore] getLibConfig].type == 2) {
                // 返回当前页面 结束会话回到启动页面
                [self goBackIsKeep];
            }else{
                if (isback) {
                    return ;
                }else{
                    // 去执行转人工的操作
                    [[ZCUICore getUICore] doConnectUserService:nil];
                }
                
            }
        };
         [self openNewPage:askVC];
        
    }else if (type == ZC_LeaveMsgPage || type == ZC_LeaveRecordPage){
        
        
        if (_delegate && [_delegate respondsToSelector:@selector(onLeaveMsgClick:)] && _isJumpCustomLeaveVC) {
            [_delegate onLeaveMsgClick:msg];
            return;
        }
        
        // 这里要在SDK进入留言页面之前做处理 调用接口，留言记录是否显示 布局UI界面
    
        __weak ZCChatView * chatView = self;
        ZCUILeaveMessageController *leaveMessageVC = [[ZCUILeaveMessageController alloc]init];
        leaveMessageVC.exitType = isExist;
        leaveMessageVC.isShowToat = isShow;
        leaveMessageVC.tipMsg = msg;
        leaveMessageVC.isNavOpen = (self.superController.navigationController!=nil ? YES: NO);
        [leaveMessageVC setCloseBlock:^{
            [chatView goBackIsKeep];
        }];
        [leaveMessageVC setBackRefreshPageblock:^(__autoreleasing id *object) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_keyboardTools hideKeyboard];
            });
        }];
        NSString * code = @"1";
        NSString * templateId = @"1";
        if (dict != nil) {
           leaveMessageVC.templateldIdDic = dict;
           
            if ([[dict allKeys] containsObject:@"selectedType"]) {
                code = [dict valueForKey:@"selectedType"];
            }
            
            if ([code intValue] ==2) {
                if (type == ZC_LeaveRecordPage) {
                    // 删除掉这条消息
                    int index = -1;
                    if([ZCUICore getUICore].listArray!=nil && [ZCUICore getUICore].listArray.count>0){
                        
                        for (int i = 0; i< [ZCUICore getUICore].listArray.count; i++) {
                            ZCLibMessage *libMassage = [ZCUICore getUICore].listArray[i];
                            // 删除上一次商品信息
                            if([libMassage.sysTips isEqualToString: ZCSTLocalString(@"您的留言状态有更新")]){
                                index = i;
                                break;
                            }
                        }
                        if(index >= 0){
                            [[ZCUICore getUICore].listArray removeObjectAtIndex:index];
                            [self.listTable reloadData];
                        }
                    }
                }
                
                // 直接跳转到 留言记录、
                leaveMessageVC.selectedType = 2;
                leaveMessageVC.ticketShowFlag  = 0;
                [chatView openNewPage:leaveMessageVC];
                return;
            }
            
            if ([[dict allKeys] containsObject:@"templateId"]) {
                templateId = [dict valueForKey:@"templateId"];
            }
            leaveMessageVC.selectedType = [code intValue];
        }

        [[ZCUIToastTools shareToast] showProgress:@"" with:self];
        
       static BOOL isJump = NO;
        // 线程处理
        dispatch_group_t group = dispatch_group_create();

        dispatch_group_enter(group);
        
        // 加载基础模板接口
        [[ZCLibServer getLibServer] postMsgTemplateConfigWithUid:[self getZCLibConfig].uid Templateld:templateId start:^{
            
        } success:^(NSDictionary *dict,NSMutableArray * typeArr, ZCNetWorkCode sendCode) {
            leaveMessageVC.tickeTypeFlag = [ zcLibConvertToString( dict[@"data"][@"item"][@"ticketTypeFlag"] )intValue];
            leaveMessageVC.ticketTypeId = zcLibConvertToString( dict[@"data"][@"item"][@"ticketTypeId"]);
            leaveMessageVC.telFlag = [zcLibConvertToString( dict[@"data"][@"item"][@"telFlag"]) boolValue];
            leaveMessageVC.telShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"telShowFlag"]) boolValue];
            leaveMessageVC.emailFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"emailFlag"]) boolValue];
            leaveMessageVC.emailShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"emailShowFlag"]) boolValue];
            leaveMessageVC.enclosureFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"enclosureFlag"]) boolValue];
            leaveMessageVC.enclosureShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"enclosureShowFlag"]) boolValue];
//            leaveMessageVC.ticketShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"ticketShowFlag"]) intValue];
            leaveMessageVC.ticketShowFlag = 1;
            leaveMessageVC.msgTmp = zcLibConvertToString(dict[@"data"][@"item"][@"msgTmp"]);
            leaveMessageVC.msgTxt = zcLibConvertToString(dict[@"data"][@"item"][@"msgTxt"]);
            if (typeArr.count) {
                if (leaveMessageVC.typeArr == nil) {
                    leaveMessageVC.typeArr = [NSMutableArray arrayWithCapacity:0];
                    leaveMessageVC.typeArr = typeArr;
                }
            }
            if ([dict[@"data"][@"retCode"] isEqualToString:@"000000"]) {
                isJump = YES;
            }else{
                isJump = NO;
            }
            dispatch_group_leave(group);
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[ZCUIToastTools shareToast] showToast:@"网络错误，请检查网络后重试" duration:1.0f view:self position:ZCToastPositionCenter];

            });
        }];
        
        dispatch_group_enter(group);
        // 加载自定义字段接口
        [[ZCLibServer getLibServer] postTemplateFieldInfoWithUid:[self getZCLibConfig].uid Templateld:templateId start:^{
         
        } success:^(NSDictionary *dict,NSMutableArray * cusFieldArray, ZCNetWorkCode sendCode) {
            @try{
                if (cusFieldArray.count) {
                    if (leaveMessageVC.coustomArr == nil) {
                        leaveMessageVC.coustomArr = [NSMutableArray arrayWithCapacity:0];
                        leaveMessageVC.coustomArr = cusFieldArray;
                    }
                    //                        [selfVC refreshViewData];
                }
                if ([dict[@"data"][@"retCode"] isEqualToString:@"000000"]) {
                    isJump = YES;
                }else{
                    isJump = NO;
                }
                dispatch_group_leave(group);
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[ZCUIToastTools shareToast] showToast:@"网络错误，请检查网络后重试" duration:1.0f view:self position:ZCToastPositionCenter];
            });
        }];

    
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            [[ZCUIToastTools shareToast] dismisProgress];
            if (isJump) {
                [chatView openNewPage:leaveMessageVC];
            }
        });
        
        
    }
}




-(void)openNewPage:(UIViewController *) vc{
    if(self.superController && [self.superController isKindOfClass:[UIViewController class]]){
        if (self.superController.navigationController) {
//            vc.isNavOpen = YES;
            [self.superController.navigationController pushViewController:vc animated:YES];
        }else{
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            vc.isNavOpen = NO;
            [self.superController  presentViewController:nav animated:YES completion:^{
                
            }];
            
        }
    }
}


#pragma mark -- 设置昵称
-(void)setTitleName:(NSString *)titleName{
    /**
     * 0.默认 1.企业昵称 2.自定义昵称
     *
     */
    if ([[ZCLibClient getZCLibClient].libInitInfo.titleType intValue] == 1) {
        // 取企业昵称
        titleName = [self getZCLibConfig].companyName;

    }else if ([[ZCLibClient getZCLibClient].libInitInfo.titleType intValue] ==2) {
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customTitle)]) {
            // 自定义的昵称
            titleName = [ZCLibClient getZCLibClient].libInitInfo.customTitle;
        }
    }
    
    if(_hideTopViewNav){
        [self.titleLabel setText:titleName];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTitleChanged:)]) {
            [self.delegate onTitleChanged:titleName];
        }
    }
    
}
#pragma mark --  scrollTableToBottom  显示消息到TableView上
/**
 显示消息到TableView上
 */
-(void)scrollTableToBottom{

//    [ZCLogUtils logHeader:LogHeader debug:@"滚动到底部"];
    isScrollBtm = false;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CGFloat ch=_listTable.contentSize.height;
        CGFloat h=_listTable.bounds.size.height;
        
        CGRect tf         = _listTable.frame;
        CGFloat x = tf.size.height-_listTable.contentSize.height;
        
        CGFloat keyBoardHeight = self.frame.size.height - _keyboardTools.zc_bottomView.frame.origin.y-BottomHeight ;
        if(x > 0){
            if(x<keyBoardHeight){
                tf.origin.y = navHeight - (keyBoardHeight - x)  - BottomHeight;
            }
        }else{
            CGFloat NH = 0;
            if (_superController.navigationController.navigationBarHidden) {
                NH = NavBarHeight;
            }
//            if (ZC_iPhoneX) {
//                NH = NH + 34;
//            }
            tf.origin.y   = NH  -keyBoardHeight;
        }
        _listTable.frame  = tf;
        
        if(ch > h){
            [_listTable setContentOffset:CGPointMake(0, ch-h) animated:NO];
        }else{
            [_listTable setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        
        isScrollBtm = true;
    });
    
}

// 加载历史消息
-(void)getHistoryMessage{
    [[ZCUICore getUICore] getChatMessages];
}

// 销毁界面
-(void)dismissZCChatView{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //    _isJumpCustomLeaveVC = nil;
    //    _isNoMore = nil;
    //    isStartConnectSockt = nil;
    //    _hideTopViewNav = nil;
    
    [[ZCUICore getUICore] desctoryBlock];
    self.closeButton = nil;
    self.delegate = nil;
    _socketStatusButton = nil;
    
    self.listTable = nil;
    self.changeRobotBtn = nil;
    
    
    self.topView = nil;
    self.topImageView = nil;
    self.backButton = nil;
    self.moreButton = nil;
    self.evaluationBtn = nil;
    self.titleLabel = nil;
    self.superController = nil;
    self.refreshControl = nil;
    self.notifitionTopView = nil;
    [self removeFromSuperview];
    
}


#pragma mark -- 原普通版使用
-(ZCLibConfig *)getZCLibConfig{
    return [self getPlatformInfo].config;
}
#pragma mark -- 涉及到UI页面展示的时候，例如：uitabelview代理方法中计算高度 使用此方法 避免卡顿
-(ZCLibConfig *)getZCIMConfig{
    return [ZCIMChat getZCIMChat].config;
}

-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_isNoMore && section == 0){
        return TableSectionHeight;
    }
//    if(section == 1 && _zcKeyboardView && !_zcKeyboardView.vioceTipLabel.hidden){
//        return 40;
//    }
    return 0;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_isNoMore && section == 0){
        
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, TableSectionHeight)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 19, viewWidth-40, TableSectionHeight -19)];
        lbl.font=[ZCUITools zcgetListKitDetailFont];
        lbl.backgroundColor = [UIColor clearColor];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        // 没有更多记录的颜色
        [lbl setTextColor:[ZCUITools zcgetTimeTextColor]];
        [lbl setAutoresizesSubviews:YES];
        [lbl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lbl setText:ZCSTLocalString(@"到顶了，没有更多")];
        [view addSubview:lbl];
        return view;
    }
    
    if(section == 1){
        
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 40)];
        [view setBackgroundColor:[UIColor clearColor]];
        return view;
    }
    
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1){
        return 0;
    }
    return [ZCUICore getUICore].chatMessages.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCChatBaseCell *cell=nil;
    
    if ( indexPath.row > [ZCUICore getUICore].chatMessages.count -1) {
        return cell;
    }
     ZCLibMessage *model=[[ZCUICore getUICore].chatMessages objectAtIndex:indexPath.row];
    // 设置内容
    if(model.tipStyle>0){
        if (model.tipStyle == ZCReceivedMessageEvaluation) {
            cell = (ZCSatisfactionCell *)[tableView dequeueReusableCellWithIdentifier:cellSatisfactionIndentifier];
            if (cell == nil) {
                cell = [[ZCSatisfactionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellSatisfactionIndentifier];
            }
        }else{
            cell = (ZCTipsChatCell*)[tableView dequeueReusableCellWithIdentifier:cellTipsIdentifier];
            if (cell == nil) {
                cell = [[ZCTipsChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTipsIdentifier];
            }
        }
    }else if(model.tipStyle == ZCReceivedMessageUnKonw){
        // 商品内容
        cell = (ZCGoodsCell*)[tableView dequeueReusableCellWithIdentifier:cellGoodsIndentifier];
        if (cell == nil) {
            cell = [[ZCGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellGoodsIndentifier];
        }
    }else if(model.tipStyle == ZCReceiVedMessageNotice){
        // 通告消息
        cell = (ZCNoticeCell*)[tableView dequeueReusableCellWithIdentifier:cellNoticeCellIdentifier];
        if (cell == nil) {
            cell = [[ZCNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellNoticeCellIdentifier];
        }
        model.isOpenNotice = isOpenNotice;
    }else if(model.richModel.msgType==1  || model.richModel.msgType == ZCMsgTypeVideo){
        cell = (ZCImageChatCell*)[tableView dequeueReusableCellWithIdentifier:cellImageIdentifier];
        if (cell == nil) {
            cell = [[ZCImageChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellImageIdentifier];
        }
    }else if(model.richModel.msgType == 0 && model.richModel.answerType != 15){
        // TODO 测试添加消息展示样式 && model.richModel.answerType != 1
        cell = (ZCRichTextChatCell*)[tableView dequeueReusableCellWithIdentifier:cellRichTextIdentifier];
        if (cell == nil) {
            cell = [[ZCRichTextChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichTextIdentifier];
        }
    }else if(model.richModel.msgType==2){
        cell = (ZCVoiceChatCell*)[tableView dequeueReusableCellWithIdentifier:cellVoiceIdentifier];
        if (cell == nil) {
            cell = [[ZCVoiceChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellVoiceIdentifier];
        }
    }else if (model.richModel.msgType == 7){
        cell = (ZCHotGuideCell*)[tableView dequeueReusableCellWithIdentifier:cellHotGuideIdentifier];
        if (cell == nil) {
            cell = [[ZCHotGuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellHotGuideIdentifier];
        }
    }else if (model.richModel.msgType == 24){
        cell = (ZCInfoCardCell*)[tableView dequeueReusableCellWithIdentifier:cellCardCellIdentifier];
        if (cell == nil) {
            cell = [[ZCInfoCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellCardCellIdentifier];
        }
    }
    else if (model.richModel.msgType == ZCMsgTypeFile){
        cell = (ZCFileCell*)[tableView dequeueReusableCellWithIdentifier:cellFileIndentifier];
        if (cell == nil) {
            cell = [[ZCFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFileIndentifier];
        }
    }else if (model.richModel.msgType == ZCMsgTypeLocation){
        cell = (ZCLocationCell*)[tableView dequeueReusableCellWithIdentifier:cellLocationIndentifier];
        if (cell == nil) {
            cell = [[ZCLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellLocationIndentifier];
        }
    }


    else if(model.richModel.msgType == 15 && model.richModel.multiModel.msgType != 3 && model.richModel.multiModel.msgType != 5){
        if (model.richModel.multiModel.msgType == 0){
            // 横向的collection
            cell = (ZCHorizontalRollCell*)[tableView dequeueReusableCellWithIdentifier:cellHorizontalRollIndentifier];
            if (cell == nil) {
                cell =  [[ZCHorizontalRollCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellHorizontalRollIndentifier];
            }
        }else if (model.richModel.multiModel.msgType== 1 ){
            cell = (ZCMultiItemCell*)[tableView dequeueReusableCellWithIdentifier:cellMultilItemIndentifier];
            if (cell) {
                cell =  [[ZCMultiItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellMultilItemIndentifier];
            }
        }else if (model.richModel.multiModel.msgType == 2){
            cell = (ZCVerticalRollCell*)[tableView dequeueReusableCellWithIdentifier:cellVerticalRollIndentifier];
            if (cell) {
                cell = [[ZCVerticalRollCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellVerticalRollIndentifier];
            }
        }
        else if (model.richModel.multiModel.msgType == 3){
            cell = (ZCMultiRichCell*)[tableView dequeueReusableCellWithIdentifier:cellMultiRichIdentifier];
            if (cell) {
                cell = [[ZCMultiRichCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellMultiRichIdentifier];
            }
        }else if (model.richModel.multiModel.msgType == 5){
            cell = (ZCTextGuideCell*)[tableView dequeueReusableCellWithIdentifier:cellTextCellIdentifier];
            if (cell) {
                cell = [[ZCTextGuideCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTextCellIdentifier];
            }
        }
    }
    if(cell == nil){
        cell = (ZCRichTextChatCell*)[tableView dequeueReusableCellWithIdentifier:cellRichTextIdentifier];
        if (cell == nil) {
            cell = [[ZCRichTextChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichTextIdentifier];
        }
    }

    
    cell.viewWidth = _listTable.frame.size.width;
    cell.delegate=self;
    NSString *time=@"";
    NSString *format=@"MM-dd HH:mm";
    
    if([model.cid isEqual:[self getZCIMConfig].cid]){// [self getZCLibConfig].cid
        format=@"HH:mm";
    }
    
    
    if(indexPath.row>0){
        ZCLibMessage *lm=[[ZCUICore getUICore].chatMessages objectAtIndex:(indexPath.row-1)];
        if(![model.cid isEqual:lm.cid]){
            //            time=intervalSinceNow(model.ts);
            time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        }
    }else{
        time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
    }
    
    if([self getZCIMConfig].isArtificial){// [self getZCLibConfig].isArtificial
        model.isHistory = YES;
    }
    
    if(model.tipStyle == 2){
        time = @"";
    }
    
    [cell InitDataToView:model time:time];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZCLibMessage *model =[[ZCUICore getUICore].chatMessages objectAtIndex:indexPath.row];
    NSString *time=@"";
    NSString *format=@"MM-dd HH:mm";
    if([model.cid isEqual:[self getZCIMConfig].cid]){// [self getZCLibConfig].cid
        format=@"HH:mm";
    }
    
    if(indexPath.row>0){
        ZCLibMessage *lm=[[ZCUICore getUICore].chatMessages objectAtIndex:(indexPath.row-1)];
        if(![model.cid isEqual:lm.cid]){
            //            time=intervalSinceNow(model.ts);
            time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        }
        //        [ZCLogUtils logHeader:LogHeader debug:@"============\n%@\ncur=%@\nlast=%@\ntime=%@",model,model.cid,lm.cid,time];
    }else{
        time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        //        time=intervalSinceNow(model.ts);
    }
    
    if(model.tipStyle == 2){
        time = @"";
    }
    
    CGFloat cellheight = 0;
    
    // 设置内容
    if(model.tipStyle>0){

        if(model.tipStyle == ZCReceivedMessageEvaluation){
            // 评价cell的高度
            cellheight = [ZCSatisfactionCell getCellHeight:model time:time viewWith:viewWidth];
        }else{
            // 提示cell的高度
            cellheight = [ZCTipsChatCell getCellHeight:model time:time viewWith:viewWidth];
        }

    }else if(model.tipStyle == ZCReceivedMessageUnKonw){
        // 商品内容
        cellheight = [ZCGoodsCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.tipStyle == ZCReceiVedMessageNotice){
         model.isOpenNotice = isOpenNotice;
        cellheight = [ZCNoticeCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==ZCMsgTypePhoto || model.richModel.msgType == ZCMsgTypeVideo){
        cellheight = [ZCImageChatCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==ZCMsgTypeFile){// 文件
        cellheight = [ZCFileCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==ZCMsgTypeLocation){// 位置
        cellheight = [ZCLocationCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==2){
        cellheight = [ZCVoiceChatCell getCellHeight:model time:time viewWith:viewWidth];
    }else if (model.richModel.msgType == 7){
        cellheight = [ZCHotGuideCell getCellHeight:model time:time viewWith:viewWidth];
    }else if (model.richModel.msgType == 24){
        cellheight = [ZCInfoCardCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==15 && model.richModel.multiModel.msgType != 3 && model.richModel.multiModel.msgType != 5){
        if (model.richModel.multiModel.msgType == 0){
            cellheight = [ZCHorizontalRollCell getCellHeight:model time:time viewWith:viewWidth];
        }else if (model.richModel.multiModel.msgType == 1){
            cellheight = [ZCMultiItemCell getCellHeight:model time:time viewWith:viewWidth];
        }else if (model.richModel.multiModel.msgType == 2){
            cellheight = [ZCVerticalRollCell getCellHeight:model time:time viewWith:viewWidth];
        }
//        else if (model.richModel.multiModel.msgType == 3){
//            cellheight = [ZCMultiRichCell getCellHeight:model time:time viewWith:viewWidth];
//        }else if(model.richModel.multiModel.msgType == 5){
//            cellheight = [ZCTextGuideCell getCellHeight:model time:time viewWith:viewWidth];
//        }
    }else{
        cellheight = [ZCRichTextChatCell getCellHeight:model time:time viewWith:viewWidth];
    }
    return cellheight;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark table cell delegate start  cell点击的代理事件
-(void)cellItemClick:(ZCLibMessage *)model type:(ZCChatCellClickType)type obj:(id)object{
    if(type == ZCChatCellClickTypeNewDataGroup){
        int allSize         = (int)model.richModel.suggestionArr.count;
        int pageSize        =  model.richModel.guideGroupNum;
        int page         = (allSize%pageSize==0) ? (allSize/pageSize) : (allSize/pageSize+1);
        if((model.richModel.guideGroupPage + 1) < page){
            model.richModel.guideGroupPage = model.richModel.guideGroupPage + 1;
        }else{
            model.richModel.guideGroupPage = 0;
        }
        [self.listTable reloadData];
        return;
    }
    if (type == ZCChatCellClickTypeItemCancelFile) {
        // 取消发送文件
        [[ZCUICore getUICore] cancelSendFileMsg:model];
        return;
    }
    
    if(type == ZCChatCellClickTypeItemOpenLocation){
        NSString *linkUrl = [NSString stringWithFormat:@"sobot://openlocation?latitude=%@&longitude=%@&address=%@",model.richModel.latitude,model.richModel.longitude,model.richModel.localLabel];
        
        [self cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:linkUrl];
        
        
        return;
    }
    
    if (type == ZCChatCellClickTypeNotice) {
        // 展开和收起
        isOpenNotice = NO;
        if ([object intValue] == 2) {
            isOpenNotice = YES;
        }
        [self.listTable reloadData];
//        [self scrollTableToBottom];
        return;
    }
    
    if (type == ZCChatCellClickTypeCollectionBtnSend) {
        // 展开和收起
        [self.listTable reloadData];
        [self scrollTableToBottom];
        return;
    }
    
    // 打开文件
    if(type == ZCChatCellClickTypeItemOpenFile){
        ZCDocumentLookController *leaveMessageVC = [[ZCDocumentLookController alloc]init];
        leaveMessageVC.message = model;
        [self openNewPage:leaveMessageVC];
        return;
    }
    
    if ([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession && type == ZCChatCellClickTypeItemChecked) {
        [[ZCUICore getUICore] addTipsListenerMessage:ZCTipCellMessageOverWord];
        return;
    }
    
    if(type == ZCChatCellClickTypeSendGoosText && ![self getZCLibConfig].isArtificial){
        return;
    }
    
    if (type == ZCChatCellClickTypeShowToast) {
        [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"   %@  ",ZCSTLocalString(@"复制成功！")] duration:1.0f view:self.superController.view.window.rootViewController.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
        return;
    }
    
    // 点击满意度，调评价
    if (type == ZCChatCellClickTypeSatisfaction) {
        
    }
    
    if (type == ZCChatCellClickTypeLeaveMessage) {
        [_keyboardTools hideKeyboard];
        [self changeLeaveMsgType:LeaveExitTypeISNOCOLSE];
        // 不直接退出SDK
//        [self jumpNewPageVC:ZC_LeaveMsgPage IsExist:2 isShowToat:NO tipMsg:@"" Dict:@{@"selectedType":@"1",@"templateId":@"1"}];
    }
    
    if (type == ZCChatCellClickTypeLeaveRecordPage) {
        [_keyboardTools hideKeyboard];
        // 跳转到留言记录
        [self jumpNewPageVC:ZC_LeaveRecordPage IsExist:2 isShowToat:NO tipMsg:@"" Dict:@{@"selectedType":@"2",@"templateId":@"1"}];
    }
    
    if(type==ZCChatCellClickTypeTouchImageYES){
        xhObj = object;
        [_keyboardTools hideKeyboard];
    }
    
    if(type==ZCChatCellClickTypeTouchImageNO){
        // 隐藏大图查看
        xhObj = nil;
    }
    
    if(type==ZCChatCellClickTypeItemChecked){
        // 向导内容
        NSDictionary *dict = model.richModel.suggestionArr[[object intValue]];
        if(dict==nil || dict[@"question"]==nil){
            return;
        }
        [[ZCUICore getUICore] sendMessage:[NSString stringWithFormat:@"%d.%@",[object intValue]+1,dict[@"question"]] questionId:dict[@"docId"] type:ZCMessageTypeText duration:@""];
    }
    
    
    if (type == ZCChatCellClickTypeGroupItemChecked) {
        // 点击机器人回复的技能组选项
        NSDictionary *dict = model.groupList[[object intValue]];
        if(dict==nil || dict[@"groupId"]==nil){
            return;
        }
        int temptype = [self getZCLibConfig].type;
        if ([ZCLibClient getZCLibClient].libInitInfo.serviceMode >0) {
            temptype = [ZCLibClient getZCLibClient].libInitInfo.serviceMode;
        }
        if (temptype == 1) {
            return;
        }
        // 点击技能组转人工
//        [ZCLibClient getZCLibClient].libInitInfo.skillSetName = zcLibConvertToString (dict[@"groupName"]);
//        [ZCLibClient getZCLibClient].libInitInfo.skillSetId = zcLibConvertToString(dict[@"groupId"]);
        
        // 执行转人工  不在显示技能组
        if ([ZCLibClient getZCLibClient].turnServiceBlock) {
            [ZCLibClient getZCLibClient].turnServiceBlock(nil, nil, ZCTurnType_CellGroupClick, model.keyword, model.keywordId);
            return;
        }
        [[ZCUICore getUICore] toConnectUserService:model  GroupId:dict[@"groupId"] GroupName:dict[@"groupName"] ZCTurnType:ZCTurnType_CellGroupClick];
        
    }
    
    // 发送商品信息给客服
    if(type == ZCChatCellClickTypeSendGoosText){
        ZCProductInfo *pinfo = object;
        NSMutableDictionary * contentDic = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString *contextStr = @"";
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.title)] forKey:@"title"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.desc)] forKey:@"description"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.label)] forKey:@"label"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.link)] forKey:@"url"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.thumbUrl)] forKey:@"thumbnail"];
        // 转json
        contextStr = [ZCLocalStore DataTOjsonString:contentDic];
        
        [[ZCUICore getUICore] sendMessage:contextStr questionId:@"" type:ZCMessageTypeCard duration:@""];
    }
    
    // 重新发送
    if(type==ZCChatCellClickTypeReSend){
        // 当前的键盘样式是新会话的样式，重新发送的消息不在发送  （用户超时下线提示和会话结束提示）
        //        [self.zcKeyboardView getKeyBoardViewStatus] == AGAINACCESSASTATUS
        if ([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
            [_listTable reloadData];
            return;
        }
        NSDictionary *dict = nil;
        if(model.richModel.msgType == ZCMsgTypeLocation){
             dict = @{@"lng":model.richModel.longitude,@"lat":model.richModel.latitude,@"localName":model.richModel.localName,@"localLabel":model.richModel.localLabel,@"file":model.richModel.richmoreurl};
            model.richModel.msg = model.richModel.richmoreurl;
        }
        if(model.richModel.msgType == ZCMsgTypeVideo){
            dict = @{@"cover":model.richModel.msg};
            model.richModel.msg = model.richModel.richmoreurl;
        }
        
        [[ZCLibServer getLibServer] sendMessage:model.richModel.msg questionId:@"" msgType:model.richModel.msgType duration:model.richModel.duration config:[self getZCLibConfig] robotFlag:[ZCLibClient getZCLibClient].libInitInfo.robotId dict:dict start:^(ZCLibMessage *message) {
            model.sendStatus = 1;
            [_listTable reloadData];
        } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            model.sendStatus = message.sendStatus;
            
            if(![self getZCLibConfig].isArtificial && sendCode == ZC_SENDMessage_New){
                NSInteger index = [[ZCUICore getUICore].listArray indexOfObject:model];
                
                // 如果返回的数据是最后一轮，当前的多轮会话的cell不可点击
                // 记录下标
//                if ( [zcLibConvertToString([NSString stringWithFormat:@"%d",message.richModel.answerType]) hasPrefix:@"15"]  && message.richModel.multiModel.endFlag) {
//                    for (ZCLibMessage *message in [ZCUICore getUICore].listArray) {
//                        if ([zcLibConvertToString([NSString stringWithFormat:@"%d",message.richModel.answerType]) hasPrefix:@"15"] && !message.richModel.multiModel.endFlag && !message.richModel.multiModel.isHistoryMessages ) {
//                            message.richModel.multiModel.isHistoryMessages = YES;// 变成不可点击，成为历史
//                        }
//                    }
//                }
                
                [[ZCUICore getUICore] splitMessageModel:message Index:index weakself:[ZCUICore getUICore]];
                
//                [[ZCUICore getUICore].listArray insertObject:message atIndex:index+1];
//                [_listTable reloadData];
//                [self scrollTableToBottom];
            }else if(sendCode == ZC_SENDMessage_Success){
                model.sendStatus = 0;
                model.richModel.msgtranslation = message.richModel.msgtranslation;
                
                [_listTable reloadData];
            }else{
                model.sendStatus = 2;
                [_listTable reloadData];
            }
        } progress:^(ZCLibMessage *message) {
            model.progress = message.progress;
            [_listTable reloadData];
        } fail:^(ZCLibMessage *message, ZCMessageSendCode errorCode) {
            model.sendStatus = 2;
            [_listTable reloadData];
            
        }];
    }
    
    if(type==ZCChatCellClickTypePlayVoice  || type == ZCChatCellClickTypeReceiverPlayVoice){
        if([ZCUICore getUICore].animateView){
            [[ZCUICore getUICore].animateView stopAnimating];
        }
        
        // 已经有播放的，关闭当前播放的
        if(_voiceTools){
            [_voiceTools stopVoice];
        }
        
        if([ZCUICore getUICore].playModel){
            [ZCUICore getUICore].playModel.isPlaying=NO;
            [ZCUICore getUICore].playModel=nil;
        }
        
        if([object isEqual:[ZCUICore getUICore].animateView]){
            [ZCUICore getUICore].animateView = nil;
            return;
        }
        
        
        [ZCUICore getUICore].playModel=model;
        [ZCUICore getUICore].playModel.isPlaying=YES;
        
        [ZCUICore getUICore].animateView=object;
        
        [[ZCUICore getUICore].animateView startAnimating];
        
        // 本地文件
        if(zcLibCheckFileIsExsis(model.richModel.msg)){
            if(_voiceTools){
                [_voiceTools playAudio:[NSURL fileURLWithPath:model.richModel.msg] data:nil];
            }
        }else{
            NSString *voiceURL=model.richModel.msg;
            NSString *dataPath = zcLibGetDocumentsFilePath(@"/sobot/");
            // 创建目录
            zcLibCheckPathAndCreate(dataPath);
            
            // 拼接完整的地址
            dataPath=[dataPath stringByAppendingString:[NSString stringWithFormat:@"/%@.wav",zcLibMd5(voiceURL)]];
            if(zcLibCheckFileIsExsis(dataPath)){
                if(_voiceTools){
                    [_voiceTools playAudio:[NSURL fileURLWithPath:dataPath] data:nil];
                }
                return;
            }
            
            // 下载，播放网络声音
            [[ZCLibServer getLibServer] downFileWithURL:model.richModel.msg start:^{
                
            } success:^(NSData *data) {
                [data writeToFile:dataPath atomically:YES];
                if(_voiceTools){
                    [_voiceTools playAudio:[NSURL fileURLWithPath:dataPath] data:nil];
                }
            } progress:^(float progress) {
                
            } fail:^(ZCNetWorkCode errorCode) {
                
            }];
        }
    }
    
    // 转人工
    if(type == ZCChatCellClickTypeConnectUser){
        if ([ZCLibClient getZCLibClient].turnServiceBlock) {
            [ZCLibClient getZCLibClient].turnServiceBlock(nil, nil, ZCTurnType_BtnClick, @"", @"");
            return;
        }
        [[ZCUICore getUICore] checkUserServiceWithObject:nil Msg:nil];
    }
    
    // 踩/顶   -1踩   1顶
    if(type == ZCChatCellClickTypeStepOn || type == ZCChatCellClickTypeTheTop){
        
        if ([self.keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
            // 置灰不可点
            [[ZCUIToastTools shareToast] showToast:@"会话结束，无法反馈" duration:1.5f view:self.window.rootViewController.view position:ZCToastPositionCenter];
            model.commentType = 4;
            [_listTable  reloadData];
            return;
        }
        
        
        int status = (type == ZCChatCellClickTypeStepOn)?-1:1;
        
        [[ZCLibServer getLibServer] rbAnswerComment:[self getZCLibConfig] message:model status:status start:^{
            
        } success:^(ZCNetWorkCode code) {
            if(status== -1){
                model.commentType = 3;
                [[ZCUIToastTools shareToast] showToast:@"我会努力学习，希望下次帮到您" duration:1.5f view:self.window.rootViewController.view position:ZCToastPositionCenter];
            }else{
                model.commentType = 2;
                [[ZCUIToastTools shareToast] showToast:@"感谢您的支持" duration:1.5f view:self.window.rootViewController.view position:ZCToastPositionCenter];
            }
            [_listTable  reloadData];
            
        } fail:^(ZCNetWorkCode errorCode) {
            
        }];
    }
    
    // collectionView item 点击
    if (type == ZCChatCellClickTypeCollectionSendMsg || type == ZCChatCellClickTypeItemGuide) {
        //  多轮会话，发送给机器人
        
        NSDictionary * dict = (NSDictionary*)object;
        
        // 发送完成再计数
        [[ZCUICore getUICore] cleanUserCount];
        
        //        * 正在发送的消息对象，方便更新状态
        __block ZCLibMessage    *sendMessage;
        
        __weak ZCChatView *safeVC = self;
        
        if ([self getZCLibConfig].isArtificial || [dict[@"ishotguide"] intValue] == 1) {
            [[ZCUICore getUICore] sendMessage:dict[@"title"] questionId:@"" type:ZCMessageTypeText duration:@""];
            return;
        }
        // 发送给机器人
        [[ZCLibServer getLibServer] sendToRobot:dict[@"requestText"] showText:dict[@"title"] questionStr:dict[@"question"] questionFlag:2 msgType:(int)model.richModel.msgType questionId:@"" config:[self getZCLibConfig] robotFlag:[NSString stringWithFormat:@"%d",[self getPlatformInfo].config.robotFlag]  duration:@"" start:^(ZCLibMessage *message) {
            sendMessage  = message;
            sendMessage.sendStatus=1;
            [[ZCUICore getUICore].listArray addObject:sendMessage];
            [safeVC.listTable reloadData];
            [safeVC scrollTableToBottom];
        } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            [ZCUICore getUICore].isSendToUser = NO;
            [ZCUICore getUICore].isSendToRobot = YES;
            if(sendCode==ZC_SENDMessage_New){
                if(message.richModel
                   && (message.richModel.answerType==3
                       ||message.richModel.answerType==4)
                   && ![ZCUICore getUICore].kitInfo.isShowTansfer
                   && ![ZCLibClient getZCLibClient].isShowTurnBtn){
                    safeVC.unknownWordsCount ++;
                    if([[ZCUICore getUICore].kitInfo.unWordsCount integerValue]==0) {
                        [ZCUICore getUICore].kitInfo.unWordsCount =@"1";
                    }
                    if (safeVC.unknownWordsCount >= [[ZCUICore getUICore].kitInfo.unWordsCount integerValue]) {
                        
                        // 仅机器人的模式不做处理
                        if ([safeVC getZCLibConfig].type != 1) {
                            // 设置键盘的样式 （机器人，转人工按钮显示）
                            [safeVC.keyboardTools setKeyBoardStatus:ZCKeyboardStatusRobot];
                            // 保存在本次有效的会话中显示转人工按钮
                            [ZCLibClient getZCLibClient].isShowTurnBtn = YES;
                        }
                    }
                    
                }
                
                NSInteger index = [[ZCUICore getUICore].listArray indexOfObject:sendMessage];
                
                // 如果返回的数据是最后一轮，当前的多轮会话的cell不可点击
                // 记录下标
//                if ( [zcLibConvertToString([NSString stringWithFormat:@"%d",message.richModel.answerType]) hasPrefix:@"15"]  && message.richModel.multiModel.endFlag) {
//                    // 便利所有多轮会话的消息 变成历史不可点
//                    for (ZCLibMessage *message in [ZCUICore getUICore].listArray) {
//                        if ([zcLibConvertToString([NSString stringWithFormat:@"%d",message.richModel.answerType]) hasPrefix:@"15"] && !message.richModel.multiModel.endFlag && !message.richModel.multiModel.isHistoryMessages ) {
//                            message.richModel.multiModel.isHistoryMessages = YES;// 变成不可点击，成为历史
//                        }
//                    }
//                }
//
//                [[ZCUICore getUICore].listArray insertObject:message atIndex:index+1];
//                [safeVC.listTable reloadData];
//                [safeVC scrollTableToBottom];
                
                [[ZCUICore getUICore] splitMessageModel:message Index:index weakself:[ZCUICore getUICore]];
                
                
            }else if(sendCode==ZC_SENDMessage_Success){
                sendMessage.sendStatus=0;
                sendMessage.richModel.msgtranslation = message.richModel.msgtranslation;
                [safeVC.listTable reloadData];
            }else {
                sendMessage.sendStatus=2;
                [safeVC.listTable reloadData];
                if(sendCode == ZC__SENDMessage_FAIL_STATUS){
                    /**
                     *   给人工发消息没有成功，说明当前已经离线
                     *   1.回收键盘
                     *   2.添加结束语
                     *   3.添加新会话键盘样式
                     *   4.中断计时
                     *
                     **/
                    [[ZCUICore getUICore] cleanUserCount];
                    [[ZCUICore getUICore] cleanAdminCount];
                    [_keyboardTools hideKeyboard];
                    [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];
                    [[ZCUICore getUICore] addTipsListenerMessage:ZCTipCellMessageOverWord];
                }
            }
            
        } progress:^(ZCLibMessage *message) {
            [ZCUICore getUICore].isSendToUser = NO;
            [ZCUICore getUICore].isSendToRobot = YES;
            [ZCLogUtils logText:@"上传进度：%f",message.progress];
            sendMessage.progress = message.progress;
            [safeVC.listTable reloadData];
        } failed:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            [ZCUICore getUICore].isSendToUser = NO;
            [ZCUICore getUICore].isSendToRobot = YES;
            sendMessage.sendStatus=2;
            [safeVC.listTable reloadData];
        }];
    }
     
}

-(void)cellItemLinkClick:(NSString *)text type:(ZCChatCellClickType)type obj:(NSString *)linkURL{
    if(type==ZCChatCellClickTypeOpenURL){
        // 通知外部可以更新UI
        if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(linkURL)){
            if([linkURL hasPrefix:@"tel:"] || zcLibValidateMobile(linkURL)){
                callURL=linkURL;
                if (![linkURL hasPrefix:@"tel:"]) {
                    linkURL = [NSString stringWithFormat:@"tel:%@",linkURL];
                    callURL = linkURL;
                }
                if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_9_x_Max) {
                    //初始化AlertView
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:[linkURL stringByReplacingOccurrencesOfString:@"tel:" withString:@""]
                                                                   delegate:self
                                                          cancelButtonTitle:ZCSTLocalString(@"取消")
                                                          otherButtonTitles:ZCSTLocalString(@"呼叫"),nil];
                    alert.tag=1;
                    [alert show];
                }else{
                    // 打电话
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
                }
                
            }else if([linkURL hasPrefix:@"mailto:"] || zcLibValidateEmail(linkURL)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkURL]];
            }else{
                NSString *urlStr;
                if ([[ZCToolsCore getToolsCore] isUrl:linkURL]) {
                    if (![linkURL hasPrefix:@"https"] && ![linkURL hasPrefix:@"http"]) {
                        linkURL = [@"https://" stringByAppendingString:linkURL];
                    }
                    urlStr = zcUrlEncodedString(linkURL);
                }else{
                    urlStr = linkURL;
                }
                
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:urlStr];
                if(self.superController.navigationController != nil ){
                    [self.superController.navigationController pushViewController:webPage animated:YES];
                }else{
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                    nav.navigationBarHidden=YES;
                    [self.superController presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
            }
        }
    }
}




// 显示打电话
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag==1){
        if(buttonIndex==1){
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
            
        }
    } else if(alertView.tag==3){
        if(buttonIndex==1){
            // 打开QQ
            [self openQQ:callURL];
            callURL=@"";
        }
    }else if (alertView.tag == 1001 && buttonIndex ==1){
        // 清空历史记录
        [[ZCUICore getUICore].listArray removeAllObjects];
        _isNoMore = NO;
        //        _isClearnHistory = YES;
        [self.listTable reloadData];
        //                [ZCUICore getUICore].isClearnHistory = YES;
        
        [[ZCLibServer getLibServer] cleanHistoryMessage:[self getZCLibConfig].uid success:^(NSData *data) {
            
        } fail:^(ZCNetWorkCode errorCode) {
            
        }];
    }
}

// 打开QQ，未使用
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
#pragma mark UITableView delegate end

-(void)configShowNotifion{
    BOOL isShowNotifion = NO;
    if ([[ZCUICore getUICore] getLibConfig].announceMsgFlag == 1 && [[ZCUICore getUICore] getLibConfig].announceTopFlag == 1) {
        isShowNotifion = YES;
    }
    [[ZCUICore getUICore] setInputListener:_keyboardTools.zc_chatTextView];

        // 初始化结束后添加通告
        [self notifitionTopViewWithisShowTopView:isShowNotifion
                                           Title:[self getPlatformInfo].config.announceMsg
                                      addressUrl:[self getPlatformInfo].config.announceClickUrl
                                         iconUrl:[ZCLibClient getZCLibClient].libInitInfo.notifitionIconUrl];

}

#pragma mark -- 通告栏 eg: “国庆大酬宾。
- (UIView *)notifitionTopViewWithisShowTopView:(BOOL) isShow  Title:(NSString *) title  addressUrl:(NSString *)url iconUrl:(NSString *)icoUrl{
    
    if (!_notifitionTopView && isShow && ![@"" isEqual:zcLibConvertToString(title)]) {
        _notifitionTopView = [[UIView alloc]init];
        CGFloat Y = 0;
        if (_superController.navigationController.navigationBarHidden || [ZCUICore getUICore].kitInfo.navcBarHidden) {
            Y = NavBarHeight;
        }
        _notifitionTopView.frame = CGRectMake(0, Y, viewWidth, 40);
        _notifitionTopView.backgroundColor = [ZCUITools getNotifitionTopViewBgColor];
//        _notifitionTopView.alpha = 0.8;
  
        UITapGestureRecognizer * tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpWebView:)];
        
        
        // icon
        ZCUIImageView * icon = [[ZCUIImageView alloc]initWithFrame:CGRectMake(10, 13, 14,14)];
        if (![@"" isEqual:zcLibConvertToString(icoUrl)]) {
            [icon loadWithURL:[NSURL URLWithString:zcUrlEncodedString(icoUrl)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_annunciate"] showActivityIndicatorView:NO];
        }else{
            [icon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_annunciate"]];
        }
        
        icon.contentMode = UIViewContentModeScaleAspectFill;
        [icon setBackgroundColor:[UIColor clearColor]];
        [icon addGestureRecognizer:tapAction];
        [_notifitionTopView addSubview:icon];
        
        
        // title
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(viewWidth - 30- 10-10 - icon.frame.size.width, 0,0, 0)];
        titleLab.font = [ZCUITools zcgetNotifitionTopViewFont];
        titleLab.textColor = [ZCUITools getNotifitionTopViewLabelColor];
        // 过滤 html标签
        // 处理换行
        
        NSString * text = title;
        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        titleLab.text = text;
        [titleLab addGestureRecognizer:tapAction];
        [titleLab sizeToFit];
    
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) +10, 10, viewWidth - 30- 10-10 - icon.frame.size.width, 20)];
        bgView.layer.masksToBounds = YES;
        [_notifitionTopView addSubview:bgView];
        [bgView addSubview:titleLab];
        if (titleLab.text.length >=15) {
            [self Aniantions];
        }else{
            CGRect frame = titleLab.frame;
            frame.size.height = ZCNumber(20);
            frame.origin.x = CGRectGetMaxX(icon.frame);
            titleLab.frame = frame;
        }
    
        if (![@"" isEqual:zcLibConvertToString(url)]) {
            // arraw
            UIImageView * arrawIcon = [[UIImageView alloc]initWithFrame:CGRectMake(viewWidth - 30, 15, 11, 11)];
            arrawIcon.backgroundColor = [UIColor clearColor];
            [arrawIcon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_arrow_right"]];
//            arrawIcon.transform = CGAffineTransformMakeRotation(M_PI);
            arrawIcon.contentMode = UIViewContentModeScaleAspectFill;
            [arrawIcon addGestureRecognizer:tapAction];
            [_notifitionTopView addSubview:arrawIcon];
            
        }
        [_notifitionTopView addGestureRecognizer:tapAction];
        [self addSubview:_notifitionTopView];
        _notifitionTopView.hidden = !isShow;
    }
    return _notifitionTopView;
}

-(void)beginAniantions{
    if (_notifitionTopView != nil) {
        [_notifitionTopView removeFromSuperview];
        _notifitionTopView = nil;
        [self configShowNotifion];
    }
   
}

-(void)Aniantions{
    if (!_notifitionTopView.hidden) {
        
        [UIView beginAnimations:@"Marquee" context:NULL];
        [UIView setAnimationDuration:CGRectGetWidth(titleLab.frame) / 30.f * (1 / 1.0f)];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:NO];
        
        [UIView setAnimationRepeatCount:MAXFLOAT];
        
        CGRect frame = titleLab.frame;
        frame.origin.x = -frame.size.width;
        titleLab.frame = frame;
        [UIView commitAnimations];
    }
}


-(UIButton *)newWorkStatusButton{
    if(!_newWorkStatusButton){
        CGFloat NWY = NavBarHeight;
        if (!self.superController.navigationController.navigationBarHidden) {
            NWY = 0;
        }
        _newWorkStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_newWorkStatusButton setFrame:CGRectMake(0, NWY, CGRectGetWidth(self.frame), 40)];
        [_newWorkStatusButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [_newWorkStatusButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_tag_nonet"] forState:UIControlStateNormal];
        [_newWorkStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_newWorkStatusButton setBackgroundColor:UIColorFromRGBAlpha(BgNetworkFailColor, 0.8)];
        [_newWorkStatusButton setTitle:[NSString stringWithFormat:@" %@",ZCSTLocalString(@"当前网络不可用，请检查您的网络设置")] forState:UIControlStateNormal];
        [_newWorkStatusButton setTitleColor:UIColorFromRGB(TextNetworkTipColor) forState:UIControlStateNormal];
        [_newWorkStatusButton.titleLabel setFont:[ZCUITools zcgetVoiceButtonFont]];
        [_newWorkStatusButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [self addSubview:_newWorkStatusButton];
        
        _newWorkStatusButton.hidden=YES;
    }
    return _newWorkStatusButton;
}

-(UIButton *)socketStatusButton{
    if(!_socketStatusButton){
        CGFloat SSY = NavBarHeight-44;
        if (!_hideTopViewNav) {
         
//            if (ZC_iPhoneX) {
//                SSY = 44;
//            } else {
                SSY =20;
//            }
            
        }
        _socketStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_socketStatusButton setFrame:CGRectMake(60, SSY, viewWidth-120, 44)];
        [_socketStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_socketStatusButton setBackgroundColor:[ZCUITools zcgetDynamicColor]];
        if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
            [_socketStatusButton setBackgroundColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
        }
        [_socketStatusButton setTitle:[NSString stringWithFormat:@"  %@",ZCSTLocalString(@"收取中...")] forState:UIControlStateNormal];
        [_socketStatusButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        [_socketStatusButton.titleLabel setFont:[ZCUITools zcgetTitleFont]];
        [_socketStatusButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        
        if (_superController.navigationController.navigationBarHidden) {
            [self addSubview:_socketStatusButton];
        }
             
        _socketStatusButton.hidden=YES;
        
        UIActivityIndicatorView *_activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.hidden=YES;
        _activityView.tag = 1;
        _activityView.center = CGPointMake(_socketStatusButton.frame.size.width/2 - 50, 22);
        [_socketStatusButton addSubview:_activityView];
    }
    return _socketStatusButton;
    
    
}

- (void)jumpWebView:(UITapGestureRecognizer*)tap{

    if (zcLibConvertToString([self getZCLibConfig].announceClickUrl).length >0 && [self getZCLibConfig].announceClickFlag == 1) {
        [self cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:[self getZCLibConfig].announceClickUrl];
    }
}


-(void)cleanHistoryMessage{
    [_keyboardTools hideKeyboard];
    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"清空聊天记录"), nil];
    mysheet.selectIndex = 1;
    [mysheet show];

}

-(void)goEvaluation{
    [[ZCUICore getUICore] keyboardOnClickSatisfacetion:NO];
}

// 清空聊天记录代理
- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        // 2.7.4版本开始，新增一层判定
        UIAlertView * alertView =[[UIAlertView alloc]initWithTitle:ZCSTLocalString(@"清空记录将无法恢复，是否要清空历史记录？") message:nil delegate:self cancelButtonTitle:ZCSTLocalString(@"取消") otherButtonTitles:ZCSTLocalString(@"清空"), nil];
        alertView.delegate = self;
        alertView.tag = 1001;
        [alertView show];
        
      
        
    }
}

- (void)confimGoBackWithType:(ZCChatViewGoBackType )type{
    
    BOOL showEvaluation = NO;
    switch (type) {
        case ZCChatViewGoBackType_normal:
        {
            if ([ZCUICore getUICore].kitInfo.isOpenEvaluation) {
                showEvaluation = YES;
            }
            
        }
            break;
        case ZCChatViewGoBackType_close:
        {
            isClickCloseBtn = YES;
            
            if ([ZCUICore getUICore].kitInfo.isShowCloseSatisfaction) {
                showEvaluation = YES;
            }
        }
            break;
        default:
            break;
    }
    
    // 隐藏键盘
    [_keyboardTools hideKeyboard];
    
    // 如果用户开起关闭时显示评价的弹框
    if (showEvaluation) {
        
        //  1.是否转接过人工   （人工的评价逻辑）
        //  2.本次会话没有评价过人工
        //  3.没有被拉黑过
        //  4.和人工讲过话
        //  5.仅人工模式，不能评价机器人
        //        [[ZCUICore getUICore] keyboardOnClickSatisfacetion:YES];
        
        if (([self getZCLibConfig].isArtificial || [ZCUICore getUICore].isOffline)
            && ![ZCUICore getUICore].isEvaluationService
            && [ZCUICore getUICore].isSendToUser
            && !([[self getZCLibConfig] isblack]|| [ZCUICore getUICore].isOfflineBeBlack)) {
            // 必须评价
            [self JumpCustomActionSheet:ServerSatisfcationBackType andDoBack:YES isInvitation:1 Rating:5 IsResolved:0];
            
        }else if(![ZCUICore getUICore].isEvaluationRobot
                 && [ZCUICore getUICore].isSendToRobot
                 && ![ZCUICore getUICore].isOffline
                 && [self getZCLibConfig].type !=2
                 && ![self getZCLibConfig].isArtificial){
            // 必须评价
            [self JumpCustomActionSheet:RobotSatisfcationBackType andDoBack:YES isInvitation:1 Rating:5 IsResolved:0];
        }else{
            if ([self.keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
                [[ZCUICore getUICore].listArray removeAllObjects];
            }
            [_listTable reloadData];
            [self goBackIsKeep];
        }
    }
    else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
                [[ZCUICore getUICore].listArray removeAllObjects];
                [_listTable reloadData];
            }
        });
        [self goBackIsKeep];
    }
}


#pragma mark -- 添加快捷入口
- (ZCQuickEntryView *)quickEntryViewWithArray:(NSMutableArray *)array{
    
    // 快捷入口接口 假数据
        if (!_quickEntryView) {
            _quickEntryView = [[ZCQuickEntryView alloc]initCustomViewWith:array WithView:self];
            [_quickEntryView showInView:self];
            _quickEntryView.frame = CGRectMake(0,CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame)- 40, viewWidth, 40);
            __weak ZCChatView * safeView = self;
            _quickEntryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            _quickEntryView.quickClickBlock = ^(ZCLibCusMenu *itemModel) {
             
                if (itemModel.url.length) {
                    [safeView cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:zcLibConvertToString(itemModel.url)];
                }
            };
        }
//        [ZCUICore getUICore].isDismissRobotPage = NO;
        return  _quickEntryView;
}


-(void)setUI{
    viewWidth  = self.frame.size.width;
    viewHeight = self.frame.size.height;
    if (_hideTopViewNav) {
        [self createTitleView];
    }
    
    _listTable = [[UITableView alloc] init];
    [self setFrameForListTable:1];
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    _listTable.delegate = self;
    _listTable.dataSource = self;
    
    [_listTable registerClass:[ZCRichTextChatCell class] forCellReuseIdentifier:cellRichTextIdentifier];
    [_listTable registerClass:[ZCImageChatCell class] forCellReuseIdentifier:cellImageIdentifier];
    [_listTable registerClass:[ZCVoiceChatCell class] forCellReuseIdentifier:cellVoiceIdentifier];
    [_listTable registerClass:[ZCTipsChatCell class] forCellReuseIdentifier:cellTipsIdentifier];
    [_listTable registerClass:[ZCGoodsCell class] forCellReuseIdentifier:cellGoodsIndentifier];
    [_listTable registerClass:[ZCSatisfactionCell class] forCellReuseIdentifier:cellSatisfactionIndentifier];
    [_listTable registerClass:[ZCHorizontalRollCell class] forCellReuseIdentifier:cellHorizontalRollIndentifier];
    [_listTable registerClass:[ZCVerticalRollCell class] forCellReuseIdentifier:cellVerticalRollIndentifier];
    [_listTable registerClass:[ZCMultiItemCell class] forCellReuseIdentifier:cellMultilItemIndentifier];
    [_listTable registerClass:[ZCMultiRichCell class] forCellReuseIdentifier:cellMultiRichIdentifier];
    [_listTable registerClass:[ZCHotGuideCell  class] forCellReuseIdentifier:cellHotGuideIdentifier];
    [_listTable registerClass:[ZCTextGuideCell class] forCellReuseIdentifier:cellTextCellIdentifier];
    [_listTable registerClass:[ZCFileCell class] forCellReuseIdentifier:cellFileIndentifier];
    [_listTable registerClass:[ZCLocationCell class] forCellReuseIdentifier:cellLocationIndentifier];
    [_listTable registerClass:[ZCNoticeCell class] forCellReuseIdentifier:cellNoticeCellIdentifier];
    [_listTable registerClass:[ZCInfoCardCell class] forCellReuseIdentifier:cellCardCellIdentifier];
    [_listTable setSeparatorColor:[UIColor clearColor]];
    [_listTable setBackgroundColor:[UIColor clearColor]];
    _listTable.clipsToBounds=NO;
    _listTable.estimatedRowHeight = 0;
    _listTable.estimatedSectionFooterHeight = 0;
    
    //一定要插入到最底部，不然自定义导航会被覆盖
    [self insertSubview:_listTable atIndex:0];
    
//     NSLog(@"列表的frame %@",NSStringFromCGRect(_listTable.frame));
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_listTable setTableFooterView:view];

    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.attributedTitle = nil;
    [self.refreshControl addTarget:self action:@selector(getHistoryMessage) forControlEvents:UIControlEventValueChanged];
    [_listTable addSubview:_refreshControl];


    _netWorkTools = [ZCLibNetworkTools shareNetworkTools];

    _keyboardTools = [[ZCUIKeyboard alloc] initConfigView:self table:_listTable];
    if (_superController.navigationController.navigationBarHidden || !_superController.navigationController.navigationBar.translucent) {
        _keyboardTools.isNavcHide = !_hideTopViewNav;  // 同步处理键盘的高度
    }
    if (!_superController.navigationController.navigationBarHidden) {
        _keyboardTools.isTranslucent = _superController.navigationController.navigationBar.translucent;
    }
    
    [_keyboardTools handleKeyboard];
    
    __weak ZCChatView *safeSelf = self;
    _keyboardTools.scrollTableToBottomBlock = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [safeSelf keyboardscrollTableToBottom];
        });
    };

    // 通道保护
    if([self getZCLibConfig] && [self getZCLibConfig].isArtificial){
        [[ZCIMChat getZCIMChat] checkConnected:NO];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChanged:) name:ZCNotification_NetworkChange object:nil];
    [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateActive];


    // TODO 需要初始化接口返回的数据
    [self changeRobotBtn];

    if([[ZCUICore getUICore] PageLoadBlock]){
        // 通知外部可以更新UI
        [ZCUICore getUICore].PageLoadBlock(self,ZCPageBlockLoadFinish);
    }
    // 添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appBecomeActive:(NSNotification*)sender{
    [self beginAniantions];
}

-(void)setFrameForListTable:(int)isAdd{
    CGRect LF = CGRectMake(0, 0, viewWidth, viewHeight  - 48 );
    if (_hideTopViewNav) {
        LF =  CGRectMake(0, NavBarHeight, viewWidth, viewHeight  - 48 - NavBarHeight);
    }
    // 快捷回复单独处理
    if (isAdd == 0) {
        LF.size.height = LF.size.height - 40;
    }
    
    [_listTable setFrame:LF];
}
#pragma mark -- 滚动到最底部
-(void)keyboardscrollTableToBottom{
    [ZCLogUtils logHeader:LogHeader debug:@"滚动到底部"];
        CGFloat ch=_listTable.contentSize.height;
        CGFloat h=_listTable.bounds.size.height;
        
        CGRect tf         = _listTable.frame;
        CGFloat x = tf.size.height-_listTable.contentSize.height;
        
    CGFloat keyBoardHeight = self.frame.size.height - _keyboardTools.zc_bottomView.frame.origin.y-BottomHeight -([self getZCLibConfig].quickEntryFlag ==1 ? 0 : 0);// 这里需要处理快捷回复的高度  2.7.5修改 高度0 原高度40

    
        if(x > 0){
            if(x<keyBoardHeight){
                tf.origin.y = navHeight - (keyBoardHeight - x)  - BottomHeight;
            }
        }else{
            CGFloat NH = 0;
            if (_superController.navigationController.navigationBarHidden) {
                NH = NavBarHeight;
            }
//            if (ZC_iPhoneX) {
//                NH = NH + 34;
//            }
            tf.origin.y   = NH  -keyBoardHeight;
        }
        _listTable.frame  = tf;
        
        if(ch > h){
            [_listTable setContentOffset:CGPointMake(0, ch-h) animated:NO];
        }else{
            [_listTable setContentOffset:CGPointMake(0, 0) animated:NO];
        }    
}



-(UIButton *)changeRobotBtn{
    if (!_changeRobotBtn) {
        _changeRobotBtn = [ZCButton buttonWithType:UIButtonTypeCustom];
        _changeRobotBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _changeRobotBtn.type = 3;
        [_changeRobotBtn setFrame:CGRectMake(viewWidth - 48, CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame) - 48 - 20 , 48, 48)];
        [_changeRobotBtn setTitle:ZCSTLocalString(@"切换业务") forState:UIControlStateNormal];
        [_changeRobotBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_changerobot"] forState:UIControlStateNormal];
        [_changeRobotBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_changeRobotBtn.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [_changeRobotBtn setTitleColor:UIColorFromRGB(0x858f90) forState:UIControlStateNormal];
        _changeRobotBtn.titleLabel.font = [UIFont systemFontOfSize:9];
        _changeRobotBtn.layer.cornerRadius = 10;
        _changeRobotBtn.layer.borderWidth = 0.75f;
        _changeRobotBtn.layer.borderColor = [ZCUITools zcgetBackgroundBottomColor].CGColor;
//        _changeRobotBtn.layer.masksToBounds = YES;
        [_changeRobotBtn setBackgroundColor:[UIColor whiteColor]];
        _changeRobotBtn.tag = BUTTON_TURNROBOT;
        _changeRobotBtn.layer.shadowOffset = CGSizeMake(0, 1);
        _changeRobotBtn.layer.shadowOpacity = 0.8;
//        _changeRobotBtn.layer.shadowRadius = 3;
        _changeRobotBtn.layer.shadowColor = UIColorFromRGB(0x858f90).CGColor;
        [_changeRobotBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changeRobotBtn];
        _changeRobotBtn.hidden = YES;
    }
    return  _changeRobotBtn;
}

-(UIButton *)goUnReadButton{
    if(!_goUnReadButton){
        _goUnReadButton=[UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnY = 40;
        if (_superController.navigationController.navigationBarHidden) {
            btnY = NavBarHeight + 40;
        }
        [_goUnReadButton setFrame:CGRectMake(viewWidth - 120, btnY, 140, 40)];
        [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_newmessages"] forState:UIControlStateNormal];
        [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_newmessages"] forState:UIControlStateHighlighted];
        
        [_goUnReadButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_goUnReadButton setTitleColor:[ZCUITools zcgetDynamicColor] forState:UIControlStateNormal];
        [_goUnReadButton.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [_goUnReadButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_goUnReadButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _goUnReadButton.layer.cornerRadius = 20;
        _goUnReadButton.layer.borderWidth = 0.75f;
        _goUnReadButton.layer.borderColor = [ZCUITools zcgetBackgroundBottomColor].CGColor;
        _goUnReadButton.layer.masksToBounds = YES;
        [_goUnReadButton setBackgroundColor:[UIColor whiteColor]];
        _goUnReadButton.tag = BUTTON_UNREAD;
        [_goUnReadButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_goUnReadButton];
        _goUnReadButton.hidden=YES;
    }
    return _goUnReadButton;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (viewWidth != self.frame.size.width && viewHeight != self.frame.size.height) {
        viewWidth  = self.frame.size.width;
        viewHeight = self.frame.size.height;
        
        // iphoneX 横屏需要单独处理
        CGFloat LW = viewWidth;
        
        CGRect LF = CGRectMake(0, navHeight, LW, viewHeight - navHeight - 48 );
//        if (_hideTopViewNav) {
//            LF =  CGRectMake(0, 0, LW, viewHeight  - 48 - (ZC_iPhoneX?34:0));
//        }
        
        if ([self getZCLibConfig].quickEntryFlag == 1) {
            LF.size.height = LF.size.height - 40;
        }
        [_listTable setFrame:LF];
        // 重新设置表情键盘的高度
        [_keyboardTools hideKeyboard];
        _keyboardTools.zc_sourceView = self;
        [_listTable reloadData];
        
        // iPhone X的导航栏需要 刷新 横竖屏切换
        _backButton.frame = CGRectMake(0, NavBarHeight-44, 64, 44);
        [self.moreButton setFrame:CGRectMake(self.frame.size.width-74, NavBarHeight-44, 74, 44)];
        self.titleLabel.frame = CGRectMake(80, NavBarHeight-44, self.frame.size.width- 80*2, 44);
    }
    
   
    
    navHeight = NavBarHeight;
    if(!_hideTopViewNav){
        _topView.hidden = YES;
        navHeight = 0;
    }
    // 添加头部信息
    [_topView setFrame:CGRectMake(0, 0, viewWidth, navHeight)];
    
    if (self.sheet !=nil) {
        self.sheet.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    }
    
    if (_quickEntryView != nil && ([self getZCLibConfig].quickEntryFlag == 1 || [ZCUICore getUICore].kitInfo.cusMenuArray.count>0)) {
        _quickEntryView.frame = CGRectMake(0,CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame)- 40, viewWidth, 40);
    }

}



// 页面点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    
    if (self.superController.navigationController.navigationBarHidden) {
        if(sender.tag == BUTTON_MORE){
            [_keyboardTools hideKeyboard];
            ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"清空聊天记录"), nil];
            mysheet.selectIndex = 1;
            [mysheet show];
            
        }
        if (sender.tag == BUTTON_BACK) {
            [self confimGoBackWithType:ZCChatViewGoBackType_normal];
        }
        
        if(sender.tag == BUTTON_CLOSE){
            [self confimGoBackWithType:ZCChatViewGoBackType_close];
        }
        
        if (sender.tag == BUTTON_EVALUATION) {
            [[ZCUICore getUICore] keyboardOnClickSatisfacetion:NO];
        }
        
        if (sender.tag == BUTTON_TEL) {
            NSString *phoneNumber = [NSString stringWithFormat:@"tel:%@",zcLibConvertToString([ZCUICore getUICore].kitInfo.customTel)];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];

        }
        
        
    }
    
    // 未读消息数
    if(sender.tag == BUTTON_UNREAD){
        self.goUnReadButton.hidden = YES;
        int unNum = [[ZCIMChat getZCIMChat] getUnReadNum];
        if(unNum<=[ZCUICore getUICore].chatMessages.count){
            CGRect  popoverRect = [_listTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:([ZCUICore getUICore].chatMessages.count - unNum) inSection:0]];
            [_listTable setContentOffset:CGPointMake(0,popoverRect.origin.y-40) animated:NO];
        }
        
    }
    
    // 切换机器人
    if (sender.tag == BUTTON_TURNROBOT) {
        
        
        [_keyboardTools hideKeyboard];
        if (![ZCUICore getUICore].isDismissRobotPage) {
            return;
        }
         __weak  ZCChatView * safeView = self;
        [[ZCLibServer getLibServer] getrobotlist:[self getPlatformInfo].config start:^{
            
        } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
            
             @try{
                 NSMutableArray * listaArr = [NSMutableArray arrayWithCapacity:0];
                 NSArray * arr = dict[@"data"][@"list"];
                 if (arr.count == 0) {
                     return ;
                 }
                for (NSDictionary * Dic in arr) {
                    ZCLibRobotSet * model = [[ZCLibRobotSet alloc]initWithMyDict:Dic];
                    [listaArr addObject:model];
                }
                 
                
                ZCTurnRobotView * robotView = [[ZCTurnRobotView alloc]initActionSheet:listaArr WithView:self RobotId:[safeView getPlatformInfo].config.robotFlag];
         
                [robotView showInView:self];
                 [ZCUICore getUICore].isDismissRobotPage = NO;
               
                robotView.robotSetClickBlock = ^(ZCLibRobotSet *itemModel) {
                    
                    if (itemModel == nil) {
                        [ZCUICore getUICore].isDismissRobotPage = YES;
                        return ;
                    }
                    if ([itemModel.robotFlag intValue] == [safeView getZCLibConfig].robotFlag) {
                        return ;
                    }else{
                        [safeView getPlatformInfo].config.robotFlag = [itemModel.robotFlag intValue];
                        [safeView getZCLibConfig].robotName = itemModel.robotName;
                        [safeView getZCLibConfig].robotLogo = itemModel.robotLog;
                        // 添加机器人欢迎语 和热点引导
                        [ZCLibClient getZCLibClient].libInitInfo.robotId = itemModel.robotFlag;
                        [ZCLibClient getZCLibClient].libInitInfo.avatarUrl = itemModel.robotLog;
                        [self getPlatformInfo].config.robotName = itemModel.robotName;
                        // 切换机器人，切换每个机器人的欢迎语
                        [self getPlatformInfo].config.robotHelloWord = itemModel.robotHelloWord;
                        if(itemModel.guideFlag){
                            [self getPlatformInfo].config.guideFlag = 1;
                        }else{
                            [self getPlatformInfo].config.guideFlag = 0;
                        }
                        
                        [[ZCUICore getUICore] changeRobotBtnClickAddRobotHelloWolrd];
                    
                        [ZCUICore getUICore].isSendToRobot = NO;
                        [ZCUICore getUICore].isEvaluationRobot = NO;
                        
                    }
                    
                };
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
            NSLog(@"%@",errorMsg);
        }];
        
        
    }
}

#pragma mark -- 点击评价
-(void)JumpCustomActionSheet:(int) sheetType andDoBack:(BOOL) isBack isInvitation:(int) invitationType Rating:(int)rating IsResolved:(int)isResolve{
    [_keyboardTools hideKeyboard];
    _sheet = [[ZCUICustomActionSheet alloc] initActionSheet:sheetType Name:[ZCUICore getUICore].receivedName Cofig:[self getZCLibConfig] cView:self IsBack:isBack isInvitation:invitationType WithUid:[self getZCLibConfig].uid IsCloseAfterEvaluation:[ZCUICore getUICore].kitInfo.isCloseAfterEvaluation Rating:rating IsResolved:isResolve IsAddServerSatifaction:[ZCUICore getUICore].isAddServerSatifaction];
    _sheet.delegate=self;
    [_sheet showInView:self];
    [ZCUICore getUICore].isDismissSheetPage = NO;
}


- (void)thankFeedBack:(int)type rating:(float)rating IsResolve:(int)isresolve{
    [[ZCUICore getUICore] thankFeedBack:type rating:rating IsResolve:isresolve];
    // 邀请评价 1-4星 点击提交后  判断是否开启 评价完人工结束会话
    [[ZCUICore getUICore] thankFeedBack];
    
}

-(void)dimissCustomActionSheetPage{
    _sheet = nil;
    [ZCUICore getUICore].isDismissSheetPage = YES;
}

//获取当前window
- (UIWindow *)mainWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)])
    {
        return [app.delegate window];
    }
    else
    {
        return [app keyWindow];
    }
}

-(void)actionSheetClick:(int)isCommentType{
    if (isCommentType != 4) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"感谢您的反馈^-^!") duration:1.0f view:[self mainWindow] position:ZCToastPositionCenter];
//            if(self.superController.navigationController){
//                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"感谢您的反馈^-^!") duration:1.0f view:self.window.rootViewController.view position:ZCToastPositionCenter];
//            }else{
//
//                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"感谢您的反馈^-^!") duration:1.0f view:self.superController.presentingViewController.view position:ZCToastPositionCenter];
//            }
            
        });
    }
    
    if(isCommentType == 1){
          // 评价完成后 结束会话
        [[ZCUICore getUICore] thankFeedBack];

//       [[ZCLibServer getLibServer] logOut:[[ZCPlatformTools sharedInstance] getPlatformInfo].config];
//        [[ZCLibClient getZCLibClient] closeIMConnection];
//        [ZCUICore getUICore].isSayHello = NO;
//        [ZCUICore getUICore].isShowRobotHello = NO;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self goBackIsKeep];
//        });
    }else if(isCommentType == 0){
        if ([self.keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
            [[ZCUICore getUICore].listArray removeAllObjects];
            [_listTable reloadData];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goBackIsKeep];
        });
    
    }else if (isCommentType == 3){
        [[ZCUICore getUICore] thankFeedBack];
    }else if(isCommentType == 4){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goBackIsKeep];
        });
    }else if (isCommentType == 5){
        // 评价完成后 结束会话
        [[ZCUICore getUICore] thankFeedBack];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goBackIsKeep];
        });
        
    }else{
        // 关闭了评价页面
    }
    
}


- (void)cellItemClick:(int)satifactionType IsResolved:(int)isResolved Rating:(int)rating{
    if (satifactionType == 1) {
        // 弹评价页面
        [[ZCUICore getUICore] CustomActionSheet:ServerSatisfcationInviteType andDoBack:NO isInvitation:0 Rating:rating IsResolved:isResolved];
        
    }else{
        // 提交评价
        [[ZCUICore getUICore] commitSatisfactionWithIsResolved:isResolved Rating:rating];
    }
}



#pragma mark 音频播放设置
-(void)voicePlayStatusChange:(ZCVoicePlayStatus)status{
    switch (status) {
        case ZCVoicePlayStatusReStart:
            if([ZCUICore getUICore].animateView){
                [[ZCUICore getUICore].animateView startAnimating];
            }
            break;
        case ZCVoicePlayStatusPause:
            if([ZCUICore getUICore].animateView){
                [[ZCUICore getUICore].animateView stopAnimating];
                
            }
            break;
        case ZCVoicePlayStatusStartError:
            if([ZCUICore getUICore].animateView){
                [[ZCUICore getUICore].animateView stopAnimating];
            }
            break;
        case ZCVoicePlayStatusFinish:
        case ZCVoicePlayStatusError:
            if([ZCUICore getUICore].animateView){
                [[ZCUICore getUICore].animateView stopAnimating];
                [ZCUICore getUICore].animateView=nil;
                
                [ZCUICore getUICore].playModel.isPlaying=NO;
                [ZCUICore getUICore].playModel=nil;
            }
            break;
        default:
            break;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_keyboardTools hideKeyboard];
    // 隐藏复制小气泡
    [[NSNotificationCenter defaultCenter] postNotificationName:UIMenuControllerDidHideMenuNotification object:nil];
}

#pragma mark 网络链接改变时会调用的方法
-(void)netWorkChanged:(NSNotification *)note
{
    BOOL isReachable = _netWorkTools.isZCReachable;
    if(!isReachable){
        self.newWorkStatusButton.hidden=NO;
        [_listTable setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
        
        if([self getZCLibConfig]==nil){
            [[ZCUILoading shareZCUILoading] showAddToSuperView:self];
        }
//        [self insertSubview:_newWorkStatusButton aboveSubview:_notifitionTopView];
        [self bringSubviewToFront:_newWorkStatusButton];
    }else{
        self.newWorkStatusButton.hidden=YES;
        [_listTable setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        // 初始化数据
        if([self getZCLibConfig]==nil && [@"" isEqual:zcLibConvertToString([self getZCLibConfig].cid)] && ![ZCUICore getUICore].isInitLoading){
            [[ZCUICore getUICore] initConfigData:YES IsNewChat:NO];
        }
    }
}


// 长连接通道发生变化时显示连接状态
-(void)showSoketConentStatus:(ZCConnectStatusCode)status{
    // 连接中
    if(status == ZC_CONNECT_START){
        UIButton *btn = [self socketStatusButton];
        [btn setTitle:[NSString stringWithFormat:@"  %@",ZCSTLocalString(@"收取中...")] forState:UIControlStateNormal];
        UIActivityIndicatorView *activityView  = [btn viewWithTag:1];
        btn.hidden = NO;
        activityView.hidden = NO;
        [activityView startAnimating];
        
        isStartConnectSockt = YES;
        
    }else{
        isStartConnectSockt = NO;
        
        UIButton *btn = [self socketStatusButton];
        UIActivityIndicatorView *activityView  = [btn viewWithTag:1];
        [activityView stopAnimating];
        activityView.hidden = YES;
        
        if(status == ZC_CONNECT_SUCCESS){
            btn.hidden = YES;
        }else{
            [btn setTitle:[NSString stringWithFormat:@"%@",ZCSTLocalString(@"未连接")] forState:UIControlStateNormal];
        }
    }
}

// 接收链接改变
-(void)onConnectStatusChanged:(ZCConnectStatusCode)status{
    
    if(status == ZC_CONNECT_KICKED_OFFLINE_BY_OTHER_CLIENT){
        if(self.superController.navigationController){
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self.window.rootViewController.view position:ZCToastPositionCenter];
        }else{
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self position:ZCToastPositionCenter];
        }
    }else{
        [self showSoketConentStatus:status];
    }
}

-(void)goBackIsKeep{
    [ZCLibClient getZCLibClient].isShowTurnBtn = NO;
    [ZCUICore getUICore].unknownWordsCount = 0;
    
    NSInteger keyboardtype = [self.keyboardTools getKeyBoardViewStatus];
    if (_keyboardTools) {
        [_keyboardTools removeKeyboardObserver];
        _keyboardTools = nil;
    }
    if (_voiceTools) {
        [_voiceTools stopVoice];
        _voiceTools.delegate = nil;
        _voiceTools = nil;
    }
    
    if (_netWorkTools) {
        [_netWorkTools removeNetworkObserver];
        _netWorkTools = nil;
    }
    
    if ([ZCUICore getUICore].lineModel) {
        [[ZCUICore getUICore].listArray removeObject:[ZCUICore getUICore].lineModel];
    }
    
    @try{ 
        if([ZCUICore getUICore].listArray && [ZCUICore getUICore].listArray.count>0){
            ZCLibMessage *lastMsg = [[ZCUICore getUICore].listArray lastObject];
            if(lastMsg.tipStyle>0){
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastMsg = lastMsg.sysTips;
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastDate = lastMsg.ts;
            } else {
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastMsg = lastMsg.richModel.msg;
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastDate = lastMsg.ts;
            }
        }
        [[ZCUICore getUICore] clearData];
        [ZCUICore getUICore].isAddNotice = NO;
        // 如果通道没有建立成功，当前正在链接中  则清空数据，下次重新初始化  2. 当前会话键盘是新会话键盘，返回时清空数据 重新初始化
        if(isStartConnectSockt || keyboardtype == ZCKeyboardStatusNewSession){
            [self getPlatformInfo].cidsArray = nil;
            
            [self getPlatformInfo].messageArr = nil;
        }else{
            [self getPlatformInfo].cidsArray = [ZCUICore getUICore].cids;
            [self getPlatformInfo].messageArr = [ZCUICore getUICore].listArray;
        }
        
        [ZCUICore getUICore].cids = nil;
        [ZCUICore getUICore].listArray = nil;
        [[ZCPlatformTools sharedInstance] savePlatformInfo:[self getPlatformInfo]];
        
        [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateBack];
        
        if([ZCUICore getUICore].PageLoadBlock){
            [ZCUICore getUICore].PageLoadBlock(self,ZCPageBlockGoBack);
        }
        
        // 离线用户，关闭通道
        if(isClickCloseBtn){
            [ZCLibClient closeAndoutZCServer:NO];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(topViewBtnClick:)]) {
            [self.delegate topViewBtnClick:Btn_BACK];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}


-(void)createTitleView{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, NavBarHeight)];
    [self.topView setBackgroundColor:[ZCUITools zcgetDynamicColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
        [self.topView setBackgroundColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
    [_topView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [_topView setAutoresizesSubviews:YES];
    [self addSubview:self.topView];
    
    
    // 用户自定义背景图片
    self.topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, NavBarHeight)];
    [self.topImageView setBackgroundColor:[UIColor clearColor]];
    
    // 如果用户传图片就添加，否则取导航条的默认颜色。
    if ([ZCUITools zcuiGetBundleImage:@"zcicon_navcbgImage"]) {
        [self.topImageView setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_navcbgImage"]];
        [_topImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
        self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_topImageView setAutoresizesSubviews:YES];
    }
    //    [self.topView addSubview:self.topImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, NavBarHeight-44, self.frame.size.width- 80*2, 44)];
    [self.titleLabel setFont:[ZCUITools zcgetTitleFont]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[ZCUITools zcgetTopViewTextColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.titleLabel setAutoresizesSubviews:YES];
    
    [self.topView addSubview:self.titleLabel];
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(0, NavBarHeight-44, 64, 44)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_pressed"] forState:UIControlStateHighlighted];
    
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg).length >0) {
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)] forState:UIControlStateNormal];
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg).length >0) {
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg)] forState:UIControlStateHighlighted];
    }
    
    [self.backButton setBackgroundColor:[UIColor clearColor]];
    if ([ZCUICore getUICore].kitInfo.topBackNolColor != nil ) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor: [ZCUICore getUICore].kitInfo.topBackNolColor]  forState:UIControlStateNormal];
    }
    if ([ZCUICore getUICore].kitInfo.topBackSelColor != nil) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.backButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setAutoresizesSubviews:YES];
    [self.backButton setTitle:ZCSTLocalString(@"返回") forState:UIControlStateNormal];
    if ([ZCUICore getUICore].kitInfo.topBackTitle != nil) {
      [self.backButton setTitle:[ZCUICore getUICore].kitInfo.topBackTitle forState:UIControlStateNormal];
    }
    
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.backButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.backButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.topView addSubview:self.backButton];
    self.backButton.tag = BUTTON_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
   
   
    
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(self.frame.size.width-74, NavBarHeight-44, 74, 44)];
    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.moreButton setAutoresizesSubviews:YES];
    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setTitle:@"" forState:UIControlStateNormal];
    [self.moreButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.moreButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg).length >0) {
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg)]  forState:UIControlStateNormal];
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg).length >0) {
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg)]  forState:UIControlStateHighlighted];
    }
    [self.topView addSubview:self.moreButton];
    self.moreButton.tag = BUTTON_MORE;
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if ([ZCUICore getUICore].kitInfo.isShowEvaluation || [ZCUICore getUICore].kitInfo.isShowTelIcon ) {
        
        [self.moreButton setFrame:CGRectMake(self.frame.size.width-44, NavBarHeight-44, 44, 44)];
        
        self.titleLabel.frame = CGRectMake(100, NavBarHeight-44, self.frame.size.width- 80*2.5, 44);
        self.evaluationBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.evaluationBtn setFrame:CGRectMake(self.frame.size.width-44*2, NavBarHeight-44, 44, 44)];
        [self.evaluationBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.evaluationBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.evaluationBtn setContentEdgeInsets:UIEdgeInsetsZero];
        [self.evaluationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.evaluationBtn setAutoresizesSubviews:YES];
        [self.evaluationBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
        [self.evaluationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//        [self.evaluationBtn setTitle:@"评价" forState:UIControlStateNormal];
        [self.evaluationBtn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
        [self.evaluationBtn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        if ([ZCUICore getUICore].kitInfo.isShowEvaluation) {
            [self.evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_evaluate"] forState:UIControlStateNormal];
            [self.evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_evaluate"] forState:UIControlStateHighlighted];
            self.evaluationBtn.tag = BUTTON_EVALUATION;
        }
        if([ZCUICore getUICore].kitInfo.isShowTelIcon){
            [self.evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_call_icon"] forState:UIControlStateNormal];
            [self.evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_call_icon"] forState:UIControlStateHighlighted];
            self.evaluationBtn.tag = BUTTON_TEL;
        }
        
        [self.topView addSubview:self.evaluationBtn];
        [self.evaluationBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if ([ZCUICore getUICore].kitInfo.isShowClose || [ZCUICore getUICore].kitInfo.isShowClose ) {
       
        [self.moreButton setFrame:CGRectMake(self.frame.size.width-44*2, NavBarHeight-44, 44, 44)];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setFrame:CGRectMake(self.frame.size.width-44, NavBarHeight-44, 44, 44)];
        [self.closeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.closeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.closeButton setContentEdgeInsets:UIEdgeInsetsZero];
        [self.closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self.closeButton setAutoresizesSubviews:YES];
//        [self.closeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//        [self.closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
        //        [self.evaluationBtn setTitle:@"评价" forState:UIControlStateNormal];
        [self.closeButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
        [self.closeButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        [self.closeButton setTitle:ZCSTLocalString(@"关闭") forState:0];
        self.closeButton.tag = BUTTON_CLOSE;
        
        
        [self.topView addSubview:self.closeButton];
        [self.closeButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}


-(void)dealloc{
    NSLog(@"chatView页面销毁");
}
#pragma mark -- 先处理是否显示 切换留言模板

-(void)changeLeaveMsgType:(LeaveExitType) isExist{
    
[_keyboardTools hideKeyboard];
    
    //先判定 留言的方式 转离线留言
    if ([self getZCLibConfig].msgToTicketFlag == 2) {
        if (_delegate && [_delegate respondsToSelector:@selector(onLeaveMsgClick:)] && _isJumpCustomLeaveVC) {
            [_delegate onLeaveMsgClick:[self getZCLibConfig].msgLeaveTxt];
            return;
        }
        
        ZCLeaveMsgVC *vc = [[ZCLeaveMsgVC alloc]init];
        vc.msgTxt = [self getZCLibConfig].msgLeaveTxt;
        vc.msgTmp = [self getZCLibConfig].msgLeaveContentTxt;
        
        vc.passMsgBlock = ^(NSString *msg) {
          // 发送离线消息 （只是本地数据的展示，不可发给机器人或者人工客服）

            ZCLibMessage * libMessage =  [[ZCUICore getUICore] setLocalDataToArr:ZCTIPCellMessageOrderLeave type:0 duration:0 style:0 send:YES name:@"" content:msg config:[self getZCLibConfig]];
            libMessage.leaveMsgFlag = 1;
            libMessage.sendStatus = 0;
            
            ZCLibMessage *tipMsg = [[ZCUICore getUICore] setLocalDataToArr:ZCTipCellMessageLeaveSuccess type:0 duration:0 style:ZCTipCellMessageLeaveSuccess send:NO name:@"" content:@"" config:[self getZCLibConfig]];
            [[ZCUICore getUICore].listArray addObject:libMessage];
            [[ZCUICore getUICore].listArray addObject:tipMsg];
            [self.listTable reloadData];
            [self scrollTableToBottom];
        };
        
         [self openNewPage:vc];
        return;
    }
    
    
// 1. 开关是否开启
    
    [[ZCLibServer getLibServer] getWsTemplateList:[self getZCLibConfig] start:^{
        [[ZCUIToastTools shareToast] showProgress:@"" with:self];
    } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
        [[ZCUIToastTools shareToast] dismisProgress];
        if (dict != nil && [zcLibConvertToString(dict[@"code"]) intValue] == 1) {
            NSArray * arr = dict[@"data"];
            if (arr.count > 0) {
                NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
                //
                for (NSDictionary * item in arr) {
                    ZCWsTemplateModel * model = [[ZCWsTemplateModel alloc]initWithMyDict:item];
                    [array addObject:model];
                }
                 __weak ZCChatView * saveSelf = self;
                
                if (arr.count == 1) {
                    ZCWsTemplateModel * model = [array lastObject];
                    NSDictionary * Dic = @{@"templateId":zcLibConvertToString(model.templateId)};
                    
                    [saveSelf jumpNewPageVC:ZC_LeaveMsgPage IsExist:isExist isShowToat:NO tipMsg:@"" Dict:Dic];
                }else{
                    // 2.掉接口 布局UI
                    ZCSelLeaveView * selMsgView = [[ZCSelLeaveView alloc]initActionSheet:array  WithView:self MsgID:[self getPlatformInfo].config.robotFlag IsExist:isExist];
                    
                    [selMsgView showInView:self];
                   
                    selMsgView.msgSetClickBlock = ^(ZCWsTemplateModel * _Nonnull itemModel) {
                
                        NSDictionary * Dic = @{@"templateId":zcLibConvertToString(itemModel.templateId)};
                        [saveSelf jumpNewPageVC:ZC_LeaveMsgPage IsExist:isExist isShowToat:NO tipMsg:@"" Dict:Dic];
                    };
                }
                
            }else{
                [self jumpNewPageVC:ZC_LeaveMsgPage IsExist:isExist isShowToat:NO tipMsg:@"" Dict:nil];
            }

         }
      
     } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
          [[ZCUIToastTools shareToast] showToast:errorMsg duration:1.5 view:self position:ZCToastPositionCenter];
    }];
    
}

@end
