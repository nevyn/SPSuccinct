
#import "SPDebugging.h"
#include <objc/runtime.h>
#include <sys/signal.h>
#include <execinfo.h>

static void *SPDebuggingRetainReleaseMonitorKey = &SPDebuggingRetainReleaseMonitorKey;
static void *SPDebuggingObservationMonitorKey = &SPDebuggingObservationMonitorKey;


typedef void(*spimp_addObserver)(id me, SEL op, id observer, id keyPath, int options, void *context);
typedef void(*spimp_removeObserver)(id me, SEL op, id observer, id keyPath, void *context);

@interface ObserverTrace : NSObject
@property (nonatomic, assign) id object;
@property (nonatomic, assign) id observer;
@property (nonatomic, retain) NSString *objectDescription;
@property (nonatomic, retain) NSString *observerDescription;
@property (nonatomic, retain) NSString *keyPath;
@property (nonatomic, retain) NSArray *stacktrace;
@end

@implementation ObserverTrace
- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        ObserverTrace *trace = (ObserverTrace*)object;
        return trace.object == self.object &&
                trace.observer == self.observer &&
                ([trace.keyPath isEqual:self.keyPath] || !(trace.keyPath && self.keyPath));
    }
    
    return [super isEqual:object];
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ observes %@.%@\n%@", self.observerDescription, self.objectDescription, self.keyPath, [[self.stacktrace objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 5)]] componentsJoinedByString:@"\n"]];
}
@end

@implementation SPObservationDebugger
{
    spimp_addObserver orig_addObserver;
    spimp_removeObserver orig_removeObserver;
    
    Class klass;
    
    NSMutableArray *traces;
}

+ (SPObservationDebugger *)monitorForClass:(Class)klass
{
    SPObservationDebugger *monitor = objc_getAssociatedObject(klass, SPDebuggingObservationMonitorKey);
    if (!monitor) {
        monitor = [[[SPObservationDebugger alloc] initWithClass:klass] autorelease];
        objc_setAssociatedObject(klass, SPDebuggingObservationMonitorKey, monitor, OBJC_ASSOCIATION_RETAIN);
    }
    return monitor;
}

- (id)initWithClass:(Class)_klass;
{
    if (!(self = [self init]))
        return nil;
    
    klass = _klass;
    traces = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)traceAdd:(id)object observer:(id)observer keyPath:(id)keyPath options:(int)options context:(void*)context
{
    ObserverTrace *trace = [[[ObserverTrace alloc] init] autorelease];
    trace.object = object;
    trace.observer = observer;
    trace.objectDescription = [object description];
    trace.observerDescription = [observer description];
    trace.keyPath = keyPath;
    trace.stacktrace = [SPDebugging stacktrace];
    [traces addObject:trace];
}

- (void)traceRemove:(id)object observer:(id)observer keyPath:(id)keyPath context:(void*)context
{
    ObserverTrace *trace = [[[ObserverTrace alloc] init] autorelease];
    trace.object = object;
    trace.observer = observer;
    trace.keyPath = keyPath;
    [traces removeObject:trace];
}

- (void)start
{
    SEL addSel = @selector(addObserver:forKeyPath:options:context:);
    SEL removeSel = @selector(removeObserver:forKeyPath:context:);
    orig_addObserver = (spimp_addObserver)[klass instanceMethodForSelector:addSel];
    orig_removeObserver = (spimp_removeObserver)[klass instanceMethodForSelector:removeSel];
    
    IMP newAdd = imp_implementationWithBlock(^(id me, id observer, id keyPath, int options, void *context){
        SPObservationDebugger *monitor = objc_getAssociatedObject(klass, SPDebuggingObservationMonitorKey);
        [monitor traceAdd:me observer:observer keyPath:keyPath options:options context:context];
        orig_addObserver(me, addSel, observer, keyPath, options, context);
    });
    
    IMP newRemove = imp_implementationWithBlock(^(id me, id observer, id keyPath, void *context){
        SPObservationDebugger *monitor = objc_getAssociatedObject(klass, SPDebuggingObservationMonitorKey);
        [monitor traceRemove:me observer:observer keyPath:keyPath context:context];
        orig_removeObserver(me, removeSel, observer, keyPath, context);
    });
    
    
    class_replaceMethod(klass, addSel, newAdd, method_getTypeEncoding(class_getInstanceMethod(klass, addSel)));
    class_replaceMethod(klass, removeSel, newRemove, method_getTypeEncoding(class_getInstanceMethod(klass, removeSel)));
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ report: %@", [self class], traces];
}

@end


@implementation SPDebuggingRetainReleaseMonitor
{
    NSMutableArray *_traces;
    id _object;
}

@synthesize object = _object;
@synthesize traces = _traces;

+ (SPDebuggingRetainReleaseMonitor *)monitorForObject:(id)object
{
    SPDebuggingRetainReleaseMonitor *monitor = objc_getAssociatedObject(object, SPDebuggingRetainReleaseMonitorKey);
    if (!monitor)
        monitor = [[[self alloc] initWithObject:object] autorelease];
    return monitor;
}

- (id)initWithObject:(id)object;
{
    if (!(self = [super init]))
        return nil;
    
    NSAssert(object, @"object must not be nil");
    _object = object;
    _traces = [[NSMutableArray alloc] init];
    
    [self attach];
    
    return self;
}

- (void)dealloc
{
    objc_setAssociatedObject(_object, SPDebuggingRetainReleaseMonitorKey, nil, OBJC_ASSOCIATION_RETAIN);
    [_traces release];
    [super dealloc];
}

- (void)traceRetain
{
    NSArray *trace =[SPDebugging stacktrace];
    [_traces addObject:trace];
    if (self.onChange)
        self.onChange(self, YES, trace);
}

- (void)traceRelease
{
    NSArray *trace = [SPDebugging stacktrace];
    [_traces addObject:trace];
    if (self.onChange)
        self.onChange(self, NO, trace);
}

- (void)attach
{
    objc_setAssociatedObject(_object, SPDebuggingRetainReleaseMonitorKey, self, OBJC_ASSOCIATION_RETAIN);
    
    id (*retain)(id, SEL) = (id(*)(id, SEL))[_object methodForSelector:@selector(retain)];
    IMP newRetain = imp_implementationWithBlock((id)^(id me, SEL op){
        id this = retain(me, op);
        SPDebuggingRetainReleaseMonitor *monitor = objc_getAssociatedObject(me, SPDebuggingRetainReleaseMonitorKey);
        [monitor traceRetain];
        return this;
    });

    void (*release)(id, SEL) = (void(*)(id, SEL))[_object methodForSelector:@selector(release)];
    IMP newRelease = imp_implementationWithBlock(^(id me, SEL op){
        SPDebuggingRetainReleaseMonitor *monitor = objc_getAssociatedObject(me, SPDebuggingRetainReleaseMonitorKey);
        [monitor traceRelease];
        release(me, op);
    });
    
    class_replaceMethod([_object class], @selector(retain), newRetain, method_getTypeEncoding(class_getInstanceMethod([_object class], @selector(retain))));
    class_replaceMethod([_object class], @selector(release), newRelease, method_getTypeEncoding(class_getInstanceMethod([_object class], @selector(release))));
}

@end

@implementation SPDebugging
+ (BOOL)objectIsZombie:(id)object
{
    NSString *name = [NSString stringWithUTF8String:class_getName(object_getClass(object))];
    return [name rangeOfString:@"_NSZombie_"].location != NSNotFound;
}

+ (NSArray *)stacktraceFrom:(int)offset
{
    NSMutableArray *trace = [NSMutableArray array];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = offset; i < frames; ++i) {
        [trace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return trace;
}

+ (NSArray *)stacktrace
{
    return [self stacktraceFrom:0];
}

+ (NSString *)findClassResponsibleForStacktrace:(NSArray *)trace
{
//    NSLog(@"stack: %@", trace);
    NSString *line = [self findLineResponsibleForStacktrace:trace];
    NSInteger start = [line rangeOfString:@"["].location;
    if (start == NSNotFound) return line;
    start += 1;
    NSInteger end = [line rangeOfString:@" " options:0 range:NSMakeRange(start, line.length-start)].location;
    return [line substringWithRange:NSMakeRange(start, end-start)];
}
    
+ (NSString *)findLineResponsibleForStacktrace:(NSArray *)trace;
{
//    NSLog(@"stack: %@", trace);
    NSString *name = [trace objectAtIndex:0];
    NSString *autoreleased = nil;
    for (NSString *line in trace) {
        if ([line rangeOfString:@"_CFAutoreleasePoolPop"].location != NSNotFound)
            autoreleased = line;
        if ([line rangeOfString:@"Spotify"].location == NSNotFound)
            continue;
        if ([line rangeOfString:@"["].location != NSNotFound)
            return line;
    }
    if (autoreleased)
        return autoreleased;
    return name;
}

+ (void)breakpoint
{
#if _DEBUG
    kill(0, SIGTRAP);
#endif
}

@end
