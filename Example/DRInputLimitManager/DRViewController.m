//
//  DRViewController.m
//  DRInputLimitManager
//
//  Created by Dean_F on 07/14/2019.
//  Copyright (c) 2019 Dean_F. All rights reserved.
//

#import "DRViewController.h"
#import <DRInputLimitManager/DRInputLimitManager.h>
#import <DRMacroDefines/DRMacroDefines.h>
#import <DRCategories/NSString+DRExtension.h>
#import <DRToastView/DRToastView.h>

@interface DRViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@end

@implementation DRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    kDRWeakSelf
    [DRInputLimitManager addTextLimitForbidStartWithSpaceCharForInputView:self.textField
                                                      textDidChangeNotice:UITextFieldTextDidChangeNotification
                                                                    limit:10
                                                           checkDoneBlock:^(DRInputLimitManager *manager, UIView<UITextInput> *inputView, NSString *text, NSInteger limit, BOOL beyondLimit) {
                                                               if (beyondLimit) {
                                                                   [weakSelf showToastView:10];
                                                               }
                                                           }];
    [DRInputLimitManager addTextLimitForbidStartWithSpaceCharForInputView:self.textView
                                                      textDidChangeNotice:UITextViewTextDidChangeNotification
                                                                    limit:40
                                                           checkDoneBlock:^(DRInputLimitManager *manager, UIView<UITextInput> *inputView, NSString *text, NSInteger limit, BOOL beyondLimit) {
                                                               if (beyondLimit) {
                                                                   [weakSelf showToastView:40];
                                                               }
                                                           }];
    [DRInputLimitManager addTextLimitForInputView:self.phoneTextField
                              textDidChangeNotice:UITextFieldTextDidChangeNotification
                                            limit:13
                                 allowedCharTypes:DRInputCharTypesSpace | DRInputCharTypesNumber
                                   checkDoneBlock:^(DRInputLimitManager *manager, UIView<UITextInput> *inputView, NSString *text, NSInteger limit, BOOL beyondLimit) {
                                       ((UITextField *)inputView).text = [text phoneFormat];
                                       if (beyondLimit) {
                                           [weakSelf showToastView:11];
                                       }
                                   }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showToastView:(NSInteger)limit {
    [DRToastView showWithMessage:[NSString stringWithFormat:@"超出%ld字限制", limit]
                        upOffset:100
                        complete:nil];
}

@end
