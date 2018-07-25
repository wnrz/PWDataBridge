//
//  ViewController.m
//  PWDataBridgeExample
//
//  Created by 王宁 on 2018/7/25.
//  Copyright © 2018年 王宁. All rights reserved.
//

#import "ViewController.h"
#import "exampleModel.h"

@interface ViewController (){
    exampleModel *model;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button1Pressed:(id)sender{
    model = model ? model : [[exampleModel alloc] init];
    [model addBridgeObserver:self forKeyPath:@"string" correction:^(id value, __autoreleasing id *result) {
        NSLog(@"string block before change is %@" , value);
        *result = [NSString stringWithFormat:@"%@_changed_before_block" , value];
    } block:^(id value) {
        NSLog(@"string block value is : %@" , value);
    }];
    [model addBridgeObserver:self forKeyPath:@"string" correction:^(id value, __autoreleasing id *result) {
        NSLog(@"string block before change is %@" , value);
        *result = [NSString stringWithFormat:@"%@_changed_before_action" , value];
    } action:@selector(showStringData:)];
    
    [model addBridgeObserver:self forKeyPath:@"num" correction:^(id value, __autoreleasing id *result) {
        NSLog(@"num block before change is %@" , value);
        *result = [NSString stringWithFormat:@"%@_changed_before_block" , value];
    } block:^(id value) {
        NSLog(@"num block value is : %@" , value);
    }];
    [model addBridgeObserver:self forKeyPath:@"num" correction:^(id value, __autoreleasing id *result) {
        NSLog(@"num block before change is %@" , value);
        *result = [NSString stringWithFormat:@"%@_changed_before_action" , value];
    } action:@selector(showNumData:)];
}

- (IBAction)button2Pressed:(id)sender{
     int h = arc4random() % 100;
    model.string = [NSString stringWithFormat:@"string_%d" , h];
}

- (IBAction)button3Pressed:(id)sender{
    model.num = model.num + 1;
}

- (IBAction)button4Pressed:(id)sender{
    [model removeAllBridge];
    model = nil;
}

- (void)showStringData:(id)value{
    NSLog(@"string action value is : %@" , value);
}


- (void)showNumData:(id)value{
    NSLog(@"num action value is : %@" , value);
}

@end
