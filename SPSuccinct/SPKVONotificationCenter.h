#import <Foundation/Foundation.h>

@interface SPKVObservation : NSObject
-(id)unregister;
@end


@interface SPKVONotificationCenter : NSObject
+(id)defaultCenter;
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;
// selector should have the following signature:
// - (void)observeChange:(NSDictionary*)change onObject:(id)target forKeyPath:(NSString *)keyPath
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options selector:(SEL)sel;
@end
