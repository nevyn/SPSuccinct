#import "SPLowVerbosity.h"

NSString *$urlencode(NSString *unencoded) {
	// Thanks, http://www.tikirobot.net/wp/2007/01/27/url-encode-in-cocoa/
	return [(id)CFURLCreateStringByAddingPercentEscapes(
														kCFAllocatorDefault, 
														(CFStringRef)unencoded, 
														NULL, 
														(CFStringRef)@";/?:@&=+$,", 
														kCFStringEncodingUTF8
														) autorelease];
}

id SPDictionaryWithPairs(id *pairs, size_t count, BOOL mutablep)
{
	id keys[count], values[count];
	size_t kvi = 0;
	for(size_t idx = 0; idx < count;) {
		keys[kvi] = pairs[idx++];
		values[kvi++] = pairs[idx++];
	}
	return [mutablep?[NSMutableDictionary class]:[NSDictionary class] dictionaryWithObjects:values forKeys:keys count:kvi];
}