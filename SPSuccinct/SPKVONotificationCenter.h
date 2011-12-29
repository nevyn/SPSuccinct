#import <Foundation/Foundation.h>

typedef void(^SPKVOCallback)(NSDictionary* change, id object, NSString* keyPath);

@interface SPKVObservation : NSObject
-(id)invalidate;
@end


@interface SPKVONotificationCenter : NSObject
+(id)defaultCenter;
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;
// selector should have the following signature:
// - (void)observeChange:(NSDictionary*)change onObject:(id)target forKeyPath:(NSString *)keyPath
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options selector:(SEL)sel;
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options callback:(SPKVOCallback)callback;

@end

@interface NSObject (SPKVONotificationCenterAddition)
-(SPKVObservation*)sp_addObserver:(NSObject*)observer forKeyPath:(NSString*)kp options:(NSKeyValueObservingOptions)options selector:(SEL)sel;
-(SPKVObservation*)sp_addObserver:(NSObject*)observer forKeyPath:(NSString*)kp options:(NSKeyValueObservingOptions)options callback:(SPKVOCallback)callback;
@end