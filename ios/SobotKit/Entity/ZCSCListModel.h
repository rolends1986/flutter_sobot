//
//  ZCServiceCategoryListModel.h
//  SobotKit
//
//  Created by lizhihui on 2019/4/2.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCSCListModel : NSObject

//"categoryId": "7feefd40bfc84e1698c6a9dc52fe7131",//分类id
//"appId": "38ea01bc1b294e44a3113e35e3bd2674",
//"categoryName": "zxc",//分类名称
//"categoryDetail": "zxcz",//分类描述
////分类图片
//"categoryUrl": "https://sobot-test.oss-cn-beijing.aliyuncs.com/console/app/helpCenter/26d36574528541b4a8eb906dbffdeb52/4836b4835ac6496bb6ab2815a384cb8c.png",
//"sortNo": 1//排序

@property (nonatomic,copy) NSString * categoryId;
@property (nonatomic,copy) NSString * appId;
@property (nonatomic,copy) NSString * categoryName;
@property (nonatomic,copy) NSString * categoryDetail;
@property (nonatomic,copy) NSString * categoryUrl;
@property (nonatomic,assign) int sortNo;


// 分类列表数据
//companyId": "26d36574528541b4a8eb906dbffdeb52",
//"docId": "8305dbef5b4f49c68908824825107e8e",//词条id
//"questionId": "996535f599694a62b45601b56aa04cc1",//问题id
//"questionTitle": "asdas"//问题标题
@property (nonatomic,copy) NSString * companyId;
@property (nonatomic,copy) NSString * docId;
@property (nonatomic,copy) NSString * questionId;
@property (nonatomic,copy) NSString * questionTitle;

//"companyId": "26d36574528541b4a8eb906dbffdeb52",
//"docId": "8305dbef5b4f49c68908824825107e8e",
//"questionTitle": "asdas",//标题
//"answerDesc": "<p>dddddd</p>"//答案 富文本

@property (nonatomic,copy) NSString * answerDesc;


-(id)initWithMyDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
