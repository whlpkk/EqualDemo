//
//  ViewController.m
//  NSAD
//
//  Created by YZK on 2017/7/11.
//  Copyright © 2017年 MOMO. All rights reserved.
//

#import "ViewController.h"

#import "People.h"
#import "People2.h"

@interface ViewController ()

@end

@implementation ViewController

/*
 哈希表的存储过程如下:
 1.根据 key 计算出它的哈希值 h。
 2.假设箱子的个数为 n，那么这个键值对应该放在第 (h % n) 个箱子中。(可能是其他的散列函数)
 3.如果该箱子中已经有了键值对，对比key是否相等（isEqual）,相等更新，不相等就使用开放寻址法或者拉链法解决冲突。
 所以，如果两个 key 的哈希值 h1 和 h2 不等，但他们的( h % n )依然有可能相等，即有可能发生哈希碰撞。
 
 
 哈希表的获取过程如下:
 1.根据 key 计算出它的哈希值 h。
 2.假设箱子的个数为 n，去第 (h % n) 个箱子中查找这个键值对。
 3.在该箱子中，对比key是否相等（isEqual）,相等就返回此键值对。
 所以，如果两个 key 的哈希值 h1 和 h2 不等，但他们的( h % n )依然有可能相等，即有可能发生哈希碰撞。
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
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
}

/*
 第一次：
 ---------------- Person类 ----------------
 2017-09-20 17:34:46.820 NSAD[1308:39307] p1 = 0x610000037500, p2 = 0x610000036e60, (p1和p2相等)
 2017-09-20 17:34:46.820 NSAD[1308:39307] p1.hash = 2714281438307418121, p2.hash = 2714281438307418121, p1.hash == p2.hash
 2017-09-20 17:34:46.820 NSAD[1308:39307] 用p2作为key取值 value1
 
 ---------------- Person2类 ----------------
 2017-09-20 17:34:46.820 NSAD[1308:39307] p1 = 0x608000035780, p2 = 0x6080000357e0, (p1和p2相等)
 2017-09-20 17:34:46.821 NSAD[1308:39307] p1.hash = 106102872299392, p2.hash = 106102872299488, p1.hash != p2.hash
 2017-09-20 17:34:46.821 NSAD[1308:39307] 用p2作为key取值 value1

 结果： Person和Person2类都能获取。
 
 
 
 
 
 
 第二次：
 ---------------- Person类 ----------------
 2017-09-20 17:45:44.665 NSAD[1359:43287] p1 = 0x608000221c00, p2 = 0x608000221ca0, (p1和p2相等)
 2017-09-20 17:45:44.666 NSAD[1359:43287] p1.hash = 2714281438307418121, p2.hash = 2714281438307418121, p1.hash == p2.hash
 2017-09-20 17:45:44.666 NSAD[1359:43287] 用p2作为key取值 value1
 
 ---------------- Person2类 ----------------
 2017-09-20 17:45:44.666 NSAD[1359:43287] p1 = 0x600000223c00, p2 = 0x600000223c20, (p1和p2相等)
 2017-09-20 17:45:44.667 NSAD[1359:43287] p1.hash = 105553118510080, p2.hash = 105553118510112, p1.hash != p2.hash
 2017-09-20 17:45:44.667 NSAD[1359:43287] 用p2作为key取值 (null)

 结果： Person能获取，Person2不能。
 
 
 思考： 为什么Person2类 代码没有改动，但是运行结果会变，第一次可以，第二次不行？
 解答： 因为Person2类的hash方法没有重写，所以p1.hash != p2.hash, 当p1作为key 存储字典时，此时会根据字典的当前“箱子个数”n，
       做 p1.hash % n 操作，算出应该存放在第几个“箱子”。再以p2为key 取值的时候， 同样会 p2.hash % n 算要去第几个“箱子”获取。
       所以p1相等于p2(isEqual:)，即使 p1.hash != p2.hash, 但是当 (p1.hash % n) == (p2.hash % n) 时，
       一样可以用p2作为key去对字典进行操作，例如结果1。 但是如果求余结果不等，则找不到，此时就会出现结果2。
       因为默认的hash方法是直接返回的对象的地址，也就是说p1和p2的hash值是不可控的，也即上述的操作结果是未定义的。
 
 结论： 如果重写了类的isEqual:方法，而且还要作为字典的key或者要放入NSSet等哈希表中，此时必须重写hash方法，否则结果是未定义的。
 */


@end
