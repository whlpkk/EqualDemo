//
//  People.h
//  NSAD
//
//  Created by YZK on 2017/7/11.
//  Copyright © 2017年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface People : NSObject <NSCopying>

@property (nonatomic,copy) NSString *firstName;
@property (nonatomic,copy) NSString *lastName;
@property (nonatomic,assign) NSInteger age;
@end
