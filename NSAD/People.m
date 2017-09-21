//
//  People.m
//  NSAD
//
//  Created by YZK on 2017/7/11.
//  Copyright © 2017年 MOMO. All rights reserved.
//

#import "People.h"

/*
 hash方法和isEqual方法的关系，例如有A、B两个对象
 1.A unequal B, 则 [A hash] != [B hash]
 1.A equal B , 则 [A hash] == [B hash]
 反正如果A和B的哈希值相等，不能推出 A equal B，这种情况叫做哈希碰撞。
 
 如果重写了isEqual方法，那么必须重写hash方法。如果不这样做，那么你有两个相同但不相同散列的对象的风险。
 如果您在dictionary, set或使用哈希表的其他内容中使用这些对象，那么问题随之而起。
 */

@implementation People

- (id)copyWithZone:(nullable NSZone *)zone {
    //可变版本
//    People *p = [[People allocWithZone:zone] init];
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
    
    if (![object isKindOfClass:[People class]]) {
        return NO;
    }
    
    return [self isEqualToPeople:object];
}

- (BOOL)isEqualToPeople:(People *)other {
    
    // ||操作符的操作看起来好像是不必要的，但是如果我们需要处理两个属性都是 nil 的情形的话，它能够正确地返回 YES。比较像 NSUInteger 这样的标量是否相等时，则只需要使用 == 就可以了。
    BOOL firstNameIsEqual = (self.firstName == other.firstName || [self.firstName isEqual:other.firstName]);
    BOOL lastNameIsEqual = (self.lastName == other.lastName || [self.lastName isEqual:other.lastName]);
    BOOL ageIsEqual = (self.age == other.age);
    
    return firstNameIsEqual && lastNameIsEqual && ageIsEqual;
}

/****************
//NSObject默认的写法
- (NSUInteger)hash {
    return (NSUInteger)self;
}

//简单写法，一般取各个属性的hash值，进行异或运算即可，但是这有一个问题，因为异或运算具有对称性，即 A ^ B == B ^ A，所以如果按照下面的这种写法，会有这种问题。 一个叫做"George Frederick"的人和一个叫做"Frederick George"的人，具有相同的hash值，然后他们并不相等。
- (NSUInteger)hash {
    return [self.firstName hash] ^ [self.lastName hash] ^ (NSUInteger)self.age;
}
*****************/

//使用按位旋转，然后在异或组合他们，如果有多个属性，只需要分别旋转不同位数，然后在异或即可
#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))
- (NSUInteger)hash
{
    //这里实际上不需要旋转lastName,这里只是演示多个属性时怎么处理。同理如果还有一个NSUInteger的属性，那么两个NSUInteger的hash值也需要被旋转
    return NSUINTROTATE([_firstName hash], NSUINT_BIT / 2) ^ NSUINTROTATE([_lastName hash], NSUINT_BIT / 3) ^ (NSUInteger)self.age;
}

@end
