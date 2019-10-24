//
//  ZCMsgDetailsVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/20.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCMsgDetailsVC.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIImageTools.h"
#import "ZCUICore.h"
#import "ZCMsgDetailCell.h"
#import "ZCButton.h"

#import "ZCUIConfigManager.h"
#import "ZCPlatformTools.h"
#import "ZCUIConfigManager.h"
#import "ZCRecordListModel.h"
#define cellmsgDetailIdentifier @"ZCMsgDetailCell"
#import "ZCUICustomActionSheet.h"
#import "ZCUIWebController.h"

@interface ZCMsgDetailsVC ()<UITableViewDelegate,UITableViewDataSource,ZCUIBackActionSheetDelegate>{
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    
    BOOL     isShowHeard;
    BOOL     isAddShowBtn;// 添加展开按钮
    
}
@property(nonatomic,strong)UITableView      *listTable;

@property (nonatomic,strong) NSMutableArray * listArray;

@property (nonatomic,strong) ZCButton * showBtn;

@property (nonatomic,strong) UIView * headerView;

/***  评价页面 **/
@property (nonatomic,strong) ZCUICustomActionSheet *sheet;

@end

@implementation ZCMsgDetailsVC

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
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionSheetItemClick:) name:@"actionSheetClick:" object:nil];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController setNavigationBarHidden:YES];
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = @"留言详情";
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    }else{
        [self createTitleView];
        self.titleLabel.text = @"留言详情";
        [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.backButton setTitle:ZCSTLocalString(@"返回") forState:UIControlStateNormal];
        [self.moreButton setHidden:YES];
        
    }
    
    isShowHeard = NO;
    _listArray = [NSMutableArray arrayWithCapacity:0];
    [self createTableView];
    [self loadData];
}
-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}
// 加载数据
-(void)loadData{
    [[ZCUIToastTools shareToast] showProgress:@"" with:self.view];
    __weak ZCMsgDetailsVC * weakSelf = self;
    [[[ZCUIConfigManager getInstance] getZCAPIServer] postUserDealTicketinfoListWith:[self getCurConfig] ticketld:_ticketId start:^{
        
    } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
        [[ZCUIToastTools shareToast] dismisProgress];
        if (itemArray.count > 0) {
//            if (_listArray.count >0) {
                [_listArray removeAllObjects];
            [_listTable reloadData];
//            }
            
            // flag ==2 时是 还需要处理
            for (ZCRecordListModel * model in itemArray) {
                if (model.flag == 2 && model.replayList.count > 0) {
                    for (ZCRecordListModel * item in model.replayList) {
                        item.flag = 2;
                        [self.listArray addObject:item];
                    }
                }else{
                    [self.listArray addObject:model];
                }
                    
            }
    
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //这里进行UI更新
            [weakSelf.listTable reloadData];
            [weakSelf.listTable layoutIfNeeded];
//            NSLog(@"刷新了");
        });
        
  
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [[ZCUIToastTools shareToast] dismisProgress];
    } ];
    
}

-(void)buttonClick:(UIButton *)sender{
    if (self.navigationController) {
      [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
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
    
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, Y, viewWidth, viewHeigth - NavBarHeight) style:UITableViewStyleGrouped];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self.view addSubview:_listTable];
    
    [_listTable registerClass:[ZCMsgDetailCell class] forCellReuseIdentifier:cellmsgDetailIdentifier];
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    [_listTable setSeparatorColor:UIColorFromRGB(0xdce0e5)];
//    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self setTableSeparatorInset];
    
//    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
//    bgView.backgroundColor = UIColorFromRGB(0xEFF3FA);
//    _listTable.tableFooterView = bgView;
    
}



#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString * str = @"";
    if (self.listArray.count > 0) {
        ZCRecordListModel * model = [_listArray lastObject];
        
        str = zcLibConvertToString(model.content);
    }
    UIView *bgView = [self getHeaderViewHeight:str];
    return bgView.frame.size.height;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString * str = @"";
    if (self.listArray.count > 0) {
        ZCRecordListModel * model = [_listArray lastObject];
        
        str = zcLibConvertToString(model.content);
    }
    return [self getHeaderViewHeight:str];
 
}

-(void)showMoreAction:(UIButton *)sender{
    if (sender.tag == 1001) {
        isShowHeard = YES;
    }else{
        isShowHeard = NO;
    }
    [self.listTable reloadData];
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if(_listArray==nil){
//        return 0;
//    }
    return _listArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCMsgDetailCell *cell = (ZCMsgDetailCell*)[tableView dequeueReusableCellWithIdentifier:cellmsgDetailIdentifier];
    if (cell == nil) {
        cell = [[ZCMsgDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellmsgDetailIdentifier];
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
    if ( indexPath.row > _listArray.count -1) {
        return cell;
    }
    ZCRecordListModel * model = _listArray[indexPath.row];
    
    __weak ZCMsgDetailsVC * saveSelf = self;
    [cell initWithData:model IndexPath:indexPath.row btnClick:^(ZCRecordListModel * _Nonnull model) {
        // 去评价
        _sheet = [[ZCUICustomActionSheet alloc] initActionSheet:ServerSatisfcationOrderType Name:@"" Cofig:[ZCUICore getUICore].getLibConfig cView:saveSelf.view IsBack:NO isInvitation:1 WithUid:[ZCUICore getUICore].getLibConfig.uid   IsCloseAfterEvaluation:NO Rating:5 IsResolved:YES IsAddServerSatifaction:NO txtFlag:model.txtFlag ticketld:_ticketId ticketScoreInfooList:model.ticketScoreInfooList];
        _sheet.delegate = saveSelf;
//        _sheet.textFlag = model.txtFlag;
//        _sheet.ticketld = _ticketId;/Users/shiyao/Documents/newProjects/ZCNavBar/ZCNavBar/ZCNavBar/ZCNavBar.m
//        _sheet.ticketScoreInfooList = model.ticketScoreInfooList;
        [_sheet showInView:saveSelf.view];
    }];
    
    [cell setShowDetailClickCallback:^(ZCRecordListModel * _Nonnull model,NSString *urlStr) {
        if (urlStr) {
            ZCUIWebController *webVC = [[ZCUIWebController alloc] initWithURL:urlStr];
            [saveSelf.navigationController pushViewController:webVC animated:YES];
            return;
        }
        
        NSString *htmlString = model.replyContent;
        if (model.flag == 3) {
            htmlString = model.content;
        }
        ZCUIWebController *webVC = [[ZCUIWebController alloc] initWithURL:htmlString];
        
        [saveSelf.navigationController pushViewController:webVC animated:YES];
    }];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.selected = NO;

    return cell;
}

//-(void)dimissCustomActionSheetPage{
//    _sheet = nil;
//    [ZCUICore getUICore].isDismissSheetPage = YES;
    // 刷新数据
//    [self loadData];
//}


// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        UIEdgeInsets inset = UIEdgeInsetsMake(0, 39, 0, 0);
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
//    [self.listTable reloadData];
}

#pragma mark UITableView delegate end

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 39, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
}


#pragma mark -- 计算文本高度
-(CGRect)getTextRectWith:(NSString *)str WithMaxWidth:(CGFloat)width  WithlineSpacing:(CGFloat)LineSpacing AddLabel:(UILabel *)label {
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:str];
    NSMutableParagraphStyle * parageraphStyle = [[NSMutableParagraphStyle alloc]init];
    [parageraphStyle setLineSpacing:LineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parageraphStyle range:NSMakeRange(0, [str length])];
    [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, str.length)];
    
    label.attributedText = attributedString;
    
    CGSize size = [self autoHeightOfLabel:label with:width IsSetFrame:YES];
    
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    
    
    return labelF;
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width IsSetFrame:(BOOL)isSet{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];// 返回最佳的视图大小
    
    //adjust the label the the new height.
    if (isSet) {
        CGRect newFrame = label.frame;
        newFrame.size.height = expectedLabelSize.height;
        label.frame = newFrame;
        [label updateConstraintsIfNeeded];
    }
    return expectedLabelSize;
}


-(UIView*)getHeaderViewHeight:(NSString *)str{
    if (_headerView != nil) {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ZCNumber(140))];
    _headerView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(ZCNumber(15), ZCNumber(10), ScreenWidth- ZCNumber(30), ZCNumber(20))];
    [titleLab setFont:VoiceButtonFont];
    titleLab.text =ZCSTLocalString(@"问题描述:");
    [titleLab setTextAlignment:NSTextAlignmentLeft];
    [titleLab setTextColor:UIColorFromRGB(TextRecordTitleColor)];
    [_headerView addSubview:titleLab];
    
   // str =; //@"kasjkdlfj按时间拉开点附近绿卡交了多少客服建立刺啦地方呢个电动阀SDK静安寺老地方金额卢卡斯打开缴费老款就死饿了咖啡记录客服看撒娇拉开大姐夫了看记录的卡；的客服ID吃撒的看法就立刻拉开圣诞节联发科就爱收到了发科技类分开就按拉卡上的缴费老卡机阿拉丁是看级分类卡上的缴费扩就拉卡上的缴费老卡机收到了拉看得见水立方看记录的控件爱上了克己复礼科技二路反馈拉卡上的缴费";
    
    UILabel * conlab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(15), CGRectGetMaxY(titleLab.frame) + ZCNumber(10), ScreenWidth - ZCNumber(30), ZCNumber(50))];
    conlab.numberOfLines = 0;
    conlab.textColor = UIColorFromRGB(TextRecordDetailColor);
    conlab.font = [UIFont systemFontOfSize:14];
    conlab.text = str;
    [_headerView addSubview:conlab];
    
    CGSize conlabSize = [self autoHeightOfLabel:conlab with:ScreenWidth - ZCNumber(30) IsSetFrame:NO];
    
    _showBtn = [ZCButton buttonWithType:UIButtonTypeCustom];
    [_showBtn addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    _showBtn.tag = 1001;
    _showBtn.type = 2;
    _showBtn.space = ZCNumber(10);
    _showBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_showBtn setTitle: ZCSTLocalString(@"全部展开") forState:UIControlStateNormal];
    [_showBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_down"] forState:UIControlStateNormal];
    [_headerView addSubview: _showBtn];
    _showBtn.frame = CGRectMake(ScreenWidth/2- ZCNumber(120/2), CGRectGetMaxY(conlab.frame) + ZCNumber(8), 120, ZCNumber(0));
    _showBtn.hidden = YES;
    [_showBtn setTitleColor:UIColorFromRGB(BgTitleColor) forState:UIControlStateNormal];
    if (conlabSize.height > 40) {
        // 添加 展开全文btn
        _showBtn.hidden = NO;
    }
    
    if (!_showBtn.hidden) {
        if (isShowHeard) {
            // 显示全部
            _showBtn.frame = CGRectMake(ScreenWidth/2- ZCNumber(120/2), CGRectGetMaxY(conlab.frame) + ZCNumber(8), 120, ZCNumber(20));
            [self getTextRectWith:str WithMaxWidth:ScreenWidth - ZCNumber(30) WithlineSpacing:6 AddLabel:conlab];
            _showBtn.tag = 1002;
            [_showBtn setTitle:ZCSTLocalString(@"点击收起") forState:UIControlStateNormal];
            [_showBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_up"] forState:UIControlStateNormal];
            CGRect sf = _showBtn.frame;
            sf.origin.y = CGRectGetMaxY(conlab.frame) + ZCNumber(20);
            _showBtn.frame = sf;
        }else{
            // 收起之后
            conlab.frame = CGRectMake(ZCNumber(15), CGRectGetMaxY(titleLab.frame) + ZCNumber(10), ScreenWidth - ZCNumber(30), ZCNumber(50));
            
            _showBtn.frame = CGRectMake(ScreenWidth/2- ZCNumber(120/2), CGRectGetMaxY(conlab.frame) + ZCNumber(8), ZCNumber(120), ZCNumber(20));
            _showBtn.tag = 1001;
            [_showBtn setTitle:ZCSTLocalString(@"全部展开") forState:UIControlStateNormal];
            [_showBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_down"] forState:UIControlStateNormal];
        }
    }
    
    // 线条
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(ZCNumber(15), CGRectGetMaxY(_showBtn.frame) + ZCNumber(8), ScreenWidth - ZCNumber(30), 0.5)];
    lineView.backgroundColor = UIColorFromRGB(recordElineColor);
    [_headerView addSubview:lineView];
    
    CGRect hf = _headerView.frame;
    hf.size.height = CGRectGetMaxY(lineView.frame);
    _headerView.frame = hf;
    
    return _headerView;
}




//-(void) actionSheetItemClick:(NSNotification *)sender{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"指定刷新页面");
//            [self loadData];
//        });
//}
-(void) actionSheetClick:(int) isCommentType{
    [[ZCUIToastTools shareToast] showProgress:@"" with:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"指定刷新页面");
        [self loadData];
    });
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
