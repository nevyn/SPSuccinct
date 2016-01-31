//
//  SPGenericTest.m
//  SPSuccinct
//
//  Created by Brian Gerstle on 1/30/16.
//
//

#import <XCTest/XCTest.h>
#import "SPGeneric.h"

// TODO: check declaration of custom generic class

/**
 Compile-time test to ensure SPGeneric macro expands properly.
 */
@interface SPGenericTest : XCTestCase
@end

// Should be able to declare types

typedef SPGeneric(NSArray, id<NSCoding>)* SPArrayOfSerializables;

typedef SPGeneric(NSArray, NSDictionary*)* SPArrayOfDictionaries;

@implementation SPGenericTest

- (SPGeneric(NSArray, NSString*)*)strings {
    SPGeneric(NSArray, NSString*)* arrayOfStrings = @[@"foo"];
    return arrayOfStrings;
}

- (SPGeneric(NSArray, NSNumber*)*)numbers {
    SPGeneric(NSArray, NSNumber*)* arrayOfNumbers = @[@0];
    return arrayOfNumbers;
}

- (SPGeneric(NSArray, NSArray*)*)arrays {
    SPGeneric(NSArray, NSArray*)* arrays = @[@[]];
    return arrays;
}

// And you thought angle-bracket-blindedness was bad >.< use typedefs!
- (SPGeneric(NSArray, SPGeneric(NSArray, NSDictionary*)*)*)arraysOfDynamicDictionaries {
    // use typedefs (and convenience macros) to make code more readable
    SPArrayOf(SPArrayOfDictionaries)* dicts = @[@[@{}]];
    return dicts;
}

#if __has_feature(objc_generics)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"

- (void)testShouldWarnAgainstImproperAssignments {
    // HAX: need to cast the literal, otherwise warning doesn't get triggered :(

    // wrong element type
    SPArrayOf(NSString*)* arrayOfStrings = (NSArray<NSNumber*>*) @[@0];

    // wrong key type
    SPDictionaryOf(NSNumber*, NSObject*)* dict = (NSDictionary<NSString*, NSObject*>*) @{@"foo": @"bar"};

    // wrong value type
    SPDictionaryOf(NSString*, NSDictionary*)* dict2 = (NSDictionary<NSString*, NSObject*>*) @{@"foo": @"bar"};
}

#pragma clang diagnostic pop

#endif

@end
