//
//  SPKVONCTest.m
//  SPSuccinct
//
//  Created by Joachim Bengtsson on 2012-11-27.
//
//

#import "SPKVONCTest.h"
#import "SPKVONotificationCenter.h"

@interface Dummy : NSObject
@property int property;
@end
@implementation Dummy
@end

@implementation SPKVONCTest
- (void)testLivingSubscription
{
    Dummy *dummy = [Dummy new];
    __block BOOL callbackTriggered = NO;
    id sub = [dummy sp_addObserver:self forKeyPath:SPS_KEYPATH(dummy, property) options:0 callback:^(NSDictionary *change, id object, NSString *keyPath) {
        callbackTriggered = YES;
    }];
    dummy.property = 1;
    STAssertTrue(callbackTriggered, @"Subscription object is still in scope and should have triggered");
    (void)sub;
}

- (void)testInvalidate
{
    Dummy *dummy = [Dummy new];
    __block BOOL callbackTriggered = NO;
    id sub = [dummy sp_addObserver:self forKeyPath:SPS_KEYPATH(dummy, property) options:0 callback:^(NSDictionary *change, id object, NSString *keyPath) {
        callbackTriggered = YES;
    }];
    [sub invalidate];
    dummy.property = 1;
    STAssertFalse(callbackTriggered, @"Subscription object should be dead, and should not have triggered");
}
@end
