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
}

@end
#define baseDataBridgeValidArray(f) (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
@interface PWBaseDataBridge (){
    
    NSMutableArray *addKeyPaths;
    NSMutableDictionary *models;
    NSMutableArray *propertys;
}


@end
@implementation PWBaseDataBridge

- (void)dealloc{
    [self removeAllBridge];
    [addKeyPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:self forKeyPath:obj];
    }];
    [addKeyPaths removeAllObjects];
    addKeyPaths = nil;
    [models removeAllObjects];
    models = nil;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        addKeyPaths = [[NSMutableArray alloc] init];
        models = [[NSMutableDictionary alloc] init];
        propertys = [[NSMutableArray alloc] init];
        [self getAllIvarList];
    }
    return self;
}

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath action:(SEL)action{
    [self addBridgeObserver:observer forKeyPath:keyPath correction:nil action:action];
}

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath correction:(PWBaseDataBridgeBeforeReturnBlock)correction action:(SEL)action{
    if (!keyPath || !observer || !action) {
        return;
    }
    if (![observer respondsToSelector:action]) {
        return;
    }
    NSString *key = [self getKeyByKeyPath:keyPath observer:observer];
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
}

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(PWBaseDataBridgeResultBlock)block{
    [self addBridgeObserver:observer forKeyPath:keyPath correction:nil block:block];
}

- (void)addBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath correction:(PWBaseDataBridgeBeforeReturnBlock)correction block:(PWBaseDataBridgeResultBlock)block{
    if (!keyPath || !observer) {
        return;
    }
    if (!block && !correction) {
        return;
    }
    NSString *key = [self getKeyByKeyPath:keyPath observer:observer];
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
}

- (void)removeBridgeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:models];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *kp = [self getKeyByKeyPath:keyPath observer:observer];
        if ([key isEqualToString:kp]) {
            [self->models removeObjectForKey:key];
        }
    }];
}

- (void)removeBridgeObserver:(NSObject *)observer{
    NSString *string = [NSString stringWithFormat:@"%p" , observer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:models];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *kp = [self getKeyPathByKey:key];
        NSString *key2 = [key stringByReplacingOccurrencesOfString:kp withString:@""];
        if ([key2 containsString:string]) {
            [self->models removeObjectForKey:key];
        }
    }];
}

- (void)removeBridgeForKeyPath:(NSString *)keyPath{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:models];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *kp = [self getKeyPathByKey:key];
        if ([kp isEqualToString:keyPath]) {
            [self->models removeObjectForKey:key];
        }
    }];
    if ([addKeyPaths containsObject:keyPath]) {
        if (keyPath) {
            [self removeObserver:self forKeyPath:keyPath];
            [addKeyPaths removeObject:keyPath];
        }
    }
}

- (void)removeAllBridge{
    [models removeAllObjects];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:addKeyPaths];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj;
        if (key) {
            [self removeObserver:self forKeyPath:obj];
            [self->addKeyPaths removeObject:key];
        }
    }];
}

- (NSString *)getKeyPathByKey:(NSString *)key{
    NSString *keyPath = [key componentsSeparatedByString:@"||"][0];
    return keyPath;
}

- (NSString *)getKeyByKeyPath:(NSString *)keyPath observer:(id)observer{
    NSString *string = [NSString stringWithFormat:@"%@||%p" , keyPath , observer];
    return string;
}

- (void)cleanUnuseKeyPath{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:addKeyPaths];
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[models allKeys]];
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
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    @autoreleasepool{
        id pra = [[change allKeys] containsObject:NSKeyValueChangeNewKey] ? change[NSKeyValueChangeNewKey] : [self->propertys containsObject:keyPath] ? [self valueForKeyPath:keyPath] : nil;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:models];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *kp = [self getKeyPathByKey:key];
            if ([kp isEqualToString:keyPath]) {
                PWBaseDataBridgeModel *model = obj;
                if (!model || !model.observer) {
                    [self->models removeObjectForKey:key];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        id praResult = pra;
                        if (model.beforeBlock) {
                            model.beforeBlock(pra , &praResult);
                        }
                        SEL action = model.selector;
                        if (action) {
                            IMP imp = [model.observer methodForSelector:action];
                            if (imp) {
                                void (*func)(id, SEL, id) = (void *)imp;
                                func(model.observer, action, praResult);
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
    }
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
