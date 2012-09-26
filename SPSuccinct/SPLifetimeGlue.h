#import <Foundation/Foundation.h>

@class SPLifetimeGlue;

typedef void(^SPLifetimeGlueCallback)(SPLifetimeGlue *glue, id objectThatDied);

@interface SPLifetimeGlue : NSObject
- (id)initWatchingLifetimesOfObjects:(NSArray*)objects callback:(SPLifetimeGlueCallback)callback;
+ (id)watchLifetimes:(NSArray*)objects callback:(SPLifetimeGlueCallback)callback;
@property(nonatomic, copy) SPLifetimeGlueCallback objectDied;
- (void)invalidate;
@end
