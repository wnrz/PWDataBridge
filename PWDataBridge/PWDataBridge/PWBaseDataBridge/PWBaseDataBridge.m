//
//  PWBaseDataBridge.m
//  UIKit
//
//  Created by wnrz on 2018/1/10.
//  Copyright © 2018年 wnrz. All rights reserved.
//

#import "PWBaseDataBridge.h"
#import <objc/runtime.h>

@implementation PWBaseDataBridgeModel

- (void)dealloc{
    _actionName = nil;
    _beforeBlock = nil;
    _block = nil;
    _observer = nil;
    _selector = NULL;
    _removed = NULL;
}

@end
#define baseDataBridgeValidArray(f) (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
@interface PWBaseDataBridge (){
    
    NSMutableArray *addKeyPaths;
    NSMutableArray *removeKeys;
    NSMutableDictionary *models;
    NSMutableArray *propertys;
    NSCondition *lock;
    
    dispatch_semaphore_t semaphore;
}


@end
@implementation PWBaseDataBridge

- (void)dealloc{
//    [lock unlock];
//    lock = nil;
    NSLog(@"PWBaseDataBridge is dealloced : %@" , self.class);
    [self removeAllBridge];
    [addKeyPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:self forKeyPath:obj];
    }];
    [addKeyPaths removeAllObjects];
    addKeyPaths = nil;
    [removeKeys removeAllObjects];
    removeKeys = nil;
    [models removeAllObjects];
    models = nil;
    semaphore = NULL;
}

- (instancetype)init{
    NSLog(@"PWBaseDataBridge is inited : %@" , self.class);
    self = [super init];
    if (self) {
        addKeyPaths = [[NSMutableArray alloc] init];
        removeKeys = [[NSMutableArray alloc] init];
        models = [[NSMutableDictionary alloc] init];
        propertys = [[NSMutableArray alloc] init];
//        lock = [[NSCondition alloc] init];
        [self getAllIvarList];
        
        semaphore = dispatch_semaphore_create(1);
        
    }
    return self;
}

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath action:(SEL)action{
    [self addBridgeObserver:observer forKeyPath:keyPath correction:nil action:action];
}

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath correction:(PWBaseDataBridgeBeforeReturnBlock)correction action:(SEL)action{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (!keyPath || !observer || !action) {
        dispatch_semaphore_signal(semaphore);
        return;
    }
    if (![observer respondsToSelector:action]) {
        dispatch_semaphore_signal(semaphore);
        return;
    }
    NSString *key = [self getKeyByKeyPath:keyPath observer:observer actionName:NSStringFromSelector(action)];
    PWBaseDataBridgeModel *model = [models objectForKey:key];
    if (!model) {
        model = [[PWBaseDataBridgeModel alloc] init];
        [models setObject:model forKey:key];
        if (![addKeyPaths containsObject:keyPath] && ([propertys containsObject:keyPath] || [propertys containsObject:[NSString stringWithFormat:@"_%@" , keyPath]])) {
            [addKeyPaths addObject:keyPath];
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        }
    }
    model.observer = observer;
    model.beforeBlock = correction;
    model.actionName = NSStringFromSelector(action);
    model.selector = action;
    model.block = nil;
    model.removed = NO;
    [removeKeys removeObject:key];
    dispatch_semaphore_signal(semaphore);
}

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(PWBaseDataBridgeResultBlock)block{
    [self addBridgeObserver:observer forKeyPath:keyPath correction:nil block:block];
}

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath correction:(PWBaseDataBridgeBeforeReturnBlock)correction block:(PWBaseDataBridgeResultBlock)block{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (!keyPath || !observer) {
        dispatch_semaphore_signal(semaphore);
        return;
    }
    if (!block && !correction) {
        dispatch_semaphore_signal(semaphore);
        return;
    }
    NSString *key = [self getKeyByKeyPath:keyPath observer:observer actionName:@"PWBaseDataBridgeModel_Block"];
    PWBaseDataBridgeModel *model = [models objectForKey:key];
    if (!model) {
        model = [[PWBaseDataBridgeModel alloc] init];
        [models setObject:model forKey:key];
        if (![addKeyPaths containsObject:keyPath] && ([propertys containsObject:keyPath] || [propertys containsObject:[NSString stringWithFormat:@"_%@" , keyPath]])) {
            [addKeyPaths addObject:keyPath];
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        }
    }
    model.observer = observer;
    model.beforeBlock = correction;
    model.block = block;
    model.actionName = nil;
    model.removed = NO;
    [removeKeys removeObject:key];
    dispatch_semaphore_signal(semaphore);
}

- (void)removeBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
//    [lock lock];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:models];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        PWBaseDataBridgeModel *model = obj;
        NSString *kp;
        if (model.actionName) {
            kp = [self getKeyByKeyPath:keyPath observer:observer actionName:model.actionName];
        }else{
            kp = [self getKeyByKeyPath:keyPath observer:observer actionName:@"PWBaseDataBridgeModel_Block"];
        }
        if ([key isEqualToString:kp]) {
            //            [self->models removeObjectForKey:key];
            model.removed = YES;
            [self->removeKeys addObject:key];
        }
    }];
    dispatch_semaphore_signal(semaphore);
//    [lock unlock];
}

- (void)removeBridgeObserver:(NSObject *)observer{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSString *string = [NSString stringWithFormat:@"%p" , observer];
//    [lock lock];
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:models];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *kp = [self getKeyPathByKey:key];
        NSString *key2 = [key stringByReplacingOccurrencesOfString:kp withString:@""];
        if ([key2 containsString:string]) {
            //            [self->models removeObjectForKey:key];
            PWBaseDataBridgeModel *model = [self->models objectForKey:key];
            model.removed = YES;
            [self->removeKeys addObject:key];
        }
    }];
    dispatch_semaphore_signal(semaphore);
//    [lock unlock];
}

- (void)removeBridgeForKeyPath:(NSString *)keyPath{
//    [lock lock];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:models];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *kp = [self getKeyPathByKey:key];
        if ([kp isEqualToString:keyPath]) {
            //            [self->models removeObjectForKey:key];
            PWBaseDataBridgeModel *model = [self->models objectForKey:key];
            model.removed = YES;
            [self->removeKeys addObject:key];
        }
    }];
    if ([addKeyPaths containsObject:keyPath]) {
        if (keyPath) {
            [self removeObserver:self forKeyPath:keyPath];
            [addKeyPaths removeObject:keyPath];
        }
    }
    dispatch_semaphore_signal(semaphore);
//    [lock unlock];
}

- (void)removeAllBridge{
//    [lock lock];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [models removeAllObjects];
    NSArray *array = [NSArray arrayWithArray:addKeyPaths];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj;
        if (key) {
            [self removeObserver:self forKeyPath:obj];
            [self->addKeyPaths removeObject:key];
        }
    }];
    dispatch_semaphore_signal(semaphore);
//    [lock unlock];
}

- (NSString *)getKeyPathByKey:(NSString *)key{
    NSString *keyPath = [key componentsSeparatedByString:@"||"][0];
    return keyPath;
}

- (NSString *)getKeyByKeyPath:(NSString *)keyPath observer:(id)observer actionName:(NSString *)actionName{
    NSString *string = [NSString stringWithFormat:@"%@||%p||%@" , keyPath , observer , actionName];
    return string;
}

- (void)cleanUnuseKeyPath{
//    [lock lock];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSArray *array = [NSArray arrayWithArray:addKeyPaths];
    NSArray *keys = [NSArray arrayWithArray:[models allKeys]];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj1;
        __block BOOL isClean = YES;
        [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *kp = [self getKeyPathByKey:obj2];
            if ([key isEqualToString:kp]) {
                isClean = NO;
            }
        }];
        if (isClean) {
            [self->addKeyPaths removeObject:key];
            [self removeObserver:self forKeyPath:key];
        }
    }];
    dispatch_semaphore_signal(semaphore);
//    [lock unlock];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//    [lock lock];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    @autoreleasepool{
        id pra = [[change allKeys] containsObject:NSKeyValueChangeNewKey] ? change[NSKeyValueChangeNewKey] : [self->propertys containsObject:keyPath] ? [self valueForKeyPath:keyPath] : nil;
        //        @try {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:self->models];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([self->removeKeys containsObject:key]) {
                return;
            }
            NSString *kp = [self getKeyPathByKey:key];
            if ([kp isEqualToString:keyPath]) {
                PWBaseDataBridgeModel *model = obj;
                __strong typeof(model.observer) strongObserver = model.observer;
                if (!model || !strongObserver || model.removed) {
                    //                    [self->models removeObjectForKey:key];
                    if (model) {
                        model.removed = YES;
                        [self->removeKeys addObject:key];
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        id praResult = pra;
                        if (model.beforeBlock) {
                            model.beforeBlock(pra , &praResult);
                        }
                        SEL action = model.selector;
                        if (action) {
                            IMP imp = [strongObserver methodForSelector:action];
                            if (imp) {
                                void (*func)(id, SEL, id) = (void *)imp;
                                func(strongObserver, action, praResult);
                            }else{
                                NSLog(@"imp is 0x0");
                            }
                        }
                        if (model.block) {
                            model.block(praResult);
                        }
                    });
                }
            }
        }];
        NSArray *array = [NSArray arrayWithArray:removeKeys];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PWBaseDataBridgeModel *model = [self->models objectForKey:obj];
            if (model != nil) {
                [self->models removeObjectForKey:obj];
            }
            [self->removeKeys removeObject:obj];
        }];
        //        } @catch (NSException *exception) {
        //            NSLog(@"%@", @"%@ observeValueForKeyPath is catch crash" . self.classForCoder);
        //        } @finally {
        //
        //        }
    }
    dispatch_semaphore_signal(semaphore);
//    [lock unlock];
}

- (void)sendSignalWith:(NSString *)key value:(id)value{
    if ([propertys containsObject:key] || [propertys containsObject:[NSString stringWithFormat:@"_%@" , key]]) {
        [self setValue:value forKey:key];
    }else{
        if (!value) {
            value = @"";
        }
        [self observeValueForKeyPath:key ofObject:value change:@{NSKeyValueChangeNewKey:value} context:nil];
    }
}

- (void) getAllIvarList {
    Class cls = [self class];
    while (cls != [NSObject class]) {
        unsigned int methodCount = 0;
        Ivar * ivars = class_copyIvarList(cls, &methodCount);
        for (unsigned int i = 0; i < methodCount; i ++) {
            Ivar ivar = ivars[i];
            const char * name = ivar_getName(ivar);
            //        const char * type = ivar_getTypeEncoding(ivar);
            [propertys addObject:[NSString stringWithFormat:@"%s" , name]];
        }
        free(ivars);
        cls = class_getSuperclass(cls);
    }
}
@end
