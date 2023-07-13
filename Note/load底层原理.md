## load底层原理
### load的调用规则
1. 类的load方法在所有父类的load方法调用之后调用
2. 分类的load方法在当前类的load方法调用之后调用
3. 分类的load方法的调用顺序和编译顺序有关
 
首先看一下 **_objc_init** 函数：

```
void _objc_init(void)
{
    static bool initialized = false;
    if (initialized) return;
    initialized = true;
    
    // fixme defer initialization until an objc-using image is found?
    environ_init();
    tls_init();
    static_init();
    lock_init();
    exception_init();

    _dyld_objc_notify_register(&map_images, load_images, unmap_image);
}
```
其中我们知道 **load_images** 是dyld初始化加载image方法，那么继续来看这个方法

```
void
load_images(const char *path __unused, const struct mach_header *mh)
{
    // Return without taking locks if there are no +load methods here.
    if (!hasLoadMethods((const headerType *)mh)) return;

    recursive_mutex_locker_t lock(loadMethodLock);

    // Discover load methods
    {
        mutex_locker_t lock2(runtimeLock);
        /** 准备
         
         */
        prepare_load_methods((const headerType *)mh);
    }

    // Call +load methods (without runtimeLock - re-entrant)
    call_load_methods();
}

```
在此，可以看到load方法，同时我们可以看到两个方法： **prepare_load_methods**以及 **call_load_methods**。首先，我们先来看一下 **prepare_load_methods**方法


```
void prepare_load_methods(const headerType *mhdr)
{
    size_t count, i;

    runtimeLock.assertLocked();

    //从 Macho 文件加载类的列表
    classref_t *classlist = 
        _getObjc2NonlazyClassList(mhdr, &count);
    for (i = 0; i < count; i++) {
        //数组：[<cls,method>,<cls,method>,<cls,method>] 有顺序
        schedule_class_load(remapClass(classlist[i]));
    }

    //针对分类的操作！
    category_t **categorylist = _getObjc2NonlazyCategoryList(mhdr, &count);
    for (i = 0; i < count; i++) {
        category_t *cat = categorylist[i];
        Class cls = remapClass(cat->cls);
        if (!cls) continue;  // category for ignored weak-linked class
        realizeClass(cls);
        assert(cls->ISA()->isRealized());
        add_category_to_loadable_list(cat);
    }
}

```
- **getObjc2NonlazyClassList**从Mach-O文件里获取了非懒加载的类列表，然后循环类列表，调用了一个递归方法**schedule_class_load**
- **schedule_class_load**是递归调用父类，一直往上找父类并调用，也就是说类的load方法在父类的load方法调用之后调用。


