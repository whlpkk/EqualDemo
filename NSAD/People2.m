//
//  People2.m
//  NSAD
//
//  Created by YZK on 2017/9/20.
//  Copyright © 2017年 MOMO. All rights reserved.
//

#import "People2.h"

@implementation People2

- (id)copyWithZone:(nullable NSZone *)zone {
    //可变版本
//    People2 *p = [[People2 allocWithZone:zone] init];
//    p.firstName = self.firstName;
//    p.lastName = self.lastName;
//    return p;
    
    //不可变版本
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%p %@ %@",self, self.firstName, self.lastName];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[People2 class]]) {
        return NO;
    }
    
    return [self isEqualToPeople:object];
}

- (BOOL)isEqualToPeople:(People2 *)other {
    
    // ||操作符的操作看起来好像是不必要的，但是如果我们需要处理两个属性都是 nil 的情形的话，它能够正确地返回 YES。比较像 NSUInteger 这样的标量是否相等时，则只需要使用 == 就可以了。
    BOOL firstNameIsEqual = (self.firstName == other.firstName || [self.firstName isEqual:other.firstName]);
    BOOL lastNameIsEqual = (self.lastName == other.lastName || [self.lastName isEqual:other.lastName]);
    BOOL ageIsEqual = (self.age == other.age);
    
    return firstNameIsEqual && lastNameIsEqual && ageIsEqual;
}

@end
