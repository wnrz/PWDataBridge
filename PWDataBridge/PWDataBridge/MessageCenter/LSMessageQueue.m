//
//  LSMessageQueue.m
//  Plug-in2Demo
//
//  Created by Lyson on 2018/1/25.
//  Copyright © 2018年 Plug-in2Demo. All rights reserved.
//

#import "LSMessageQueue.h"
#import <pthread.h>
#import "PWMessageQueueDataBridge.h"
#import "PWMessageQueueModel.h"
//#import <YYKit/YYThreadSafeDictionary.h>
//#import <GWBaseLib/GWBaseLib.h>
@interface LSMessageQueue()
{
    NSMutableArray<PWMessageQueueModel *> *waitEvent;
    NSMutableArray<PWMessageQueueModel *> *sendEvent;
    NSCondition *con;
    NSLock *_lock;
}

@property (nonatomic , assign) BOOL isRunning;
@property (nonatomic , strong) LSRunloopContext *context;
@property (nonatomic , assign) NSInteger waitingNum;
@property (nonatomic , weak) id<LSMessageQueueSignalDelegate> delegate;
@property (nonatomic , assign) BOOL threadIsRunning;
@end

@implementation LSMessageQueue

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)runLoopScheduleRouting:(LSRunloopContext *)context strRef:(CFStringRef)mode{
    
    self.context = context;
}

-(void)runLoopPerformRouting:(void *)info{
    
    
}

-(void)runLoopCancelRouting:(LSRunloopContext *)context strRef:(CFStringRef)mode{
    
    
}

-(void)willTerminate:(NSNotification*)notification{
    
    _threadIsRunning = NO;
}

-(instancetype)initWithDelegate:(id<LSMessageQueueSignalDelegate>)delegate{
    
    if (self = [super init]) {
        
        self.name = @"com.gw.msgQueue";
        _delegate = delegate;
        
        _waitingNum = 100;
        _maxMsgNum = 10000;
        
        _threadIsRunning = YES;
        
        sendEvent = [[NSMutableArray alloc] init];
        
        con = [[NSCondition alloc] init];
        
        _lock = [[NSLock alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
        
    }
    return self;
}

-(instancetype)init{
    
    if (self = [super init]) {
        
        self.waitingNum = 100;
        
    }
    return self;
}

-(void)main{
    
    @autoreleasepool{
        
        NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
        
        LSRunloopSource *source = [[LSRunloopSource alloc] initWithDelegate:(id<LSRunloopSourceDelegate>)self];
        [source addToCurrentLoop];
        
        while (_threadIsRunning) {
            
            [self doTask];
            
            [myRunLoop runMode:NSDefaultRunLoopMode
                    beforeDate:[NSDate distantFuture]];
        }

    }
}




#pragma mark -消息处理

//-(void)pushMsgs:(NSArray*)msgs{
//
//    if (!self.isRunning) {
//        //发送信号激活
//        [self fire];
//    }
//}

-(void)sendEvent:(NSString *)topic param:(NSDictionary *)dict{
    
    !waitEvent ? waitEvent = [[NSMutableArray alloc] init] : 0;
    PWMessageQueueModel *model = [PWMessageQueueModel new];
    model.topic = [topic copy];
    model.param = [dict copy];
//    NSLog(@"LSMessageQueue will addObject");
    @synchronized (self) {
        [waitEvent addObject:model];
//        NSLog(@"LSMessageQueue did addObject");
    }
    if (!self.isRunning) {
        //发送信号激活
        [self fire];
    }
}

//消息添加
//-(void)push:(LSMessageModel*)model{
//    
//    if (!self.isRunning) {
//        //发送信号激活
//        [self fire];
//    }
//}

-(void)remove{
    
    [self.context.source removeLoop];
}

-(void)fire{
    
    [self.context.source fireRunloop:self.context.runLoop];
}



-(void)doTask{
    
    @autoreleasepool{
        
        if (!waitEvent || waitEvent.count == 0) {
            self.isRunning = NO;
            
            if (_delegate && [_delegate respondsToSelector:@selector(messageQueueIsWaitingMessage:)]) {
                [_delegate messageQueueIsWaitingMessage:self];
            }
        }else{
            if (!self.isRunning && _delegate && [_delegate respondsToSelector:@selector(messageQueueIsStartingMessage:)]) {
                [_delegate messageQueueIsStartingMessage:self];
            }
            self.isRunning = YES;
            [self popMsg];
            
            [self sendMsg];
            [self fire];
            
        }
        
    }
    
}

- (void)popMsg{
    @synchronized (self) {
//        NSLog(@"LSMessageQueue popMsg start");
        sendEvent = [NSMutableArray arrayWithArray:waitEvent];
        [waitEvent removeAllObjects];
//        NSLog(@"LSMessageQueue popMsg end");
    }
}

-(void)sendMsg{
// sendEvent
    NSMutableArray *arr = sendEvent;//[NSMutableArray arrayWithArray:sendEvent];
//    [sendEvent removeObjectsInArray:arr];
    sendEvent = nil;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PWMessageQueueModel *model = obj;
        [[PWMessageQueueDataBridge shareBridge] sendSignalWith:model.topic value:model.param];
    }];
}

@end

