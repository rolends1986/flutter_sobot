//
//  ZCUILeaveMessageController.m
//  SobotKit
//
//  Created by lizhihui on 16/1/21.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCUILeaveMessageController.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIPlaceHolderTextView.h"
#import "ZCLibServer.h"
#import "ZCUIConfigManager.h"
#import "ZCIMChat.h"
#import "ZCMLEmojiLabel.h"
#import "ZCUIWebController.h"
#import "ZCStoreConfiguration.h"

#import "ZCXJAlbumController.h"
#import "ZCSobotCore.h"
#import "ZCActionSheet.h"

#import "ZCUILoading.h"

#import "ZCOrderEditCell.h"
#import "ZCOrderCheckCell.h"
#import "ZCOrderContentCell.h"
#import "ZCOrderCreateCell.h"
#import "ZCOrderOnlyEditCell.h"
#define cellCheckIdentifier @"ZCOrderCheckCell"
#define cellEditIdentifier @"ZCOrderEditCell"
#define cellOrderContentIdentifier @"ZCOrderContentCell"
#define cellOrderSwitchIdentifier @"ZCOrderReplyOpenCell"
#define cellOrderSingleIdentifier @"ZCOrderOnlyEditCell"
#import "ZCLibOrderCusFieldsModel.h"
#import "ZCLibTicketTypeModel.h"
#import "ZCOrderTypeController.h"
#import "ZCLibOrderCusFieldsModel.h"
#import "ZCZHPickView.h"
#import "ZCOrderCusFieldController.h"
//#import "ZCUploadImageModel.h"
#import "ZCLibCommon.h"
#import "ZCPlatformTools.h"

#import "ZCUICore.h"
#import "ZCUIImageTools.h"
#import "ZCMsgDetailsVC.h"
#import "ZCMsgRecordVC.h"

#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

typedef NS_ENUM(NSInteger,ExitType) {
    ISCOLSE         = 1,// 直接退出SDK
    ISNOCOLSE       = 2,// 不直接退出SDK
    ISBACKANDUPDATE = 3,// 仅人工模式 点击技能组上的留言按钮后,（返回上一页面 提交退出SDK）
    ISROBOT         = 4,// 机器人优先，点击技能组的留言按钮后，（返回技能组 提交和机器人会话）
    ISUSER          = 5,// 人工优先，点击技能组的留言按钮后，（返回技能组 提交机器人会话）
};

@interface ZCUILeaveMessageController ()<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,ZCMLEmojiLabelDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,ZCActionSheetDelegate,ZCXJAlbumDelegate,UITableViewDataSource,UITableViewDelegate,ZCZHPickViewDelegate,ZCOrderCreateCellDelegate>
{
 
    
    CGRect scFrame  ;
    
    void(^CloseBlock)();// 直接退出
    
    BOOL isLandScape ; // 是否是横屏
    

    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    
    // 呼叫的电话号码
    NSString                    *callURL;
    
    NSMutableArray  *imageURLArr;

    
    ZCLibOrderCusFieldsModel *curEditModel;
    CGPoint        contentoffset;// 记录list的偏移量

    
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    
    UIView *btnBgView; // 选项卡
    
    int  btnTag; // 当前选中的选项卡下标
    UIView *lineView; // 选项卡下面的线条
    UIButton * leftBtn; // 留言选项卡
    UIButton * rightBtn;// 留言记录
    
    UIView * lmsView;// 留言成功后 提示页面
}


@property (nonatomic, assign) BOOL isSend;
/** 系统相册相机图片 */
@property (nonatomic,strong) UIImagePickerController *zc_imagepicker;

@property (nonatomic,strong) UITableView * listTable;

@property (nonatomic,strong) NSMutableArray * listArray;

@property(nonatomic,strong)NSMutableArray   *imageArr;

@property (nonatomic,strong) NSMutableArray * imagePathArr;// 存储本地图片路径
@property(nonatomic,strong)NSMutableArray   *imageReplyArr;

@property(nonatomic,strong)UITextView       *tempTextView;
@property(nonatomic,strong)UITextField      *tempTextField;
@property(nonatomic,assign) BOOL isReplyPhoto;// 是否是回复的图片

@property (nonatomic,strong) ZCZHPickView *pickView; // 日期控件

@property (nonatomic,strong) UIScrollView * mainScrollView;

@property (nonatomic,strong)  ZCMsgRecordVC * mesRecordVC;// 留言记录

@property (nonatomic,strong) UIView * rightView;



@end

@implementation ZCUILeaveMessageController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// 横竖屏切换
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        CGFloat c = viewWidth;
        if(viewWidth > viewHeigth){
            viewWidth = viewHeigth;
            viewHeigth = c;
        }
    }else{
        CGFloat c = viewHeigth;
        if(viewWidth < viewHeigth){
            viewHeigth = viewWidth;
            viewWidth = c;
        }
    }
    // 切换的方法必须调用
    [self viewDidLayoutSubviews];
}

//**************************项目中的导航栏一部分是自定义的View,一部分是系统自带的NavigationBar*********************************
- (void)setNavigationBarStyle{
    NSString * img ;
    NSString * selImg;
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg).length >0) {
        img = zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg);
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg).length >0) {
        selImg = zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg);
    }

    [self createLeftBarItemSelect:@selector(goBack) norImageName:img highImageName:selImg];
}

- (void)createLeftBarItemSelect:(SEL)select norImageName:(NSString *)imageName highImageName:(NSString *)heightImageName{
    //12 * 19
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    //    [btn addTarget:self action:select forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 44,44) ;
    if (imageName) {
        [btn setImage:[ZCUITools zcuiGetBundleImage:imageName] forState:UIControlStateNormal];
    }else{
        btn.frame = CGRectMake(0, 0, 44, 44);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
    }
    if (heightImageName) {
        [btn setImage:[ZCUITools zcuiGetBundleImage:heightImageName] forState:UIControlStateHighlighted];
    }else{
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_pressed"] forState:UIControlStateHighlighted];
    }
    
    if ([ZCUICore getUICore].kitInfo.topBackNolColor != nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackNolColor] forState:UIControlStateNormal];
    }
    if ([ZCUICore getUICore].kitInfo.topBackSelColor != nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
    
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateDisabled];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    btn.tag = BUTTON_BACK;
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect lf = btn.frame;
    lf.size.width=60;
    [btn setFrame:lf];
    [btn setTitle:ZCSTLocalString(@"返回") forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    //    self.navigationItem.leftBarButtonItem = item;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
    
    /**
     width为负数时，相当于btn向右移动width数值个像素，由于按钮本身和  边界间距为5pix，所以width设为-5时，间距正好调整为0；width为正数 时，正好相反，相当于往左移动width数值个像素
     */
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, item, nil];
    
//    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightBtn.frame = CGRectMake(viewWidth - 60, NavBarHeight - 40, 50, 40);
//    [rightBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
//    rightBtn.titleLabel.font = [ZCUITools zcgetListKitTitleFont];
//    rightBtn.tag = BUTTON_MORE;
//    [rightBtn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
//    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetDynamicColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
       [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    viewHeigth = self.view.frame.size.height;
    viewWidth = self.view.frame.size.width;
    // Do any additional setup after loading the view.
//    [self.navigationController setNavigationBarHidden:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
//    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBar.translucent = NO;
//    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"留言");
        if (self.selectedType == 2) {
             self.title = ZCSTLocalString(@"留言记录");
        }
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    }else{
        [self createTitleView];
        self.titleLabel.text = ZCSTLocalString(@"留言");
        if (self.selectedType == 2) {
            self.titleLabel.text = ZCSTLocalString(@"留言记录");
        }
        // 提交 的button 2.7.1 页面改版 位置改变
        [self.moreButton setImage:nil forState:UIControlStateNormal];
        [self.moreButton setImage:nil forState:UIControlStateHighlighted];
        self.moreButton.tag = 1002;
//        [self.moreButton setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
//        [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        //    self.moreButton.alpha = 0.4;
        //    self.moreButton.userInteractionEnabled = NO;
        
        //back
//        [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
   
    
    self.view.backgroundColor = UIColorFromRGB(0xEFF3FA);
    _listArray = [[NSMutableArray alloc] init];

    // 添加选项卡
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
//    if (self.ticketShowFlag == 1) { // 开启
        [self createTabItemView:Y];
//    }
    
    // 获取用户初始化配置参数  添加子页面
    [self customLayoutSubviewsWith:[ZCUIConfigManager getInstance].kitInfo];
    _isSend = NO;
    
    if (_isShowToat) {
        [[ZCUIToastTools shareToast] showToast:_tipMsg duration:3.0f view:self.view position:ZCToastPositionBottom];
    }
    
    // 布局子页面
    [self refreshViewData];
    
    _model =  [[ZCOrderModel alloc]init];
    // 工单自定义字段和类型接口
//    [self loadDataForPage];
    
    // 设置选中的选项卡
    if (self.selectedType != 2) {
        [leftBtn setTitleColor:UIColorFromRGB(0x16B0B2) forState:UIControlStateNormal];
    }else{
        [self itemsClick:rightBtn];
    }
    
}

#pragma mark -- 添加选项卡

-(void)createTabItemView:(CGFloat) Y{
    NSMutableArray * titleArr = [NSMutableArray arrayWithCapacity:0];
    [titleArr addObject:@"请您留言"];
    [titleArr addObject:@"留言记录"];
    NSMutableArray * tagArr = [NSMutableArray arrayWithCapacity:0];
    [tagArr addObject:@"2001"];
    [tagArr addObject:@"2002"];
    [self createBtnItem:titleArr withTags:tagArr Y:Y];
    
}


-(void)createBtnItem:(NSMutableArray *)titleArr withTags:(NSMutableArray *)tagArr Y:(CGFloat)Y{
    btnBgView = [[UIView alloc]initWithFrame:CGRectMake(0, Y, ScreenWidth, 54)];
    
    // 间距线条
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, ScreenWidth, 10)];
    bottomView.backgroundColor = UIColorFromRGB(0xF0F0F0);
    [btnBgView addSubview:bottomView];
    
    btnBgView.backgroundColor = UIColorFromRGB(TextWhiteColor);
    CGFloat BY = ZCNumber(10);
    CGFloat BW = ZCNumber(100);
    CGFloat BH = ZCNumber(21);
    CGFloat BX = 0;
    for (int i = 0; i< titleArr.count; i++) {
        int tag = [tagArr[i] intValue];
        BX = (ScreenWidth/titleArr.count)/2 + i*(ScreenWidth/titleArr.count) - BW/2;
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(BX, BY, BW, BH);
        btn.tag = tag;
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitle:titleArr[i] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
        [btn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x16B0B2) forState:UIControlStateHighlighted];
        [btnBgView addSubview:btn];
        
        if (i == 0) {
            leftBtn = btn;
        }else if(i == 1){
            rightBtn = btn;
        }
        
    }
    btnTag = [[tagArr firstObject] intValue];
    lineView = [[UIView alloc]initWithFrame:CGRectMake(ZCNumber(11), ZCNumber(41), BW, 3)];
    lineView.backgroundColor = UIColorFromRGB(0x16B0B2);
    CGRect LF = lineView.frame;
    LF.origin.x = leftBtn.frame.origin.x;
    lineView.frame = LF;
    [btnBgView addSubview:lineView];
    [self.view addSubview:btnBgView];
    
}

-(void) itemsClick:(UIButton *)sender{
    
    if (btnTag == sender.tag) {
        return;
    }
    for (id object in [btnBgView subviews]) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)object;
            [btn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        }
    }
    CGRect LF = lineView.frame;
    LF.origin.x = sender.frame.origin.x;
    lineView.frame = LF;
    btnTag = (int)sender.tag;
    [sender setTitleColor:UIColorFromRGB(0x16B0B2) forState:UIControlStateNormal];
    switch (sender.tag) {
        case 2001:
            // 会话统计
//            NSLog(@"添加留言");
            break;
        case 2002:
            // 满意度统计
//            NSLog(@"留言记录");
            break;
        default:
            break;
    }
    
  
    
    // 1.获取当前的页面
    NSInteger index = (NSInteger)(sender.tag - 2001);
    
    // 2.计算偏移量
    CGPoint offSetPoint = CGPointMake(index *_mainScrollView.bounds.size.width, 0);
    
    // 3。将偏移量赋值给scrollerView
    [_mainScrollView setContentOffset:offSetPoint animated:YES];
    
}
#pragma mark --- 选项卡 end -------

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

-(void)loadDataForPage{
    
//    __weak ZCUILeaveMessageController *selfVC = self;
//
//    NSString * templateId = _templateldIdDic[@"templateId"] ;
//    [[[ZCUIConfigManager getInstance] getZCAPIServer] postMsgTemplateConfigWithUid:[self getCurConfig].uid Templateld:templateId start:^{
//        
//    } success:^(NSDictionary *dict,NSMutableArray * typeArr, ZCNetWorkCode sendCode) {
//        _tickeTypeFlag = [ zcLibConvertToString( dict[@"data"][@"item"][@"ticketTypeFlag"] )intValue];
//        _ticketTypeId = zcLibConvertToString( dict[@"data"][@"item"][@"ticketTypeId"]);
//        _telFlag = [zcLibConvertToString( dict[@"data"][@"item"][@"telFlag"]) boolValue];
//        _telShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"telShowFlag"]) boolValue];
//        _emailFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"emailFlag"]) boolValue];
//        _emailShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"emailShowFlag"]) boolValue];
//        _enclosureFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"enclosureFlag"]) boolValue];
//        _enclosureShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"enclosureShowFlag"]) boolValue];
//        _ticketShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"ticketShowFlag"]) intValue];
//        _msgTmp = zcLibConvertToString(dict[@"data"][@"item"][@"msgTmp"]);
//        _msgTxt = zcLibConvertToString(dict[@"data"][@"item"][@"msgTxt"]);
//        if (typeArr.count) {
//            if (_typeArr == nil) {
//                _typeArr = [NSMutableArray arrayWithCapacity:0];
//                _typeArr = typeArr;
//            }
//        }
//        
//        [selfVC refreshViewData];
//    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
//        
//    }];
//    
//    [[[ZCUIConfigManager getInstance] getZCAPIServer] postTemplateFieldInfoWithUid:[self getCurConfig].uid Templateld:templateId start:^{
//        
//    } success:^(NSDictionary *dict,NSMutableArray * cusFieldArray, ZCNetWorkCode sendCode) {
//        @try{
//            if (cusFieldArray.count) {
//                if (_coustomArr == nil) {
//                    _coustomArr = [NSMutableArray arrayWithCapacity:0];
//                    _coustomArr = cusFieldArray;
//                }
//                [selfVC refreshViewData];
//            }
//        } @catch (NSException *exception) {
//            
//        } @finally {
//            
//        }
//    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
//        
//    }];
    
}

#pragma mark -- 数据刷新
-(void)refreshViewData{
    
    
    [_listArray removeAllObjects];
    //    NSDictionary *dict = [ZCJSONDataTools getObjectData:_model];
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    // propertyType == 1是自定义字段，0固定字段, 3不可点击
    
    NSMutableArray *arr1 = [[NSMutableArray alloc] init];
    
    [arr1 addObject:@{@"code":@"2",
                      @"dictName":@"ticketType",
                      @"dictDesc":ZCSTLocalString(@"问题类型*"),
                      @"placeholder":@"",
                      @"dictValue":zcLibConvertToString(_model.ticketTypeName),
                      @"dictType":@"3",
                      @"propertyType":@"0"
                      }];
    if (_typeArr.count && _tickeTypeFlag == 1) {
       [_listArray addObject:@{@"sectionName":@"提交内容",@"arr":arr1}];
    }
    
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
        
    if (_coustomArr.count >0) {
        int index = 0;
        for (ZCLibOrderCusFieldsModel *cusModel in _coustomArr) {
            NSString *propertyType = @"1";
            if ([zcLibConvertToString(cusModel.openFlag) intValue] == 0) {
                propertyType = @"3";
                cusModel.fieldType = @"3";
            }
            NSString * titleStr = zcLibConvertToString(cusModel.fieldName);
            if([zcLibConvertToString(cusModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"%@*",titleStr];
            }
            [arr2 addObject:@{@"code":[NSString stringWithFormat:@"%d",index],
                              @"dictName":zcLibConvertToString(cusModel.fieldName),
                              @"dictDesc":zcLibConvertToString(titleStr),
                              @"placeholder":zcLibConvertToString(cusModel.fieldRemark),
                              @"dictValue":zcLibConvertToString(cusModel.fieldValue),
                              @"dictType":zcLibConvertToString(cusModel.fieldType),
                              @"propertyType":propertyType
                              }];
            index = index + 1;
        }
         [_listArray addObject:@{@"sectionName":@"自定义字段",@"arr":arr2}];
    }
    
    //    留言相关 1显示 0不显示
    //    telShowFlag 电话是否显示
    //    telFlag 电话是否必填
    //    enclosureShowFlag 附件是否显示
    //    enclosureFlag 附件是否必填
    //    emailFlag 邮箱是否必填
    //    emailShowFlag 邮箱是否显示
    //    ticketStartWay 工单发起方式 1邮箱，2手机
//    ZCLibConfig *libConfig = [self getCurConfig];
    
    NSString * tmp = @"";
    if (_msgTmp != nil) {
        tmp = _msgTmp;
    }
    
    // 过滤标签
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
    
//    if (libConfig.enclosureShowFlag) {
        NSMutableArray *arr3 = [[NSMutableArray alloc] init];
        [arr3 addObject:@{@"code":@"1",
                          @"dictName":@"ticketReplyContent",
                          @"dictDesc":@"回复内容",
                          @"placeholder":tmp,//  libConfig.msgTmp
                          @"dictValue":zcLibConvertToString(_model.ticketDesc),
                          @"dictType":@"0",
                          @"propertyType":@"0"
                          }];
        [_listArray addObject:@{@"sectionName":@"回复",@"arr":arr3}];

//    }
   
    
    NSMutableArray *arr4 = [[NSMutableArray alloc] init];
    
//    if ([ZCUIConfigManager getInstance].kitInfo.isShowNickName) {
//        NSString * text = ZCSTLocalString(@"请输入昵称（选填）");
//        if ([ZCUIConfigManager getInstance].kitInfo.isAddNickName) {
//            text = ZCSTLocalString(@"请输入昵称（必填）");;
//        }
//        [arr4 addObject:@{@"code":@"1",
//                          @"dictName":@"ticketTitle",
//                          @"dictDesc":@"昵称",
//                          @"placeholder":text,
//                          @"dictValue":zcLibConvertToString(_model.userName),
//                          @"dictType":@"1",
//                          @"propertyType":@"0"
//                          }];
//    }
    
    if ( _emailShowFlag) {
        NSString * text = ZCSTLocalString(@"请输入邮箱地址（选填）");
        NSString * title = @"邮箱";
        if( _emailFlag){
            text = ZCSTLocalString(@"请输入邮箱地址（必填）");
            title = @"邮箱*";
        }
        [arr4 addObject:@{@"code":@"1",
                          @"dictName":@"ticketEmail",
                          @"dictDesc":title,
                          @"placeholder":text,
                          @"dictValue":zcLibConvertToString(_model.email),
                          @"dictType":@"1",
                          @"propertyType":@"0"
                          }];
    }
    
    if ( _telShowFlag) {
        NSString * text = ZCSTLocalString(@"请输入手机号码（选填）");
        NSString * title = @"手机";
        if ( _telFlag) {
            text = ZCSTLocalString(@"请输入手机号码（必填）");
            title = @"手机*";
        }
        [arr4 addObject:@{@"code":@"1",
                          @"dictName":@"ticketTel",
                          @"dictDesc":title,
                          @"placeholder":text,
                          @"dictValue":zcLibConvertToString(_model.tel),
                          @"dictType":@"1",
                          @"propertyType":@"0"
                          }];
    }
    if (arr4.count>0) {
        [_listArray addObject:@{@"sectionName":@"",@"arr":arr4}];
    }

    [_listTable reloadData];
}


/**
 *  监听滑动返回的事件
 *
 *  @param navigationController  导航控制器
 *  @param viewController  将要显示的VC
 *  @param animated  是否添加动画
 */
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 解决ios7调用系统的相册时出现的导航栏透明的情况
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        return;
    }
    
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    __weak ZCUILeaveMessageController *safeVC = self;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(![context isCancelled]){
            // 设置页面不能使用边缘手势关闭
//            if(iOS7 && navigationController!=nil){
//                navigationController.interactivePopGestureRecognizer.enabled = NO;
//            }
//            __strong __typeof(self) strongSelf = safeVC;
            [safeVC backAction];
        }
    }];
    
}
#pragma mark -- 系统键盘的监听事件


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

//    if (iOS7) {
//        if (self.navigationController !=nil) {
//            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//            self.navigationController.delegate = nil;
//        }
//    }
//    // 移除键盘的监听
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)keyboardHide:(NSNotification*)notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
}



#pragma mark -- 提交事件
-(IBAction)buttonClick:(UIButton *) sender{
    
    
    if(sender.tag == BUTTON_MORE){
        // 工单类型
        if (_typeArr.count>0 && _tickeTypeFlag == 1) {
            if ([@"" isEqualToString:zcLibConvertToString(_model.ticketType)]) {
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请选择问题类型") duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
        }
        
        NSMutableArray *cusFields = [NSMutableArray arrayWithCapacity:0];
        // 自定义字段
        for (ZCLibOrderCusFieldsModel *cusModel in _coustomArr) {
            if([cusModel.fillFlag intValue] == 1 && zcLibIs_null(cusModel.fieldValue)){
                [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"%@不能为空",cusModel.fieldName] duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
            if(!zcLibIs_null(cusModel.fieldSaveValue)){
                [cusFields addObject:@{@"id":zcLibConvertToString(cusModel.fieldId),
                                       @"value":zcLibConvertToString(cusModel.fieldSaveValue)
                                       }];
            }else{
                [cusFields addObject:@{@"id":zcLibConvertToString(cusModel.fieldId),
                                       @"value":zcLibConvertToString(cusModel.fieldValue)
                                       }];
            }
        }
        
//        ZCLibConfig *libConfig = [ZCIMChat getZCIMChat].libConfig;
//        ZCLibConfig *libConfig = [self getCurConfig];
         // 显示邮箱
        if (_emailShowFlag) {
            // 必填
            if (_emailFlag) {
                if (zcLibTrimString(_model.email).length>0) {
                     if(![self match:_model.email]){
                        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"邮箱格式不正确") duration:1.0f view:self.view position:ZCToastPositionCenter];
                        return;
                     }
                }else{
                    [[ZCUIToastTools shareToast] showToast:@"请输入您的邮箱" duration:1.0f view:self.view position:ZCToastPositionCenter];
                    return;
                }
            }else{
              // 非必填
                if(zcLibTrimString(_model.email).length>0){
                    if(![self match:_model.email]){
                        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"邮箱格式不正确") duration:1.0f view:self.view position:ZCToastPositionCenter];
                        return;
                    }
                }
                
            }
            
        }
        
        // 显示 手机
        if (_telShowFlag && _telFlag &&  zcLibTrimString(_model.tel).length==0) {
            // 必填
            [[ZCUIToastTools shareToast] showToast:@"请您输入手机号" duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        
        // 附件
        if (self.enclosureShowFlag && self.enclosureFlag && _imagePathArr.count<=0) {
            [[ZCUIToastTools shareToast] showToast:@"请您上传附件" duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        
        
        // 提交留言内容
        if (_model.ticketDesc.length<=0) {
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请填写问题描述")  duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        // 留言不能大于3000字
        if (_model.ticketDesc.length >3000) {
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"问题描述，最多只能输入3000字符") duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        
        
        [self UpLoadWith:cusFields];
        [self allHideKeyBoard];
    }
    
    // 返回的事件
    if(sender.tag == BUTTON_BACK){
        [self backAction];
    }
    
}



// 提交请求
- (void)UpLoadWith:(NSMutableArray*)arr{
    if(_isSend){
        return;
    }
    
    _isSend = YES;
    __weak ZCUILeaveMessageController *leaveVC = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:zcLibConvertToString(_model.ticketDesc) forKey:@"ticketContent"];
    
//    ZCLibConfig *libConfig = [ZCIMChat getZCIMChat].libConfig;
//    ZCLibConfig *libConfig = [self getCurConfig];
    if(_emailFlag || _emailShowFlag){
        [dic setValue:zcLibConvertToString(_model.email) forKey:@"customerEmail"];
        
    }
    if ( _telFlag || _telShowFlag) {
      [dic setValue:zcLibConvertToString(_model.tel) forKey:@"customerPhone"];
    }
//    if ([ZCUIConfigManager getInstance].kitInfo.isShowNickName) {
//       [dic setValue:_nickNameTf.text forKey:@"customerNick"];
//    }
    
    // 添加自定义字段
    if (_coustomArr>0) {
        [dic setValue:zcLibConvertToString([ZCLocalStore DataTOjsonString:arr]) forKey:@"extendFields"];
    }
    
    // 工单类型
    if ( _tickeTypeFlag == 2 ) {
        [dic setValue:zcLibConvertToString(_ticketTypeId) forKey:@"ticketTypeId"];
    }else{
        [dic setValue:zcLibConvertToString(_model.ticketType) forKey:@"ticketTypeId"];
    }
    
    if(_imageArr.count>0){
        NSString *fileStr = @"";
        for (NSDictionary *model in _imageArr) {
            fileStr = [fileStr stringByAppendingFormat:@"%@;",zcLibConvertToString(model[@"fileUrl"])];
        }
//        for (NSString *imagePath in _imageArr) {
//            fileStr = [fileStr stringByAppendingFormat:@"%@;",imagePath];
//        }
        fileStr = [fileStr substringToIndex:fileStr.length-1];
        [dic setObject:zcLibConvertToString(fileStr) forKey:@"fileStr"];
    }
    
    // 技能组ID
    [dic setObject:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.skillSetId) forKey:@"groupId"];
    NSString * templateId = @"1";
    if (self.templateldIdDic != nil && [[self.templateldIdDic allKeys] containsObject:@"templateId"]) {
        templateId = self.templateldIdDic[@"templateId"];
    }
    
    [[[ZCUIConfigManager getInstance] getZCAPIServer] sendLeaveMessage:dic config:[leaveVC getCurConfig] TemplateId: templateId success:^(ZCNetWorkCode code,int status ,NSString *msg) {
        
        // 手机号格式错误
        if (status ==0) {
            if(self.navigationController){
                [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:leaveVC.view position:ZCToastPositionCenter];
            }else{
                
                [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:leaveVC.presentingViewController.view position:ZCToastPositionCenter];
            }
            leaveVC.isSend = NO;
        }else{
            // 提交成功之后，是否直接退出  2.7.0修改 新增提示页面
//            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"留言成功，我们将尽快联系您") duration:1.0f view:self.view position:ZCToastPositionCenter];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                // 退出
//                [self goBack:leaveVC.exitType];
//            });
            [self addLeaveMsgSuccessView];
        }
        
//        isSend = NO;
    } failed:^(NSString *errorMessage, ZCNetWorkCode erroCode) {
        leaveVC.isSend = NO;
        [[ZCUIToastTools shareToast]showToast:errorMessage duration:1.0f view:leaveVC.view position:ZCToastPositionCenter];
    }];
    
  
}

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 10, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
}


#pragma mark -- 布局子视图
- (void)customLayoutSubviewsWith:(ZCKitInfo *)zcKitInfo{
    
    // 屏蔽橡皮筋功能
    self.automaticallyAdjustsScrollViewInsets = NO;
//    // 计算Y值
//    CGFloat Y = 0;
//    if (self.navigationController.navigationBarHidden) {
//        Y = NavBarHeight;
//    }
//    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
//        Y = NavBarHeight;
//    }
    
    CGRect bf = btnBgView.frame;
    CGFloat by = CGRectGetMaxY(btnBgView.frame) +1;
    if (self.ticketShowFlag != 1) {
        bf.size.height = 0;
        btnBgView.frame = bf;
        btnBgView.hidden = YES;
        by = NavBarHeight;
    }

    
    
    // 添加滑动控件
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(btnBgView.frame) +1, ScreenWidth, ScreenHeight - NavBarHeight - btnBgView.frame.size.height)];
    CGFloat scrollHeight = ScreenHeight - NavBarHeight - btnBgView.frame.size.height;
    [_mainScrollView setContentSize:CGSizeMake(ScreenWidth*2 , scrollHeight)];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.delegate = self;
    _mainScrollView.userInteractionEnabled = YES;
    _mainScrollView.scrollEnabled = NO;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainScrollView];

   
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, scrollHeight) style:UITableViewStyleGrouped];
    _listTable.backgroundColor = [UIColor clearColor];
    _listTable.dataSource = self;
    _listTable.delegate = self;
//    _listTable.bounces = YES;
    _listTable.layer.masksToBounds = YES;
    [_mainScrollView addSubview:_listTable];
    [_listTable registerClass:[ZCOrderCheckCell class] forCellReuseIdentifier:cellCheckIdentifier];
    [_listTable registerClass:[ZCOrderContentCell class] forCellReuseIdentifier:cellOrderContentIdentifier];
    [_listTable registerClass:[ZCOrderEditCell class] forCellReuseIdentifier:cellEditIdentifier];
    [_listTable registerClass:[ZCOrderOnlyEditCell class] forCellReuseIdentifier:cellOrderSingleIdentifier];
    [_listTable setSeparatorColor:UIColorFromRGB(0xdce0e5)];
    [self setTableSeparatorInset];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
    [_listTable addGestureRecognizer:gestureRecognizer];
    
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
    footView.backgroundColor = [UIColor clearColor];
    
    // 区尾添加提交按钮 2.7.1改版
    UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    [commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateSelected];
    // [self createImageWithColor:UIColorFromRGB(BgTitleColor)]
    
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
    UIImage * img = [self createImageWithColor:[ZCUITools zcgetLeaveSubmitImgColor]];// UIColorFromRGB(BgTitleColor)
    [commitBtn setBackgroundImage:img forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:img forState:UIControlStateSelected];
    commitBtn.frame = CGRectMake(ZCNumber(15), ZCNumber(35), ScreenWidth- ZCNumber(30), ZCNumber(44));
    commitBtn.tag = BUTTON_MORE;
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.layer.masksToBounds = YES;
    commitBtn.layer.cornerRadius = 3.5f;
    commitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [footView addSubview:commitBtn];

    _listTable.tableFooterView = footView;
    
    
    CGFloat Y = 0;
    CGFloat H = scrollHeight;
    if (self.selectedType == 2) {
        Y = 10;
        H = scrollHeight -10;
    }
    
    _rightView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth,Y, ScreenWidth, H)];
    
    _mesRecordVC = [[ZCMsgRecordVC alloc]init];
    
    [_rightView addSubview:_mesRecordVC.view];
    [_mainScrollView addSubview:_rightView];
    
    [_mesRecordVC updataWithArray:[NSMutableArray arrayWithCapacity:0] height:H];
    
    __weak ZCUILeaveMessageController * saveVC = self;
    _mesRecordVC.jumpMsgDetailBlock = ^(ZCRecordListModel *model) {
        ZCMsgDetailsVC * detailVC = [[ZCMsgDetailsVC alloc]init];
        detailVC.ticketId = model.ticketId;
        if (saveVC.navigationController!= nil) {
            [saveVC.navigationController pushViewController:detailVC animated:YES];
        }else{
            [saveVC presentViewController:detailVC animated:YES completion:^{
                
            }];
        }
    };
}

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
#pragma mark -- 邮箱格式
// 正则表达式判断
- (BOOL)match:(NSString *) email{
    // 1.创建正则表达式
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";// 判断输入的数字是否是1~99
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:email options:0 range:NSMakeRange(0, email.length)];
    return results.count > 0;
}


#pragma mark -- 页面返回的事件 *******************************************
// 关闭页面
-(void)goBack:(ExitType) isClose{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    if(iOS7){
//        if(self.navigationController!=nil){
//            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//            self.navigationController.delegate = nil;
//        }
//    }
    if (isClose == ISCOLSE || isClose == ISBACKANDUPDATE) {
        [self isClose];
    }else{
        // 直接返回到上一级页面
        [self noIsClose : isClose];
    }
}

#pragma mark -- 返回到上一VC
- (void)backAction{
    if (_exitType == ISCOLSE) {
        [self isClose];
    }else{
        [self noIsClose:ISNOCOLSE];
    }
    [self allHideKeyBoard];
}

// 是否直接退出SDK
- (void)isClose{
    [self hideKeyboard];
    if (_isNavOpen) {
//        if(iOS7){
//            // 设置页面不能使用边缘手势关闭
//            if(self.navigationController!=nil){
//                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//                self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//                self.navigationController.delegate = nil;
//            }
//        }
        // 用户接入VC -》chatVC -》留言VC
        if(self.navigationController.viewControllers.count>=3){
        
            [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count -3] animated:YES];
        }else{
            [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
        }
  
        CloseBlock();
        if (self.backRefreshPageblock) {
            self.backRefreshPageblock(nil);
        }
    }else{
        [self dismissViewControllerAnimated:NO completion:^{
            CloseBlock();
            if (self.backRefreshPageblock) {
                self.backRefreshPageblock(nil);
            }
        }];
    }
    
}

-(void)setCloseBlock:(void (^)())closeBlock{
    CloseBlock = closeBlock;
}


// 不直接退出
- (void)noIsClose:(ExitType) isExitType{
    
    switch (isExitType) {
        case 1:
            [self isClose];
            break;
        case 2:
            [self popSkillView];
            break;
        case 3:
            [self isClose];
            break;
        case 4:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"closeSkillView" object:nil];
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(popSkillView) userInfo:nil repeats:NO];
            
            break;
        case 5:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gotoRobotChatAndLeavemeg" object:nil];
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(popSkillView) userInfo:nil repeats:NO];
            break;
        default:
            break;
    }
    
}

- (void)popSkillView{
     [self hideKeyboard];
    if (self.backRefreshPageblock) {
        self.backRefreshPageblock(nil);
    }
    if(_isNavOpen){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}
#pragma mark -- 页面返回的事件  End *******************************************



#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    
    //    NSLog(@"url:%@  url.absoluteString:%@",url,url.absoluteString);
    [self doClickURL:url.absoluteString text:@""];
}


// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}


// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if(LinkedClickBlock){
            LinkedClickBlock(url);
        }else{
            if([url hasPrefix:@"tel:"] || zcLibValidateMobile(url)){
                callURL=url;
                
                //初始化AlertView
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[url stringByReplacingOccurrencesOfString:@"tel:" withString:@""]
                                                               delegate:self
                                                      cancelButtonTitle:ZCSTLocalString(@"取消")
                                                      otherButtonTitles:ZCSTLocalString(@"呼叫"),nil];
                alert.tag=1;
                [alert show];
            }else if([url hasPrefix:@"mailto:"] || zcLibValidateEmail(url)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
         
            else{
                if (![url hasPrefix:@"https"] && ![url hasPrefix:@"http"]) {
                    url = [@"http://" stringByAppendingString:url];
                }
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:zcUrlEncodedString(url)];
                if(self.navigationController != nil ){
                    [self.navigationController pushViewController:webPage animated:YES];
                }else{
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                    nav.navigationBarHidden=YES;
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
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
            
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeReSend obj:nil];
//                //                [_delegate itemOnClick:_tempModel clickType:SobotCellClickReSend];
//            }
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

#pragma mark UITableView delegate Start

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self allHideKeyBoard];
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArray.count;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        ZCMLEmojiLabel  *label=[[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(15, 15, ScreenWidth-30, 0)];
        label.numberOfLines = 0;
        NSString *text = @"";
        if (_msgTxt != nil && _msgTxt.length >0)   {
            text = zcLibConvertToString(_msgTxt);
        }
//        NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 != nil && text1.length > 0) {
                label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromRGB(TextWordOrderListTextColor) textFont:ListTimeFont linkColor:[ZCUITools zcgetChatLeftLinkColor]];
                
            }else{
                label.attributedText = [[NSAttributedString alloc] initWithString:@""];;
                
            }
            
        }];
        
//        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
//        text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//        while ([text hasPrefix:@"\n"]) {
//            text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//        }
//        NSMutableDictionary *dict = [label getTextADict:text];
//        if(dict){
//            text = dict[@"text"];
//        }
//
//        [label setText:text];// 设置留言引导文案

        CGSize  labSize = [label preferredSizeWithMaxWidth:ScreenWidth-30];
        return labSize.height + 15;
    }
    return 0.01;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    if (section == 0) {
        [view setBackgroundColor:UIColorFromRGB(wordOrderListHeaderBgColor)];
        ZCMLEmojiLabel *label=[[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(15, 15, ScreenWidth-30, 0)];
        [label setFont:ListTimeFont];
        //    [label setText:_listArray[section][@"sectionName"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromRGB(TextWordOrderListTextColor)];
        label.numberOfLines = 0;
        label.isNeedAtAndPoundSign = NO;
        label.disableEmoji = NO;
        
        label.lineSpacing = 3.0f;
        [label setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        label.delegate = self;
        

        NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 !=nil && text1.length > 0) {
                 label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromRGB(TextWordOrderListTextColor) textFont:ListTimeFont linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                 label.attributedText = [[NSAttributedString alloc] initWithString:@""];
            }
           
        }];
        
//        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//
//        text = [text stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
//        text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//        while ([text hasPrefix:@"\n"]) {
//            text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//        }
//        NSMutableDictionary *dict = [label getTextADict:text];
//        if(dict){
//            text = dict[@"text"];
//        }
//
//        if(dict){
//            NSArray *arr = dict[@"arr"];
//            //    [_emojiLabel setText:tempText];
//            for (NSDictionary *item in arr) {
//                NSString *text = item[@"htmlText"];
//                int loc = [item[@"realFromIndex"] intValue];
//
//                // 一定要在设置text文本之后设置
//                [label addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
//            }
//        }
//        [label setText:text];
        CGSize  labSize  =  [label preferredSizeWithMaxWidth:ScreenWidth-30];
        label.frame = CGRectMake(15, 15, labSize.width, labSize.height);
        [view addSubview:label];
        
        CGRect VF = view.frame;
        VF.size.height = labSize.height + 15;
        view.frame = VF;
        
    }else{
        view.frame = CGRectMake(0, 0, ScreenWidth, 0.01);
    }
    
   
    return view;
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
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}


// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    NSDictionary *sectionDict = _listArray[section];
    return ((NSMutableArray *)sectionDict[@"arr"]).count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCOrderCreateCell *cell = nil;
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    NSDictionary *itemDict = _listArray[indexPath.section][@"arr"][indexPath.row];
    int type = [itemDict[@"dictType"] intValue];
//    int propertyType = [itemDict[@"propertyType"] intValue];
    if(type == 0){
        cell = (ZCOrderContentCell*)[tableView dequeueReusableCellWithIdentifier:cellOrderContentIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOrderContentIdentifier];
        }
        cell.isReply = YES;
        ((ZCOrderContentCell *)cell).imageArr = _imageArr;
        ((ZCOrderContentCell *)cell).imagePathArr = _imagePathArr;
        ((ZCOrderContentCell *)cell).enclosureShowFlag = self.enclosureShowFlag;
    }else if(type == 1 || type ==5){
        cell = (ZCOrderOnlyEditCell*)[tableView dequeueReusableCellWithIdentifier:cellOrderSingleIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderOnlyEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOrderSingleIdentifier];
        }
    }else if(type == 2){
        cell = (ZCOrderEditCell*)[tableView dequeueReusableCellWithIdentifier:cellEditIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEditIdentifier];
        }
    }else{
        cell = (ZCOrderCheckCell*)[tableView dequeueReusableCellWithIdentifier:cellCheckIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderCheckCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellCheckIdentifier];
        }
    }
    
    
    cell.delegate = self;
    cell.tempModel = _model;
    cell.tempDict = itemDict;
    cell.indexPath = indexPath;
    [cell initDataToView:itemDict];
    return cell;
}



// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// 删除清理数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;
}


// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *itemDict = _listArray[indexPath.section][@"arr"][indexPath.row];
    
    if([itemDict[@"propertyType"] intValue]==3){
        return;
    }
    
    NSString *dictName = itemDict[@"dictName"];
    
    // 多级 工单分类
    if([@"ticketType" isEqual:dictName]){
        __block ZCUILeaveMessageController *myself = self;
        ZCOrderTypeController *typeVC = [[ZCOrderTypeController alloc] init];
        typeVC.typeId = @"-1";
        typeVC.parentVC = self;
        typeVC.listArray = _typeArr;
        typeVC.orderTypeCheckBlock = ^(ZCLibTicketTypeModel *tempmodel) {
            if(tempmodel){
                myself.model.ticketType = tempmodel.typeId;
                myself.model.ticketTypeName = tempmodel.typeName;
                [self refreshViewData];
            }
        };
        
        [self.navigationController pushViewController:typeVC animated:YES];
        return;
    }
    
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    int propertyType = [itemDict[@"propertyType"] intValue];
    if(propertyType == 1){
        int index = [itemDict[@"code"] intValue];
        curEditModel = _coustomArr[index];
        
        int fieldType = [curEditModel.fieldType intValue];
        if(fieldType == 4){
           _pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeTime isHaveNavControler:NO];
            _pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            _pickView.delegate = self;
            [_pickView show];

        }
        if(fieldType == 3){
            _pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            _pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            _pickView.delegate = self;
            [_pickView show];
        }
        
        if(fieldType == 6 || fieldType == 7 || fieldType == 8){
            ZCOrderCusFieldController *vc = [[ZCOrderCusFieldController alloc] init];
            vc.preModel = curEditModel;
            vc.orderCusFiledCheckBlock = ^(ZCLibOrderCusFieldsDetailModel *model, NSMutableArray *arr) {
                curEditModel.fieldValue = model.dataName;
                curEditModel.fieldSaveValue = model.dataValue;
                
                if(fieldType == 7){
                    NSString *dataName = @"";
                    NSString *dataIds = @"";
                    for (ZCLibOrderCusFieldsDetailModel *item in arr) {
                        dataName = [dataName stringByAppendingFormat:@",%@",item.dataName];
                        dataIds = [dataIds stringByAppendingFormat:@",%@",item.dataValue];
                    }
                    if(dataName.length>0){
                        dataName = [dataName substringWithRange:NSMakeRange(1, dataName.length-1)];
                        dataIds = [dataIds substringWithRange:NSMakeRange(1, dataIds.length-1)];
                    }
                    curEditModel.fieldValue = dataName;
                    curEditModel.fieldSaveValue = dataIds;
                }
                
                [self refreshViewData];
            };
            if (_isNavOpen) {
                vc.isPush = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                vc.isPush = NO;
                [self presentViewController:vc animated:YES completion:nil];
            }
            
        }
    }
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        UIEdgeInsets inset = UIEdgeInsetsMake(0, 10, 0, 0);
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:inset];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:inset];
        }
    }
}


#pragma mark 日期控件
-(void)toobarDonBtnHaveClick:(ZCZHPickView *)pickView resultString:(NSString *)resultString{
//    NSLog(@"%@",resultString);
    if(curEditModel && ([curEditModel.fieldType intValue]==4 || [curEditModel.fieldType intValue]==3)){
        curEditModel.fieldValue = resultString;
        curEditModel.fieldSaveValue = resultString;
        [self refreshViewData];
    }
    
}

#pragma mark UITableViewCell 行点击事件处理
-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType)type dictValue:(NSString *)value dict:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    // 单行或多行文本，是自定义字段，需要单独处理_coustomArr对象的内容
    if(type == ZCOrderCreateItemTypeOnlyEdit || type == ZCOrderCreateItemTypeMulEdit){
        int propertyType = [dict[@"propertyType"] intValue];
        if(propertyType == 1){
            int index = [dict[@"code"] intValue];
            ZCLibOrderCusFieldsModel *temModel = _coustomArr[index];
            temModel.fieldValue = value;
            temModel.fieldSaveValue = value;
            
            // 这里要重新处理数据 *
            NSString * titleStr = zcLibConvertToString(temModel.fieldName);
            if([zcLibConvertToString(temModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"%@*",titleStr];
            }
            
            NSMutableArray *arr1 = _listArray[indexPath.section][@"arr"];
            arr1[indexPath.row] = @{@"code":[NSString stringWithFormat:@"%d",index],
                                    @"dictName":zcLibConvertToString(temModel.fieldName),
                                    @"dictDesc":zcLibConvertToString(titleStr),
                                    @"placeholder":zcLibConvertToString(temModel.fieldRemark),
                                    @"dictValue":zcLibConvertToString(temModel.fieldValue),
                                    @"dictType":zcLibConvertToString(temModel.fieldType),
                                    @"propertyType":@"1"
                                    };
        }
        if (propertyType == 0) {
            ZCLibConfig *libConfig = [self getCurConfig];
            NSMutableArray * arr4 = _listArray[indexPath.section][@"arr"];
            
            if([@"ticketEmail" isEqual:dict[@"dictName"]]){
                _model.email = value;
                
                NSString * text = ZCSTLocalString(@"请输入邮箱地址（选填）");
                NSString * title = @"邮箱";
                if( libConfig.emailFlag){
                    text = ZCSTLocalString(@"请输入邮箱地址（必填）");
                    title = @"邮箱*";
                }
               arr4[indexPath.row] = @{@"code":@"1",
                                  @"dictName":@"ticketEmail",
                                  @"dictDesc":title,
                                  @"placeholder":text,
                                  @"dictValue":zcLibConvertToString(_model.email),
                                  @"dictType":@"1",
                                  @"propertyType":@"0"
                                  };
                
            }
            
            if([@"ticketTel" isEqual:dict[@"dictName"]]){
                _model.tel = value;
                
                NSString * text = ZCSTLocalString(@"请输入手机号码（选填）");
                NSString * title = @"手机";
                if ( libConfig.telFlag) {
                    text = ZCSTLocalString(@"请输入手机号码（必填）");
                    title = @"手机*";
                }
                arr4[indexPath.row] = @{@"code":@"1",
                                        @"dictName":@"ticketTel",
                                        @"dictDesc":title,
                                        @"placeholder":text,
                                        @"dictValue":zcLibConvertToString(_model.tel),
                                        @"dictType":@"1",
                                        @"propertyType":@"0"
                                        };
                
            }
        }
    }
}

- (void)didAddImage{
    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"拍照"),ZCSTLocalString(@"从相册选择"), nil];
    [mysheet show];
    
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        // 保存图片到相册
        [self getPhotoByType:1];
    }
    if(buttonIndex == 1){
        [self getPhotoByType:2];
    }
}



-(void)itemCreateCellOnClick:(ZCOrderCreateItemType)type dictKey:(NSString *)key model:(ZCOrderModel *)model{
    if(type == ZCOrderCreateItemTypeAddPhoto || type == ZCOrderCreateItemTypeAddReplyPhoto){
        if(type == ZCOrderCreateItemTypeAddReplyPhoto){
            _isReplyPhoto = YES;
        }else{
            _isReplyPhoto = NO;
        }
        [self didAddImage];
    }
    if(type == ZCOrderCreateItemTypeDesc || type == ZCOrderCreateItemTypeTitle || type == ZCOrderCreateItemTypeReplyType){
        _model = model;
    }
    
    if(type == ZCOrderCreateItemTypeLookAtPhoto || type == ZCOrderCreateItemTypeLookAtReplyPhoto){

        // 浏览图片
        if(type == ZCOrderCreateItemTypeLookAtReplyPhoto){

            ZCXJAlbumController *albumVC = [[ZCXJAlbumController alloc] initWithImgULocationArr:_imagePathArr CurPage:[key intValue]];
            albumVC.myDelegate = self;
            
            [self.navigationController pushViewController:albumVC animated:YES];
                
        }else{

        }
        
    }
    
}

#pragma mark --- 图片浏览代理
-(void)getCurPage:(NSInteger)curPage{
    
}
-(void)delCurPage:(NSInteger)curPage{
    [_imageArr removeObjectAtIndex:curPage];
    [_imagePathArr removeObjectAtIndex:curPage];
    [_listTable reloadData];
}


#pragma mark 发送图片相关
/**
 *  根据类型获取图片
 *
 *  @param buttonIndex 2，来源照相机，1来源相册
 */
-(void)getPhotoByType:(NSInteger) buttonIndex{
    _zc_imagepicker = nil;
    _zc_imagepicker = [[UIImagePickerController alloc]init];
    _zc_imagepicker.delegate = self;
    [ZCSobotCore getPhotoByType:buttonIndex byUIImagePickerController:_zc_imagepicker Delegate:self];
}
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_zc_imagepicker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    __weak  ZCUILeaveMessageController *_myselft  = self;
    [ZCSobotCore imagePickerController:_zc_imagepicker didFinishPickingMediaWithInfo:info WithView:self.view Delegate:self block:^(NSString *filePath, ZCMessageType type, NSDictionary *dict) {
        [[[ZCUIConfigManager getInstance] getZCAPIServer] fileUploadForLeave:filePath commanyId:[self getCurConfig].companyID start:^{
            [[ZCUIToastTools shareToast] showProgress:@"上传中..." with:_myselft.view];
        } success:^(NSString *fileURL, ZCNetWorkCode code) {

            [[ZCUIToastTools shareToast] dismisProgress];
            if (zcLibIs_null(_imageArr)) {
                _imageArr = [NSMutableArray arrayWithCapacity:0];
            }
            if (zcLibIs_null(_imagePathArr)) {
                _imagePathArr = [NSMutableArray arrayWithCapacity:0];
            }
            [_imagePathArr addObject:filePath];
            
            NSDictionary * dic = @{@"fileUrl":fileURL};
//            ZCUploadImageModel * item = [[ZCUploadImageModel alloc]initWithMyDict:dic];
            [_imageArr addObject:dic];
            [_listTable reloadData];

        } fail:^(ZCNetWorkCode errorCode) {
            [[ZCUIToastTools shareToast] showToast:@"网络错误" duration:2.0f view:_myselft.view position:ZCToastPositionCenter];
        }];

    }];

}


#pragma mark -- 键盘滑动的高度
-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *)textField{
    _tempTextView = textview;
    _tempTextField = textField;
    
    //获取当前cell在tableview中的位置
    CGRect rectintableview = [_listTable rectForRowAtIndexPath:indexPath];
    
    //获取当前cell在屏幕中的位置
    CGRect rectinsuperview = [_listTable convertRect:rectintableview fromView:[_listTable superview]];
    
    contentoffset = _listTable.contentOffset;
    
    if ((rectinsuperview.origin.y+50 - _listTable.contentOffset.y)>200) {
        
        [_listTable setContentOffset:CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y) animated:YES];
        contentoffset = CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y);
    }
}



-(void)tapHideKeyboard{
    if(!zcLibIs_null(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!zcLibIs_null(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }
    
    if (_listTable.contentSize.height <( ScreenHeight - NavBarHeight)) {
        [_listTable setContentOffset:CGPointMake(0, 0)];
    }
}


- (void) hideKeyboard {
    if(!zcLibIs_null(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!zcLibIs_null(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }

    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
        [_listTable setContentOffset:contentoffset];
    }
}


#pragma mark UITableView delegate end

- (void)allHideKeyBoard
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        for (UIView* view in window.subviews)
        {
            [self dismissAllKeyBoardInView:view];
        }
    }
}

-(BOOL) dismissAllKeyBoardInView:(UIView *)view
{
    if([view isFirstResponder])
    {
        [view resignFirstResponder];
        return YES;
    }
    for(UIView *subView in view.subviews)
    {
        if([self dismissAllKeyBoardInView:subView])
        {
            return YES;
        }
    }
    return NO;
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTableSeparatorInset];
//    [self.listTable setFrame:CGRectMake(0, NavBarHeight, viewWidth, viewHeigth - NavBarHeight)];
    [self.listTable reloadData];
    if (_pickView != nil) {
        [_pickView setFrame:CGRectMake(0, 0, viewWidth, viewHeigth)];
    }
  
}


- (void)dealloc{
//    NSLog(@" go to dealloc");
    // 移除键盘的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteLookAtImage" object:nil];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 留言创建成功弹层

-(void)addLeaveMsgSuccessView{
    
    if (lmsView != nil) {
        return;
    }
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    lmsView = [[UIView alloc]initWithFrame:CGRectMake(0, Y, ScreenWidth, ScreenHeight - NavBarHeight)];
    lmsView.backgroundColor = [UIColor whiteColor];
    
    UIImageView * img = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth/2 - ZCNumber(93/2), ZCNumber(60), ZCNumber(93), ZCNumber(93))];
    img.image = [ZCUITools zcuiGetBundleImage:@"zcicon_addleavemsgsuccess"];
    [lmsView addSubview:img];
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(img.frame)+ ZCNumber(20), ScreenWidth, ZCNumber(28))];
    titleLab.text = @"创建成功";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont fontWithName:@"Arial-BoldMT" size:20];
    [lmsView addSubview:titleLab];
    
    UILabel * tiplab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(45), CGRectGetMaxY(titleLab.frame) + ZCNumber(10), ScreenWidth - ZCNumber(90), ZCNumber(40))];
    tiplab.textAlignment = NSTextAlignmentCenter;
    tiplab.font = [UIFont systemFontOfSize:14];
    tiplab.text = ZCSTLocalString(@"我们将会以链接的形式在会话中向您反馈工单处理状态");
    [tiplab setNumberOfLines:2];
    tiplab.textColor = UIColorFromRGB(TextRecordDetailColor);
    [lmsView addSubview:tiplab];
    
    UIButton * comBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    comBtn.frame = CGRectMake(ZCNumber(15), CGRectGetMaxY(tiplab.frame) + ZCNumber(15), ScreenWidth - ZCNumber(30), ZCNumber(44)) ;
    comBtn.backgroundColor = UIColorFromRGB(BgTitleColor);
    [comBtn setTitle:ZCSTLocalString(@"完成") forState:UIControlStateNormal];
    [comBtn setTitle:ZCSTLocalString(@"完成") forState:UIControlStateSelected];
    UIImage * colorimg = [self createImageWithColor:UIColorFromRGB(BgTitleColor)];
    [comBtn setBackgroundImage:colorimg forState:UIControlStateNormal];
    [comBtn setBackgroundImage:colorimg forState:UIControlStateSelected];
    [comBtn addTarget:self action:@selector(completionBackAction:) forControlEvents:UIControlEventTouchUpInside];
    comBtn.tag = 3001;
    comBtn.layer.masksToBounds = YES;
    comBtn.layer.cornerRadius = 3.5f;
    comBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [lmsView addSubview:comBtn];
    
    UIButton * recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake(ZCNumber(30), CGRectGetMaxY(comBtn.frame) + ZCNumber(20), ScreenWidth- ZCNumber(60), ZCNumber(30));
    [recordBtn setTitle:ZCSTLocalString(@"前往留言记录") forState:UIControlStateNormal];
    [recordBtn setTitleColor:UIColorFromRGB(BgTitleColor) forState:UIControlStateNormal];
    recordBtn.tag = 3002;
    [recordBtn addTarget:self action:@selector(completionBackAction:) forControlEvents:UIControlEventTouchUpInside];
    recordBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [lmsView addSubview:recordBtn];
    
    [self.view addSubview:lmsView];
}

-(void)removeAddLeaveMsgSuccessView{
    if (lmsView && lmsView!=nil) {
        [lmsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [lmsView removeFromSuperview];
        lmsView = nil;
    }
}

-(void)completionBackAction:(UIButton *)sender{
    if (sender.tag == 3001) {
        __weak ZCUILeaveMessageController *leaveVC = self;
        [self removeAddLeaveMsgSuccessView];
        [self goBack:leaveVC.exitType];
        
    }else if (sender.tag == 3002){
        [self removeAddLeaveMsgSuccessView];
        [self itemsClick:rightBtn];
        [_mesRecordVC loadData];
    }
}
#pragma mark -- 提示页面 end ------------


@end
