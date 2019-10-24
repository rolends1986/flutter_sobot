//
//  ZCUIChatListController.m
//  SobotKit
//
//  Created by zhangxy on 2017/9/5.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCUIChatListController.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"

#import "ZCUIChatListCell.h"
#define cellIdentifier @"ZCUIChatListCell"
#import "ZCSobot.h"

#import "ZCIMChat.h"
#import "ZCLocalStore.h"
#import "ZCUIConfigManager.h"
#import "ZCUICore.h"
#import "ZCLibServer.h"

@interface ZCUIChatListController ()<UITableViewDelegate,UITableViewDataSource,ZCMessageDelegate>{
    
    // 是否显示系统状态栏，退出时显示
    BOOL                        navBarHide;
}

@property(nonatomic,strong)NSString      *userId;

@property(nonatomic,strong)UITableView      *listTable;
@property(nonatomic,strong)NSMutableArray   *listArray;
@property (nonatomic,assign) BOOL isHiddenNav;
@end

@implementation ZCUIChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isHiddenNav = self.byController.navigationController.navigationBarHidden;
//    [ZCUIConfigManager getInstance].kitInfo = _kitInfo;
    [ZCUICore getUICore].kitInfo = _kitInfo;
    navBarHide=self.navigationController.navigationBarHidden;
    
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = false;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self createTableView];
    [self createTitleView];
    [self.titleLabel setText:ZCSTLocalString(@"消息中心")];
    self.moreButton.hidden = YES;
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self loadMoreData];
    [ZCIMChat getZCIMChat].delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_BACK){
        [ZCIMChat getZCIMChat].delegate = nil;
        self.byController.navigationController.navigationBarHidden = _isHiddenNav;
//        self.navigationController.navigationBarHidden = navBarHide;
        
        if(self.navigationController != nil ){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}




-(void)createTableView{
    _listArray = [[NSMutableArray alloc] init];
    
    _listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight , ScreenWidth, ScreenHeight-NavBarHeight)];
    
    [_listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    _listTable.delegate=self;
    _listTable.dataSource=self;
    [_listTable setSeparatorColor:[UIColor clearColor]];
    [_listTable setBackgroundColor:[UIColor clearColor]];
    _listTable.clipsToBounds=NO;
    [_listTable registerClass:[ZCUIChatListCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:_listTable];
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_listTable setTableFooterView:view];
    
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    
    [_listTable setSeparatorColor:UIColorFromRGB(LineTextMenuColor)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    [self setTableSeparatorInset];
    
    [ZCIMChat getZCIMChat].delegate = self;
}


/**
 加载更多
 */
-(void)loadMoreData{
    if (_listArray) {
        [_listArray removeAllObjects];
    }
    _userId = [ZCLibClient getZCLibClient].libInitInfo.userId;
    _listArray = [[ZCPlatformTools sharedInstance] getPlatformList:_userId];
//    if(_listArray.count == 0){
    
    __weak ZCUIChatListController * listVC = self;
    __block NSMutableArray *difObject = [NSMutableArray arrayWithCapacity:0];
        [[ZCLibServer getLibServer] getPlatformMemberNews:_userId start:^{
            
        } success:^(NSMutableArray *news, NSDictionary *dictionary, ZCNetWorkCode sendCode) {
            
            // 对比appkey是否相同 相同用本地的替换 接口的
            //找到news中有,_listArray中没有的数据
            [news enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ZCPlatformInfo *info1 = (ZCPlatformInfo*)obj;
                __block BOOL isHave = NO;
                [_listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ZCPlatformInfo *info2 = (ZCPlatformInfo*)obj;
                    if ([info1.appkey isEqual:info2.appkey]) {
                        if (info1.avatar.length >0) {
                            info2.avatar = info1.avatar;
                        
                        }
                        if (info1.platformName.length >0) {
                            info2.platformName  = info1.platformName;
                        }
                        
                        if (info1.lastDate.length >0) {
                            info2.lastDate = info1.lastDate;
                        }
                        isHave = YES;
                        *stop = YES;
                    }
                }];
                if (!isHave) {
                    [difObject addObject:info1];
                }
            }];
            
            if (difObject.count >0) {
                [_listArray addObjectsFromArray:difObject];
            }
            [difObject removeAllObjects];
//            _listArray = news;
            [listVC sortedListArray];
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            [listVC sortedListArray];
        }];
//    }else{
//        [_listTable reloadData];
//    }
}

-(void)sortedListArray{
    if (_listArray.count >1) {
        [_listArray sortUsingComparator:^NSComparisonResult(ZCPlatformInfo * obj1, ZCPlatformInfo * obj2) {
            NSString * time1 = obj1.lastDate;
            NSString * time2 = obj2.lastDate;
             return [time2 compare:time1];
        }];
    }
    
     [_listTable reloadData];
}

#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
     if(_listArray==nil || _listArray.count==0){
        return 80;
    }else{
        return 0;
    }
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_listArray==nil || _listArray.count==0){
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(12, 40, ScreenWidth-24, 40)];
        [label setFont:ListDetailFont];
        [label setText:@"没有任何消息!"];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:UIColorFromRGB(TextTimeColor)];
        [label setBackgroundColor:[UIColor clearColor]];
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
    ZCUIChatListCell *cell = (ZCUIChatListCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell =  (ZCUIChatListCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        
        
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
//        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(BgTextColor)];
    if(_listArray.count < indexPath.row){
        return cell;
    }
    
    ZCPlatformInfo *model=[_listArray objectAtIndex:indexPath.row];
    [cell dataToView:model];
    
    
    return cell;
}



// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 删除清理数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ZCPlatformInfo *model = [_listArray objectAtIndex:indexPath.row];
        
        [[ZCPlatformTools sharedInstance] deletePlatformByAppKey:zcLibConvertToString(model.appkey) user:zcLibConvertToString(model.userId)];
        
        [[ZCLibServer getLibServer] delPlatformMemberByUser:model.listId start:^{
        } success:^(NSDictionary *dictionary, ZCNetWorkCode sendCode) {
            if (dictionary && [dictionary[@"code"] intValue] ==1) {
                [_listArray removeObject:model];
                [_listTable reloadData];
            }
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            
        }];
    }
    
}


// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_listArray==nil || _listArray.count<indexPath.row){
        return;
    }
    ZCPlatformInfo *info = [_listArray objectAtIndex:indexPath.row];
    if([ZCLibClient getZCLibClient].libInitInfo==nil || ![info.appkey isEqual:[ZCLibClient getZCLibClient].libInitInfo.appKey]){
        if(zcLibConvertToString(info.configJson).length > 0){
            [ZCLibClient getZCLibClient].libInitInfo = [[ZCLibInitInfo alloc] initByJsonDict:[ZCLocalStore dictionaryWithJsonString:info.configJson]];
        }else{
            ZCLibInitInfo *initinfo = [ZCLibInitInfo new];
            initinfo.appKey = info.appkey;
            initinfo.userId = _userId;
            [ZCLibClient getZCLibClient].libInitInfo = initinfo;
        }
    }
    [ZCIMChat getZCIMChat].delegate = nil;
    
    
//  BOOL  isaa =  [ZCSobot getPlatformIsArtificialWithAppkey:info.appkey Uid:info.uid];
//    NSLog(@"%d",isaa);
    
    if(_OnItemClickBlock){
        _OnItemClickBlock(self,info);
    }else{
     
        [ZCSobot startZCChatVC:_kitInfo with:self target:nil pageBlock:nil messageLinkClick:nil];
    }
    
}



//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        [self setTableSeparatorInset];
    }
}

-(void)viewDidLayoutSubviews{
    [self setTableSeparatorInset];
}

#pragma mark UITableView delegate end

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
}


#pragma mark 消息监听
-(void)onReceivedMessage:(ZCLibMessage *)message unReaded:(int)num object:(id)obj showType:(ZCReceivedMessageType)type{
    [self loadMoreData];
}

-(void)onConnectStatusChanged:(ZCConnectStatusCode)status{
    
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
