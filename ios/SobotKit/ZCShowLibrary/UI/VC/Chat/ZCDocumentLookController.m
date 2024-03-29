//
//  ZCDocumentLookController.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/9.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCDocumentLookController.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"

@interface ZCDocumentLookController ()<UIDocumentInteractionControllerDelegate,NSURLConnectionDataDelegate>{
    
}
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic, strong) UIButton *btnDown;
@property (nonatomic, strong) UILabel *labSize;
@property (nonatomic, strong) UILabel *labLookTip;
@property (nonatomic, strong) UIView *viewProgress;
@property (nonatomic, strong) UIImageView *imgProgress;


//文件总大小
@property (nonatomic, assign) long long fileSize;
//本地已经下载了多少
@property (nonatomic, assign) long long currentSize;
//输出流
//不管输入流还是输出流, 参考对象都是内存
@property (nonatomic ,strong) NSOutputStream *output;
//下载的URLConnection
@property (nonatomic ,strong) NSURLConnection *conn;
//本地下载文件的存放路径
@property (nonatomic, copy) NSString *localFilePath;




@end

@implementation ZCDocumentLookController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
    }
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self createTitleView];
    
    [self.titleLabel setText:ZCSTLocalString(@"文件预览")];
    self.moreButton.hidden = YES;
    
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2-53/2, 41 + NavBarHeight, 53, 70)];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    [imgView setBackgroundColor:UIColor.clearColor];
    [imgView setImage:[ZCUITools getFileIcon:_message.richModel.richmoreurl fileType:_message.richModel.fileType]];
    
    UILabel *labName = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(imgView.frame)+20, ScreenWidth - 40, 0)];
    [labName setFont:DetGoodsFont];
    [labName setTextColor:UIColorFromRGB(robotListTextColor)];
    [labName setTextAlignment:NSTextAlignmentCenter];
    labName.numberOfLines = 0;
    [labName setText:_message.richModel.msg];
    [self autoHeightOfLabel:labName with:ScreenWidth - 40];
    
    
    _labSize = [[UILabel  alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(labName.frame) + 15, ScreenWidth, 21)];
    [_labSize setTextColor:UIColorFromRGB(SatisfactionTextColor)];
    [_labSize setTextAlignment:NSTextAlignmentCenter];
    [_labSize setFont:ListDetailFont];
    
    
    _viewProgress = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_labSize.frame) + 20, ScreenWidth - 40, 15)];
    [_viewProgress setBackgroundColor:UIColor.clearColor];
    
    [self addProgressView];
    _viewProgress.hidden = YES;
    
    _btnDown = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDown setTitle:ZCSTLocalString(@"立即下载") forState:0];
    [_btnDown setBackgroundColor:[ZCUITools zcgetDynamicColor]];
    [_btnDown setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:0];
    _btnDown.layer.cornerRadius = 2.0;
    _btnDown.layer.masksToBounds = YES;
    _btnDown.tag = BUTTON_EVALUATION;
    [_btnDown setFrame:CGRectMake(38, CGRectGetMaxY(_labSize.frame) + 20, ScreenWidth - 38*2, 44)];
    [_btnDown addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    _labLookTip = [[UILabel  alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnDown.frame) + 10, ScreenWidth, 18)];
    [_labLookTip setTextColor:UIColorFromRGB(SatisfactionTextColor)];
    [_labLookTip setTextAlignment:NSTextAlignmentCenter];
    [_labLookTip setFont:ListDetailFont];
    [_labLookTip setText:ZCSTLocalString(@"智齿暂时无法打开此类文件，可使用其他应用打开浏览")];
    _labLookTip.hidden = YES;
    
    [self.view addSubview:imgView];
    [self.view addSubview:labName];
    [self.view addSubview:_labSize];
    [self.view addSubview:_viewProgress];
    [self.view addSubview:_btnDown];
    [self.view addSubview:_labLookTip];
    
    
    //拿到cache目录的路径
    
    NSString *dataPath = zcLibGetDocumentsFilePath(@"/sobot/");
    // 创建目录
    zcLibCheckPathAndCreate(dataPath);
    
    //拼接文件的路径
    self.localFilePath = [dataPath stringByAppendingPathComponent:_message.richModel.msg];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //从服务器获取文件的总大小
        [self getServerFileSize];
        [self getLocalFileSize];
        
        [self changeDownStatus];
    });
}

-(void)addProgressView{
    CGFloat pw = _viewProgress.bounds.size.width;
    CGFloat ph = _viewProgress.bounds.size.height;
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ph/2 - 2, pw, 4)];
    [bgView setBackgroundColor:UIColorFromRGB(LineTextMenuColor)];
    bgView.layer.cornerRadius = 2.0;
    bgView.layer.masksToBounds = YES;
    [_viewProgress addSubview:bgView];
    
    
    _imgProgress = [[UIImageView alloc] initWithFrame:CGRectMake(0, ph/2 - 2, 1, 4)];
    [_imgProgress setBackgroundColor:[ZCUITools zcgetDynamicColor]];
    _imgProgress.layer.cornerRadius = 2.0;
    _imgProgress.layer.masksToBounds = YES;
    [_viewProgress addSubview:bgView];
    
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setBackgroundColor:UIColor.clearColor];
    [btnCancel setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_close_down"] forState:0];
    btnCancel.layer.cornerRadius = 2.0;
    btnCancel.layer.masksToBounds = YES;
    [btnCancel setFrame:CGRectMake(pw - 15, 0,15, 15)];
    btnCancel.tag = BUTTON_CLOSE;
    [btnCancel addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewProgress addSubview:btnCancel];
}


// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_BACK){
        if(self.navigationController != nil ){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
    
    if(sender.tag == BUTTON_MORE){
        NSURL *url = [NSURL fileURLWithPath:self.localFilePath];
        _documentInteractionController = [UIDocumentInteractionController
                                          interactionControllerWithURL:url];
        [_documentInteractionController setDelegate:self];

        [_documentInteractionController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
//        [_documentInteractionController presentPreviewAnimated:YES];
    }
    
    // 下载
    if(sender.tag == BUTTON_EVALUATION){
        _btnDown.hidden = YES;
        _viewProgress.hidden = NO;
        _labLookTip.hidden = YES;
        
        [self downloadFile];
    }
    
    if(sender.tag == BUTTON_CLOSE){
        // 取消下载
        [self.conn cancel];
        
        _labLookTip.hidden = YES;
        _viewProgress.hidden = YES;
        _btnDown.hidden = NO;
        [_btnDown setTitle:ZCSTLocalString(@"立即下载") forState:0];
        _btnDown.tag = BUTTON_EVALUATION;
    }
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller{
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller{
    
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}



-(void)changeDownStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        //本地文件已经存在并且是下载完成的,那么就不去下载
        if(self.currentSize == self.fileSize || [_message.richModel.richmoreurl hasPrefix:@"file:///"]){
//            NSLog(@"文件已下载完成, 请不要重复下载");
            
            _viewProgress.hidden = YES;
            _btnDown.hidden = NO;
            _labLookTip.hidden = NO;
            
            _btnDown.tag = BUTTON_MORE;
            
            [_labSize setText:[NSString stringWithFormat:ZCSTLocalString(@"文件大小:%.2fKB)"),self.fileSize*1.0/1024]];
            [_labSize setFont:ListTimeFont];
            
            [_btnDown setTitle:ZCSTLocalString(@"用其他应用打开") forState:0];
            return ;
        }else{
            [_labSize setText:[NSString stringWithFormat:ZCSTLocalString(@"正在下载中...(%.2fKB/%.2fKB)"),(self.currentSize*1.0)/1024,self.fileSize*1.0/1024]];
            [_labSize setFont:VoiceButtonFont];
            
            CGRect f = _imgProgress.frame;
            f.size.width = (ScreenWidth - 40) * (self.currentSize*1.0/self.fileSize);
            _imgProgress.frame = f;
        }
    });
}



//获取本地沙盒已经下载的文件的大小
- (void)getLocalFileSize{
//    NSLog(@"获取本地文件大小之前:%lld",self.currentSize);
    //操作本地文件的管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    
    //attributesOfItemAtPath 返回给定路径文件的属性(大小, 时间)
    NSDictionary *dict = [manager attributesOfItemAtPath:self.localFilePath error:NULL];
    //给当前文件的大小的变量赋值
    //fileSize 返回本地文件的大小
    self.currentSize = dict.fileSize;
//    NSLog(@"获取本地文件大小之后:%lld",self.currentSize);
}

//获取文件的总大小(从服务器上获取)
- (void)getServerFileSize{
    //1. url
    NSURL *url = [NSURL URLWithString:zcUrlEncodedString(_message.richModel.richmoreurl)];
    //2.request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置HEAD请求方法
    request.HTTPMethod = @"HEAD";
    
    //创建NSURLResponse
    NSURLResponse *response  = [NSURLResponse new];
    
    //HEAD请求可以用同步的方法
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    //给文件总长度赋值
    self.fileSize = response.expectedContentLength;
}


//具体下载文件的方法
- (void)downloadFile{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //从服务器获取文件的总大小
        [self getServerFileSize];
        [self getLocalFileSize];
        
        [self changeDownStatus];
        //本地文件已经存在并且是下载完成的,那么就不去下载
        if(self.currentSize == self.fileSize){
//            NSLog(@"文件已下载完成, 请不要重复下载");
            return ;
        }
        
        //如果本地文件比服务器上的文件要大, 说明下载的本地文件有问题,删除本地文件,重新下载
        if (self.currentSize > self.fileSize) {
            //操作本地文件的管理器
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtPath:self.localFilePath error:NULL];
            self.currentSize = 0;
        }
        
        //比较服务器文件的总大小和本地文件的总大小
        //1. url
        NSURL *url = [NSURL URLWithString:zcUrlEncodedString(_message.richModel.richmoreurl)];
        //2.request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //设置请求头 Range
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-",self.currentSize];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 使用下面的方法 NSURLConnection就会自动去请求数据了
        self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
        
        //运行循环--- 处理一些事件(点击, 触摸, 移动), 定时器, 任务
        //开启子线程的运行循环--- 如果要想子线程运行任务,必须要手动开启运行循环
        [[NSRunLoop currentRunLoop] run];
    });
    
}

#pragma mark - NSURLConnectionDataDelegate
//当接收到服务器的响应时, 调用的代理方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    NSLog(@"%@接收到服务器的响应:" ,response);
//    NSLog(@"%@",[NSThread currentThread]);
    
    //创建输出流
    //append 表示是否是添加数据
    self.output = [NSOutputStream outputStreamToFileAtPath:self.localFilePath append:YES];
    
    [self.output open];
}

//接收到服务器的数据, 这个方法会调用多次
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    NSLog(@"%@",[NSThread currentThread]);
    
    //    NSLog(@"%lu接收到服务器文件的数据:" ,(unsigned long)data.length);
    self.currentSize += data.length;
    
    //计算下载进度
    float progress =  self.currentSize*1.0/self.fileSize;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeDownStatus];
    });
//    NSLog(@"%f%%",progress*100);
    
    //通过输出流往沙盒里写数据
    [self.output write:data.bytes maxLength:data.length];
}

//下载完成之后会调用的代理方法
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    NSLog(@"下载完成");
//    NSLog(@"%@",[NSThread currentThread]);
    
    //关闭输出流
    [self.output close];
    
    [self changeDownStatus];
}

//下载出错时回调方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
//    NSLog(@"下载出错了,请重新下载");
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}





/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
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
    [self createLeftBarItemSelect:@selector(buttonClick:) norImageName:img  highImageName:selImg];
}

- (void)createLeftBarItemSelect:(SEL)select norImageName:(NSString *)imageName highImageName:(NSString *)heightImageName{
    //12 * 19
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn.titleLabel setFont:[ZCUITools zcgetTitleFont]];
    [btn addTarget:self action:select forControlEvents:UIControlEventTouchUpInside];
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
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = Btn_BACK;
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateDisabled];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackNolColor] && [ZCUICore getUICore].kitInfo.topBackNolColor != nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackNolColor] forState:UIControlStateNormal];
    }
    if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackSelColor] && [ZCUICore getUICore].kitInfo.topBackSelColor !=nil) {
        [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
    
    CGRect lf = btn.frame;
    lf.size.width=60;
    [btn setFrame:lf];
    [btn setTitle:ZCSTLocalString(@"返回") forState:UIControlStateNormal];
    if ([ZCUICore getUICore].kitInfo.topBackTitle != nil) {
        [btn setTitle:[ZCUICore getUICore].kitInfo.topBackTitle forState:UIControlStateNormal];
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    //    self.navigationItem.leftBarButtonItem = item;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
    
    /**
     width为负数时，相当于btn向右移动width数值个像素，由于按钮本身和  边界间距为5pix，所以width设为-5时，间距正好调整为0；width为正数 时，正好相反，相当于往左移动width数值个像素
     */
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, item, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    
    
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetDynamicColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
        [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
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
