//
//  SPDependsTest.m
//  SPSuccinct
//
//  Created by Joachim Bengtsson on 2012-11-27.
//
//

#import "SPDependsTest.h"
#import "SPKVONotificationCenter.h"
#import "SPDepends.h"

@interface Dummy2 : NSObject
@property int property;
@end
@implementation Dummy2
@end


@implementation SPDependsTest
- (void)testLivingSubscription
{
    Dummy2 *dummy = [Dummy2 new];
    __block BOOL callbackCount = 0;
    id sub = SPAddDependency(nil, nil, @[SPD_PAIR(dummy, property)], ^{
        callbackCount++;
    });
    dummy.property = 1;
    XCTAssertTrue(callbackCount == 2, @"Should have triggered initial + 1");
    (void)sub;
}

- (void)testInvalidate
{
    Dummy2 *dummy = [Dummy2 new];
    __block BOOL callbackCount = 0;
    id sub = SPAddDependency(nil, nil, @[SPD_PAIR(dummy, property)], ^{
        callbackCount++;
    });
    [sub invalidate];
    dummy.property = 1;
    XCTAssertTrue(callbackCount == 1, @"Should have triggered initial + 1");
    (void)sub;
}
@end
