//
//  ZCUIAskCityController.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/4.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCUIAskCityController.h"

#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"

#import "ZCUIConfigManager.h"

#define cellIdentifier @"ZCUITableViewCell"
#import "ZCUICore.h"
@interface ZCUIAskCityController ()<UITableViewDelegate,UITableViewDataSource>{
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}

@property(nonatomic,strong)UITableView      *listTable;

@end

@implementation ZCUIAskCityController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    viewHeigth = self.view.frame.size.height;
    viewWidth = self.view.frame.size.width;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    [self createTitleView];
    
    self.titleLabel.text = _pageTitle;
    
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setTitle:@" 返回" forState:UIControlStateNormal];
    [self.moreButton setHidden:YES];
    [self createTableView];
  
    
    _listArray = [NSMutableArray arrayWithCapacity:0];
    [self loadAddressData];
    
}


-(void)loadAddressData{
    NSString * addId = @"";
    switch (_levle) {
        case 1:
            
            break;
        case 2:
            addId = _proviceId;
            break;
        case 3:
            addId = _cityId;
            break;
        default:
            break;
    }
    
    [[self getZCAPIServer] getAddressWithLevel:_levle nextaddressId:addId start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
//        NSLog(@"%@",dict);
        NSArray * addressArr = [NSArray array];
        if (dict) {
            switch (_levle) {
                case 1:
                    addressArr = dict[@"data"][@"provinces"];
                    break;
                case 2:
                    addressArr = dict[@"data"][@"citys"];
                    break;
                case 3:
                    addressArr = dict[@"data"][@"areas"];
                    break;
                    
                default:
                    break;
            }
            
            for (NSDictionary * item in addressArr) {
                ZCAddressModel * model = [[ZCAddressModel alloc] initWithMyDict:item];
                if (self.levle ==3) {
                    model.provinceName = self.proviceName;
                    model.provinceId = self.proviceId;
                    model.cityId = self.cityId;
                    model.cityName = self.cityName;
                }else if(self.levle == 2){
                    model.provinceName = self.proviceName;
                    model.provinceId = self.proviceId;
                }
                [_listArray addObject:model];
            }
            [_listTable reloadData];
        }
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
    
}


-(void)buttonClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)createTableView{
    
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NavBarHeight, viewWidth, viewHeigth - NavBarHeight) style:UITableViewStylePlain];
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
    
    ZCAddressModel *model=[_listArray objectAtIndex:indexPath.row];
    
    switch (_levle) {
        case 1:
            textLabel.text = model.provinceName;
            break;
        case 2:
            textLabel.text = model.cityName;
            break;
        case 3:
            textLabel.text = model.areaName;
            break;
        default:
            break;
    }
    
    CGRect imgf = imageView.frame;
    if(self.levle != 3){
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
    
    ZCAddressModel *model = [_listArray objectAtIndex:indexPath.row];
    if (model.endFlag == 1 || self.levle == 3) {
        if(_orderTypeCheckBlock){
            _orderTypeCheckBlock(model);
            [self.navigationController popToViewController:_parentVC animated:YES];
        }
    }else{
        ZCUIAskCityController *typeVC = [[ZCUIAskCityController alloc] init];
        typeVC.orderTypeCheckBlock =  _orderTypeCheckBlock;
        typeVC.parentVC = _parentVC;
        int count = 1;
        count  += self.levle;
        typeVC.levle = count;
        typeVC.proviceId = model.provinceId;
        typeVC.proviceName = model.provinceName;
        typeVC.cityName = model.cityName;
        typeVC.cityId = model.cityId;
        [self.navigationController pushViewController:typeVC animated:YES];
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
    [self setTableSeparatorInset];
    [self.listTable setFrame:CGRectMake(0, NavBarHeight, viewWidth, viewHeigth - NavBarHeight)];
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



-(ZCUIConfigManager *)getShareMS{
    return [ZCUIConfigManager getInstance];
}

-(ZCLibServer *)getZCAPIServer{
    return [[self getShareMS] getZCAPIServer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
