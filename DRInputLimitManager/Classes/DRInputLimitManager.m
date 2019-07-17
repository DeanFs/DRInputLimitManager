//
//  DRInputLimitManager.m
//  AFNetworking
//
//  Created by 冯生伟 on 2019/5/23.
//

#import "DRInputLimitManager.h"
#import <BlocksKit/BlocksKit.h>
#import <DRMacroDefines/DRMacroDefines.h>

#define kAssociatedKey @selector(addTextLimitForInputView:limit:textDidChangeNotice:)

@interface DRInputLimitManager ()

@property (nonatomic, weak) UIView<UITextInput> *inputView;
@property (nonatomic, copy) NSString *textDidChangeNoticeName;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) BOOL forbidSpaceChar;
@property (nonatomic, assign) BOOL forBidSpaceCharStart;
@property (nonatomic, assign) DRInputCharTypes charTypes;
@property (nonatomic, copy) DRInputLimitBlock checkDoneBlock;

// control params
@property (nonatomic, copy) NSString *baseText; // 当前处理的文本原始值
@property (nonatomic, copy) NSString *oldText;  // 保存输入框最新的变更
@property (nonatomic, copy) NSString *tempText; // 当前文本处理过程值
@property (nonatomic, assign) NSInteger location; // 光标位置
@property (nonatomic, assign) BOOL busy;
@property (nonatomic, assign) BOOL beyond;

@end

@implementation DRInputLimitManager

#pragma mark - API
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
                  checkDoneBlock:(DRInputLimitBlock)checkDoneBlock {
    [self addTextLimitForInputView:inputView
               textDidChangeNotice:textDidChange
                             limit:limit
                   forbidSpaceChar:NO
              forbidSpaceCharStart:NO
                    checkDoneBlock:checkDoneBlock];
}

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
                                          checkDoneBlock:(DRInputLimitBlock)checkDoneBlock {
    [self addTextLimitForInputView:inputView
               textDidChangeNotice:textDidChange
                             limit:limit
                   forbidSpaceChar:NO
              forbidSpaceCharStart:YES
                    checkDoneBlock:checkDoneBlock];
}

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
                                 checkDoneBlock:(DRInputLimitBlock)checkDoneBlock {
    [self addTextLimitForInputView:inputView
               textDidChangeNotice:textDidChange
                             limit:limit
                   forbidSpaceChar:YES
              forbidSpaceCharStart:NO
                    checkDoneBlock:checkDoneBlock];
}

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
                  checkDoneBlock:(DRInputLimitBlock)checkDoneBlock {
    DRInputLimitManager *manager = [self addTextLimitForInputView:inputView
                                              textDidChangeNotice:textDidChange
                                                            limit:limit
                                                  forbidSpaceChar:NO
                                             forbidSpaceCharStart:NO
                                                   checkDoneBlock:checkDoneBlock];
    manager.charTypes = charTypes;
}

/**
 添加输入框字数限制
 
 @param inputView 需要限制字数的输入框
 @param textDidChange 输入内容变更消息名称，如: UITextFieldTextDidChangeNotification
 @param limit 限制字数
 @param forbidSpaceChar YES:不允许输入空白字符(" ", "\n", "\r")
 @param forbidSpaceCharStart YES:不允许在第一个字符位置输入空白字符(" ", "\n", "\r")
 @param checkDoneBlock 每次监听到输入框变更，进行完校验后调用
 */
+ (instancetype)addTextLimitForInputView:(UIView<UITextInput> *)inputView
                     textDidChangeNotice:(NSString *)textDidChange
                                   limit:(NSInteger)limit
                         forbidSpaceChar:(BOOL)forbidSpaceChar
                    forbidSpaceCharStart:(BOOL)forbidSpaceCharStart
                          checkDoneBlock:(DRInputLimitBlock)checkDoneBlock {
    DRInputLimitManager *manager = [inputView bk_associatedValueForKey:_cmd];
    if (!manager) {
        manager = [[DRInputLimitManager alloc] initWithInputView:inputView
                                                      noticeName:textDidChange];
        [inputView bk_associateValue:manager withKey:_cmd];
    }
    manager.limit = limit;
    manager.forbidSpaceChar = forbidSpaceChar;
    manager.forBidSpaceCharStart = forbidSpaceCharStart;
    manager.checkDoneBlock = checkDoneBlock;
    return manager;
}

/**
 如果输入框字符长度超过限制长度，则会调用该方法
 该方法为虚函数，在子类中实现
 用处：如做统一的toast提示文字超限，其他一些设置等
 
 @param limit 用户设置的文本最大长度
 */
- (void)whenTextBeyondLimit:(NSInteger)limit {
    
}

#pragma mark - life cycle
- (instancetype)initWithInputView:(UIView<UITextInput> *)inputView noticeName:(NSString *)textDidChange {
    if (self = [super init]) {
        self.inputView = inputView;
        self.textDidChangeNoticeName = textDidChange;
        self.limit = -1;
        self.forbidSpaceChar = NO;
        self.busy = NO;
        self.charTypes = 0;
        
        kDR_ADD_OBSERVER_OBJ(textDidChange, @selector(onTextDidChange:), inputView)
    }
    return self;
}

- (void)dealloc {
    kDR_REMOVE_OBSERVER
}

#pragma mark - private
// 文本调整入口，监听到文本变更
- (void)onTextDidChange:(NSNotification *)notice {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isPreinput]) {
            return;
        }
        self.oldText = [self text];
        if (self.busy) {
            return;
        }
        self.busy = YES;
        self.location = [self getCurrentLocation];
        [self doCheckAction];
    });
}

- (void)doCheckAction {
    self.baseText = self.oldText;
    self.tempText = self.baseText;
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self check];
        });
    } else {
        [self check];
    }
}

// 开始检测修正文本
- (void)check {
    kDRWeakSelf
    if (self.tempText.length == 0) { // 文本为空
        dispatch_async(dispatch_get_main_queue(), ^{
            kDR_SAFE_BLOCK(self.checkDoneBlock, self, self.inputView, self.tempText, self.limit, NO);
            self.busy = NO;
        });
        return;
    }
    [self removeSpaceCharStart]; // 去除开头的空白字符
    [self removeSpaceChars];     // 去除所有空白字符
    [self checkAllowedCharTypes];// 仅留下允许输入的空格字符
    [self checkLimit];           // 做字符长度限制
    
    if (![self.oldText isEqualToString:self.baseText]) {
        // 在处理检测期间，输入框内容又有变更
        [self doCheckAction];
        return;
    }
    
    // 检测变更完成
    [self replaceTextComplete:^{
        weakSelf.busy = NO;
    }];
}

// 移除开头的空白字符
- (void)removeSpaceCharStart {
    if (self.forBidSpaceCharStart) {
        NSMutableString *text = [NSMutableString stringWithString:self.baseText];
        if (text.length > 0) {
            NSError *error;
            NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"^\\s+"
                                                                            options:0
                                                                              error:&error];
            if (!error) {
                NSRange spaceRange = [exp rangeOfFirstMatchInString:self.tempText options:0 range:NSMakeRange(0, self.tempText.length)];
                if (spaceRange.length == 0) {
                    return;
                }
                if (spaceRange.length > self.location) {
                    self.location = 0;
                } else {
                    self.location -= spaceRange.length;
                }
                [text replaceCharactersInRange:spaceRange withString:@""];
                self.tempText = text;
            }
        }
    }
}

// 移除所有空白字符
- (void)removeSpaceChars {
    if (self.forbidSpaceChar) {
        NSMutableString *text = [NSMutableString stringWithString:self.baseText];
        if (text.length > 0) {
            NSError *error;
            NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"\\s+"
                                                                            options:0
                                                                              error:&error];
            if (!error) {
                if ([exp rangeOfFirstMatchInString:self.tempText options:0 range:NSMakeRange(0, self.tempText.length)].length == 0) {
                    return;
                }
                NSString *subText = [self.tempText substringToIndex:self.location];
                if (subText.length > 0) {
                    NSString *newSubText = [exp stringByReplacingMatchesInString:subText options:0 range:NSMakeRange(0, subText.length) withTemplate:@""];
                    self.location -= (subText.length - newSubText.length);
                }
                
                [exp replaceMatchesInString:text
                                    options:0
                                      range:NSMakeRange(0, text.length)
                               withTemplate:@""];
                self.tempText = text;
            }
        }
    }
}

// 筛选满足要求的字符
- (void)checkAllowedCharTypes {
    if (self.charTypes > 0) {
        NSMutableString *rx = [NSMutableString string];
        if (self.charTypes & DRInputCharTypesSpace) {
            [rx appendString:@"\\s+|"];
        }
        if (self.charTypes & DRInputCharTypesNumber) {
            [rx appendString:@"\\d+|"];
        }
        if (self.charTypes & DRInputCharTypesEnglish) {
            [rx appendString:@"[a-zA-Z]+|"];
        }
        if (self.charTypes & DRInputCharTypesChinese) {
            [rx appendString:@"[^\\x00-\\xff]+|"];
        }
        if (self.charTypes & DRInputCharTypesSymbol) {
            [rx appendString:@"[^\\w\\s]+|"];
        }
        [rx replaceCharactersInRange:NSMakeRange(rx.length-1, 1) withString:@""]; // 去掉最后一个 |
        
        NSError *error;
        NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:rx
                                                                        options:0
                                                                          error:&error];
        if (!error) {
            NSMutableString *text = [NSMutableString string];
            NSArray *matchs = [exp matchesInString:self.tempText options:0 range:NSMakeRange(0, self.tempText.length)];
            for (NSTextCheckingResult *result in matchs) {
                [text appendString:[self.tempText substringWithRange:result.range]];
            }
            if (text.length != self.tempText.length) {
                self.location = text.length;
            }
            self.tempText = text;
        }
    }
}

// 字符长度限制
- (void)checkLimit {
    self.beyond = NO;
    if (self.limit >= 0) {
        if (self.tempText.length > 0) {
            NSMutableArray *wholeChars = [NSMutableArray array];
            NSRange range;
            NSInteger locationLength = 0;
            for (int i=0; i<self.tempText.length; i+=range.length){
                if (i == self.location) {
                    locationLength = wholeChars.count;
                }
                range = [self.tempText rangeOfComposedCharacterSequenceAtIndex:i];
                [wholeChars addObject:[self.tempText substringWithRange:range]];
            }
            NSInteger length = wholeChars.count;
            if (length > self.limit) {
                NSMutableString *text = [NSMutableString string];
                NSInteger beyond = length - self.limit;
                if (beyond > self.location || // 光标之前的文字还不够删
                    self.tempText.length == self.location) { // 光标在末端
                    for (NSInteger i=0; i<self.limit; i++) {
                        [text appendString:wholeChars[i]];
                    }
                    self.location = text.length;
                } else {
                    NSInteger prevCount = locationLength - beyond; // 光标前可留下的字符个数
                    for (NSInteger i=0; i<self.limit; i++) {
                        NSString *subText;
                        if (i < prevCount) {
                            subText = wholeChars[i];
                        } else if (i == prevCount) {
                            self.location = text.length;
                            subText = wholeChars[locationLength];
                        } else {
                            subText = wholeChars[locationLength + i - prevCount];
                        }
                        [text appendString:subText];
                    }
                }
                self.beyond = YES;
                self.tempText = text;
            }
        }
    }
}

- (void)replaceTextComplete:(dispatch_block_t)complete {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.tempText isEqualToString:self.oldText]) {
            // 处理结果与输入框内容无差异
            kDR_SAFE_BLOCK(self.checkDoneBlock, self, self.inputView, self.tempText, self.limit, self.beyond);
            kDR_SAFE_BLOCK(complete);
            return;
        }
        // 避免死循环，先移除监听
        kDR_REMOVE_OBSERVER_NOTICE_OBJ(self.textDidChangeNoticeName, self.inputView)
        [self.inputView replaceRange:[self wholeRange] withText:self.tempText];
        self.inputView.selectedTextRange = [self newSelectedRange];
        if ([self.inputView respondsToSelector:@selector(scrollRangeToVisible:)]) {
            [(UITextView *)self.inputView scrollRangeToVisible:NSMakeRange(self.location, 0)];
        }
        kDR_SAFE_BLOCK(self.checkDoneBlock, self, self.inputView, self.tempText, self.limit, self.beyond);
        if (self.beyond) {
            [self whenTextBeyondLimit:self.limit];
        }
        // 文本修改后，恢复监听
        kDR_ADD_OBSERVER_OBJ(self.textDidChangeNoticeName, @selector(onTextDidChange:), self.inputView)
        kDR_SAFE_BLOCK(complete);
    });
}

// 新的光标位置
- (UITextRange *)newSelectedRange {
    UITextPosition *beginning = self.inputView.beginningOfDocument;
    UITextPosition *start = [self.inputView positionFromPosition:beginning offset:self.location];
    UITextPosition *end = [self.inputView positionFromPosition:start offset:0];
    return [self.inputView textRangeFromPosition:start toPosition:end];
}

// 找到当前光标位置
- (NSInteger)getCurrentLocation {
    UITextPosition* beginning = self.inputView.beginningOfDocument;
    UITextRange* selectedRange = self.inputView.selectedTextRange;
    return [self.inputView offsetFromPosition:beginning toPosition:selectedRange.start];
}

- (BOOL)isPreinput {
    UITextRange *selectedRange = [self.inputView markedTextRange];
    UITextPosition *position = [self.inputView positionFromPosition:selectedRange.start
                                                             offset:0];
    if (position) {
        return YES;
    }
    return NO;
}

- (NSString *)text {
    return [self.inputView textInRange:[self wholeRange]];
}

- (UITextRange *)wholeRange {
    UITextPosition *begin = self.inputView.beginningOfDocument;
    UITextPosition *end = self.inputView.endOfDocument;
    return [self.inputView textRangeFromPosition:begin toPosition:end];
}

@end
