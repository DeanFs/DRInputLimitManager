//
//  DRMacroDefines.h
//  DRBasicKit
//
//  Created by 冯生伟 on 2019/3/18.
//

#ifndef DRMacroDefines_h
#define DRMacroDefines_h

#pragma mark - 值
#define kDRAnimationDuration            0.25
#define kDRWeakSelf                     __weak typeof(self) weakSelf = self;
#define kDRScreenWidth                  CGRectGetWidth([UIScreen mainScreen].bounds)
#define kDRScreenHeight                 CGRectGetHeight([UIScreen mainScreen].bounds)
#define kDRWindow                       [UIApplication sharedApplication].keyWindow
#define kDRBundleIdentifier             [[NSBundle mainBundle] bundleIdentifier]
#define KDR_CURRENT_BUNDLE              [NSBundle bundleForClass:[self class]]

#pragma mark - 方法
// log
#ifdef DEBUG // 开发
#define kDR_LOG(format, ...) \
    NSLog((@"\n[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d]\n" @"[输出:" format@"]"@"\n\n"), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else // 发布
#define kDR_LOG(...);
#endif

// 安全执行block
#define kDR_SAFE_BLOCK(block, ...) \
    if(block){block(__VA_ARGS__);}

// post 消息
#define kDR_POST_NOTIFICATION(name, obj) \
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];

// post 消息并传递userInfo
#define KDR_POST_NOTIFICATION_INFO(name, obj, userInfo) \
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj userInfo: userInfo];

// 监听消息
#define KDR_ADD_OBSERVER(nameValue, methodValue) \
    [[NSNotificationCenter defaultCenter] addObserver:self selector:methodValue name:nameValue object:nil];

// 监听指定对象的消息
#define kDR_ADD_OBSERVER_OBJ(nameValue, methodValue, obj) \
    [[NSNotificationCenter defaultCenter] addObserver:self selector:methodValue name:nameValue object:obj];

// 移除所有监听
#define kDR_REMOVE_OBSERVER \
    [[NSNotificationCenter defaultCenter] removeObserver:self];

// 移除指定消息的监听
#define kDR_REMOVE_OBSERVER_NOTICE(notice) \
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notice object:nil];

// 移除指定消息的监听
#define kDR_REMOVE_OBSERVER_NOTICE_OBJ(notice, obj) \
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notice object:obj];

// 加载xib
#define kDR_LOAD_XIB_NAMED(name) \
    [[KDR_CURRENT_BUNDLE loadNibNamed:name owner:self options:nil] lastObject];

// 加载Storyboard
#define kDR_LOAD_STORYBOARD_NAMED(name) \
    [[UIStoryboard storyboardWithName:name bundle:KDR_CURRENT_BUNDLE] instantiateInitialViewController];

#endif /* DRMacroDefines_h */
