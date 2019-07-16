//
//  DRInputLimitManager.h
//  AFNetworking
//
//  Created by 冯生伟 on 2019/5/23.
//

#import <Foundation/Foundation.h>

@class DRInputLimitManager;
typedef void (^DRInputLimitBlock) (DRInputLimitManager *manager,
                                   UIView<UITextInput> *inputView,
                                   NSString *text,
                                   NSInteger limit,
                                   BOOL beyondLimit);

typedef NS_ENUM(NSInteger, DRInputCharTypes) {
    DRInputCharTypesSpace = 1 << 0,      // 空格回车等空白字符
    DRInputCharTypesNumber = 1 << 1,     // 数字
    DRInputCharTypesEnglish = 1 << 2,    // 英文字母
    DRInputCharTypesChinese = 1 << 3,    // 汉字
    DRInputCharTypesSymbol = 1 << 4,     // 特殊符号
};

@interface DRInputLimitManager : NSObject

#pragma mark - API 一下方式选其中一个调用，调用多个或多次时，以最后一次调用为准
/**
 添加输入框字数限制
 
 @param inputView 需要限制字数的输入框
 @param textDidChange 输入内容变更消息名称，如: UITextFieldTextDidChangeNotification
 @param limit 限制字数
 @param checkDoneBlock 每次监听到输入框变更，进行校验完成后调用
 */
+ (void)addTextLimitForInputView:(UIView<UITextInput> *)inputView
             textDidChangeNotice:(NSString *)textDidChange
                           limit:(NSInteger)limit
                  checkDoneBlock:(DRInputLimitBlock)checkDoneBlock;

/**
 添加输入框字数限制，并且禁止以空格、换行符开头
 
 @param inputView 需要限制字数的输入框
 @param textDidChange 输入内容变更消息名称，如: UITextFieldTextDidChangeNotification
 @param limit 限制字数
 @param checkDoneBlock 每次监听到输入框变更，进行校验完成后调用
 */
+ (void)addTextLimitForbidStartWithSpaceCharForInputView:(UIView<UITextInput> *)inputView
                                     textDidChangeNotice:(NSString *)textDidChange
                                                   limit:(NSInteger)limit
                                          checkDoneBlock:(DRInputLimitBlock)checkDoneBlock;

/**
 添加输入框字数限制，并且禁止输入空格、换行符
 
 @param inputView 需要限制字数的输入框
 @param textDidChange 输入内容变更消息名称，如: UITextFieldTextDidChangeNotification
 @param limit 限制字数
 @param checkDoneBlock 每次监听到输入框变更，进行完校验后调用
 */
+ (void)addTextLimitForbidSpaceCharForInputView:(UIView<UITextInput> *)inputView
                            textDidChangeNotice:(NSString *)textDidChange
                                          limit:(NSInteger)limit
                                 checkDoneBlock:(DRInputLimitBlock)checkDoneBlock;

/**
 添加输入框字数限制
 
 @param inputView 需要限制字数的输入框
 @param textDidChange 输入内容变更消息名称，如: UITextFieldTextDidChangeNotification
 @param limit 限制字数
 @param charTypes 允许输入的字符类型
 @param checkDoneBlock 每次监听到输入框变更，进行校验完成后调用
 */
+ (void)addTextLimitForInputView:(UIView<UITextInput> *)inputView
             textDidChangeNotice:(NSString *)textDidChange
                           limit:(NSInteger)limit
                allowedCharTypes:(DRInputCharTypes)charTypes
                  checkDoneBlock:(DRInputLimitBlock)checkDoneBlock;

/**
 如果输入框字符长度超过限制长度，则会调用该方法
 该方法为虚函数，在子类中实现
 用处：如做统一的toast提示文字超限，其他一些设置等

 @param limit 用户设置的文本最大长度
 */
- (void)whenTextBeyondLimit:(NSInteger)limit;

@end
