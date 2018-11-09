//
//  PWMessageCenter.h
//  ThreadTest
//
//  Created by 王宁 on 2018/7/6.
//  Copyright © 2018年 王宁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMessageQueue.h"


@interface PWMessageCenter : NSObject<LSMessageQueueSignalDelegate>

+ (PWMessageCenter *)shareMessageCenter;
+ (void)addBridgeObserver:(NSObject *)observer forTopic:(NSString *)topic action:(SEL)action;
+ (void)removeBridgeObserver:(NSObject *)observer forTopic:(NSString *)topic;
+ (void)removeBridgeObserver:(NSObject *)observer;
+ (void)removeBridgeForTopic:(NSString *)topic;
+ (void)removeAllBridge;
+ (void)sendTopic:(NSString *)topic param:(NSDictionary *)value;
@end
