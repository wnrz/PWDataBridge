//
//  LSMessageQueue.h
//  Plug-in2Demo
//
//  Created by Lyson on 2018/1/25.
//  Copyright © 2018年 Plug-in2Demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRunloopSource.h"
//#import "LSMessageList.h"
//#import "LSMessageModel.h"
//#import "GWMQMessageListManager.h"

@class LSMessageQueue;


@protocol LSMessageQueueSignalDelegate<NSObject>

-(void)messageQueueIsWaitingMessage:(LSMessageQueue*)queue;
-(void)messageQueueIsStartingMessage:(LSMessageQueue*)queue;

@end


@class LSMessageModel;

/**
 消息派发队列
 */
@interface LSMessageQueue : NSThread

/**
 最大消息数
 */
@property (readonly) NSInteger maxMsgNum;

/**
 当前消息数
 */
@property (readonly) NSInteger msgCount;

/**
 话题数
 */
@property (readonly) NSInteger topicCount;

/**
 最后一次添加消息数
 */
@property (readonly) NSInteger lastAddMsgNum;

/**
 代理初始化

 @param delegate 代理
 @return LSMessageQueue
 */
-(instancetype)initWithDelegate:(id<LSMessageQueueSignalDelegate>)delegate;

/**
 移除
 */
-(void)remove;


/**
 派发消息派发
 
 @param model 消息
 */
//-(void)push:(LSMessageModel*)model;

/**
 派发消息
 
 @param msgs 消息
 */
//-(void)pushMsgs:(NSArray*)msgs;

-(void)sendEvent:(NSString *)topic param:(NSDictionary *)dict;
@end
