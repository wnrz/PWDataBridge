//
//  exampleModel.h
//  PWDataBridgeExample
//
//  Created by 王宁 on 2018/7/25.
//  Copyright © 2018年 王宁. All rights reserved.
//

#import <PWDataBridge/PWBaseDataBridge.h>

@interface exampleModel : PWBaseDataBridge

@property (nonatomic , copy)NSString *string;
@property (nonatomic , assign)NSInteger num;
@end
