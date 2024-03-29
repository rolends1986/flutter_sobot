//
//  ZCXJAlbumController.m
//  SobotKit
//
//  Created by zhangxy on 2017/4/5.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCXJAlbumController.h"
#import "ZCLibHttpManager.h"
#import "ZCActionSheet.h"
#import "ZCUIImageTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUICore.h"
@interface ZCXJAlbumController ()<ZCActionSheetDelegate>

@end

@implementation ZCXJAlbumController
{
    //UI
    UIScrollView *wholeScoll;
    UIPageControl * pageControl;
    //member
    NSMutableArray * mImgUrlArr;             //图片链接数组
    NSMutableArray * mImgLocationArr;        //本地图片数组
    NSInteger mcurpage;               //当前显示页
    CGSize  maxSize;                  //最大的Size
    CGSize  minSize;                  //最小的Size
    CGFloat maxScale;                 //最大放大倍数
    CGFloat imgviewInitMarginY;       //imgview初始化的Y轴Margin
    CGFloat imgviewmarginY;           //imgview的Y轴Margin
    CGFloat offsetPinchX;
    CGFloat xInScreen;
    CGSize  oldSize;
    CGSize  endSize;
    CGFloat oldLength;
    CGFloat newLength;
    CGPoint oldFirstPoint;
    CGPoint oldSecondPoint;
    CGPoint newFirstPoint ;
    CGPoint newSecondPoint ;
    CGSize  newSize;
    CGPoint centrePoint;              //捏合时的中心点
    BOOL    isBigger;                 //是否已经放大
    CGFloat biggerScale;              //放大的倍数
    
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}


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

-(void)viewDidAppear:(BOOL)animated
{
    
}



-(id)initWithImgUrlArr:(NSMutableArray*)array CurPage:(NSInteger)curpage
{
    mImgUrlArr = array;
    mcurpage = curpage;
    self = [super init];
    self.view.frame = [UIScreen mainScreen].bounds;
    if (self) {
        [self setWholeScoll];
        [self setImagesUrlAlbum];
        [self setPage];
        [self setMemer];
    }
    return self;
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
    
    //    self.navigationItem.leftBarButtonItem = item;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
    
    /**
     width为负数时，相当于btn向右移动width数值个像素，由于按钮本身和  边界间距为5pix，所以width设为-5时，间距正好调整为0；width为正数 时，正好相反，相当于往左移动width数值个像素
     */
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, item, nil];
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(viewWidth - 60, NavBarHeight - 40, 50, 40);
    
    [rightBtn.imageView setContentMode:UIViewContentModeCenter];
    [rightBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_delete_icon"] forState:UIControlStateNormal];
    [rightBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_delete_icon"] forState:UIControlStateHighlighted];

    rightBtn.tag = BUTTON_MORE;
    [rightBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
       [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
}


-(id)initWithImgULocationArr:(NSMutableArray*)array CurPage:(NSInteger)curpage
{
    mImgLocationArr = array;
    mcurpage = curpage;
    self = [super init];
    self.view.frame = [UIScreen mainScreen].bounds;
    if (self) {
        [self setWholeScoll];
        [self setImagesLocationAlbum];
        [self setPage];
        [self setMemer];
        
        if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
            self.navigationController.navigationBarHidden = YES;
            [self createTitleView];
            [self.topView setBackgroundColor:[UIColor clearColor]];
            [self.titleLabel setText:[NSString stringWithFormat:@"%zd/%zd",mcurpage+1,array.count]];
            [self.moreButton.imageView setContentMode:UIViewContentModeCenter];
            [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_delete_icon"] forState:UIControlStateNormal];
            [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_delete_icon"] forState:UIControlStateHighlighted];
        }else{
            [self setNavigationBarStyle];
            self.title = [NSString stringWithFormat:@"%zd/%zd",mcurpage+1,array.count];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
        }
        
    }
    return self;
}
-(void)setMemer
{
    isBigger = NO;
    maxScale = 3.0;
    maxSize = CGSizeMake(myScreenWidth*3.0, myScreenHeight*3.0);
    minSize = CGSizeMake(myScreenWidth, myScreenHeight);
}
-(void)setWholeScoll
{
    wholeScoll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, myScreenWidth, myScreenHeight)];
    wholeScoll.backgroundColor = [UIColor blackColor];
    wholeScoll.contentOffset = CGPointMake(wholeScoll.frame.size.width*mcurpage, 0);
    [self.view addSubview:wholeScoll];
    wholeScoll.pagingEnabled = YES;
    wholeScoll.delegate = self;
}
-(void)setPage
{
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = mImgLocationArr?mImgLocationArr.count:mImgUrlArr.count;
    pageControl.currentPage   = mcurpage;
    pageControl.frame = CGRectMake(0,myScreenHeight-40, myScreenWidth, 40);
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
}

-(void)setImagesLocationAlbum
{
    wholeScoll.contentSize = CGSizeMake(myScreenWidth*mImgLocationArr.count, myScreenHeight);
    for (int i = 0; i<mImgLocationArr.count; i++) {
        //设置 imageview
        UIImageView * imgview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, myScreenWidth, myScreenHeight)];
        imgview.contentMode = UIViewContentModeScaleAspectFit;
        if(zcLibCheckFileIsExsis([mImgLocationArr objectAtIndex:i])){
            UIImage *img=[UIImage imageWithContentsOfFile:[mImgLocationArr objectAtIndex:i]];
        
//        UIImage *img  = [UIImage imageNamed:[mImgLocationArr objectAtIndex:i]];
            imgview.image = img;
        }
        imgview.frame = [self getRectfixMinImageView:imgview];
        //设置 scrollview
        UIScrollView * singleview = [[UIScrollView alloc]initWithFrame:CGRectMake(myScreenWidth*i,-20,myScreenWidth, myScreenHeight)];

        [wholeScoll addSubview:singleview];
        [singleview addSubview:imgview];
        singleview.tag = 101+i;
        // 添加手势
        [self addGestureRecognizer];
    }
}
-(void)setImagesUrlAlbum
{
    wholeScoll.contentSize = CGSizeMake(myScreenWidth*mImgUrlArr.count, myScreenHeight);
    for (int i = 0; i<mImgUrlArr.count; i++) {
        
        UIActivityIndicatorView * Indicator = [[UIActivityIndicatorView alloc]init];
        Indicator.center = CGPointMake(myScreenWidth/2+i*myScreenWidth,myScreenHeight/2);
        [Indicator startAnimating];
        UIScrollView * singleview = [[UIScrollView alloc]initWithFrame:CGRectMake(myScreenWidth*i,0,myScreenWidth, myScreenHeight)];
        [singleview setBackgroundColor:[UIColor blackColor]];
        UIImageView * imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,myScreenWidth, myScreenHeight)];
        imgview.contentMode = UIViewContentModeScaleAspectFit;
        [wholeScoll addSubview:Indicator];
        
        
        [ZCLibHttpManager get:[mImgUrlArr objectAtIndex:i] start:^{
            
        } finish:^(id response, NSData *data) {
            //设置image
            imgview.image = [UIImage imageWithData:data];;
            imgview.frame = [self getRectfixMinImageView:imgview];
            //设置 scrollview
            [Indicator stopAnimating];
        } complete:^(NSDictionary *dict) {
            
        } fail:^(id response, NSString *errorMsg, NSError *connectError) {
            
        } progress:^(CGFloat progress) {
            
        }];
//        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:[mImgUrlArr objectAtIndex:i]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            ;
//        }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            //设置image
//            imgview.image = image;
//            imgview.frame = [self getRectfixMinImageView:imgview];
//            //设置 scrollview
//            [Indicator stopAnimating];
//        }];
        singleview.tag = 101+i;
        [wholeScoll addSubview:singleview];
        [singleview addSubview:imgview];
        
        // 添加手势
        [self addGestureRecognizer];
    }
}
#pragma mark 手势
-(void)addGestureRecognizer
{
    NSInteger count = mImgUrlArr?mImgUrlArr.count:mImgLocationArr.count;
    for (int i =0; i<count; i++) {
        UIScrollView *singleview = (UIScrollView*)[wholeScoll viewWithTag:101+i];
        
        //单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnScrollView)];
        [singleview addGestureRecognizer:singleTap];
    
        //双击手势
//        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapOnScrollView:)];
//        [singleview addGestureRecognizer:doubleTap];
//        [doubleTap setNumberOfTapsRequired:2];
//        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        //捏合手势
        UIPinchGestureRecognizer * pinchGes = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchOnScrollView:)];
        [singleview addGestureRecognizer:pinchGes];
    }
}
#pragma mark 单击
-(void)singleTapOnScrollView
{
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+mcurpage];
    UIImageView * imgview = singleScrollView.subviews[0];
    [_myDelegate getCurPage:mcurpage];
    if (isBigger) {
        [UIView animateWithDuration:0.5 animations:^{
            imgview.frame = [self getRectfixMinImageView:imgview];
            singleScrollView.contentSize = [self getScrollViewContentSize:imgview];
            singleScrollView.contentOffset = CGPointMake(0, 0);
        }completion:^(BOOL finished) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_BACK){
        [self singleTapOnScrollView];
    }
    if(sender.tag == BUTTON_MORE){
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) showTitle:ZCSTLocalString(@"要删除这张照片吗？") CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"删除"), nil];
        mysheet.selectIndex = 2;
        [mysheet show];
        
    }
}


- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 2){
        
        
        if(self.myDelegate && [self.myDelegate respondsToSelector:@selector(delCurPage:)]){
            [self.myDelegate delCurPage:mcurpage];
        }
        
        
        if(mImgLocationArr.count == 0){
            [self singleTapOnScrollView];
        }else if(mcurpage == mImgLocationArr.count){
            UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+mcurpage];
            [singleScrollView removeFromSuperview];
            mcurpage = mcurpage - 1;
            wholeScoll.contentSize = CGSizeMake(myScreenWidth*mImgLocationArr.count, myScreenHeight);
            pageControl.numberOfPages = mImgLocationArr?mImgLocationArr.count:mImgUrlArr.count;
            [pageControl setCurrentPage:mcurpage];
        }else{
            for(UIScrollView *v in wholeScoll.subviews){
                [v removeFromSuperview];
            }
            
            [self setImagesLocationAlbum];
            pageControl.numberOfPages = mImgLocationArr?mImgLocationArr.count:mImgUrlArr.count;
            [pageControl setCurrentPage:mcurpage];
        }
        
        [self.titleLabel setText:[NSString stringWithFormat:@"%zd/%zd",pageControl.currentPage+1,pageControl.numberOfPages]];
    }
}

#pragma mark 双击
-(void)doubleTapOnScrollView:(UITapGestureRecognizer*)doubletap
{
    // 放大  获取到点击的位置
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+pageControl.currentPage];
    
    UIImageView * imgview = singleScrollView.subviews[0];

    CGFloat imgHeight = imgview.frame.size.height;
    CGFloat imgY = imgview.frame.origin.y;
    CGFloat imgX = imgview.frame.origin.x;
    CGPoint tapPoint = [doubletap locationInView:doubletap.view];
    CGFloat tapX = tapPoint.x;
    CGFloat tapY = tapPoint.y;
    BOOL isOutImgView = NO;
    XJAlbumOutImgViewPointType pointType = 0;
    
    if (tapY<imgY) {
        //上面
        pointType = XJAlbumOutImgViewPointLeftUp;
        if (tapX>myScreenWidth/2) {
            pointType = XJAlbumOutImgViewPointRightUp;
        }
        isOutImgView = YES;
    }
    else if(tapY>imgY+imgHeight)
    {
        //下面
        pointType = XJAlbumOutImgViewPointLeftDown;
        if (tapX>myScreenWidth/2) {
            pointType = XJAlbumOutImgViewPointRightDown;
        }
        isOutImgView = YES;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        if (isBigger) {
            //缩小
            singleScrollView.contentOffset = CGPointMake(0.0f, 0.0f);
            imgview.frame = [self getRectfixMinImageView:imgview];
            singleScrollView.contentSize = [self getScrollViewContentSize:imgview];
            isBigger = NO;
        }
        else
        {
            //放大
            
            imgview.frame = CGRectMake(0, 0,imgview.frame.size.width * maxScale, imgview.frame.size.height * maxScale);
            singleScrollView.contentSize = CGSizeMake(imgview.frame.size.width,imgview.frame.size.height);
            if (isOutImgView) {
                //如果点击的是在图片外面
//                NSLog(@"isout");
                
                switch (pointType) {
                    case XJAlbumOutImgViewPointLeftUp:
                    {
                        singleScrollView.contentOffset = CGPointMake(0, 0);
                    }
                        break;
                    case XJAlbumOutImgViewPointLeftDown:
                    {
                        singleScrollView.contentOffset = CGPointMake(0, imgview.frame.size.height - myScreenHeight);
                    }
                        break;
                    case XJAlbumOutImgViewPointRightDown:
                    {
                        singleScrollView.contentOffset = CGPointMake(imgview.frame.size.width - myScreenWidth, imgview.frame.size.height - myScreenHeight);
                    }
                        break;
                    case XJAlbumOutImgViewPointRightUp:
                    {
                        singleScrollView.contentOffset = CGPointMake(imgview.frame.size.width - myScreenWidth, 0);
                    }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                //将双击的点设置到屏幕的中心
                CGFloat offsetX = (tapX-imgX)*maxScale - myScreenWidth/2;
                CGFloat offsetY = (tapY-imgY)*maxScale - myScreenHeight/2;
                //如果超出最大范围，则设置边界值
                offsetY = offsetY<0?0:offsetY;
                offsetY = offsetY>imgview.frame.size.height-myScreenHeight?imgview.frame.size.height-myScreenHeight:offsetY;
                offsetX = offsetX<0?0:offsetX;
                offsetX = offsetX>imgview.frame.size.width - myScreenWidth?imgview.frame.size.width - myScreenWidth:offsetX;
                singleScrollView.contentOffset = CGPointMake(offsetX,offsetY);
            }
            isBigger = YES;
        }
    }];
}
#pragma mark 捏合
-(void)pinchOnScrollView:(UIPinchGestureRecognizer*)pinchGes
{
    // 捏合手势是  初始的中心点所在屏幕的位置不变
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+mcurpage];
    UIImageView * imgview = singleScrollView.subviews[0];
    
    if (!isBigger) {
        // 如果没有放大，初始值
        oldSize = imgview.frame.size;
        imgviewInitMarginY = imgview.frame.origin.y;
    }
    imgviewmarginY=imgviewInitMarginY;
    
    if (pinchGes.numberOfTouches==2) {
        
        if (pinchGes.state == UIGestureRecognizerStateBegan) {
            
            oldFirstPoint = [pinchGes locationOfTouch:0 inView:pinchGes.view];
            oldSecondPoint = [pinchGes locationOfTouch:1 inView:pinchGes.view];
            oldLength = [self caculateLengthBetweenP1:oldFirstPoint P2:oldSecondPoint];
            //计算出初始中心点
            centrePoint = CGPointMake((oldFirstPoint.x+oldSecondPoint.x)/2,(oldSecondPoint.y+oldFirstPoint.y)/2);
            xInScreen = centrePoint.x - offsetPinchX;
        }
        else if (pinchGes.state == UIGestureRecognizerStateChanged) {
            
            newFirstPoint = [pinchGes locationOfTouch:0 inView:pinchGes.view];
            newSecondPoint = [pinchGes locationOfTouch:1 inView:pinchGes.view];
            // 计算出两点之间的距离
            newLength = [self caculateLengthBetweenP1:newFirstPoint P2:newSecondPoint];
            // 计算出是放大或者是缩小
            biggerScale = newLength/oldLength;
            newSize = CGSizeMake(oldSize.width*biggerScale,oldSize.height*biggerScale);
            if (newSize.width>maxSize.width)
            {
                newSize = CGSizeMake(maxSize.width, [self getHeightInImageView:imgview imageWidth:maxSize.width]);
            }
            
            [self pinchBlewMinSize:singleScrollView imgView:imgview];
            
            isBigger = YES;
        }
        else
        {
            [self pinchBlewMinSize:singleScrollView imgView:imgview];
            oldSize = newSize;
        }
    }
    else
    {
        [self pinchBlewMinSize:singleScrollView imgView:imgview];
        oldSize = newSize;
    }
}
-(void)pinchBlewMinSize:(UIScrollView*)singleScrollView imgView:(UIImageView*)imgview
{
    if (newSize.width<minSize.width) {
        // 缩小
        newSize = CGSizeMake(minSize.width*0.965, [self getHeightInImageView:imgview imageWidth:minSize.width]*0.965);
        isBigger = NO;
        [self changeMethod:singleScrollView imgView:imgview];
        singleScrollView.contentOffset = CGPointMake(-minSize.width* 0.015, -minSize.width* 0.01);
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect imgRect = CGRectMake(0, imgviewmarginY, minSize.width, [self getHeightInImageView:imgview imageWidth:minSize.width]);
            imgview.frame = imgRect;
            singleScrollView.contentOffset = CGPointMake(0, 0);
        }];
    }
    else
    {
        [self changeMethod:singleScrollView imgView:imgview];
    }
}
- (void)changeMethod:(UIScrollView*)singleScroll imgView:(UIImageView*)imgView;
{
    // newSize
    imgviewmarginY = (myScreenHeight - newSize.height)/2;
    
    imgviewmarginY = imgviewmarginY<0?0:imgviewmarginY;
    
    imgviewmarginY = imgviewmarginY>imgviewInitMarginY?imgviewInitMarginY:imgviewmarginY;
    
    singleScroll.contentSize = newSize;
    
    CGRect imgRect = CGRectMake(0, imgviewmarginY, newSize.width, newSize.height);
    
    //    NSLog(@"%f---------%f---------%f",myScreenHeight-imgviewmarginY-newSize.height,imgviewmarginY,myScreenHeight);
    
    imgView.frame = imgRect;
    
    //难度在contentOffset
    //首先要知道初始中心点 x 的位置 centrePoint.x
    
    
    CGFloat newScale = newSize.width / minSize.width;
    
    // 算出 在屏幕的点
    
    if (newSize.width < maxSize.width && newScale>1) {
        offsetPinchX = xInScreen * (newScale - 1);
    }
    if (offsetPinchX<0) {
        offsetPinchX = 0;
    }
    if (offsetPinchX>(newSize.width - myScreenWidth)) {
        offsetPinchX = newSize.width - myScreenWidth;
    }
//    NSLog(@"%f ------ %f ------%f",offsetPinchX,centrePoint.x,newScale);
    
    if (newSize.width == maxSize.width) {
        
    }
    else
    {
        singleScroll.contentOffset = CGPointMake(offsetPinchX, 0);
    }
}

#pragma mark 委托
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+mcurpage];
    UIImageView *imgview = singleScrollView.subviews[0];
    imgview.frame = [self getRectfixMinImageView:imgview];
    singleScrollView.contentSize = [self getScrollViewContentSize:imgview];
    singleScrollView.contentOffset = CGPointMake(0, 0);
    mcurpage = scrollView.contentOffset.x / myScreenWidth;
    pageControl.currentPage = mcurpage;
    [_myDelegate getCurPage:mcurpage];
    
    [self.titleLabel setText:[NSString stringWithFormat:@"%zd/%zd",pageControl.currentPage+1,pageControl.numberOfPages]];
}

//初始化的rect
#pragma mark 初始化布局
-(CGRect)getRectfixMinImageView:(UIImageView*)imgview
{
    // 这个方法有问题
    UIImage *img = imgview.image;
    CGFloat imgWidth = img.size.width;
    CGFloat imgHeight = img.size.height;
    CGFloat kScale = img.size.height / img.size.width;
    imgWidth = myScreenWidth;
    imgHeight = imgWidth * kScale;
    CGFloat marginY = (myScreenHeight - imgHeight)/2;
    CGRect frame = CGRectMake(0, marginY, imgWidth, imgHeight);
    return frame;
}
// 获取imageview的高度
-(CGFloat)getHeightInImageView:(UIImageView*)imgview imageWidth:(CGFloat)imgWidth
{
    UIImage * img = imgview.image;
    CGFloat imgHeightWithWidthScale = img.size.height / img.size.width;
    CGFloat imgHeight = imgWidth * imgHeightWithWidthScale;
    return imgHeight;
}
// 获取Y轴的距离
-(CGFloat)getMarginfixMinImageView:(UIImageView*)imgview
{
    UIImage *img = imgview.image;
    CGFloat imgHeightWithWidthScale = img.size.height / img.size.width;
    CGFloat imgWidth = myScreenWidth;
    CGFloat imgHeight = imgWidth * imgHeightWithWidthScale;
    CGFloat marginY = (myScreenHeight - imgHeight)/2;
    return marginY;
}
-(CGSize)getScrollViewContentSize:(UIImageView*)imageview
{
    CGSize size = CGSizeMake(imageview.frame.size.width, imageview.frame.size.height);
    return size;
}
-(CGRect)getReSizeInImageView:(UIImageView*)imgview Size:(CGSize)size
{
    return CGRectMake(imgview.frame.origin.x, imgview.frame.origin.y, size.width, size.height);
}

#pragma mark -数学方法
- (CGFloat)caculateLengthBetweenP1:(CGPoint)p1 P2:(CGPoint)p2;
{
    CGFloat x = p1.x-p2.x;
    CGFloat y = p1.y-p2.y;
    return sqrtf(x*x+y*y);
}
-(CGPoint)caculateCentrePointP1:(CGPoint)p1 P2:(CGPoint)p2;
{
    return CGPointMake((p1.x+p2.x)/2,(p1.y+p2.y)/2);
}
#pragma mark 封装UI

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    [self setWholeScoll];
//    [self setImagesLocationAlbum];
//    [self setPage];
//    [self setMemer];
}

@end
