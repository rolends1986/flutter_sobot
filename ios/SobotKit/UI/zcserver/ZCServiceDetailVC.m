//
//  ZCServiceDetailVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/4/2.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCServiceDetailVC.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"
#import "ZCUIImageTools.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibServer.h"
#import "ZCSCListModel.h"
#import "ZCButton.h"
#import "ZCServiceCentreVC.h"
#import "ZCUIToastTools.h"
//#import "ZCObjButton.h"
@interface ZCServiceDetailVC ()<UIWebViewDelegate>{
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    
    UIButton    *serviceBtn;
    UIWebView   * webView;
    
    NSString * htmlStr;
    
    UILabel * titleLab;
}

@end

@implementation ZCServiceDetailVC


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
    }else if(![ZCUICore getUICore].kitInfo.navcBarHidden && self.navigationController){
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"问题详情");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
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
        self.title = ZCSTLocalString(@"问题详情");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
    }else{
        [self createTitleViewWith:1];
        self.titleLabel.text = ZCSTLocalString(@"问题详情");
        self.titleLabel.font = NavcTitleFont;
        [self.moreButton setImage:nil forState:UIControlStateNormal];
        [self.moreButton setImage:nil forState:UIControlStateHighlighted];
        
    }
    
    
    [self createSubviews];
    
    [self loadData];
    
    
}

-(void)createSubviews{
    
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
    titleLab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(10), Y + ZCNumber(20), ScreenWidth -ZCNumber(20), 20)];
    titleLab.textColor = UIColorFromRGB(0x333333);
    titleLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    [self.view addSubview:titleLab];
    
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLab.frame) +ZCNumber(12), viewWidth, viewHeigth - ZCNumber(59) -(ZC_iPhoneX? 20:0) - Y -ZCNumber(52))];
    [self.view addSubview:webView];
    webView.delegate = self;
    webView.scalesPageToFit = NO;
    webView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
   
    
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
    serviceBtn.frame = CGRectMake(ZCNumber(30), CGRectGetMaxY(webView.frame) , viewWidth - ZCNumber(60), ZCNumber(44));
    serviceBtn.layer.borderColor = UIColorFromRGB(servicbtnlayerColor).CGColor;
    serviceBtn.layer.borderWidth = 0.5f;
    [serviceBtn setImageEdgeInsets:UIEdgeInsetsMake(0, ZCNumber(115), 0, ZCNumber(182))];
    [serviceBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, ZCNumber(116), 0, ZCNumber(115))];
    [self.view addSubview:serviceBtn];
    
}



-(void)loadData{
    [[ZCLibServer getLibServer] getHelpDocByDocIdWith:self.appId DocId:self.docId start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        @try{
            if (dict) {
                NSDictionary * dataDic = dict[@"data"];
                if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic != nil) {
                    [webView loadHTMLString:zcLibConvertToString(dict[@"data"][@"answerDesc"]) baseURL:nil];
                    titleLab.text = zcLibConvertToString(dict[@"data"][@"questionTitle"]);
                }
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}


-(void)openZCSDK:(UIButton *)sender{
    
    if (self.OpenZCSDKTypeBlock) {
        self.OpenZCSDKTypeBlock(self, ZCOpenTypeServiceDetailVC);
    }else{
        [ZCSobot startZCChatVC:[ZCUICore getUICore].kitInfo with:self target:nil pageBlock:^(id object, ZCPageBlockType type) {
            if (type == ZCPageBlockGoBack) {
                // 直接返回到分类页面
                if (self.navigationController) {
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[ZCServiceCentreVC class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                    
                }else{
                    UIViewController *rootVC = self.presentingViewController;
                    
                    while (rootVC.presentingViewController) {
                        rootVC = rootVC.presentingViewController;
                    }
                    [rootVC dismissViewControllerAnimated:NO completion:nil];
                }
            }else if (type == ZCPageBlockLoadFinish){
                
            }
        } messageLinkClick:nil];
    }
    
}


-(void)webViewDidStartLoad:(UIWebView *)webView{
//    NSLog(@"kai shi jia zai ");
    
     [[ZCUIToastTools shareToast] showProgress:@"" with:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    NSLog(@" jia zai wan cheng ");
    
     [[ZCUIToastTools shareToast] dismisProgress];
    //重写contentSize,防止左右滑动
    
    CGSize size = webView.scrollView.contentSize;
    
    size.width= webView.scrollView.frame.size.width;
    
    webView.scrollView.contentSize= size;
    
    NSString *jsStr = [NSString stringWithFormat:@"var script = document.createElement('script');"
                       "script.type = 'text/javascript';"
                       "script.text = \"function ResizeImages() { "
                       "var myimg,oldwidth;"
                       "var maxwidth=%lf;" //缩放系数
                       "for(i=0;i <document.images.length;i++){"
                       "myimg = document.images[i];"
                       "if(myimg.width > maxwidth){"
                       "oldwidth = myimg.width;"
                       "myimg.width = maxwidth;"
                       "}"
                       "}"
                       "}\";"
                       "document.getElementsByTagName('head')[0].appendChild(script);",ScreenWidth-16];// SCREEN_WIDTH是屏幕宽度
    
    [webView stringByEvaluatingJavaScriptFromString:jsStr];
    
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    
     [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'"];//修改百分比即可
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    NSLog(@" jia zai shi bei");
    
    [[ZCUIToastTools shareToast] dismisProgress];
//    [[ZCUIToastTools shareToast] showToast:@"请求超时" duration:2.0f view:self.view position:ZCToastPositionCenter];
}


//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth
                                 html:(NSString *)html
                              webView:(UIWebView *)webView
{
    NSMutableString *str = [NSMutableString stringWithString:html];
    //计算要缩放的比例
    CGFloat initialScale = webView.frame.size.width/pageWidth;
    //将</head>替换为meta+head
    NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\"></head>",initialScale];
    
    NSRange range =  NSMakeRange(0, str.length);
    //替换
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    return str;
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
