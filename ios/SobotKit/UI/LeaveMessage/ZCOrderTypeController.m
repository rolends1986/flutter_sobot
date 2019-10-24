//
//  ZCOrderTypeController.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/18.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderTypeController.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIImageTools.h"
#define cellIdentifier @"ZCUITableViewCell"
#import "ZCUICore.h"

@interface ZCOrderTypeController ()<UITableViewDelegate,UITableViewDataSource>{
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}


@property(nonatomic,strong)UITableView      *listTable;


@end

@implementation ZCOrderTypeController

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
    
    if ([ZCUICore getUICore].kitInfo.topViewBgColor) {
        [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    viewHeigth = self.view.frame.size.height;
    viewWidth = self.view.frame.size.width;
    
    // Do any additional setup after loading the view.
//    [self createTitleMenu];
    
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        if([@"" isEqual:zcLibConvertToString(_pageTitle)]){
            self.title = @"选择分类";
        }else{
            self.title = _pageTitle;
        }
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    }else{
        [self createTitleView];
        if([@"" isEqual:zcLibConvertToString(_pageTitle)]){
            self.titleLabel.text = @"选择分类";
        }else{
            self.titleLabel.text = _pageTitle;
        }
        [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.backButton setTitle:ZCSTLocalString(@"返回") forState:UIControlStateNormal];
        [self.moreButton setHidden:YES];
        
    }
    
    if([@"" isEqual:zcLibConvertToString(_typeId)]){
        _typeId = @"-1";
    }
    [self createTableView];
//    [self loadMoreData];
}

-(void)buttonClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)createTableView{
    // 计算Y值
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        Y = NavBarHeight;
    }
    
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, Y, viewWidth, viewHeigth - NavBarHeight) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self.view addSubview:_listTable];
    
    [_listTable setBackgroundColor:UIColorFromRGB(BgSystemColor)];
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    [_listTable setSeparatorColor:UIColorFromRGB(0xdce0e5)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self setTableSeparatorInset];
    
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    bgView.backgroundColor = UIColorFromRGB(0xEFF3FA);
    _listTable.tableFooterView = bgView;
    
}



#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0;
    }else{
        return 25;
    }
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==1){
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 25)];
        [view setBackgroundColor:UIColorFromRGB(BgSystemColor)];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, ScreenWidth-24, 25)];
        [label setFont:ListDetailFont];
        [label setText:@"gansha a"];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromRGB(TextBlackColor)];
        [view addSubview:label];
        return view;
    }
    return nil;
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
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(indexPath.row==_listArray.count-1){
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
    
    
    if(_listArray.count < indexPath.row){
        return cell;
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, ScreenWidth - 50, 21)];
    textLabel.font = DetGoodsFont;
    textLabel.textColor = UIColorFromRGB(TextUnPlaceHolderColor);
    [cell.contentView addSubview:textLabel];
    
    ZCLibTicketTypeModel *model=[_listArray objectAtIndex:indexPath.row];
    textLabel.text = model.typeName;
    
    
    CGRect imgf = imageView.frame;
    if([model.nodeFlag intValue] == 1){
        imageView.image =  [ZCUITools zcuiGetBundleImage:@"zcicon_web_next_disabled"];
        imgf.size = CGSizeMake(15, 21);
    }

    imgf.origin.x = ScreenWidth - imgf.size.width - 15;
    imgf.origin.y = (44 - imgf.size.height)/2;
    imageView.frame = imgf;
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
    return 44.0f;
    //    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    //    return cell.frame.size.height;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_listArray==nil || _listArray.count<indexPath.row){
        return;
    }
    
    ZCLibTicketTypeModel *model = [_listArray objectAtIndex:indexPath.row];
    if([model.nodeFlag intValue] == 1){
        ZCOrderTypeController *typeVC = [[ZCOrderTypeController alloc] init];
        typeVC.typeId = model.typeId;
        typeVC.pageTitle = model.typeName;
        typeVC.orderTypeCheckBlock =  _orderTypeCheckBlock;
        typeVC.parentVC = _parentVC;
        typeVC.listArray = model.items;

        [self.navigationController pushViewController:typeVC animated:YES];
        
    }else{
        if(_orderTypeCheckBlock){
            _orderTypeCheckBlock(model);

            [self.navigationController popToViewController:_parentVC animated:YES];
            
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

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTableSeparatorInset];
//    [self.listTable setFrame:CGRectMake(0, NavBarHeight, viewWidth, viewHeigth - NavBarHeight)];
    [self.listTable reloadData];
}

#pragma mark UITableView delegate end

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
