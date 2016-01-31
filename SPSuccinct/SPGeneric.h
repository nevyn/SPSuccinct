
#if __has_feature(objc_generics)

/**
 @function SPGeneric(U, ...)
 
 Declare a "lightweight" generic type, falling back to untyped in older versions of Xcode.

 @param U   The generic type (e.g. @c NSArray, @c NSDictionary)
 @param ... The type parameters or constraints (see tests for examples).


 Usage examples:
 
 <code>
 // [NSString]
 SPGeneric(NSArray, NSString*)* == NSArray<NSString*>*
 // [[String:NSObject]]
 SPGeneric(NSArray, SPGeneric(NSDictionary, NSString*, NSObject*))* == NSArray<NSDictionary<NSString*, NSObject*>>
 </code>

 */
#define SPGeneric(U, ...) U<__VA_ARGS__>

#else

// Erase all generic parameters when ObjC generics aren't available.
#define SPGeneric(U, ...) U

#endif

///
/// @name Conveniences
///

#define SPDictionaryOf(k, v) SPGeneric(NSDictionary, k, v)

#define SPArrayOf(t) SPGeneric(NSArray, t)
