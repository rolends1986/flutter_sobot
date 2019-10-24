//
//  ZCCacheCore.m
//  SobotKit
//
//  Created by zhangxy on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCCacheCore.h"

@implementation ZCCacheCore

static ZCCacheCore *_instance = nil;
static dispatch_once_t onceToken;
+(ZCCacheCore *)getCacheCore{
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [[ZCCacheCore alloc] initPrivate];
        }
    });
    return _instance;
}

-(id)initPrivate{
    self=[super init];
    if(self){
        
    }
    return self;
}

-(id)init{
    return [[self class] getCacheCore];
}



-(void)clear{
    onceToken=0;
    _instance = nil;
    
}



@end
