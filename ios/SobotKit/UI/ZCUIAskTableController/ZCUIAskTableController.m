//
//  ZCUIAskTableController.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/2.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCUIAskTableController.h"
#import "ZCLibOrderCusFieldsModel.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIWebController.h"

#import "ZCZHPickView.h"
#import "ZCOrderCusFieldController.h"

#import "ZCLocalStore.h"
#import "ZCPlatformInfo.h"
#import "ZCPlatformTools.h"

#import "ZCOrderEditCell.h"
#import "ZCOrderCheckCell.h"

#import "ZCUIConfigManager.h"

#import "ZCOrderCreateCell.h"
#import "ZCOrderOnlyEditCell.h"

#import "ZCUIAskCityController.h"
#import "ZCUIImageTools.h"
#define cellCheckIdentifier @"ZCOrderCheckCell"
#define cellEditIdentifier @"ZCOrderEditCell"

#define cellOrderSwitchIdentifier @"ZCOrderReplyOpenCell"
#define cellOrderSingleIdentifier @"ZCOrderOnlyEditCell"

#import "ZCAddressModel.h"
#import "ZCUICore.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

@interface ZCUIAskTableController ()<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,ZCMLEmojiLabelDelegate,UIScrollViewDelegate,ZCZHPickViewDelegate,ZCOrderCreateCellDelegate>{
    
    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    
    // 呼叫的电话号码
    NSString                    *callURL;
    
    ZCLibOrderCusFieldsModel    *curEditModel;
    
    CGPoint        contentoffset;// 记录list的偏移量
    
    CGFloat     headerViewH ;// 区头的高度
    
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}

@property (nonatomic, assign) BOOL isSend;// 是否正在发送

@property (nonatomic,strong) UITableView * listTable;

@property (nonatomic,strong) NSMutableArray * listArray;

@property(nonatomic,strong)NSMutableArray   *coustomArr;// 用户自定义字段数组

@property(nonatomic,strong)UITextView       *tempTextView;

@property(nonatomic,strong)UITextField      *tempTextField;

@property (nonatomic,strong) UIView * placeholderView;

@property (nonatomic,copy) NSString * detailStr;// 表单描述

@property (nonatomic,strong) ZCAddressModel * addressModel;

@end

@implementation ZCUIAskTableController

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

    [self createLeftBarItemSelect:@selector(goBack) norImageName:img  highImageName:selImg];
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
    
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateDisabled];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackNolColor] && [ZCUICore getUICore].kitInfo.topBackNolColor != nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackNolColor] forState:UIControlStateNormal];
    }
    if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackSelColor] && [ZCUICore getUICore].kitInfo.topBackSelColor !=nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
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
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(viewWidth - 60, NavBarHeight - 40, 50, 40);
    [rightBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [ZCUITools zcgetListKitTitleFont];
    [rightBtn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetDynamicColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
         [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    viewWidth = self.view.frame.size.width;
    viewHeigth = self.view.frame.size.height;
    
//    [self.navigationController setNavigationBarHidden:YES];
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = @"请填写询前表单";
    }else{
        [self createTitleView];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = UIColorFromRGB(0xEFF3FA);
    
    _listArray = [[NSMutableArray alloc] init];
    
    
    // 布局页面
    [self customLayoutSubviews];
    
    self.titleLabel.text = @"请填写询前表单";
    
    [self.moreButton setImage:nil forState:UIControlStateNormal];
    [self.moreButton setImage:nil forState:UIControlStateHighlighted];
    [self.moreButton setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //back
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _isSend = NO;
    
//    if(iOS7){
//        if(self.navigationController!=nil){
//            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//            self.navigationController.interactivePopGestureRecognizer.delegate = self;
//            self.navigationController.delegate = self;
//        }
//    }
    
    // 加载数据
    [self loadDataForPage];
    
    // 布局子页面
    [self refreshViewData];
   
    
    
}

#pragma mark -- 返回和提交
-(void)buttonClick:(UIButton*)sender{
    if (sender.tag == BUTTON_BACK) {
        // 点击技能组的Item 之后会记录当前点选的技能组，返回是置空 重新显示技能组弹框
        if (_isclearskillId) {
            [ZCLibClient getZCLibClient].libInitInfo.skillSetName = @"";
            [ZCLibClient getZCLibClient].libInitInfo.skillSetId = @"";
        }
        [ZCUICore getUICore].isShowForm = NO;
        [self backAction];
        if (_trunServerBlock) {
            _trunServerBlock(YES);
        }
    }else{
        
        NSMutableDictionary *cusFields = [NSMutableDictionary dictionaryWithCapacity:0];
        // 自定义字段
        for (ZCLibOrderCusFieldsModel *cusModel in _coustomArr) {
            if([cusModel.fillFlag intValue] == 1 && zcLibIs_null(cusModel.fieldValue)){
                [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"%@不能为空",cusModel.fieldName] duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
            if( [@"email" isEqual:zcLibConvertToString(cusModel.fieldId)] && zcLibConvertToString(cusModel.fieldValue).length>0 && ![self match:zcLibConvertToString(cusModel.fieldValue)]){
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"邮箱格式不正确") duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
            
            if(!zcLibIs_null(cusModel.fieldSaveValue)){
                if (![@"city" isEqualToString:zcLibConvertToString(cusModel.fieldId)]) {
                     [cusFields setObject:zcLibConvertToString(cusModel.fieldSaveValue) forKey:zcLibConvertToString(cusModel.fieldId)];
                }else if([@"city" isEqualToString:zcLibConvertToString(cusModel.fieldId)]){
                    [cusFields setObject:zcLibConvertToString(_addressModel.provinceId) forKey:@"proviceId"];
                    [cusFields setObject:zcLibConvertToString(_addressModel.provinceName) forKey:@"proviceName"];
                    [cusFields setObject:zcLibConvertToString(_addressModel.cityId) forKey:@"cityId"];
                    [cusFields setObject:zcLibConvertToString(_addressModel.cityName) forKey:@"cityName"];
                    [cusFields setObject:zcLibConvertToString(_addressModel.areaId) forKey:@"areaId"];
                    [cusFields setObject:zcLibConvertToString(_addressModel.areaName) forKey:@"areaName"];
                }
            }
        
        }
        
        [self UpLoadWith:cusFields];
        [self allHideKeyBoard];
        
//        [self backAction];
        
    }
}


// 提交请求
- (void)UpLoadWith:(NSMutableDictionary*)dict{
    if(_isSend){
        return;
    }
    
    _isSend = YES;
     NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // 添加自定义字段
    if (_coustomArr>0) {
        [dic setValue:zcLibConvertToString([ZCLocalStore DataTOjsonString:dict]) forKey:@"customerFields"];
    }
    
    // 调用接口
    
    [[self getZCAPIServer] postAskTabelWithUid:[self getZCLibConfig].uid Parms:dic start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        [[ZCUIToastTools shareToast] showToast:@"  提交成功   " duration:1.0f view:self.view position:ZCToastPositionCenter];
         _isSend = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self backAction];
            if (_trunServerBlock) {
                _trunServerBlock(NO);
            }
        });
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
         _isSend = NO;
        
        [[ZCUIToastTools shareToast] showToast:errorMessage duration:1.0f view:self.view position:ZCToastPositionCenter];
        
    }];
    
}

-(void)backAction{
    if (self.navigationController != nil) {
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)customLayoutSubviews{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NavBarHeight, viewWidth, viewHeigth - NavBarHeight) style:UITableViewStylePlain];
    _listTable.backgroundColor = [UIColor clearColor];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    _listTable.bounces = NO;
    [self.view addSubview:_listTable];
    _listTable.estimatedRowHeight = 0;
    _listTable.estimatedSectionFooterHeight = 0;

    _listTable.clipsToBounds = YES;
    [_listTable registerClass:[ZCOrderCheckCell class] forCellReuseIdentifier:cellCheckIdentifier];
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
    _listTable.tableFooterView = footView;
    
}


-(void)refreshViewData{
    [_listArray removeAllObjects];
    
    //    NSDictionary *dict = [ZCJSONDataTools getObjectData:_model];
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    // propertyType == 1是自定义字段，0固定字段, 3不可点击
    
    NSMutableArray * arr1 = [NSMutableArray arrayWithCapacity:0];
    if (_coustomArr.count >0 && ![_coustomArr isKindOfClass:[NSNull class]]) {
        int index = 0;
        for (ZCLibOrderCusFieldsModel *cusModel in _coustomArr) {
            NSString *propertyType = @"1";
            NSString * titleStr = zcLibConvertToString(cusModel.fieldName);
            if([zcLibConvertToString(cusModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"%@ *",titleStr];
            }
            // 城市
            if ([zcLibConvertToString(cusModel.fieldId) isEqualToString:@"city"] ) {
                cusModel.fieldValue = [NSString stringWithFormat:@"%@%@%@", zcLibConvertToString(self.addressModel.provinceName) ,zcLibConvertToString(self.addressModel.cityName) ,zcLibConvertToString(self.addressModel.areaName)];
                cusModel.fieldSaveValue = cusModel.fieldValue;
            }
            
            if ([zcLibConvertToString(cusModel.fieldId) isEqualToString:@"qq"]) {
                cusModel.fieldType = @"5";
            }
            [arr1 addObject:@{@"code":[NSString stringWithFormat:@"%d",index],
                              @"dictName":zcLibConvertToString(cusModel.fieldName),
                              @"dictDesc":zcLibConvertToString(titleStr),
                              @"placeholder":zcLibConvertToString(cusModel.fieldRemark),
                              @"dictValue":zcLibConvertToString(cusModel.fieldValue),
                              @"dictType":zcLibConvertToString(cusModel.fieldType),
                              @"propertyType":propertyType,
                              @"dictfiledId":zcLibConvertToString(cusModel.fieldId)
                              }];
            index = index + 1;
        }

        [_listArray addObjectsFromArray:arr1];
    }
    [self reloadHeaderView];
    [_listTable reloadData];
    
}

-(void)reloadHeaderView{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    if (_coustomArr.count) {
        [view setBackgroundColor:UIColorFromRGB(wordOrderListHeaderBgColor)];
        ZCMLEmojiLabel *label=[[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(15, 15, ScreenWidth-30, 0)];
        [label setFont:ListDetailFont];
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
        
        NSString *text = self.detailStr;
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 !=nil && text1.length > 0) {
                label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromRGB(TextWordOrderListTextColor) textFont:ListDetailFont linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                label.attributedText = [[NSAttributedString alloc] initWithString:@""];
            }
            
            
        }];
        
//        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
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
        VF.size.height = CGRectGetMaxY(label.frame) + 15;
        view.frame = VF;
        
    }else{
        view.frame = CGRectMake(0, 0, ScreenWidth, 0.01);
    }
    
    headerViewH = CGRectGetHeight(view.frame);
    self.listTable.tableHeaderView = view;
}
-(void)loadDataForPage{
    
    if (_coustomArr == nil) {
        _coustomArr = [NSMutableArray arrayWithCapacity:0];
    }else{
        [_coustomArr removeAllObjects];
    }
  
    if (_dict) {
        if (![_dict[@"fields"] isKindOfClass:[NSNull class]]) {
            for (NSDictionary * item  in _dict[@"fields"]) {
                ZCLibOrderCusFieldsModel * model = [[ZCLibOrderCusFieldsModel alloc]initWithMyDict:item];
                [_coustomArr addObject:model];
            }
        }
        self.titleLabel.text = zcLibConvertToString(_dict[@"formTitle"]);
        self.detailStr = zcLibConvertToString(_dict[@"formDoc"]);
    }
    
    
    if (_coustomArr.count<1) {
        [self createPlaceholderView:nil message:@"网络原因请求超时 重新加载" image:[UIImage imageNamed:@"zcicon_networkfail"] withView:_listTable action:nil];
    }else{
        [self removePlaceholderView];
    }
    
}

#pragma mark --  监听左滑返回的事件
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 解决ios7调用系统的相册时出现的导航栏透明的情况
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        return;
    }
    
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    __weak ZCUIAskTableController *weakSelf = self;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(![context isCancelled]){
            // 设置页面不能使用边缘手势关闭
//            if(iOS7 && navigationController!=nil){
//                navigationController.interactivePopGestureRecognizer.enabled = NO;
//            }
            [weakSelf backAction];
        }
    }];
    
}




#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
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

        }
    }else if(alertView.tag==3){
        if(buttonIndex==1){
            // 打电话
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

#pragma mark --- EmojiLabel链接点击事件 end


#pragma mark -- uitabelView delegate
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

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self allHideKeyBoard];
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    
    return _listArray.count;
}


// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCOrderCreateCell *cell = nil;
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    NSDictionary *itemDict = _listArray[indexPath.row];
    int type = [itemDict[@"dictType"] intValue];
    if(type == 1 || type ==5){
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
//    cell.tempModel = _model;
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
    
    NSDictionary *itemDict = _listArray[indexPath.row];
    
    if([itemDict[@"propertyType"] intValue]==3){
        return;
    }
    
    
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    int propertyType = [itemDict[@"propertyType"] intValue];
    if(propertyType == 1){
        int index = [itemDict[@"code"] intValue];
        curEditModel = _coustomArr[index];
        
        int fieldType = [curEditModel.fieldType intValue];
        if(fieldType == 4){
//            ZCZHPickView *pickView = [[ZCZHPickView alloc] initDatePickWithDate:[NSDate new] datePickerMode:UIDatePickerModeTime isHaveNavControler:NO];
            ZCZHPickView *pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeTime isHaveNavControler:NO];
            pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            pickView.delegate = self;
            [pickView show];
        }
        if(fieldType == 3){
//            ZCZHPickView *pickView = [[ZCZHPickView alloc] initDatePickWithDate:[NSDate new] datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            ZCZHPickView *pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            pickView.delegate = self;
            [pickView show];
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
        
        __weak  ZCUIAskTableController *weakSelf = self;
        // 城市 级联字段
        if ([itemDict[@"dictfiledId"] isEqualToString:@"city"]) {
            ZCUIAskCityController * cityVC = [[ZCUIAskCityController alloc]init];
            cityVC.parentVC = self;
            cityVC.levle = 1;
            cityVC.orderTypeCheckBlock = ^(ZCAddressModel *model) {
                weakSelf.addressModel = model;
                // 刷新 城市
                [self refreshViewData];
            };
            
            [self.navigationController pushViewController:cityVC animated:YES];
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
    if(curEditModel && ([curEditModel.fieldType intValue]== 4 || [curEditModel.fieldType intValue] == 3)){
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
            
            _listArray[indexPath.row] = @{@"code":[NSString stringWithFormat:@"%d",index],
                                    @"dictName":zcLibConvertToString(temModel.fieldName),
                                    @"dictDesc":zcLibConvertToString(temModel.fieldName),
                                    @"placeholder":zcLibConvertToString(temModel.fieldRemark),
                                    @"dictValue":zcLibConvertToString(temModel.fieldValue),
                                    @"dictType":zcLibConvertToString(temModel.fieldType),
                                    @"propertyType":@"1"
                                    };
        }
    }
}

#pragma mark -- 系统键盘的监听事件
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 影藏NavigationBar
//    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    if (iOS7) {
//        if (self.navigationController !=nil) {
//            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//            self.navigationController.delegate = nil;
//        }
//    }
    // 移除键盘的监听
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)keyboardHide:(NSNotification*)notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
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

#pragma mark -- 加载失败的占位页面
- (void)createPlaceholderView:(NSString *)title message:(NSString *)message image:(UIImage *)image withView:(UIView *)superView action:(void (^)(UIButton *button)) clickblock{
    if (_placeholderView) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
    if(superView==nil){
        superView=self.view;
    }
    
    _placeholderView = [[UIView alloc]initWithFrame:superView.frame];
    
//    NSLog(@"%@",NSStringFromCGRect(superView.bounds));
    
    [_placeholderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [_placeholderView setAutoresizesSubviews:YES];
    [_placeholderView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_placeholderView];
    
    
    CGRect pf = CGRectMake(0, 0, superView.bounds.size.width, 0);
    UIImageView *icon = [[UIImageView alloc]initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_networkfail"]];
    if(image){
        [icon setImage:image];
    }
    [icon setContentMode:UIViewContentModeCenter];
    [icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    icon.frame = CGRectMake(pf.size.width/2 - 55/2, ZCNumber(110), 55, 76);
    [_placeholderView addSubview:icon];
    
    CGFloat y= CGRectGetMaxY(icon.frame) + 10;


    if(message){
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, 20)];
        
        [lblTitle setFont:DetGoodsFont];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setAutoresizesSubviews:YES];
        lblTitle.textColor = UIColorFromRGB(TextWordOrderListTextColor);
        lblTitle.attributedText = [self getOtherColorString:@"重新加载" Color:UIColorFromRGB(0x4d9dfe) withString:message];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        lblTitle.userInteractionEnabled = YES;
        [_placeholderView addSubview:lblTitle];
        y = y+25;
        
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshViewDataAgain)];
        gestureRecognizer.numberOfTapsRequired = 1;
        gestureRecognizer.cancelsTouchesInView = NO;
        [lblTitle addGestureRecognizer:gestureRecognizer];
    }
    
}


-(void)refreshViewDataAgain{
//    NSLog(@"点击了");
}


-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
    
    NSMutableString *temp = [NSMutableString stringWithString:originalString];
    str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
        
    }
    return str;
    
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




-(ZCUIConfigManager *)getShareMS{
    return [ZCUIConfigManager getInstance];
}

-(ZCLibServer *)getZCAPIServer{
    return [[self getShareMS] getZCAPIServer];
}


-(ZCLibConfig *)getZCLibConfig{
    return [self getPlatformInfo].config;
}

-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}


// 移除
- (void)removePlaceholderView{
    if (_placeholderView && _placeholderView!=nil) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
}

-(void)dealloc{
    // 移除键盘的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- 重新布局
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTableSeparatorInset];
    self.listTable.frame = CGRectMake(0, NavBarHeight, viewWidth, viewHeigth - NavBarHeight);
    [_listTable reloadData];
}

@end
