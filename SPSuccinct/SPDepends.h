typedef void(^SPDependsCallback)();
typedef void(^SPDependsFancyCallback)(NSDictionary *change, id object, NSString *keyPath);

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Add a dependency from an object to another object.
 * Registers that your object depends on the given objects and their key paths,
 * and invokes the callback when the values of any of the given key paths
 * changes.
 * 
 * @param owner See associationName. 
 * @param associationName If an owner and association name is given, the dependency 
 *                        object is associated with the owner under the given name, 
 *                        and automatically deallocated if another dependency with the 
 *                        same name is given, or if the owner object dies.
 *
 *                        If the automatic association described above is not used, 
 *                        you must retain the returned dependency object until the 
 *                        dependency becomes invalid.
 * @param callback Called when the association changes. Always called once immediately
 *                 after registration. Can be a SPDependsFancyCallback if you want.
 * @example
 *  __block __typeof(self) selff; // weak reference
 *  NSArray *dependencies = [NSArray arrayWithObjects:foo, @"bar", @"baz", a, @"b", nil]
 *  SPAddDependency(self, @"modifyThing", dependencies, ^ {
 *      selff.thing = foo.bar*3 + foo.baz - a.b;
 *  });
 */
id SPAddDependency(id owner, NSString *associationName, NSArray *dependenciesAndNames, SPDependsCallback callback);
/**
 * Like SPAddDependency, but can be called varg style without an explicit array object.
 * End with the callback and then nil.
 */
id SPAddDependencyV(id owner, NSString *associationName, ...) NS_REQUIRES_NIL_TERMINATION;

/**
 * Removes all dependencies this object has on other objects.
 */
void SPRemoveAssociatedDependencies(id owner);

#ifdef __cplusplus
}
#endif

/**
 * Shortcut for SPAddDependencyV
 */
#define $depends(associationName, object, keypath, ...) ({ \
	__block __typeof(self) selff = self; /* Weak reference*/ \
	SPAddDependencyV(self, associationName, object, keypath, __VA_ARGS__, nil);\
})
