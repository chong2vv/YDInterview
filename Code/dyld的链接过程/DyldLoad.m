-(void)mwviewDidLoad{
    //打开动态库
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Kidswaste-Sans Toi" ofType:@"mp3"];
    // 加载库到当前运行程序
    void *lib = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_LAZY);
    if (lib) {
        // 获取类名称
        Class playerClass = NSClassFromString(@"AVAudioPlayer");
        // 获取函数方法
        SEL selector = NSSelectorFromString(@"initWithData:error:");
        // 调用实例化对象方法
        _runtime_Player = [[playerClass alloc] performSelector:selector withObject:[NSData dataWithContentsOfFile:path] withObject:nil];
        // 获取函数方法
        selector = NSSelectorFromString(@"play");
        // 调用播放方法
        [_runtime_Player performSelector:selector];
        NSLog(@"动态加载播放");
    }
    dlclose(lib);
    NSLog(@"hello world from mwviewDidLoad");
    [self mwviewDidLoad];
    
}
