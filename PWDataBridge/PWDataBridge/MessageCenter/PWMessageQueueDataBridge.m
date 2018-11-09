//
//  PWBaseDataBridge.m
//
//
//  Created by 王宁 on 2018/6/12.
//  Copyright © 2018年 xiongguobing. All rights reserved.
//

#import "PWMessageQueueDataBridge.h"

#define baseDataBridgeValidArray(f) (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
@interface PWMessageQueueDataBridge ()

@end

@implementation PWMessageQueueDataBridge

+ (PWMessageQueueDataBridge *)shareBridge{
    static dispatch_once_t _onceToken;
    static PWMessageQueueDataBridge *_instance;
    dispatch_once(&_onceToken, ^{
        _instance = [PWMessageQueueDataBridge new];
    });
    return _instance;
}

@end
