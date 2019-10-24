//
//  ZCOrderCusFieldController.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/21.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderCusFieldController.h"

//#import "ZCOrderCustomCell.h"
#import "ZCUIImageTools.h"
#import "ZCUIColorsDefine.h"

#import "ZCLIbGlobalDefine.h"

#import "ZCLibOrderCusFieldsModel.h"

#define cellIdentifier @"ZCUITableViewCell"

#import "ZCUICore.h"
@interface ZCOrderCusFieldController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableDictionary *checkDict;
    
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}
@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,strong) NSMutableArray *mulArr;

@end

@implementation ZCOrderCusFieldController
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
    
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetDynamicColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
        [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    viewHeigth = self.view.frame.size.height;
    viewWidth = self.view.frame.size.width;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
   
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    }else{
        [self createTitleView];

        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@""] forState:UIControlStateNormal];
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@""] forState:UIControlStateHighlighted];
    }
    
    // 计算Y值
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        Y = NavBarHeight;
    }
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, Y, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self.view addSubview:_listTable];
    [_listTable setBackgroundColor:UIColorFromRGB(BgSystemColor)];
    UIView * bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    bgview.backgroundColor = UIColorFromRGB(0xEFF3FA);
    _listTable.tableFooterView = bgview;
    
    
    [_listTable setSeparatorColor:UIColorFromRGB(0xdce0e5)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    [self setTableSeparatorInset];
    
    if(!zcLibIs_null(_preModel) && [_preModel.fieldType intValue] == 7){
        _mulArr = [NSMutableArray arrayWithCapacity:0];
        for (ZCLibOrderCusFieldsDetailModel *model in _preModel.detailArray) {
            if (model.isChecked) {
                [_mulArr addObject:model];
            }
        }
        
        self.moreButton.hidden = NO;
        [self.moreButton setTitle:@"提交" forState:UIControlStateNormal];
        
    }
    _listArray = _preModel.detailArray;
    checkDict  = [NSMutableDictionary dictionaryWithCapacity:0];
    if(!zcLibIs_null(_listArray)){
        [_listTable reloadData];
    }
}

-(void)buttonClick:(UIButton *)sender{
//    [super buttonClick:sender];
    if(sender.tag == BUTTON_MORE){
        if(_orderCusFiledCheckBlock){
            _orderCusFiledCheckBlock(nil,_mulArr);
        }

    }
    if (_isPush) {
       [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
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

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTableSeparatorInset];
//    [self.listTable setFrame:CGRectMake(0, NavBarHeight, viewWidth, viewHeigth - NavBarHeight)];
    [self.listTable reloadData];
}

#pragma mark -- tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

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
    
//        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
//        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(LineListColor)];
    if(_listArray.count < indexPath.row){
        return cell;
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, ScreenWidth - 50, 21)];
    textLabel.font = DetGoodsFont;
    textLabel.textColor = UIColorFromRGB(TextWordOrderListNolTextColor);
    [cell.contentView addSubview:textLabel];
    
    ZCLibOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    
    textLabel.text = model.dataName;
    
    CGRect imgf = imageView.frame;
    
    imgf.size = CGSizeMake(14, 14);
    
    if (!zcLibIs_null(_preModel) && [_preModel.fieldType intValue] == 7) {
        if (model.isChecked) {
            imageView.image =  [ZCUITools zcuiGetBundleImage:@"zcicon_app_moreselected_sel"];
        }else{
            imageView.image =  [ZCUITools zcuiGetBundleImage:@"zcicon_app_moreselected_nol"];
        }
        imgf.origin.x = 15;
        imgf.origin.y = (44 - imgf.size.height)/2;
        
        CGRect titleF = textLabel.frame;
        titleF.origin.x = 39;
        titleF.size.width = ScreenWidth - 39-20;//20为右间距
        textLabel.frame = titleF;
    }else{
        if([model.dataValue isEqual:_preModel.fieldSaveValue]){
            imageView.image = [ZCUITools zcuiGetBundleImage:@"zcicon_ordertype_sel"];
        }
        imgf.origin.x = ScreenWidth - imgf.size.width - 15;
        imgf.origin.y = (44 - imgf.size.height)/2;
    }
    
    imageView.frame = imgf;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZCLibOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    
    
    if([_preModel.fieldType intValue] != 7){
        if(_orderCusFiledCheckBlock){
            _orderCusFiledCheckBlock(model,_mulArr);
        }

        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        // 复选框
        if(model.isChecked){
            model.isChecked = NO;
            [_mulArr removeObject:model];
        }else{
            model.isChecked = YES;
            [_mulArr addObject:model];
        }
        [_listTable reloadData];
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
