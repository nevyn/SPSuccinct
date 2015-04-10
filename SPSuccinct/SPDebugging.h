
#import <Foundation/Foundation.h>

@interface SPDebugging : NSObject

/// Check if an object is a zombie, if Zombies are enabled
+ (BOOL)objectIsZombie:(id)object;

/// Collect a stacktrace as an array of NSStrings
+ (NSArray *)stacktrace;
+ (NSArray *)stacktraceFrom:(int)offset;

/// Generate a breakpoint signal
+ (void)breakpoint;

+ (NSString *)findClassResponsibleForStacktrace:(NSArray *)trace;

@end


@class SPDebuggingRetainReleaseMonitor;
typedef void(^SPDebuggingRetainReleaseMonitorChanged)(SPDebuggingRetainReleaseMonitor *monitor, BOOL retained, NSArray *trace);
// Monitors
@interface SPDebuggingRetainReleaseMonitor : NSObject
//Called each time retain or release is called
@property (nonatomic, copy) SPDebuggingRetainReleaseMonitorChanged onChange;
@property (nonatomic, readonly) id object;
@property (nonatomic, readonly) NSArray *traces;

//Will return a monitor associated with the object.
//Warning; the monitor will swizzle retain and release
+ (SPDebuggingRetainReleaseMonitor *)monitorForObject:(id)object;

@end


@interface SPObservationDebugger : NSObject
+ (SPObservationDebugger *)monitorForClass:(Class)klass;

- (void)start;
@end
