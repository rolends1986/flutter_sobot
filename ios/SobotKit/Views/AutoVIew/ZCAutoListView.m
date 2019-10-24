//
//  ZCAutoListView.m
//  SobotKit
//
//  Created by zhangxy on 2018/1/22.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCAutoListView.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIConfigManager.h"
#import "ZCPlatformInfo.h"
#import "ZCPlatformTools.h"


#define LineHeight 36

@interface ZCAutoListView()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSMutableArray *listArray;
@property(nonatomic,strong) NSMutableDictionary *dict;
@property (nonatomic,strong) UITableView * listTable;

@property (nonatomic,strong) NSString * searchText;


@end

@implementation ZCAutoListView

+(ZCAutoListView *) getAutoListView{
    static ZCAutoListView *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [[ZCAutoListView alloc] initPrivate];            
        }
    });
    return _instance;
}

-(id)initPrivate{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if(self){
        _dict = [[NSMutableDictionary alloc] init];
        _listArray = [[NSMutableArray alloc] init];
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0) style:UITableViewStylePlain];
        _listTable.dataSource = self;
        _listTable.delegate = self;
        [_listTable setBackgroundColor:[UIColor clearColor]];
        [_listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_listTable setSeparatorColor:UIColorFromRGB(0xdce0e5)];
        [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        if(iOS7){
            [_listTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        UIView *view =[ [UIView alloc]init];
        view.backgroundColor = [UIColor clearColor];
        [_listTable setTableFooterView:view];
        [self addSubview:_listTable];
        
        _listArray  = [[NSMutableArray alloc] init];
        [self setTableSeparatorInset];

        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
    }
    return self;
}

-(id)init{
    return [[self class] getAutoListView];
}


-(void)showWithText:(NSString *) searchText rect:(CGRect) f isHiddNav:(BOOL)isNavcHide isTranslucent:(BOOL)nacTranslucent;{
    if(zcLibConvertToString(searchText).length == 0){
        [self dissmiss];
        return;
    }
  
    _searchText = searchText;
    NSMutableArray *arr  = [_dict objectForKey:searchText];
    
    if(!zcLibIs_null(arr)&& arr.count>0){
        if (_listArray.count>0) {
            [_listArray removeAllObjects];
        
        }
        [_listArray addObjectsFromArray:arr];
        [self setlistTableFrameWith:f isHiddNav:isNavcHide isTranslucent:nacTranslucent];
        
    }else{
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setValue:zcLibConvertToString(searchText) forKey:@"question"];
        [dict setValue:[NSString stringWithFormat:@"%zd",[self getZCLibConfig].robotFlag] forKey:@"robotFlag"];

        [[self getZCAPIServer] getrobotGuess:[self getZCLibConfig] Parms:dict start:^(ZCLibMessage *message) {

        } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
            // 本地缓存 收索数据
            if(_dict.count > 10){
                [_dict removeAllObjects];
            }
            
            if ([dict[@"code"] intValue] == 1) {
                NSArray * arr = dict[@"data"][@"respInfoList"];
                if (arr.count>0) {
                    if (_listArray.count>0) {
                        [_listArray removeAllObjects];
                    }
                    _listArray = [NSMutableArray arrayWithArray:arr];
                    
                    if (self.isAllowShow) {
                        [_dict setObject:_listArray forKey:searchText];
                        [self setlistTableFrameWith:f isHiddNav:isNavcHide isTranslucent:nacTranslucent];
                        
                    }
                  
                }else{
                   [self dissmiss];
                    return ;
                }
            }
        } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
    
            if (_listArray.count == 0) {
                [self dissmiss];
                return;
            }
        }];
    }
    

}

-(void)setlistTableFrameWith:(CGRect)f isHiddNav:(BOOL)isNavcHide isTranslucent:(BOOL)nacTranslucent{
    CGFloat height = _listArray.count * LineHeight;
    if(_listArray.count > 3){
        height = 3 * LineHeight + LineHeight /2;
    }
    CGFloat H = 0;
//        NSLog(@" 影藏不 %d 透明不 %d",isNavcHide,nacTranslucent);
//    if (!isNavcHide && nacTranslucent) {
//        H = NavBarHeight ;
//    }
    if (!isNavcHide) {
        if (nacTranslucent) {
             H = NavBarHeight;
        }
    }else{
        if (nacTranslucent) {
             H = 0;
        }else{
            H = NavBarHeight;
        }
    }
    
    
    CGRect sheetViewF = CGRectMake(0,f.origin.y - height + H , f.size.width, height);
    self.frame = sheetViewF;
    [self.listTable setFrame:CGRectMake(0, 0, ScreenWidth, height)];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [_listTable reloadData];
    //    [UIView animateWithDuration:0.2 animations:^{
    //        self.frame = sheetViewF;
    //    } completion:^(BOOL finished) {
    //
    //    }];
}

-(void)dissmiss{
    CGRect sheetViewF = self.frame;
    
    sheetViewF.size.height = 0;
    
    self.frame = sheetViewF;
    
     [self removeFromSuperview];
    
//    [UIView animateWithDuration:0.2 animations:^{
//
//        self.frame = sheetViewF;
//        self.alpha = 0.0;
//    } completion:^(BOOL finished) {
////        [self removeFromSuperview];
//    }];
}


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


#pragma mark -- tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
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
    
    cell.textLabel.textColor = UIColorFromRGB(0x454545);
    cell.textLabel.font = DetGoodsFont;
    cell.backgroundColor = [UIColor whiteColor];
//    NSString * str =  zcLibConvertToString(_listArray[indexPath.row][@"question"]);
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithData:[_listArray[indexPath.row][@"highlight"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];

    [attrStr addAttribute:NSFontAttributeName value:DetGoodsFont range:NSMakeRange(0, attrStr.length)];
    
    cell.textLabel.attributedText = attrStr;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString * text = _listArray[indexPath.row][@"question"];
    if (_CellClick) {
        _CellClick(text);
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return LineHeight;
}



#pragma mark -- 获取公共参数和方法
-(ZCUIConfigManager *)getShareMS{
    return [ZCUIConfigManager getInstance];
}

-(ZCLibServer *)getZCAPIServer{
    return [[self getShareMS] getZCAPIServer];
}


-(ZCLibConfig *)getZCLibConfig{
    return [self getPlatformInfo].config;
}

-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
