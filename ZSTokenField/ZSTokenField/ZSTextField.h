//
//  ZSTextField.h
//  ZSTokenField
//
//  Created by Zhu Shengqi on 9/3/15.
//  Copyright (c) 2015 DSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSTextField;
@protocol ZSTextFieldDelegate <NSObject>

@required
- (void) textField:(ZSTextField *)textField didDeleteWithRemainingText:(NSString *)text;

@end

@interface ZSTextField : UITextField

@property (nonatomic, weak) id<ZSTextFieldDelegate> mDelegate;


- (instancetype) init NS_DESIGNATED_INITIALIZER;

@end
