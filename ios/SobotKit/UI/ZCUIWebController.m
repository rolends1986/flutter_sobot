//
//  ZCUIWebController.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIWebController.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"
/**
 *  PageClickTag ENUM
 */
typedef NS_ENUM(NSInteger, PageClickTag) {
    /** 返回 */
    BUTTON_WEB_BACK      = 1,
    /** 刷新 */
    BUTTON_REREFRESH = 2,
};


@interface ZCUIWebController ()<UIWebViewDelegate>{
    NSString *pageURL;
    
    UIWebView *_webView;
    
    BOOL  navBarHide;
    
//    NSString *_htmlString;
    
}

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshButtonItem;
@property (nonatomic, strong) UIBarButtonItem *urlCopyButtonItem;

@property(nonatomic,strong) NSString *htmlString;

@end

@implementation ZCUIWebController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createTitleView];
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.tag = BUTTON_WEB_BACK;
    [self.backButton setTitle:@"" forState:UIControlStateNormal];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_webtitleback_normal"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_webtitleback_pressed"] forState:UIControlStateHighlighted];
    
    
    if (![@"" isEqual:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)]) {
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)] forState:UIControlStateNormal];
    }
    if (![@"" isEqual:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg)]) {
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg)] forState:UIControlStateHighlighted];
    }
    if ([ZCUICore getUICore].kitInfo.topBackNolColor != nil) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackNolColor] forState:UIControlStateNormal];
    }
    if ([ZCUICore getUICore].kitInfo.topBackSelColor != nil) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
   
    // 隐藏右上角的按钮
    self.moreButton.enabled = NO;
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@""] forState:UIControlStateNormal];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, NavBarHeight, self.view.frame.size.width, self.view.frame.size.height-NavBarHeight-44)];
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [_webView scalesPageToFit];
    [_webView setScalesPageToFit:YES];
    [_webView setDelegate:self];
    
    [self.view addSubview:_webView];
    
//    NSURL *url=[[ NSURL alloc ] initWithString:pageURL];
//    [_webView loadRequest:[ NSURLRequest requestWithURL:url]];
    [self checkTxtEncode];
    
    [self updateToolbarItems];
    
    navBarHide = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES];
}

/**
 *  暂时不使用
 */
-(void) checkTxtEncode{
    NSString *fileName = [pageURL lastPathComponent];
    
    if (fileName && [[fileName lowercaseString] hasSuffix:@".txt"])
    {
        NSData *attachmentData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:pageURL]];
        
        //txt分带编码和不带编码两种，带编码的如UTF-8格式txt，不带编码的如ANSI格式txt
        //不带的，可以依次尝试GBK和GBK编码
        NSString *aStr=[[NSString alloc] initWithData:attachmentData encoding:0x80000632];
        if (!aStr)
        {
            //用GBK编码不行,再用GB18030编码
            aStr=[[NSString alloc] initWithData:attachmentData encoding:0x80000631];
        }
        if( !aStr){
            aStr=[[NSString alloc] initWithData:attachmentData encoding:NSUTF8StringEncoding];
        }
        if(aStr){
            //通过html语言进行排版
            NSString* responseStr = [NSString stringWithFormat:
                                     @"<HTML>"
                                     "<head>"
                                     "<title>Text View</title>"
                                     "</head>"
                                     "<BODY>"
                                     "<pre>"
                                     "%@"
                                     "/pre>"
                                     "</BODY>"
                                     "</HTML>",
                                     aStr];
            
            [_webView loadHTMLString:responseStr baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        }else{
            NSURL *url=[[ NSURL alloc ] initWithString:pageURL];
            [_webView loadRequest:[ NSURLRequest requestWithURL:url]];
        }
    }else if ([self isUrl:pageURL]){
        NSURL *url=[[ NSURL alloc ] initWithString:pageURL];
        [_webView loadRequest:[ NSURLRequest requestWithURL:url]];
        
    }else{//富文本展示
        
        NSString* htmlString = [NSString stringWithFormat:
                                 @"<!DOCTYPE html>"
                                 "<html>"
                                 "<head>"
                                 "<meta charset=\"utf-8\">"
                                 "<title>详情</title>"
                                 "<style>"
                                 "img{"
                                 "width: auto;"
                                 "height:auto;"
                                "max-height: 100%%;"
                                "max-width: 100%%;"
                                 "}"
                                 "</style>"
                                 "</head>"
                                "<body  style=\"FONT-SIZE: 36px;\">"
                                 "%@"
                                 "</body>"
                                 "</html>",
                                 self.htmlString];
        [_webView loadHTMLString:htmlString baseURL:nil];

    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _webView = nil;
    _backBarButtonItem = nil;
    _forwardBarButtonItem = nil;
    _refreshBarButtonItem = nil;
    _stopBarButtonItem = nil;
    _refreshButtonItem = nil;
    _urlCopyButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    if(!navBarHide){
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    
}
-(id)initWithURL:(NSString *)url{
    self=[super init];
    if(self){
        if ([self isUrl:url]) {
            
            pageURL=url;
            
        }else{
            
            self.htmlString = url;
            self.titleLabel.text = @"详细信息";
            
        }
        
//        _htmlString = @"<p><strong>我是加粗</strong></p><p><em><strong>我是加粗斜体</strong></em></p><p><em>我是斜体</em></p><p><img src=\"https://sobot-test.oss-cn-beijing.aliyuncs.com/console/402921fbb4514fd2b2e573d1febf9b67/kb/image/60e8d5daf1c94ef8b42c1d3c4a65a96c.png\" title=\"60e8d5daf1c94ef8b42c1d3c4a65a96c.png\" alt=\"bitcode设置.png\"/></p><p><br/></p><p><em>哈哈<strong>哈哈</strong></em></p>";
        
    }
    return self;
}


-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_WEB_BACK){
        if(self.navigationController != nil && self.navigationController.childViewControllers.count>1){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 处理掉底部输入框的痕迹
            self.navigationController.toolbarHidden = YES;
        });
        
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateToolbarItems];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}



- (void)updateToolbarItems {
    self.backBarButtonItem.enabled = _webView.canGoBack;
    self.forwardBarButtonItem.enabled = _webView.canGoForward;
    
//    UIBarButtonItem *refreshStopBarButtonItem = _webView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    // 显示刷新的按钮
    UIBarButtonItem *refreshStopBarButtonItem =  self.refreshBarButtonItem  ;
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat toolbarWidth = 250.0f;
        fixedSpace.width = 35.0f;
        
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          refreshStopBarButtonItem,
                          fixedSpace,
                          self.backBarButtonItem,
                          fixedSpace,
                          self.forwardBarButtonItem,
                          fixedSpace,
                          self.urlCopyButtonItem,
                          nil];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f)];
        toolbar.items = items;
        toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationItem.rightBarButtonItems = items.reverseObjectEnumerator.allObjects;
    }
    
    else {
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          self.backBarButtonItem,
                          flexibleSpace,
                          self.forwardBarButtonItem,
                          flexibleSpace,
                          self.urlCopyButtonItem,
                          flexibleSpace,
                          refreshStopBarButtonItem,
                          fixedSpace,
                          nil];
        
        self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.toolbarItems = items;
        
    }
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
//        _backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_back"]
//                                                              style:UIBarButtonItemStylePlain
//                                                             target:self
//                                                             action:@selector(goBackTapped:)];
//        _backBarButtonItem.width = 18.0f;
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_back"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_back_pressed"] forState:UIControlStateHighlighted];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_back_disabled"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(goBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _backBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        
        _backBarButtonItem.width = 25.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    if (!_forwardBarButtonItem) {
//        _forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_next"]
//                                                                 style:UIBarButtonItemStylePlain
//                                                                target:self
//                                                                action:@selector(goForwardTapped:)];
//        _forwardBarButtonItem.width = 18.0f;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_next"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_next_pressed"] forState:UIControlStateHighlighted];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_next_disabled"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(goForwardTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _forwardBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        
        _forwardBarButtonItem.width = 25.0f;
        
        
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
      
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_refreshbar_normal"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_refreshbar_pressed"] forState:UIControlStateHighlighted];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_refreshbar_pressed"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(reloadTapped:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _refreshBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];

        _refreshBarButtonItem.width = 25.0f;
        
    }
    return _refreshBarButtonItem;
}



- (UIBarButtonItem *)urlCopyButtonItem {
    if (!_urlCopyButtonItem) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_copy_nols"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_copy_press"] forState:UIControlStateHighlighted];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_web_copy_press"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(copyURL:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _urlCopyButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        
        _urlCopyButtonItem.width = 25.0f;
        
    }
    return _urlCopyButtonItem;
}

#pragma mark - Target actions

- (void)goBackTapped:(UIBarButtonItem *)sender {
    [_webView goBack];
}

- (void)goForwardTapped:(UIBarButtonItem *)sender {
    [_webView goForward];
}

- (void)reloadTapped:(UIBarButtonItem *)sender {
    
    //v2.7.9 如果是通过htmlstring直接加载的页面无URL，不需要刷新
    if (zcLibConvertToString(pageURL).length == 0) {
        return;
    }
    
    [_webView reload];
}

- (void)copyURL:(UIBarButtonItem *)sender{
    NSString *currentURL = [_webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    
    if (zcLibConvertToString(currentURL).length >0) {
        //    NSLog(@"复制链接%@",currentURL);
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:zcLibConvertToString(currentURL)];
        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@" 复制成功 ") duration:1.0f view:self.view position:ZCToastPositionCenter];
    }

}


- (BOOL)isUrl:(NSString *)urlString{
    if(urlString == nil)
        return NO;
    NSString *url;
    if (urlString.length>4 && [[urlString substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",urlString];
        
    }else{
        url = urlString;
        
    }
    //    NSString *urlRegex = @"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://((((25[0-5]|2[0-4]\\d|1?\\d?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1?\\d?\\d))|([0-9a-z_!~*'()-]*\\.?))([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.([a-z]{2,6})(:[0-9]{1,4})?([a-zA-Z/?_=]*)\\.\\w{1,5}";
    NSString*urlRegex =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
    
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
