//
//  ZCZHPickView.m
//  ZCZHPickView
//
//  Created by liudianling on 14-11-18.
//  Copyright (c) 2014年 赵恒志. All rights reserved.
//
#define ZHToobarHeight 40
#import "ZCZHPickView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
@interface ZCZHPickView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic,copy)NSString *plistName;
@property(nonatomic,strong)NSArray *plistArray;
@property(nonatomic,assign)BOOL isLevelArray;
@property(nonatomic,assign)BOOL isLevelString;
@property(nonatomic,assign)BOOL isLevelDic;
@property(nonatomic,strong)NSDictionary *levelTwoDic;
@property(nonatomic,strong)UIToolbar *toolbar;

@property (nonatomic,strong) UIButton * rightBtn;
@property (nonatomic,strong) UIView * toolbarView;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,assign)NSDate *defaulDate;
@property(nonatomic,assign)BOOL isHaveNavControler;
@property(nonatomic,assign)NSInteger pickeviewHeight;
@property(nonatomic,copy)NSString *resultString;
@property(nonatomic,strong)NSMutableArray *componentArray;
@property(nonatomic,strong)NSMutableArray *dicKeyArray;
@property(nonatomic,copy)NSMutableArray *state;
@property(nonatomic,copy)NSMutableArray *city;
@end

@implementation ZCZHPickView

-(NSArray *)plistArray{
    if (_plistArray==nil) {
        _plistArray=[[NSArray alloc] init];
    }
    return _plistArray;
}

-(NSArray *)componentArray{

    if (_componentArray==nil) {
        _componentArray=[[NSMutableArray alloc] init];
    }
    return _componentArray;
}
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self setUpToolBar];
//
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismisView)];
//        [self addGestureRecognizer:tap];
//
//    }
//    return self;
//}

-(void)dismisView{
    [self remove];
}

-(instancetype)initPickviewWithPlistName:(NSString *)plistName isHaveNavControler:(BOOL)isHaveNavControler{
    
    self=[super init];
    if (self) {
        _plistName=plistName;
        self.plistArray=[self getPlistArrayByplistName:plistName];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
        
    }
    return self;
}
-(instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler{
    self=[super init];
    if (self) {
        self.plistArray=array;
        [self setArrayClass:array];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame DatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode isHaveNavControler:(BOOL)isHaveNavControler{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpToolBar];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismisView)];
        [self addGestureRecognizer:tap];
        _defaulDate = defaulDate;
//        [self setUpPickView];
        [self setUpDatePickerWithdatePickerMode:(UIDatePickerMode)datePickerMode];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}


-(NSArray *)getPlistArrayByplistName:(NSString *)plistName{
    
    NSString *path= [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSArray * array=[[NSArray alloc] initWithContentsOfFile:path];
    [self setArrayClass:array];
    return array;
}

-(void)setArrayClass:(NSArray *)array{
    _dicKeyArray=[[NSMutableArray alloc] init];
    for (id levelTwo in array) {
        
        if ([levelTwo isKindOfClass:[NSArray class]]) {
            _isLevelArray=YES;
            _isLevelString=NO;
            _isLevelDic=NO;
        }else if ([levelTwo isKindOfClass:[NSString class]]){
            _isLevelString=YES;
            _isLevelArray=NO;
            _isLevelDic=NO;
            
        }else if ([levelTwo isKindOfClass:[NSDictionary class]])
        {
            _isLevelDic=YES;
            _isLevelString=NO;
            _isLevelArray=NO;
            _levelTwoDic=levelTwo;
            [_dicKeyArray addObject:[_levelTwoDic allKeys] ];
        }
    }
}

-(void)setFrameWith:(BOOL)isHaveNavControler{
    CGFloat toolViewX = 0;
    CGFloat toolViewH = ScreenHeight;// _pickeviewHeight+ZHToobarHeight;
    CGFloat toolViewY ;
    if (isHaveNavControler) {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH-50;
    }else {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH;
    }
    CGFloat toolViewW = [UIScreen mainScreen].bounds.size.width;
    [self setBackgroundColor:UIColorFromRGBAlpha(0x000000, 0.4)];
    self.frame = CGRectMake(toolViewX, 0, toolViewW, toolViewH);
}
-(void)setUpPickView{
    
    if (_pickerView!= nil) {
        [_pickerView removeFromSuperview];
    }
    
//    UIPickerView *pickView=[[UIPickerView alloc] init];
//    [pickView setBackgroundColor:[UIColor whiteColor]];
//    pickView.delegate=self;
//    pickView.dataSource=self;
//    _pickeviewHeight = pickView.frame.size.height;
//    pickView.frame=CGRectMake(0, self.frame.size.height - _pickeviewHeight,pickView.frame.size.width, pickView.frame.size.height);
//    [self addSubview:pickView];
//    _pickerView=pickView;
    
    
    _pickerView = [[UIPickerView alloc] init];
    [_pickerView setBackgroundColor:[UIColor whiteColor]];
    _pickerView.delegate=self;
    _pickerView.dataSource=self;
    _pickeviewHeight = _pickerView.frame.size.height;
    _pickerView.frame=CGRectMake(0, self.frame.size.height - _pickeviewHeight,_pickerView.frame.size.width, _pickerView.frame.size.height);
    [self addSubview:_pickerView];


    [self ToolbarWithPickViewFrame];
}

-(void)setUpDatePickerWithdatePickerMode:(UIDatePickerMode)datePickerMode{
//    UIDatePicker *datePicker=[[UIDatePicker alloc] init];
//    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    datePicker.datePickerMode = datePickerMode;
//    [datePicker setBackgroundColor:[UIColor whiteColor]];
//    if (_defaulDate) {
//        [datePicker setDate:_defaulDate];
//    }
//    //[datePicker setMaximumDate:[NSDate date]];
//    [datePicker setMinimumDate:[[NSDate date] dateByAddingTimeInterval:-1000*60*60*24*365]];
//    _datePicker = datePicker;
//    _pickeviewHeight=datePicker.frame.size.height;
//    datePicker.frame=CGRectMake(0, ScreenHeight - _pickeviewHeight,ScreenWidth, datePicker.frame.size.height);
//    [self addSubview:datePicker];
    
    
    //
    if (_datePicker != nil) {
        [_datePicker removeFromSuperview];
    }
    
    _datePicker =[[UIDatePicker alloc] init];
    _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    _datePicker.datePickerMode = datePickerMode;
    [_datePicker setBackgroundColor:[UIColor whiteColor]];
    if (_defaulDate) {
        [_datePicker setDate:_defaulDate];
    }
    [_datePicker setMinimumDate:[[NSDate date] dateByAddingTimeInterval:-1000*60*60*24*365]];
    _pickeviewHeight = _datePicker.frame.size.height;
    _datePicker.frame=CGRectMake(0, self.frame.size.height - _pickeviewHeight,self.frame.size.width, _datePicker.frame.size.height);
    [self addSubview:_datePicker];
    
    
    [self ToolbarWithPickViewFrame];
}

-(void)setUpToolBar{
    _toolbar = [self setToolbarStyle];
//    [self setToolbarWithPickViewFrame];
    _toolbarView = [self setToolbarViewSubView];
    
    [self ToolbarWithPickViewFrame];
//    [self addSubview:_toolbar];
    [self addSubview:_toolbarView];
}
-(UIToolbar *)setToolbarStyle{
    UIToolbar *toolbar=[[UIToolbar alloc] init];
    
    UIBarButtonItem *lefttem=[[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    UIBarButtonItem *right=[[UIBarButtonItem alloc] initWithTitle:@"确定  " style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];
    toolbar.items=@[lefttem,centerSpace,right];
    
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(4, 1, 30, 20);
//    [btn setTitleColor:self.tintColor forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
//    [btn setTitle:@"取消" forState:UIControlStateNormal];
////    [btn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateNormal];
//    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
//    
//    UIButton *rightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightbtn.frame = CGRectMake(ScreenWidth - 15 - 30 ,15, 30, 20);
//    [rightbtn setTitleColor:self.tintColor forState:UIControlStateNormal];
//    [rightbtn addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
//    [rightbtn setTitle:@"确定" forState:UIControlStateNormal];
////    [rightbtn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateNormal];
//    UIBarButtonItem *rightBtnitem = [[UIBarButtonItem alloc]initWithCustomView:rightbtn];
//    
////    NSArray * buttonsArray = [NSArray arrayWithObjects:leftBtn,rightBtnitem,nil];
//    _toolbar.items = @[leftBtn,rightBtnitem];
    
    
    [self setTintColor:UIColorFromRGB(0x0DAEAF)];

    
    return toolbar;
}

-(UIView*)setToolbarViewSubView{
    _toolbarView = [[UIView alloc]init];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 10, 48, 20);
    [btn setTitleColor:self.tintColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateNormal];
    btn.titleLabel.font = DetGoodsFont;
    [_toolbarView addSubview:btn];
    
    UIButton *rightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightbtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    rightbtn.frame = CGRectMake(self.frame.size.width - 10 - 48 ,10, 48, 20);
    [rightbtn setTitleColor:self.tintColor forState:UIControlStateNormal];
    [rightbtn addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    [rightbtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightbtn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateNormal];
    rightbtn.titleLabel.font = DetGoodsFont;
    [_toolbarView addSubview:rightbtn];
    _rightBtn = rightbtn;
    
    return _toolbarView;
}

-(void)setToolbarWithPickViewFrame{
    _toolbar.frame=CGRectMake(0, ScreenHeight - _pickeviewHeight-ZHToobarHeight,[UIScreen mainScreen].bounds.size.width, ZHToobarHeight);
    _toolbar.backgroundColor = [UIColor whiteColor];
}

-(void)ToolbarWithPickViewFrame{
    _toolbarView.frame=CGRectMake(0, ScreenHeight - _pickeviewHeight-ZHToobarHeight,[UIScreen mainScreen].bounds.size.width, ZHToobarHeight);
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    _toolbarView.backgroundColor = [UIColor whiteColor];
    _rightBtn.frame = CGRectMake(self.frame.size.width - 10 - 48 ,10, 48, 20);
}

#pragma mark piackView 数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    NSInteger component = 0;
    if (_isLevelArray) {
        component=_plistArray.count;
    } else if (_isLevelString){
        component=1;
    }else if(_isLevelDic){
        component=[_levelTwoDic allKeys].count*2;
    }
    return component;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *rowArray=[[NSArray alloc] init];
    if (_isLevelArray) {
        rowArray=_plistArray[component];
    }else if (_isLevelString){
        rowArray=_plistArray;
    }else if (_isLevelDic){
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic=_plistArray[pIndex];
        for (id dicValue in [dic allValues]) {
                if ([dicValue isKindOfClass:[NSArray class]]) {
                    if (component%2==1) {
                        rowArray=dicValue;
                    }else{
                        rowArray=_plistArray;
                    }
            }
        }
    }
    return rowArray.count;
}

#pragma mark UIPickerViewdelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *rowTitle=nil;
    if (_isLevelArray) {
        rowTitle=_plistArray[component][row];
    }else if (_isLevelString){
        rowTitle=_plistArray[row];
    }else if (_isLevelDic){
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic=_plistArray[pIndex];
        if(component%2==0)
        {
            rowTitle=_dicKeyArray[row][component];
        }
        for (id aa in [dic allValues]) {
           if ([aa isKindOfClass:[NSArray class]]&&component%2==1){
                NSArray *bb=aa;
                if (bb.count>row) {
                    rowTitle=aa[row];
                }
                
            }
        }
    }
    return rowTitle;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (_isLevelDic&&component%2==0) {
        
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
    if (_isLevelString) {
        _resultString=_plistArray[row];
        
    }else if (_isLevelArray){
        _resultString=@"";
        if (![self.componentArray containsObject:@(component)]) {
            [self.componentArray addObject:@(component)];
        }
        for (int i=0; i<_plistArray.count;i++) {
            if ([self.componentArray containsObject:@(i)]) {
                NSInteger cIndex = [pickerView selectedRowInComponent:i];
                _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][cIndex]];
            }else{
                _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][0]];
                          }
        }
    }else if (_isLevelDic){
        if (component==0) {
          _state =_dicKeyArray[row][0];
        }else{
            NSInteger cIndex = [pickerView selectedRowInComponent:0];
            NSDictionary *dicValueDic=_plistArray[cIndex];
            NSArray *dicValueArray=[dicValueDic allValues][0];
            if (dicValueArray.count>row) {
                _city =dicValueArray[row];
            }
        }
    }
}

-(void)remove{
    
    [self removeFromSuperview];
}
-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
}
-(void)doneClick
{
    if (_pickerView) {
        
        if (_resultString) {
           
        }else{
            if (_isLevelString) {
                _resultString=[NSString stringWithFormat:@"%@",_plistArray[0]];
            }else if (_isLevelArray){
                _resultString=@"";
                for (int i=0; i<_plistArray.count;i++) {
                    _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][0]];
                }
            }else if (_isLevelDic){
                
                if (_state==nil) {
                     _state =_dicKeyArray[0][0];
                    NSDictionary *dicValueDic=_plistArray[0];
                    _city=[dicValueDic allValues][0][0];
                }
                if (_city==nil){
                    NSInteger cIndex = [_pickerView selectedRowInComponent:0];
                    NSDictionary *dicValueDic=_plistArray[cIndex];
                    _city=[dicValueDic allValues][0][0];
                    
                }
              _resultString=[NSString stringWithFormat:@"%@%@",_state,_city];
           }
        }
    }else if (_datePicker) {
        if(_datePicker.datePickerMode == UIDatePickerModeTime){
            _resultString = zcLibDateTransformString(@"HH:mm", _datePicker.date);
        }
        if(_datePicker.datePickerMode == UIDatePickerModeDate){
            _resultString = zcLibDateTransformString(@"yyyy-MM-dd", _datePicker.date);
            
        }
        if(_datePicker.datePickerMode == UIDatePickerModeDateAndTime){
            _resultString = zcLibDateTransformString(@"yyyy-MM-dd HH:mm:ss", _datePicker.date);
            
        }
    }
    if ([self.delegate respondsToSelector:@selector(toobarDonBtnHaveClick:resultString:)]) {
        [self.delegate toobarDonBtnHaveClick:self resultString:_resultString];
    }
    [self removeFromSuperview];
}
/**
 *  设置PickView的颜色
 */
-(void)setPickViewColer:(UIColor *)color{
    _pickerView.backgroundColor=color;
}
/**
 *  设置toobar的文字颜色
 */
-(void)setTintColor:(UIColor *)color{
    
    _toolbar.tintColor=color;
}
/**
 *  设置toobar的背景颜色
 */
-(void)setToolbarTintColor:(UIColor *)color{
    
    _toolbar.barTintColor=color;
}
-(void)dealloc{
    
//    NSLog(@"销毁了");
}


-(void)layoutSubviews{
    [super layoutSubviews];
     [self ToolbarWithPickViewFrame];
    _datePicker.frame = CGRectMake(0, ScreenHeight - _pickeviewHeight,self.frame.size.width, _datePicker.frame.size.height);

}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
