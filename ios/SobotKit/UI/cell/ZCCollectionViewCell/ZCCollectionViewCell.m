//
//  ZCCollectionViewCell.m
//  SobotKit
//
//  Created by lizhihui on 2017/11/13.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCCollectionViewCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIImageTools.h"
#import "ZCUIColorsDefine.h"


NSString *const kZCCollectionViewCellID = @"ZCCollectionViewCell";

@implementation ZCCollectionViewCell

-(void)prepareForReuse{
    [super prepareForReuse];
    _posterView.image = nil;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}


-(void)setupViews{
    if (_posterView) {
        return;
    }
    
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _posterView=[[ZCUIImageView alloc] init];
    [_posterView setContentMode:UIViewContentModeScaleAspectFill];
    _posterView.layer.masksToBounds=YES;
    _posterView.clipsToBounds = YES;
    [_posterView setFrame:CGRectMake(0, 0, 128, 128)];
    _posterView.backgroundColor =[UIColor whiteColor];
    [self.contentView addSubview:_posterView];
    

    
    CGFloat SpaceX = 6;
    _labTitle = [[UILabel alloc]init];
    [_labTitle setTextColor:UIColorFromRGB(0x3D4966)];
    [_labTitle setFont:[UIFont systemFontOfSize:14]];
    _labTitle.numberOfLines = 1;

    [_labTitle setFrame:CGRectMake( SpaceX, CGRectGetMaxY(self.posterView.frame) +5, 128-SpaceX *2, 20)];
    [self.contentView addSubview:_labTitle];
    
    
    _labDesc = [[UILabel alloc]init];
    [_labDesc setTextColor:UIColorFromRGB(0x8B98AD)];
    [_labDesc setFont:[UIFont systemFontOfSize:12]];
    _labDesc.numberOfLines = 0;
    [_labDesc setFrame:CGRectMake(SpaceX, 128+20+6, 128-SpaceX *2, 20)];
    [self.contentView addSubview:_labDesc];
    
    
    _labTag = [[UILabel alloc]init];
    [_labTag setTextColor:UIColorFromRGB(0xf6a623)];
    [_labTag setFont:[UIFont systemFontOfSize:15]];
    _labTag.numberOfLines = 1;
    [_labTag setFrame:CGRectMake(SpaceX, 128+40 +6, 128-SpaceX *2, 20)];
    [self.contentView addSubview:_labTag];
    
//    _bottomLineView = [[UIView alloc]init];
//    _bottomLineView.backgroundColor = UIColorFromRGB(0xe6e9ef);
//    [_bottomLineView setFrame:CGRectMake(0, 53, ScreenWidth - 30, 1)];
//    [self.contentView addSubview:_bottomLineView];
//    _bottomLineView.hidden = YES;

    
}


#pragma mark - Public Method

- (void)configureCellWithPostURL:(NSDictionary *)model WithIsHistory:(BOOL) isHistory{
    
    [_posterView loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model[@"thumbnail"])] placeholer:nil showActivityIndicatorView:YES];
    [_labTitle setText:zcLibConvertToString(model[@"title"])];// [NSString stringWithFormat:@"我是标题%@",item[@"row"]]
    [_labDesc setText:zcLibConvertToString(model[@"summary"])];// [NSString stringWithFormat:@"我是描述%@",item[@"desc"]]
    if (_collectionCellType == CollectionCellType_Vertical) {
        [_labTag setText:zcLibConvertToString(model[@"tag"])];// [NSString stringWithFormat:@"我是关键要素%@",item[@"row"]]
    }else{
         [_labTag setText:zcLibConvertToString(model[@"label"])];
    }
   
    
    if (isHistory) {
        self.contentView.backgroundColor = UIColorFromRGB(multiWheelBgColor);
    }else{
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    
    if (_collectionCellType == CollectionCellType_Vertical) {
        self.layer.borderColor = UIColorFromRGB(0xe6e9ef).CGColor;
        self.layer.borderWidth = 0.5f;
    }
}


@end
