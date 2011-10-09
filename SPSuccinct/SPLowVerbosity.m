#import "SPLowVerbosity.h"

NSString *$urlencode(NSString *unencoded) {
	// Thanks, http://www.tikirobot.net/wp/2007/01/27/url-encode-in-cocoa/
	return [(__bridge id)CFURLCreateStringByAddingPercentEscapes(
														kCFAllocatorDefault, 
														(CFStringRef)unencoded, 
														NULL, 
														(CFStringRef)@";/?:@&=+$,", 
														kCFStringEncodingUTF8
														) autorelease];
}

id SPDictionaryWithPairs(NSArray *pairs, BOOL mutablep)
{
	NSUInteger count = pairs.count/2;
	id keys[count], values[count];
	size_t kvi = 0;
	for(size_t idx = 0; kvi < count;) {
		keys[kvi] = [pairs objectAtIndex:idx++];
		values[kvi++] = [pairs objectAtIndex:idx++];
	}
	return [mutablep?[NSMutableDictionary class]:[NSDictionary class] dictionaryWithObjects:values forKeys:keys count:kvi];
}

NSError *$makeErr(NSString *domain, NSInteger code, NSString *localizedDesc)
{
    return [NSError errorWithDomain:domain code:code userInfo:$dict(
        NSLocalizedDescriptionKey, localizedDesc
    )];
}

#if NS_BLOCKS_AVAILABLE
@implementation NSDictionary (SPMap)
-(NSDictionary*)sp_map:(id(^)(NSString *key, id value))mapper;
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    for(NSString *key in self.allKeys)
        [d setObject:mapper(key, [self objectForKey:key]) forKey:key];
    return [[d copy] autorelease];
}
@end
#endif