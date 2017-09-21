//
//  People2.h
//  NSAD
//
//  Created by YZK on 2017/9/20.
//  Copyright © 2017年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 和Person类对比，没有重新hash方法
 */
@interface People2 : NSObject <NSCopying>

@property (nonatomic,copy) NSString *firstName;
@property (nonatomic,copy) NSString *lastName;
@property (nonatomic,assign) NSInteger age;

@end
