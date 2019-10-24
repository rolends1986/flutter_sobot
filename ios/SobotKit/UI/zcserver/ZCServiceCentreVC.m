//
//  ZCServiceCentreVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/27.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCServiceCentreVC.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibServer.h"
#import "ZCButton.h"
#import "ZCUIImageView.h"
#import "ZCServiceListVC.h"
#import "ZCSCListModel.h"


typedef NS_ENUM(NSInteger,ZCLineType) {
    LineLayerBorder = 0,//边框线
    LineHorizontal  = 1,//竖线
    LineVertical    = 2,//横线
};
// 理想线宽
#define LINE_WIDTH                  1
// 实际应该显示的线宽
#define SINGLE_LINE_WIDTH           floor((LINE_WIDTH / [UIScreen mainScreen].scale)*100) / 100

//偏移的宽度
#define SINGLE_LINE_ADJUST_OFFSET   floor(((LINE_WIDTH / [UIScreen mainScreen].scale) / 2)*100) / 100

typedef BOOL(^LinkClickBlock)(NSString *linkUrl);
typedef void (^PageLoadBlock)(id object,ZCPageBlockType type);

@interface ZCServiceCentreVC (){
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    
    UIScrollView     * scrollView;
    
    UIButton      *serviceBtn;// 客服入口
    
    NSMutableArray   *_listArray;
    
}

//当页面的list数据为空时，给它一个带提示的占位图。
@property(nonatomic,strong) UIView *placeholderView;

//@property (nonatomic,copy) LinkClickBlock linkBlock;
//
//@property (nonatomic,copy) PageLoadBlock  pageBlock;

@property (nonatomic,assign) id<ZCChatControllerDelegate> delegate;

@end

@implementation ZCServiceCentreVC

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

-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == BUTTON_BACK) {
        if (self.navigationController && self.isPush) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }else if (![ZCUICore getUICore].kitInfo.navcBarHidden && self.navigationController){
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"客户服务中心");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    viewHeigth = self.view.frame.size.height;
    viewWidth = self.view.frame.size.width;
   
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"客户服务中心");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
    }else{
        [self createTitleViewWith:1];
         self.titleLabel.text = ZCSTLocalString(@"客户服务中心");
        self.titleLabel.font = NavcTitleFont;
        [self.moreButton setImage:nil forState:UIControlStateNormal];
        [self.moreButton setImage:nil forState:UIControlStateHighlighted];
    }
    
    [self createSubviews];
    
    [self loadData];
}

#pragma mark -- 添加子控件
-(void)createSubviews{
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, Y, viewWidth, viewHeigth - ZCNumber(59) -(ZC_iPhoneX? 20:0) - Y)];
    scrollView.scrollEnabled = YES;
//    scrollView.backgroundColor = [UIColor redColor];
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = NO;
    scrollView.bounces = NO;
    [self.view addSubview:scrollView];
    
    // 在线客服btn
    serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    serviceBtn.type = 5;
    [serviceBtn setTitle:ZCSTLocalString(@"在线客服") forState:UIControlStateNormal];
    [serviceBtn setTitle:ZCSTLocalString(@"在线客服") forState:UIControlStateHighlighted];
    [serviceBtn setTitleColor:UIColorFromRGB(robotListTextColor) forState:UIControlStateNormal];
    [serviceBtn setTitleColor:UIColorFromRGB(robotListTextColor) forState:UIControlStateHighlighted];
    [serviceBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_openzc"] forState:UIControlStateNormal];
    [serviceBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_openzc"] forState:UIControlStateHighlighted];
    serviceBtn.titleLabel.font = ListTitleFont;
    [serviceBtn addTarget:self action:@selector(openZCSDK:) forControlEvents:UIControlEventTouchUpInside];
    serviceBtn.frame = CGRectMake(ZCNumber(30), CGRectGetMaxY(scrollView.frame) , viewWidth - ZCNumber(60), ZCNumber(44));
    serviceBtn.layer.borderColor = UIColorFromRGB(servicbtnlayerColor).CGColor;
    serviceBtn.layer.borderWidth = 0.5f;
    [serviceBtn setImageEdgeInsets:UIEdgeInsetsMake(0, ZCNumber(115), 0, ZCNumber(182))];
    [serviceBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, ZCNumber(116), 0, ZCNumber(115))];
    [serviceBtn setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
    [serviceBtn setAutoresizesSubviews:YES];
    [self.view addSubview:serviceBtn];
    
    
}


#pragma mark -- 加载数据
-(void)loadData{
    [self createPlaceholderView:@"暂无帮助内容" message:@"可点击下方按钮咨询人工客服" image:nil withView:self.view action:nil];
    _listArray = [NSMutableArray arrayWithCapacity:0];
    
    __weak ZCServiceCentreVC *weakself = self;
    [[ZCLibServer getLibServer] getCategoryWith:[ZCLibClient getZCLibClient].libInitInfo.appKey start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        
        @try{
            if (dict) {
                NSArray * dataArr = dict[@"data"];
                if ([dataArr isKindOfClass:[NSArray class]] && dataArr.count > 0) {
                   
                    for (NSDictionary *item in dataArr) {
                        ZCSCListModel * listModel = [[ZCSCListModel alloc]initWithMyDict:item];
                        [_listArray addObject:listModel];
                    }
                    
                    if (_listArray.count > 0) {
                        [weakself removePlaceholderView];
                        [weakself layoutItemWith:_listArray];
                    }
                    
                }
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
    
}

-(void)layoutItemWith:(NSMutableArray *)array{
    CGFloat bw=viewWidth;
    CGFloat x= 0;
    CGFloat y= 0;
    CGFloat itemH = 85;
    CGFloat itemW = (bw-0.25)/2.0f;
    
    int index = _listArray.count%2==0?round(_listArray.count/2):round(_listArray.count/2)+1;
    for (int i =0; i<_listArray.count; i++) {
        UIView * itemView = [self addItemView:_listArray[i] withX:x withY:y withW:itemW withH:itemH Tag:i];
        
        [itemView setBackgroundColor:[UIColor whiteColor]];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        if(i%2==1){
            // 单数添加 右边的线条和下边的线条
//            UIView * rline = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(itemView.frame), y, 0.5, itemH)];
//            rline.backgroundColor = UIColorFromRGB(0xE3E3E3); // CGRectMake(x, CGRectGetMaxY(itemView.frame), itemW+0.25, 0.5)
            UIView * bLine = [[UIView alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(itemView.frame), itemW+0.25, 0.5)];
            bLine.backgroundColor = UIColorFromRGB(0xE3E3E3);
//            [scrollView addSubview:rline];
            [scrollView addSubview:bLine];
            
//            [self setLineOffset:LineVertical withView:itemView];
            
            x = 0;
            y = y + itemH + 1;
            
            
        }else if(i%2==0){// CGRectMake(x, CGRectGetMaxY(itemView.frame), itemW+0.25, 0.25)
            UIView * bLine = [[UIView alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(itemView.frame), itemW+0.25, 0.5)];
            bLine.backgroundColor = UIColorFromRGB(0xE3E3E3);
            [scrollView addSubview:bLine];
//            if (i == 0) {
                UIView * rline = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(itemView.frame), y, 0.5, itemH)];
                rline.backgroundColor = UIColorFromRGB(0xE3E3E3);
                [scrollView addSubview:rline];
//            }
            x = itemW + 1;
           
        }
        [scrollView addSubview:itemView];
    }
    [scrollView setContentSize:CGSizeMake(bw, index*itemH + (index-1)*3)];
}


-(UIView *)addItemView:(ZCSCListModel *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h Tag:(int)i{
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    [itemView setBackgroundColor:UIColorFromRGB(TextTopColor)];
    
    ZCUIImageView *img = [[ZCUIImageView alloc]initWithFrame:CGRectMake(12, 26, 28, 28)];
    img.backgroundColor = UIColorFromRGB(serviceImgBgColor);
    [img loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.categoryUrl)] placeholer:nil showActivityIndicatorView:NO];
    [itemView addSubview:img];
    
    UILabel *titlelab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + ZCNumber(10), 20, ZCNumber(120), 40)];
    titlelab.numberOfLines = 2;
    [titlelab setTextAlignment:NSTextAlignmentLeft];
    [titlelab setTextColor:UIColorFromRGB(serciceItemTextColor)];
    [titlelab setText:zcLibConvertToString(model.categoryName)];
    [titlelab setFont:ListTitleFont];
    [itemView addSubview:titlelab];
    [titlelab sizeToFit];
    
    
    UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectZero];
    detailLab.frame = CGRectMake(CGRectGetMaxX(img.frame) +ZCNumber(10), CGRectGetMaxY(titlelab.frame) +ZCNumber(2), ZCNumber(120), 18);
    [detailLab setTextAlignment:NSTextAlignmentLeft];
    [detailLab setTextColor:UIColorFromRGB(SatisfactionTextColor)];
    [detailLab setText:zcLibConvertToString(model.categoryDetail)];
    [detailLab setFont:[UIFont systemFontOfSize:14]];
    [itemView addSubview:detailLab];
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = i;
    btn.frame = CGRectMake(0, 0, CGRectGetWidth(itemView.frame),CGRectGetHeight(itemView.frame));
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(tapItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [itemView addSubview:btn];

    
    return itemView;
}


-(void)tapItemAction:(UIButton *)sender{
 
    ZCServiceListVC * listVC = [[ZCServiceListVC alloc]init];
    int tag = (int)sender.tag;
    ZCSCListModel * model= _listArray[tag];
    listVC.titleName = zcLibConvertToString(model.categoryName);
    listVC.appId = zcLibConvertToString(model.appId);
    listVC.categoryId = model.categoryId;
    [listVC setOpenZCSDKTypeBlock:self.OpenZCSDKTypeBlock];
    if (self.navigationController) {
        [self.navigationController pushViewController:listVC animated:NO];
    }else{
        [self presentViewController:listVC animated:NO completion:nil];
    }
    
}

-(void)openZCSDK:(ZCButton *)sender{
    
    if (self.OpenZCSDKTypeBlock) {
        self.OpenZCSDKTypeBlock(self, ZCOpenTypeServiceCentreVC);
    }else{
        [ZCSobot startZCChatVC:_kitInfo with:self target:nil pageBlock:nil messageLinkClick:nil];
    }
}


-(id)initWithInitInfo:(ZCKitInfo *)info{
    self=[super init];
    if(self){
        if(info !=nil && !zcLibIs_null([ZCLibClient getZCLibClient].libInitInfo) && !zcLibIs_null([ZCLibClient getZCLibClient].libInitInfo.appKey)){
            //            self.zckitInfo=info;
        }else{
            //            self.zckitInfo=[ZCKitInfo new];
        }
        [ZCUICore getUICore].kitInfo = info;
        
//        self.delegate = delegate;
//        self.linkBlock = messagelinkBlock;
//        self.pageBlock = pageClick;
    }
    return self;
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


#pragma mark -- 设置分割线条 反截距
/**
 *  设置线条宽度
 *
 *  @param type 类型，横线、竖线、边框线
 *  @param view 要设置的view
 */
-(void)setLineOffset:(ZCLineType) type withView:(UIView *) view{
    CGFloat pixelAdjustOffset = 0;
    if ((int)(LINE_WIDTH * [UIScreen mainScreen].scale + 1) % 2 == 0) {
        pixelAdjustOffset = SINGLE_LINE_ADJUST_OFFSET;
    }
    
    CGRect rect = view.frame;
    
    if(type==LineHorizontal){
        rect.origin.y = rect.origin.y - pixelAdjustOffset;
        rect.size.height = SINGLE_LINE_WIDTH;
    }else if(type==LineVertical){
        rect.origin.x = rect.origin.x - pixelAdjustOffset;
        rect.size.width = SINGLE_LINE_WIDTH;
    }else{
        rect.origin.x = rect.origin.x - pixelAdjustOffset;
        rect.origin.y = rect.origin.y - pixelAdjustOffset;
        
        view.layer.borderWidth = SINGLE_LINE_WIDTH;
    }
    
    
    if(rect.size.height<0.5){
        rect.size.height = 0.5;
    }
    if(rect.size.width<0.5){
        rect.size.width = 0.5;
    }
    
    view.frame = rect;
}



-(void)dealloc{
//        NSLog(@" 客户帮助中心 释放了");
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
