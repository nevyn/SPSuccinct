#import <Foundation/Foundation.h>
#import <SPSuccinct/SPSuccinct.h>

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
	
	// This line establishes a dependency from 'self' to x.a, x.b and y.a.
	$depends(@"printing", x, @"a", @"b", y, @"a", ^{
		NSLog(@"%@ %@, %@", x.a, x.b, selff.y.a);
	});
	// It is called once after the dependency is established, similarly to as if
	// you had registered KVO with NSKeyValueObservingOptionInitial.
	
	// After changing y.a, the 'printing' dependency's block is ran, since
	// 'self' now depends on y.a.
	y.a = @"world!";
}
@end

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	[[[Foo new] autorelease] main];
    
    
    NSLog(@"Yay multiplication: %@", [$array($num(1), $num(2), $num(3)) sp_map:^(id obj) {
        return $num([obj intValue]*2);
    }]);
    
    NSLog(@"Yay dict fake literals %@", $dict(@"foo", @"bar"));
    
	
	[pool drain];
	return 0;
}

