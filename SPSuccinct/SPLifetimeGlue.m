#import "SPLifetimeGlue.h"
#import <objc/runtime.h>

@interface NSObject (SPLifetimeGlue)
- (void)sp_notifyingDealloc;
@end

@implementation SPLifetimeGlue
+ (id)watchLifetimes:(NSArray*)objects callback:(SPLifetimeGlueCallback)callback
{
    return [[[self alloc] initWatchingLifetimesOfObjects:objects callback:callback] autorelease];
}

- (id)initWatchingLifetimesOfObjects:(NSArray*)objects callback:(SPLifetimeGlueCallback)callback
{
    if (!(self = [super init]))
        return nil;
    
    self.objectDied = callback;
    
    for(id object in objects)
        [self addSelfAsDeallocListenerTo:object];
    
    return self;
}

- (void)dealloc;
{
    self.objectDied = nil;
    [super dealloc];
}

- (void)preDealloc:(id)sender;
{
    if (self.objectDied)
        self.objectDied(self, sender);
}

static NSString *const SPLifetimeGlueClassPrefix = @"__SPLifetimeObserving_";
static void *SPLifetimeObserversKey = &SPLifetimeObserversKey;

- (void)addSelfAsDeallocListenerTo:(id)object
{
    // A Class can never die, so don't add a listener to it. Remove these two lines to have your mind explode.
    if (object == [object class])
        return;
    
    Class origClass = [object class];
    NSString *altClassName = [NSString stringWithFormat:@"%@_%@", SPLifetimeGlueClassPrefix, NSStringFromClass(origClass)];
    Class altClass = NSClassFromString(altClassName);
    
    if ([NSStringFromClass(origClass) rangeOfString:SPLifetimeGlueClassPrefix].location != NSNotFound) {
        altClass = origClass;
        origClass = [object superclass];
    }
    
    if (!altClass) {
        altClass = objc_allocateClassPair(origClass, [altClassName UTF8String], 0);
        
        SEL sel = @selector(dealloc);
        const char *deallocType = method_getTypeEncoding(class_getInstanceMethod([self class], sel));
        IMP altMethodIMP = imp_implementationWithBlock(^(__unsafe_unretained id me) {
            NSMutableArray *observers = objc_getAssociatedObject(me, SPLifetimeObserversKey);
            
            for(__typeof(self) observer in observers)
                [observer preDealloc:me];
            
            void(*superIMP)(id, SEL) = (void(*)(id, SEL))[origClass instanceMethodForSelector:sel];
            superIMP(me, sel);
        });
        class_addMethod(altClass, sel, altMethodIMP, deallocType);
        objc_registerClassPair(altClass);
    }
    
    if (![[object class] isEqual:altClass]) {
        object_setClass(object, altClass);
        NSMutableArray *observers = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(object, SPLifetimeObserversKey, observers, OBJC_ASSOCIATION_RETAIN);
        [observers release];
    }
    
    NSMutableArray *observers = objc_getAssociatedObject(object, SPLifetimeObserversKey);
    [observers addObject:self];
}

@end
