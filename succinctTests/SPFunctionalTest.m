//
//  SPFunctionalTest.m
//  SPSuccinct
//
//  Created by Joachim Bengtsson on 2012-11-27.
//
//

#import "SPFunctionalTest.h"
#import "SPFunctional.h"

@implementation SPFunctionalTest
- (void)testMap
{
    NSArray *original = @[@1, @2, @3];
    NSArray *doubles = [original sp_map:^(id obj) {
        return @([obj intValue] * 2);
    }];
    NSArray *expected = @[@2, @4, @6];
    STAssertEqualObjects(doubles, expected, @"Multiplication of objects in map");
}
@end
