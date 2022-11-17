//
//  NSArray+HighOrderFunction.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/17.
//

#import "NSArray+HighOrderFunction.h"

@implementation NSArray (HighOrderFunction)

- (NSArray *)map:(id(^)(id))hanlde {
    if (!hanlde || !self) return self;
    
    NSMutableArray *arr = NSMutableArray.array;
    for (id obj in self) {
        id new = hanlde(obj);
        [arr addObject:new];
    }
    return arr.copy;
}

- (NSArray *)filter:(BOOL(^)(id))handle {
    if (!handle || !self) return self;
    
    NSMutableArray *arr = NSMutableArray.array;
    for (id obj in self) {
        if (handle(obj)) {
            [arr addObject:obj];
        }
    }
    return arr.copy;
}

- (id)reduce:(id(^)(id, id))handle initial:(id)initial {
    if (!handle || !self || !initial) return self;
    if (self.count <1) return initial;
    
    id value = initial;
    for (id obj in self) {
        value = handle(value, obj);
    }
    return value;
}

@end
