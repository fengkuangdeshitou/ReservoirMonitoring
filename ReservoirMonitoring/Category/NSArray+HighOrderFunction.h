//
//  NSArray+HighOrderFunction.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (HighOrderFunction)

- (NSArray *)map:(id(^)(id))hanlde;

- (NSArray *)filter:(BOOL(^)(id))handle;

- (id)reduce:(id(^)(id, id))handle initial:(id)initial;

@end

NS_ASSUME_NONNULL_END
