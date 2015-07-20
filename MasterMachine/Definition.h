//#define TEST
#ifdef TEST
#   define DSLog(...) NSLog(__VA_ARGS__)
#else
#   define DSLog(...)
#endif

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif
