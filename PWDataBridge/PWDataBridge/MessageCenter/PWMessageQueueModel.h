//
//  PWMessageQueueModel.h
//  ThreadTest
//
//  Created by 王宁 on 2018/7/6.
//  Copyright © 2018年 王宁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWMessageQueueModel : NSObject

@property (nonatomic , copy) NSString *topic;
@property (nonatomic , strong) NSDictionary *param;
@end
