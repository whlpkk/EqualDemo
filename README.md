##Objective-C中的hash方法

####简介
Objective-C中，经常会有需要重写`- (BOOL)isEuqal:(id)other`方法的情况。但是很少有人重写`- (NSUInteger)hash`方法。本文就详细解释一下`hash`方法的用处和不重写可能出现的问题。

####哈希表
Objective-C中，`NSDictionary`和`NSSet`是由哈希表实现的。

在讨论哈希表之前，先规范几个接下来会用到的概念。哈希表的本质是一个数组，数组中每一个元素称为一个箱子(bin)，箱子中存放的是需要存储的对象，比如字典中就是键值对，集合中就是要放入集合的对象。

哈希表的存储过程如下:

根据 key 计算出它的哈希值 h。
假设箱子的个数为 n，那么这个键值对应该放在第 (h % n) 个箱子中。
如果该箱子中已经有了键值对，就使用开放寻址法或者拉链法解决冲突。
在使用拉链法解决哈希冲突时，每个箱子其实是一个链表，属于同一个箱子的所有键值对都会排列在链表中。

哈希表还有一个重要的属性: 负载因子(load factor)，它用来衡量哈希表的 空/满 程度，一定程度上也可以体现查询的效率，计算公式为:

负载因子 = 总键值对数 / 箱子个数
负载因子越大，意味着哈希表越满，越容易导致冲突，性能也就越低。因此，一般来说，当负载因子大于某个常数(可能是 1，或者 0.75 等)时，哈希表将自动扩容。

####重写hash函数

Objective-C中，NSObject的默认hash方法实现为：

```
- (NSUInteger)hash {
    return (NSUInteger)self;
}
```

在实现一个`hash`函数的时候，需要技巧的一点是，找出哪个值对于对象来说是关键的。

对于一个 NSDate 对象来说，从一个参考日期到它本身的时间间隔就已经足够了：

```
@implementation NSDate (Approximate)
- (NSUInteger)hash {
  return (NSUInteger)abs([self timeIntervalSinceReferenceDate]);
}
```

对于一个 UIColor 对象，RGB 元素的移位和可以很方便地计算出来：

```
@implementation UIColor (Approximate)
- (NSUInteger)hash {
  CGFloat red, green, blue;
  [self getRed:&red green:&green blue:&blue alpha:nil];
  return ((NSUInteger)(red * 255) << 16) + ((NSUInteger)(green * 255) << 8) + (NSUInteger)(blue * 255);
}
@end
```

综合上面所说的内容，下面是一个在子类中重载默认相等性检查时可能的实现：

```
@interface Person
@property NSString *firstName;
@property NSString *lastName;
@property NSDate *birthday;

- (BOOL)isEqualToPerson:(Person *)person;
@end

@implementation Person

- (BOOL)isEqualToPerson:(Person *)person {
  if (!person) {
    return NO;
  }

  // ||操作符的操作看起来好像是不必要的，但是如果我们需要处理两个属性都是 nil 的情形的话，它能够正确地返回 YES。比较像 NSUInteger 这样的标量是否相等时，则只需要使用 == 就可以了。
  BOOL firstNameIsEqual = (self.firstName == person.firstName || [self.firstName isEqual:person.firstName]);
  BOOL lastNameIsEqual = (self.lastName == person.lastName || [self.lastName isEqual:person.lastName]);
  BOOL haveEqualBirthdays = (self.birthday == person.birthday) || [self.birthday isEqualToDate:person.birthday];

  return firstNameIsEqual && lastNameIsEqual && haveEqualBirthdays;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }

  if (![object isKindOfClass:[Person class]]) {
    return NO;
  }

  return [self isEqualToPerson:(Person *)object];
}

- (NSUInteger)hash {
  return [self.firstName hash] ^ [self.lastName hash] ^ [self.birthday hash];
}
```

上面的例子中，有一个小问题，因为 ^ 操作是有对称性的， 即`A^B == B^A`，所以如果两个生日相同的人，一个叫"George Frederick"，另一个叫"Frederick George"，则他们的hash值一样。

为了避免这种情况，我们需要手动打破这种对称性，比如旋转移位操作。

```
#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))
- (NSUInteger)hash
{
    //这里实际上不需要旋转lastName,这里只是演示多个属性时怎么处理。同理如果还有一个NSUInteger的属性，那么两个NSUInteger的hash值也需要被旋转
    return NSUINTROTATE([_firstName hash], NSUINT_BIT / 2) ^ NSUINTROTATE([_lastName hash], NSUINT_BIT / 3) ^ [self.birthday hash];
}
```

在实现一个`hash`函数的时候，一个很常见的误解来源于认为 hash 得到的值 **必须** 是唯一可区分的。实际上，对于关键属性的散列值进行一个简单的XOR操作，就能够满足在 99% 的情况下的需求了。

####何时需要重写hash

Objective-C中，重写了`isEqual:`方法，一般来说不需要重写`hash`方法，但是如果这个对象需要被用作key在字典中存储时，就需要重写。

现在有`People`和`People2`两个类，代码如下：

```
@interface People : NSObject <NSCopying>
@property (nonatomic,copy) NSString *firstName;
@property (nonatomic,copy) NSString *lastName;
@property (nonatomic,assign) NSInteger age;
@end

@implementation People

- (id)copyWithZone:(nullable NSZone *)zone {
    return self;
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
    BOOL firstNameIsEqual = (self.firstName == other.firstName || [self.firstName isEqual:other.firstName]);
    BOOL lastNameIsEqual = (self.lastName == other.lastName || [self.lastName isEqual:other.lastName]);
    BOOL ageIsEqual = (self.age == other.age);
    return firstNameIsEqual && lastNameIsEqual && ageIsEqual;
}

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))
- (NSUInteger)hash
{
    //这里实际上不需要旋转lastName,这里只是演示多个属性时怎么处理。同理如果还有一个NSUInteger的属性，那么两个NSUInteger的hash值也最好旋转
    return NSUINTROTATE([_firstName hash], NSUINT_BIT / 2) ^ NSUINTROTATE([_lastName hash], NSUINT_BIT / 3) ^ (NSUInteger)self.age;
}

@end

```

`People2`类和`People`类一模一样，但是没有重新`hash`方法。现在我们以People类的实例来作为key，在字典中存储一对键值对。代码如下：

```
printf("\n---------------- Person类 ----------------\n");
{
    People *p1 = [[People alloc] init];
    p1.firstName = @"lucy";
    p1.lastName = @"Green";
    
    People *p2 = [[People alloc] init];
    p2.firstName = @"lucy";
    p2.lastName = @"Green";
    
    
    NSLog(@"p1 = %p, p2 = %p, (p1和p2%@)", p1, p2, [p1 isEqual:p2] ? @"相等" : @"不相等");
    
    BOOL hashEqual = ([p1 hash] == [p2 hash]);
    NSLog(@"p1.hash = %ld, p2.hash = %ld, p1.hash %@ p2.hash", [p1 hash], [p2 hash], hashEqual?@"==":@"!=");
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{p1:@"value1"}];
    NSLog(@"用p2作为key取值 %@",[dict objectForKey:p2]);
}


printf("\n---------------- Person2类 ----------------\n");
{
    People2 *p1 = [[People2 alloc] init];
    p1.firstName = @"lucy";
    p1.lastName = @"Green";
    
    People2 *p2 = [[People2 alloc] init];
    p2.firstName = @"lucy";
    p2.lastName = @"Green";
    
    NSLog(@"p1 = %p, p2 = %p, (p1和p2%@) ", p1, p2, [p1 isEqual:p2] ? @"相等" : @"不相等");
    
    BOOL hashEqual = ([p1 hash] == [p2 hash]);
    NSLog(@"p1.hash = %ld, p2.hash = %ld, p1.hash %@ p2.hash", [p1 hash], [p2 hash], hashEqual?@"==":@"!=");
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{p1:@"value1"}];
    NSLog(@"用p2作为key取值 %@",[dict objectForKey:p2]);
}
```

运行上面的代码，打印结果，多打印几次，这里我列出其中两次的log情况：

```
---------------- Person类 ----------------
2017-09-20 17:34:46.820 NSAD[1308:39307] p1 = 0x610000037500, p2 = 0x610000036e60, (p1和p2相等)
2017-09-20 17:34:46.820 NSAD[1308:39307] p1.hash = 2714281438307418121, p2.hash = 2714281438307418121, p1.hash == p2.hash
2017-09-20 17:34:46.820 NSAD[1308:39307] 用p2作为key取值 value1

---------------- Person2类 ----------------
2017-09-20 17:34:46.820 NSAD[1308:39307] p1 = 0x608000035780, p2 = 0x6080000357e0, (p1和p2相等)
2017-09-20 17:34:46.821 NSAD[1308:39307] p1.hash = 106102872299392, p2.hash = 106102872299488, p1.hash != p2.hash
2017-09-20 17:34:46.821 NSAD[1308:39307] 用p2作为key取值 value1
```
```
---------------- Person类 ----------------
2017-09-20 17:45:44.665 NSAD[1359:43287] p1 = 0x608000221c00, p2 = 0x608000221ca0, (p1和p2相等)
2017-09-20 17:45:44.666 NSAD[1359:43287] p1.hash = 2714281438307418121, p2.hash = 2714281438307418121, p1.hash == p2.hash
2017-09-20 17:45:44.666 NSAD[1359:43287] 用p2作为key取值 value1

---------------- Person2类 ----------------
2017-09-20 17:45:44.666 NSAD[1359:43287] p1 = 0x600000223c00, p2 = 0x600000223c20, (p1和p2相等)
2017-09-20 17:45:44.667 NSAD[1359:43287] p1.hash = 105553118510080, p2.hash = 105553118510112, p1.hash != p2.hash
2017-09-20 17:45:44.667 NSAD[1359:43287] 用p2作为key取值 (null)
```

可以看到，两次log的结果，`Person2`类的行为不同，第一次可以使用实例`p2`读出`key`为`p1`的`value`，第二次不行。

思考：   
为什么`Person2`类代码没有改动，但是运行结果会变，第一次可以，第二次不行？

解答：  
`Person2`类的`hash`方法没有重写，所以`p1.hash != p2.hash`。  

当`p1`作为`key`存储字典时，此时会根据字典的当前“箱子个数”`n`，做 `p1.hash % n` 操作，算出应该存放在第几个“箱子”。

再以`p2`为`key`取值的时候， 同样会 `p2.hash % n` 算要去第几个“箱子”获取。找到对应的箱子后，再使用`isEqual:`方法比较`key`，找到对应的`value`。  

所以`p1`相等于`p2`(`isEqual:`)，即使 `p1.hash != p2.hash`, 但是当 `(p1.hash % n) == (p2.hash % n)` 时，一样可以用`p2`作为`key`去对字典进行操作，例如结果1。 但是如果求余结果不等，则找不到，此时就会出现结果2。

因为默认的`hash`方法是直接返回的对象的地址，也就是说`p1`和`p2`的`hash`值是不可控的，所以上面的代码，`Person2`类的行为是未定义的。


####结论

综上所述，如果我们重写了`isEqual:`方法，大部分情况写可以不管`hash`方法，但是当我们需要把这个类的对象加入一张哈希表中的时候，我们一定要重新`hash`方法。

最后在总结一下`equal`和`hash`的关系。

* 对象相等具有 交换性 `（[a isEqual:b] ⇒ [b isEqual:a])`  
* 如果两个对象相等，它们的 `hash` 值也一定是相等的 `([a isEqual:b] ⇒ [a hash] == [b hash])`  
* 反过来则不然，两个对象的散列值相等不一定意味着它们就是相等的 `([a hash] == [b hash] ¬⇒ [a isEqual:b])`


####参考资料：  
[Equality - NSHipster](http://nshipster.cn/equality/)  
[Implementing Equality and Hashing](https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html)  
[深入理解哈希表](http://ios.jobbole.com/87716/)  
