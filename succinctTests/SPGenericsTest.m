//
//  SPGenericsTest.m
//  SPSuccinct
//
//  Created by Brian Gerstle on 1/30/16.
//
//

#import <XCTest/XCTest.h>
#import "SPGenerics.h"

/**
 Compile-time test to ensure SPGenerics macro expands properly.
 */
@interface SPGenericsTest : XCTestCase
@end

@implementation SPGenericsTest

- (void)testValidAssignmentToGenericallyTypedVariables {
    SPGeneric(NSArray, NSString*)* arrayOfStrings = @[@"foo"];
}

@end
