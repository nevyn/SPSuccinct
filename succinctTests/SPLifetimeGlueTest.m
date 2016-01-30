//
//  SPLifetimeGlueTest.m
//  SPSuccinct
//
//  Created by Joachim Bengtsson on 2012-11-27.
//
//

#import "SPLifetimeGlueTest.h"
#import "SPLifetimeGlue.h"

@interface Base : NSObject
@end
@interface Derived : Base
@end

@implementation SPLifetimeGlueTest
- (void)testSimpleLifetime
{
    __block BOOL objectLives = YES;
    {
        NSObject *foo = [NSObject new];
        NSArray *objs = [[NSArray alloc] initWithObjects:foo, nil];
        [SPLifetimeGlue watchLifetimes:objs callback:^(SPLifetimeGlue *glue, id objectThatDied) {
            objectLives = NO;
        }];
    }
    XCTAssertTrue(objectLives == NO, @"Object should have died when block dies");
}

// Regression test: subscribing to a Base and then a Derived would infinite-loop, IOS-1718 at Spotify
- (void)testLifetimeWithInheritance
{
    // 1. Watch lifetime on a Derived instance, swizzling its dealloc.
    __block BOOL derivedLives = YES;
    {
        Derived *derived = [Derived new];
        NSArray *objs = [[NSArray alloc] initWithObjects:derived, nil];
        [SPLifetimeGlue watchLifetimes:objs callback:^(SPLifetimeGlue *glue, id objectThatDied) {
            derivedLives = NO;
        }];
    }
    XCTAssertTrue(derivedLives == NO, @"Object should have died when block dies");

    // 2. Watch lifetime on a Base instance, to swizzle its dealloc
    __block BOOL baseLives = YES;
    {
        Base *base = [Base new];
        NSArray *objs = [[NSArray alloc] initWithObjects:base, nil];
        [SPLifetimeGlue watchLifetimes:objs callback:^(SPLifetimeGlue *glue, id objectThatDied) {
            baseLives = NO;
        }];
    }
    XCTAssertTrue(baseLives == NO, @"Object should have died when block dies");

    // 3. Watch lifetime on a Derived instance. Now we have two swizzled deallocs in a chain.
    derivedLives = YES;
    {
        Derived *derived = [Derived new];
        NSArray *objs = [[NSArray alloc] initWithObjects:derived, nil];
        [SPLifetimeGlue watchLifetimes:objs callback:^(SPLifetimeGlue *glue, id objectThatDied) {
            derivedLives = NO;
        }];
    }
    XCTAssertTrue(derivedLives == NO, @"Object should have died when block dies");

}
@end


@implementation Base
- (void)dealloc
{}
@end
@implementation Derived
- (void)dealloc
{}
@end
