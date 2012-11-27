//
//  SPLifetimeGlueTest.m
//  SPSuccinct
//
//  Created by Joachim Bengtsson on 2012-11-27.
//
//

#import "SPLifetimeGlueTest.h"
#import "SPLifetimeGlue.h"

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
    STAssertTrue(objectLives == NO, @"Object should have died when block dies");
}
@end
