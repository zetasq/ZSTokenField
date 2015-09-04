//
//  ZSTextField.m
//  ZSTokenField
//
//  Created by Zhu Shengqi on 9/3/15.
//  Copyright (c) 2015 DSoftware. All rights reserved.
//

#import "ZSTextField.h"

@interface ZSTextField ()
{
    struct {
        unsigned int deleteBackward: 1;
    } _mDelegateFlags;
}

@end

@implementation ZSTextField

- (instancetype) init {
    if (self = [super init]) {
        //
    }
    return self;
}

- (void) setMDelegate:(id<ZSTextFieldDelegate>)mDelegate {
    _mDelegate = mDelegate;
    
    _mDelegateFlags.deleteBackward = [_mDelegate respondsToSelector:@selector(textField:didDeleteWithRemainingText:)];
}

- (void) deleteBackward {
    [super deleteBackward];
    
    if (_mDelegateFlags.deleteBackward) {
        [self.mDelegate textField:self didDeleteWithRemainingText:self.text];
    }
}
@end
