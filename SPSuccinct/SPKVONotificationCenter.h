#import <Foundation/Foundation.h>

/**
 * This macro takes an object and a property name and expands into a string
 * literal with the property name. It generates a compile-time error if the
 * given object does not have the specified property.
 *
 * It is possible to use chains of properties, SPS_KEYPATH(obj, a.b) will for
 * instance expand into something that evaluates to @"a.b".
 *
 * The purpose of this macro is to serve as a helper when you need a KVC
 * keypath. The fact that it generates a compile time error is very valuable:
 * Without it, things like KVO callbacks will just be silently ignored when the
 * property it observes is renamed or removed.
 */
#define SPS_KEYPATH(object, property) ((void)(NO && ((void)object.property, NO)), @#property)

typedef void(^SPKVOCallback)(NSDictionary* change, id object, NSString* keyPath);

enum {
    /// By default, SPKVONC holds on to the observation after it has been added, and automatically invalidates
    /// when either 'observer' or 'observed' dies. You can disable this behavior with the ManualLifetime
    /// flag.
    SPKeyValueObservingOptionManualLifetime = 1 << 8,
};


@interface SPKVObservation : NSObject
-(void)invalidate;
@end


@interface SPKVONotificationCenter : NSObject
+(id)defaultCenter DEPRECATED_ATTRIBUTE;
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options DEPRECATED_ATTRIBUTE;
// selector should have the following signature:
// - (void)observeChange:(NSDictionary*)change onObject:(id)target forKeyPath:(NSString *)keyPath
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options selector:(SEL)sel DEPRECATED_ATTRIBUTE;
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options callback:(SPKVOCallback)callback DEPRECATED_ATTRIBUTE;

@end

@interface NSObject (SPKVONotificationCenterAddition)
-(SPKVObservation*)sp_addObserver:(NSObject*)observer forKeyPath:(NSString*)kp options:(NSKeyValueObservingOptions)options selector:(SEL)sel;
-(SPKVObservation*)sp_addObserver:(NSObject*)observer forKeyPath:(NSString*)kp options:(NSKeyValueObservingOptions)options callback:(SPKVOCallback)callback;
-(SPKVObservation*)sp_observe:(NSString*)kp removed:(void(^)(id))onRemoved added:(void(^)(id))onAdded;
-(SPKVObservation*)sp_observe:(NSString*)kp removed:(void(^)(id))onRemoved added:(void(^)(id))onAdded initial:(BOOL)callbackInitial;
@end