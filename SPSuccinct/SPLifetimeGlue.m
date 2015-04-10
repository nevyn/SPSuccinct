#import "SPLifetimeGlue.h"
#import <objc/runtime.h>
#import <objc/message.h>

static const void *NopRetainer(CFAllocatorRef allocator, const void *value) {
    return value;
}
static void NopReleaser(CFAllocatorRef allocator, const void *value) {}


@interface NSObject (SPLifetimeGlue)
- (void)sp_swizzledNotifyingDealloc;
@end

@implementation SPLifetimeGlue
{
    CFMutableArrayRef _observeds;
}

+ (id)watchLifetimes:(NSArray*)objects callback:(SPLifetimeGlueCallback)callback
{
    if ([objects count] == 0)
        return nil;
    
    id me = [[self alloc] initWatchingLifetimesOfObjects:objects callback:callback];
    // ownership by observed objects acts as autorelease, so we can have a more well-determined lifetime than 'later'
    [me release];
    return me;
}

- (id)initWatchingLifetimesOfObjects:(NSArray*)objects callback:(SPLifetimeGlueCallback)callback
{
    if (!(self = [super init]))
        return nil;
    
    self.objectDied = callback;
    CFArrayCallBacks callbacks = {0, NopRetainer, NopReleaser, CFCopyDescription, CFEqual};
    _observeds = CFArrayCreateMutable(NULL, 0, &callbacks);

    for(id object in objects)
        [self addSelfAsDeallocListenerTo:object];
    CFArrayAppendArray(_observeds, (CFArrayRef)objects, CFRangeMake(0, [objects count]));
    
    return self;
}

- (void)dealloc;
{
    self.objectDied = nil;
    CFRelease(_observeds);
    [super dealloc];
}

- (void)preDealloc:(id)sender;
{
    
    CFIndex idx = CFArrayGetFirstIndexOfValue(_observeds, CFRangeMake(0, CFArrayGetCount(_observeds)), sender);
    CFArrayRemoveValueAtIndex(_observeds, idx);
    
    if (self.objectDied)
        self.objectDied(self, sender);
}

//static NSString *const SPLifetimeGlueClassPrefix = @"__SPLifetimeObserving_";
static void *SPLifetimeObserversKey = &SPLifetimeObserversKey;

static NSMutableSet *swizzledClasses;

- (void)addSelfAsDeallocListenerTo:(id)object
{
    // Swizzling NSKVODealloc crashes, which happens if you use object_getClass(object) instead of [object class]
    Class sourceClass = [object class];
    
    // A Class can never die, so don't add a listener to it. Remove these two lines to have your mind explode.
    if (class_isMetaClass(sourceClass))
        return;
    
    NSMutableArray *observers = objc_getAssociatedObject(object, SPLifetimeObserversKey);
    
    if(!observers) {
        observers = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(object, SPLifetimeObserversKey, observers, OBJC_ASSOCIATION_RETAIN);
        [observers release];
    }
    
    SEL origSel = sel_registerName("dealloc");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [NSMutableSet new];
    });
    
    if(![swizzledClasses containsObject:sourceClass]) {
        [swizzledClasses addObject:sourceClass];
        
        Method origMethod = class_getInstanceMethod(sourceClass, origSel);
        IMP origImpl = method_getImplementation(origMethod);
        
        IMP altImpl = imp_implementationWithBlock(^void(__unsafe_unretained id me) {
            CFMutableArrayRef observers = (CFMutableArrayRef)objc_getAssociatedObject(me, SPLifetimeObserversKey);
            
            if (observers) {
                //Copy as preDealloc modifies the array.
                CFArrayRef observersCopy = CFArrayCreateCopy(NULL, observers);
                for(__typeof(self) observer in (NSArray *)observersCopy)
                    [observer preDealloc:me];
                
                CFRelease(observersCopy);
            }
            
            ((void(*)(id, SEL))origImpl)(me, origSel);
        });
        
        class_replaceMethod(sourceClass, origSel, altImpl, method_getTypeEncoding(origMethod));
    }
    
    [observers addObject:self];
}

- (void)invalidate
{
    [self retain];
    self.objectDied = nil;
    for(id obj in (NSArray*)_observeds) {
        NSMutableArray *observers = objc_getAssociatedObject(obj, SPLifetimeObserversKey);
        [observers removeObject:self];
    }
    [self release];

}

@end
