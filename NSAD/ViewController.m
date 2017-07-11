//
//  ViewController.m
//  NSAD
//
//  Created by YZK on 2017/7/11.
//  Copyright © 2017年 MOMO. All rights reserved.
//

#import "ViewController.h"

#import "People.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    People *p1 = [[People alloc] init];
    p1.firstName = @"lucy";
    p1.lastName = @"Green";
    
    People *p2 = [[People alloc] init];
    p2.firstName = @"lucy";
    p2.lastName = @"Green";

    NSLog(@"%p,%p",p1,p2);

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{p1:@"value1"}];
    NSLog(@"%@",[dict objectForKey:p2]);
    
    NSLog(@"---%@",dict);
    [dict removeObjectForKey:p2];
    NSLog(@"%@",dict);
}

/*
 重写了hash函数前，可以看到，此时用p2不可以读写字典。
 2017-07-11 16:45:28.727 NSAD[7841:176459] (null)
 2017-07-11 16:45:28.727 NSAD[7841:176459] ---{
 "lucy Green" = value1;
 }
 2017-07-11 16:45:28.727 NSAD[7841:176459] {
 "lucy Green" = value1;
 }
 
  
 重写了hash函数后，可以看到，此时用p2也可以读写字典。
 2017-07-11 16:43:25.257 NSAD[7823:175372] value1
 2017-07-11 16:43:25.258 NSAD[7823:175372] ---{
 "lucy Green" = value1;
 }
 2017-07-11 16:43:25.258 NSAD[7823:175372] {
 }
 */


@end
