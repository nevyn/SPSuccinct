#import <Foundation/Foundation.h>

@interface NSArray (SPFunctional)
-(NSArray*)sp_map:(id(^)(id obj))mapper;
-(NSArray*)sp_mapi:(id(^)(id obj, int idx))mapper;
-(id)sp_collect:(id)start with:(id(^)(id sum, id obj))collector;
-(NSArray*)sp_filter:(BOOL(^)(id obj))predicate;
-(void)sp_each:(void(^)(id obj))iterator;
@end
@interface NSDictionary (SPFunctional)
-(NSDictionary*)sp_map:(id(^)(NSString *key, id value))mapper;
-(NSDictionary*)sp_filter:(BOOL(^)(id key, id val))predicate;
@end