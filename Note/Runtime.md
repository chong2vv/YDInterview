## Runtime消息传递
实例方法调用[obj foo]，编译器转成消息发送objc_mesgSend(obj, foo)，Runtime时如下执行：

- obj的isa指针查找它的class；
- 在class的method_list找foo；
- 如果class中没有foo则继续去它的superclass中找；
- 如果找到foo则执行它实现的IMP

同时，为了增加它的查找效率，objc_class有一个重要成员objc_cache，顾名思义，就是缓存，在找到foo之后把foo的method_name作为key，method_imp作为value缓存起来。当再次收到foo的消息时，会先从cache中查找。

objec_msgSend方法定义如下：

```
OBJC_EXPORT id objc_msgSend(id self, SEL op, ...)
```
对象、类、方法结构体如下：

```
//对象
struct objc_object {
    Class isa  OBJC_ISA_AVAILABILITY;
};
//类
struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;
#if !__OBJC2__
    Class super_class                                        OBJC2_UNAVAILABLE;
    const char *name                                         OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;
    struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache *cache                                 OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
#endif
} OBJC2_UNAVAILABLE;
//方法列表
struct objc_method_list {
    struct objc_method_list *obsolete                        OBJC2_UNAVAILABLE;
    int method_count                                         OBJC2_UNAVAILABLE;
#ifdef __LP64__
    int space                                                OBJC2_UNAVAILABLE;
#endif
    /* variable length structure */
    struct objc_method method_list[1]                        OBJC2_UNAVAILABLE;
}                                                            OBJC2_UNAVAILABLE;
//方法
struct objc_method {
    SEL method_name                                          OBJC2_UNAVAILABLE;
    char *method_types                                       OBJC2_UNAVAILABLE;
    IMP method_imp                                           OBJC2_UNAVAILABLE;
}
```
