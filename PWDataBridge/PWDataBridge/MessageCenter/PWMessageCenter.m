//
//  PWMessageCenter.m
//  ThreadTest
//
//  Created by 王宁 on 2018/7/6.
//  Copyright © 2018年 王宁. All rights reserved.
//

#import "PWMessageCenter.h"
#import "PWMessageQueueDataBridge.h"
#import "LSMessageQueue.h"

@interface PWMessageCenter (){
    LSMessageQueue *queue;
}

@end
@implementation PWMessageCenter

+ (PWMessageCenter *)shareMessageCenter{
    static dispatch_once_t _onceToken;
    static PWMessageCenter *_instance;
    dispatch_once(&_onceToken, ^{
        _instance = [PWMessageCenter new];
        [_instance initQueue];
    });
    return _instance;
}

+ (void)addBridgeObserver:(NSObject *)observer forTopic:(NSString *)topic action:(SEL)action{
    [[PWMessageQueueDataBridge shareBridge] addBridgeObserver:observer forKeyPath:topic action:action];
}

+ (void)addBridgeObserver:(NSObject *)observer forTopic:(NSString *)topic block:(PWBaseDataBridgeResultBlock)block{
    [[PWMessageQueueDataBridge shareBridge] addBridgeObserver:observer forKeyPath:topic block:block];
}   

+ (void)removeBridgeObserver:(NSObject *)observer forTopic:(NSString *)topic{
    [[PWMessageQueueDataBridge shareBridge] removeBridgeObserver:observer forKeyPath:topic];
}

+ (void)removeBridgeObserver:(NSObject *)observer{
    [[PWMessageQueueDataBridge shareBridge] removeBridgeObserver:observer];
}

+ (void)removeBridgeForTopic:(NSString *)topic{
    [[PWMessageQueueDataBridge shareBridge] removeBridgeForKeyPath:topic];
}

+ (void)removeAllBridge{
    [[PWMessageQueueDataBridge shareBridge] removeAllBridge];
}

+ (void)sendTopic:(NSString *)topic param:(NSDictionary *)value{
    [[PWMessageCenter shareMessageCenter].queue sendEvent:topic param:value];
}

- (void)initQueue{
    if (!queue) {
        queue = [[LSMessageQueue alloc] initWithDelegate:(id<LSMessageQueueSignalDelegate>)self];
        queue.name = [NSString stringWithFormat:@"%@%@",NSStringFromClass([LSMessageQueue class]),queue];
        [queue start];
    }
}

- (LSMessageQueue *)queue{
    return queue;
}

- (void)messageQueueIsWaitingMessage:(LSMessageQueue *)queue{
//    NSLog(@"线程休息时间:%@" , [NSDate date]);
}

- (void)messageQueueIsStartingMessage:(LSMessageQueue *)queue{
//    NSLog(@"线程激活时间:%@" , [NSDate date]);
}

@end
