//
//  PWBaseDataBridge.h
//  UIKit
//
//  Created by wnrz on 2018/1/10.
//  Copyright © 2018年 wnrz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PWBaseDataBridgeBeforeReturnBlock)(id value , id *result);
typedef void(^PWBaseDataBridgeResultBlock)(id value);

@interface PWBaseDataBridgeModel : NSObject

@property (nonatomic , weak) id observer;
@property (nonatomic , copy) NSString *actionName;
@property (nonatomic , assign) SEL selector;
@property (nonatomic , copy) PWBaseDataBridgeResultBlock block;
@property (nonatomic , copy) PWBaseDataBridgeBeforeReturnBlock beforeBlock;
@end

@interface PWBaseDataBridge : NSObject{
}

@property(nonatomic , assign)int bridgeNum;
@property(nonatomic , strong)NSString *bridgeString;
@property(nonatomic , copy)NSMutableDictionary *bridgeDict;
@property(nonatomic , strong)NSMutableArray *bridgeArray;

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath correction:(PWBaseDataBridgeBeforeReturnBlock)correction action:(SEL)action;
- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath action:(SEL)action;
- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(PWBaseDataBridgeResultBlock)block;
- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath correction:(PWBaseDataBridgeBeforeReturnBlock)correction block:(PWBaseDataBridgeResultBlock)block;
- (void)removeBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)removeBridgeObserver:(NSObject *)observer;
- (void)removeBridgeForKeyPath:(NSString *)keyPath;
- (void)removeAllBridge;
- (void)sendSignalWith:(NSString *)key value:(id)value;
@end
