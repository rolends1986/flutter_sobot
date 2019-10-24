//
//  ZCServiceListVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/28.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCServiceListVC.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"
#import "ZCUIImageTools.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibServer.h"
#import "ZCSCListModel.h"
#import "ZCServiceListCell.h"
#define  serviceCelIdentifier   @"ZCServiceListCell"
#import "ZCLibServer.h"
#import "ZCServiceDetailVC.h"
#import "ZCUIToastTools.h"
@interface ZCServiceListVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    
    NSMutableArray   *_listArray;
    UITableView * _listView;
}

//当页面的list数据为空时，给它一个带提示的占位图。
@property(nonatomic,strong) UIView *placeholderView;

@end

@implementation ZCServiceListVC

#pragma mark -- 横竖屏切换问题

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
    [btn.titleLabel setFont:[ZCUITools  zcgetscTopBackTextFont]];
    //    [btn addTarget:self action:select forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 44,44) ;
    if (imageName) {
        [btn setImage:[ZCUITools zcuiGetBundleImage:imageName] forState:UIControlStateNormal];
    }else{
        btn.frame = CGRectMake(0, 0, 44, 44);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_scback_gray"] forState:UIControlStateNormal];
    }
    if (heightImageName) {
        [btn setImage:[ZCUITools zcuiGetBundleImage:heightImageName] forState:UIControlStateHighlighted];
    }else{
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_scback_gray"] forState:UIControlStateHighlighted];
    }
    
    if ([ZCUICore getUICore].kitInfo.topBackNolColor != nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackNolColor] forState:UIControlStateNormal];
    }
    if ([ZCUICore getUICore].kitInfo.topBackSelColor != nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
    
    [btn setTitleColor:[ZCUITools zcgetscTopBackTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:[ZCUITools zcgetscTopBackTextColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[ZCUITools zcgetscTopBackTextColor] forState:UIControlStateDisabled];
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
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetscTopBgColor]];
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

-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == BUTTON_BACK) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    viewHeigth = self.view.frame.size.height;
    viewWidth = self.view.frame.size.width;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = self.titleName;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
    }else{
        [self createTitleViewWith:1];
        self.titleLabel.text = self.titleName;
        self.titleLabel.font = NavcTitleFont;
        [self.moreButton setImage:nil forState:UIControlStateNormal];
        [self.moreButton setImage:nil forState:UIControlStateHighlighted];
    }
    
    _listArray = [NSMutableArray arrayWithCapacity:0];
    
    [self createSubviews];
    
    [self loadData];
}

-(void)createSubviews{
    self.view.backgroundColor = UIColorFromRGB(servicelistBgColor);
    CGFloat y = 0;
    if (self.navigationController.navigationBarHidden) {
        y = NavBarHeight;
    }
    _listView = [[UITableView alloc]initWithFrame:CGRectMake(0, y, viewWidth, viewHeigth - NavBarHeight) style:UITableViewStylePlain];
//    [_listView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_listView registerClass:[ZCServiceListCell class] forCellReuseIdentifier:serviceCelIdentifier];
    _listView.dataSource = self;
    _listView.delegate = self;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listView];
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 15)];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 0.5)];
    lineView.backgroundColor = UIColorFromRGB(servicbtnlayerColor);
    [footView addSubview:lineView];
    _listView.tableFooterView = footView;
    [_listView setSeparatorColor:UIColorFromRGB(servicbtnlayerColor)];
    [_listView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self setTableSeparatorInset];

}

-(void)viewDidLayoutSubviews{
    [self setTableSeparatorInset];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//
//    return nil;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return viewHeigth - _listView.contentSize.height;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCServiceListCell * cell = [tableView dequeueReusableCellWithIdentifier:serviceCelIdentifier];
    if (cell == nil) {
        cell = [[ZCServiceListCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:serviceCelIdentifier];
    }
    if(_listArray==nil || _listArray.count<indexPath.row){
        return cell;
    }
    
    ZCSCListModel * model = _listArray[indexPath.row];
    
    [cell initWithModel:model];
    
    return cell;
}

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listView setSeparatorInset:inset];
    }
    
    if ([_listView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listView setLayoutMargins:inset];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZCSCListModel * model  = _listArray[indexPath.row];
    
    ZCServiceDetailVC *VC = [[ZCServiceDetailVC alloc]init];
    VC.appId = zcLibConvertToString(self.appId);
    VC.docId = zcLibConvertToString(model.docId);
    VC.questionTitle = zcLibConvertToString(model.questionTitle);
    [VC setOpenZCSDKTypeBlock:self.OpenZCSDKTypeBlock];
   
    if (self.navigationController) {
        [self.navigationController pushViewController:VC animated:NO];
    }else{
        [self presentViewController:VC animated:NO completion:nil];
    }
    
}

-(void)loadData{
    
//    [self createPlaceholderView:@"暂无相关内容" message:@"" image:nil withView:self.view action:nil];
    __weak ZCServiceListVC * saveSelf = self;
    [[ZCLibServer getLibServer] getHelpDocByCategoryIdWith:self.appId CategoryId:self.categoryId start:^{
        [[ZCUIToastTools shareToast] showProgress:@"" with:self.view];
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        
        if (dict) {
            NSArray * dataArr = dict[@"data"];
            if ([dataArr isKindOfClass:[NSArray class]] && dataArr.count > 0) {
                for (NSDictionary * item in dataArr) {
                    ZCSCListModel * model = [[ZCSCListModel alloc]initWithMyDict:item];
                    [_listArray addObject:model];
                }
                if (_listArray.count > 0) {
                    [saveSelf removePlaceholderView];
                    [_listView reloadData];
                }else{
                    [saveSelf createPlaceholderView:@"暂无相关内容" message:@"" image:nil withView:self.view action:nil];
                }
            }else{
                [saveSelf createPlaceholderView:@"暂无相关内容" message:@"" image:nil withView:self.view action:nil];
            }
        }
        
        [[ZCUIToastTools shareToast] dismisProgress];
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [[ZCUIToastTools shareToast] dismisProgress];
        [saveSelf createPlaceholderView:@"暂无相关内容" message:@"" image:nil withView:self.view action:nil];
    }];
    
}

#pragma mark -- 处理占位 空态
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
    [_placeholderView setBackgroundColor:[UIColor clearColor]];
    //    [_placeholderView setBackgroundColor:UIColorFromRGB(BgSystemColor)];
    [superView addSubview:_placeholderView];
    
    
    CGRect pf = CGRectMake(0, 0, superView.bounds.size.width, 0);
    UIImageView *icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"robot_default"]];
    if(image){
        [icon setImage:image];
    }
    [icon setContentMode:UIViewContentModeCenter];
    [icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    icon.frame = CGRectMake(0,0, pf.size.width, image.size.height);
    [_placeholderView addSubview:icon];
    
    CGFloat y= icon.frame.size.height+20;
    if(title){
        CGFloat height=[self getHeightContain:title font:ListTitleFont Width:pf.size.width];
        
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, height)];
        [lblTitle setText:title];
        [lblTitle setFont:[UIFont systemFontOfSize:16]];
        [lblTitle setTextColor:UIColorFromRGB(TextNetworkTipColor)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setNumberOfLines:0];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [_placeholderView addSubview:lblTitle];
        y=y+height+5;
    }
    
    if(message){
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, 20)];
        [lblTitle setText:message];
        [lblTitle setFont:[UIFont systemFontOfSize:14]];
        [lblTitle setTextColor:UIColorFromRGB(SatisfactionTextColor)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setAutoresizesSubviews:YES];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [_placeholderView addSubview:lblTitle];
        y=y+25;
    }
    
    
    pf.size.height= y;
    
    [_placeholderView setFrame:pf];
    [_placeholderView setCenter:CGPointMake(superView.center.x, superView.bounds.size.height/2-80)];
}

- (void)removePlaceholderView{
    if (_placeholderView && _placeholderView!=nil) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
}


-(CGFloat)getHeightContain:(NSString *)string font:(UIFont *)font Width:(CGFloat) width
{
    if(string==nil){
        return 0;
    }
    //转化为格式字符串
    NSAttributedString *astr = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:font}];
    CGSize contansize=CGSizeMake(width, CGFLOAT_MAX);
    if(iOS7){
        CGRect rec = [astr boundingRectWithSize:contansize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        return rec.size.height;
    }else{
        CGSize s=[string sizeWithFont:font constrainedToSize:contansize lineBreakMode:NSLineBreakByCharWrapping];
        return s.height;
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
