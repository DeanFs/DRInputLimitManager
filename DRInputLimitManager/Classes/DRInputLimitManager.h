//
//  DRInputLimitManager.h
//  AFNetworking
//
//  Created by 冯生伟 on 2019/5/23.
//

#import <Foundation/Foundation.h>

typedef void (^DRInputLimitBlock) (UIView<UITextInput> *inputView, NSString *text);

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
 @param beyondLimitBlock 当文字长度超过上限时调用该回调
 @param checkDoneBlock 每次监听到输入框变更，进行校验完成后调用
 */
+ (void)addTextLimitForInputView:(UIView<UITextInput> *)inputView
             textDidChangeNotice:(NSString *)textDidChange
                           limit:(NSInteger)limit
                beyondLimitBlock:(DRInputLimitBlock)beyondLimitBlock
                  checkDoneBlock:(DRInputLimitBlock)checkDoneBlock;

/**
 添加输入框字数限制，并且禁止以空格、换行符开头
 
 @param inputView 需要限制字数的输入框
 @param textDidChange 输入内容变更消息名称，如: UITextFieldTextDidChangeNotification
 @param limit 限制字数
 @param beyondLimitBlock 当文字长度超过上限时调用该回调
 @param checkDoneBlock 每次监听到输入框变更，进行校验完成后调用
 */
+ (void)addTextLimitForbidStartWithSpaceCharForInputView:(UIView<UITextInput> *)inputView
                                     textDidChangeNotice:(NSString *)textDidChange
                                                   limit:(NSInteger)limit
                                        beyondLimitBlock:(DRInputLimitBlock)beyondLimitBlock
                                          checkDoneBlock:(DRInputLimitBlock)checkDoneBlock;

/**
 添加输入框字数限制，并且禁止输入空格、换行符
 
 @param inputView 需要限制字数的输入框
 @param textDidChange 输入内容变更消息名称，如: UITextFieldTextDidChangeNotification
 @param limit 限制字数
 @param beyondLimitBlock 当文字长度超过上限时调用该回调
 @param checkDoneBlock 每次监听到输入框变更，进行完校验后调用
 */
+ (void)addTextLimitForbidSpaceCharForInputView:(UIView<UITextInput> *)inputView
                            textDidChangeNotice:(NSString *)textDidChange
                                          limit:(NSInteger)limit
                               beyondLimitBlock:(DRInputLimitBlock)beyondLimitBlock
                                 checkDoneBlock:(DRInputLimitBlock)checkDoneBlock;

/**
 添加输入框字数限制
 
 @param inputView 需要限制字数的输入框
 @param textDidChange 输入内容变更消息名称，如: UITextFieldTextDidChangeNotification
 @param limit 限制字数
 @param charTypes 允许输入的字符类型
 @param beyondLimitBlock 当文字长度超过上限时调用该回调
 @param checkDoneBlock 每次监听到输入框变更，进行校验完成后调用
 */
+ (void)addTextLimitForInputView:(UIView<UITextInput> *)inputView
             textDidChangeNotice:(NSString *)textDidChange
                           limit:(NSInteger)limit
                allowedCharTypes:(DRInputCharTypes)charTypes
                beyondLimitBlock:(DRInputLimitBlock)beyondLimitBlock
                  checkDoneBlock:(DRInputLimitBlock)checkDoneBlock;

@end
