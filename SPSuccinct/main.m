#import <Foundation/Foundation.h>
#import "SPDepends.h"

@interface Foo : NSObject
@property(retain) NSString *a, *b;
@property(retain) Foo *y;
@end
@implementation Foo
@synthesize a, b, y;
-(void)main;
{
	Foo *x = [[Foo new] autorelease];
	self.y = [[Foo new] autorelease];
	x.a = @"Hello";
	x.b = @"there";
	$depends(@"printing", x, @"a", @"b", y, @"a", ^{
		NSLog(@"%@ %@, %@", x.a, x.b, selff.y.a);
	});
	y.a = @"world!";
}
@end

int main (int argc, const char * argv[])
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	[[[Foo new] autorelease] main];
	
    [pool drain];
	return 0;
}

