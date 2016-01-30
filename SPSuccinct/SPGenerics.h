
#if __has_feature(objc_generics)

#define SPGeneric(U, ...) U<__VA_ARGS__>

#else

#define SPGeneric(U, ...) U

#endif
