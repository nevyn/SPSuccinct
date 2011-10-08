#import <Foundation/Foundation.h>

//#define $array(...) ({ id values[] = {__VA_ARGS__}; [NSArray arrayWithObjects:values count:sizeof(values)/sizeof(id)]; })
#define $array(...) [NSArray arrayWithObjects:__VA_ARGS__, nil]
#define $set(...) [NSSet setWithObjects:__VA_ARGS__, nil]
#define $marray(...) [NSMutableArray arrayWithObjects:__VA_ARGS__, nil]
#define $dict(...) ({ __unsafe_unretained id pairs[] = {__VA_ARGS__}; SPDictionaryWithPairs(pairs, sizeof(pairs)/sizeof(id), false); })
#define $mdict(...) ({ id pairs[] = {__VA_ARGS__}; SPDictionaryWithPairs(pairs, sizeof(pairs)/sizeof(id), true); })
#define $num(val) [NSNumber numberWithInt:val]
#define $numf(val) [NSNumber numberWithDouble:val]
#define $sprintf(...) [NSString stringWithFormat:__VA_ARGS__]
#define $nsutf(cstr) [NSString stringWithUTF8String:cstr]

#define $cast(klass, obj) ({\
	__typeof__(obj) obj2 = (obj); \
	if(![obj2 isKindOfClass:[klass class]]) \
		[NSException exceptionWithName:NSInternalInconsistencyException \
								reason:$sprintf(@"%@ is not a %@", obj2, [klass class]) \
								userInfo:nil]; \
	(klass*)obj2;\
})
#define $castIf(klass, obj) ({ __typeof__(obj) obj2 = (obj); [obj2 isKindOfClass:[klass class]]?(klass*)obj2:nil; })

#define $notNull(x) ({ __typeof(x) xx = (x); NSAssert(xx != nil, @"Must not be nil"); xx; })

#ifdef __cplusplus
extern "C" {
#endif
	

NSString *$urlencode(NSString *unencoded);
id SPDictionaryWithPairs(__unsafe_unretained id *pairs, size_t count, BOOL mutablep);

#ifdef __cplusplus
}
#endif