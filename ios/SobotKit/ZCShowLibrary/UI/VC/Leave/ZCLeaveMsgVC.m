//
//  ZCLeaveMsgVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/4/3.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCLeaveMsgVC.h"
#import "ZCUICore.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIPlaceHolderTextView.h"
#import "ZCLibServer.h"
#import "ZCUIImageTools.h"
#import "ZCMLEmojiLabel.h"
#import "ZCUIWebController.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

@interface ZCLeaveMsgVC ()<ZCMLEmojiLabelDelegate,UITextFieldDelegate,UITextViewDelegate>{
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    NSString * callURL;
    CGPoint        contentoffset;// 记录list的偏移量
    
    UILabel  * detailLab ;  // 问题描述
   
}

@property (nonatomic,strong) ZCUIPlaceHolderTextView * textView;

@property (nonatomic,strong) ZCMLEmojiLabel * tipLab;

@property (nonatomic,strong) UIScrollView * scrollView;

@end

@implementation ZCLeaveMsgVC

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
    
//        self.navigationItem.leftBarButtonItem = item;
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
        rightBtn.tag = BUTTON_MORE;
        [rightBtn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
        self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetDynamicColor]];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    viewHeigth = self.view.frame.size.height;
    viewWidth = self.view.frame.size.width;
    // Do any additional setup after loading the view.
    //    [self.navigationController setNavigationBarHidden:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    //    if (self.navigationController.navigationBarHidden) {
    self.navigationController.navigationBar.translucent = NO;
    //    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"留言消息");
       
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    }else{
        [self createTitleView];
        self.titleLabel.text = ZCSTLocalString(@"留言消息");
        
        // 提交 的button 2.7.1 页面改版 位置改变
    
        [self.moreButton setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
        [self.moreButton setTitle:ZCSTLocalString(@"提交") forState:UIControlStateHighlighted];
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@""] forState:UIControlStateNormal];
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@""] forState:UIControlStateHighlighted];
        [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//        self.moreButton.alpha = 0.4;
//        self.moreButton.userInteractionEnabled = NO;
        
        //back
        [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.view.backgroundColor = UIColorFromRGB(0xEFF3FA);
    
    [self layoutSubViews];
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
}

-(void)tapAction:(UITapGestureRecognizer *)sender{
    [self hideKeyboard];
}


-(void)buttonClick:(UIButton*)sender{
    if (sender.tag == BUTTON_BACK) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }else if (sender.tag == BUTTON_MORE){
        if (_textView.text.length <=0) {
            return;
        }
        
        __weak ZCLeaveMsgVC * saveSelf = self;
        [[ZCLibServer getLibServer] getLeaveMsgWith:[[ZCUICore getUICore] getLibConfig].uid Content:_textView.text start:^{
            
        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            if (dict) {
                // 返回，发送留言消息
                if (saveSelf.passMsgBlock) {
                    saveSelf.passMsgBlock(saveSelf.textView.text);
                }
                if (saveSelf.navigationController) {
                    [saveSelf.navigationController popViewControllerAnimated:NO];
                }else{
                    [saveSelf dismissViewControllerAnimated:NO completion:nil];
                }
            }
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            NSLog(@"%@",errorMessage);
        }];
        
    }
}

-(void)layoutSubViews{
    CGFloat y = 0;
    if (self.navigationController.navigationBarHidden) {
        y = NavBarHeight;
    }
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, viewWidth, viewHeigth -NavBarHeight)];
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.backgroundColor = UIColorFromRGB(0xF0F3FC);
    [self.view addSubview:_scrollView];
    
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
    _tipLab = [[ZCMLEmojiLabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 0)];
    _tipLab.textColor = UIColorFromRGB(TextWordOrderListTextColor);
    _tipLab.font = ListDetailFont;
    _tipLab.numberOfLines = 0;
    _tipLab.backgroundColor = [UIColor clearColor];
    [_tipLab setTextAlignment:NSTextAlignmentLeft];
    [_tipLab setTextColor:UIColorFromRGB(TextWordOrderListTextColor)];
    _tipLab.numberOfLines = 0;
    _tipLab.isNeedAtAndPoundSign = NO;
    _tipLab.disableEmoji = NO;
    
    _tipLab.lineSpacing = 3.0f;
    [_tipLab setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
    _tipLab.delegate = self;
    NSString *text = @"";
    if (_msgTxt !=nil && _msgTxt.length > 0) {
        text = zcLibConvertToString(_msgTxt);
    }
//    NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
    
        if (text1.length > 0 && text1 != nil) {
            _tipLab.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:_tipLab textColor:UIColorFromRGB(TextWordOrderListTextColor) textFont:ListDetailFont linkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }else{
            _tipLab.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }
        
    }];
    
//    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
//    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//    while ([text hasPrefix:@"\n"]) {
//        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//    }
//    NSMutableDictionary *dict = [_tipLab getTextADict:text];
//    if(dict){
//        text = dict[@"text"];
//    }
//
//    if(dict){
//        NSArray *arr = dict[@"arr"];
//        //    [_emojiLabel setText:tempText];
//        for (NSDictionary *item in arr) {
//            NSString *text = item[@"htmlText"];
//            int loc = [item[@"realFromIndex"] intValue];
//
//            // 一定要在设置text文本之后设置
//            [_tipLab addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
//        }
//    }
//    [_tipLab setText:text];
    CGSize  labSize  =  [_tipLab preferredSizeWithMaxWidth:ScreenWidth-30];
    _tipLab.frame = CGRectMake(15, 15, labSize.width, labSize.height);
    [_scrollView addSubview:_tipLab];
    
    
   
    UIView * wbgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tipLab.frame) +ZCNumber(15),ScreenWidth , 30)];
    wbgView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:wbgView];
     detailLab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(10), 5, ScreenWidth - ZCNumber(30), 20)];
//    detailLab.text = @"问题描述*";
    detailLab.font = [UIFont systemFontOfSize:14];
    detailLab.textColor = UIColorFromRGB(TextUnPlaceHolderColor);
    detailLab.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:@"问题描述*"];
    [wbgView addSubview:detailLab];
    
    _textView = [[ZCUIPlaceHolderTextView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(wbgView.frame), viewWidth, ZCNumber(130))];
    _textView.type = 1;
    NSString * tmp =   zcLibConvertToString(self.msgTmp);
    // 过滤标签
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    tmp =  [NSString stringWithFormat:@"%@",tmp];
    
    _textView.placeholder = tmp;
    [_textView setPlaceholderColor:UIColorFromRGB(TextPlaceHolderColor)];
    [_textView setFont:DetGoodsFont];
    [_textView setTextColor:UIColorFromRGB(TextUnPlaceHolderColor)];
    _textView.delegate = self;
    _textView.placeholederFont = DetGoodsFont;
    [_scrollView addSubview:_textView];
        
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

#pragma mark -- 键盘滑动的高度

- (void) hideKeyboard {
    [_textView resignFirstResponder];
    [self allHideKeyBoard];
    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
        [_scrollView setContentOffset:contentoffset];
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

#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    //    NSLog(@"url:%@  url.absoluteString:%@",url,url.absoluteString);
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
