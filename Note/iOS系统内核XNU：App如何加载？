# iOS系统内核XNU：App如何加载

## iOS系统架构

iOS系统是基于ARM架构：

- 最上层是用户体验层，主要是提供用户界面。这一层包含了 SpringBoard、Spotlight、Accessibility。
- 第二层是应用框架层，是开发者会用到的。这一层包含了开发框架 Cocoa Touch。
- 第三层是核心框架层，是系统核心功能的框架层。这一层包含了各种图形和媒体核心框架、Metal 等。
- 第四层是 Darwin 层，是操作系统的核心，属于操作系统的内核态。这一层包含了系统内核 XNU、驱动等。