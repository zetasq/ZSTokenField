//
//  ZSTokenField.m
//  ZSTokenField
//
//  Created by Zhu Shengqi on 9/3/15.
//  Copyright (c) 2015 DSoftware. All rights reserved.
//

#import "ZSTokenField.h"
#import "ZSTextField.h"

@interface ZSTokenField () <UITextFieldDelegate, ZSTextFieldDelegate>
{
    struct {
        unsigned int didTextChangeInTextField: 1;
        unsigned int didUserPressedEnterInTextField: 1;
    } _delegateFlags;
}

@property (nonatomic, strong) ZSTextField *editingField;
@property (nonatomic, strong) NSMutableArray *tokenViews; // the last tokenView is editingField
@property (nonatomic, assign, getter=isEditingFieldAlreadyEmpty) BOOL alreadyEmpty;
@property (nonatomic, assign) CGSize newFrameSize;
@property (nonatomic, assign) BOOL firstLoad; // this flag is used to reload tokens in layoutsubviews only once

@end

@implementation ZSTokenField

- (instancetype) init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _firstLoad = YES;
        
        _lineSpace = 5;
        _tagHeight = 25;
        _tagSpace = 3;
        _tagMargin = 8;
        _horizontalPadding = 5;
        _verticalPadding = 5;
        
        _tagFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _tagTextColor = [UIColor colorWithRed:0.4 green:0.6 blue:1 alpha:1];

        _tagBackgroundColor = [UIColor colorWithRed:0.6 green:0.8 blue:1 alpha:1];
        _tagCornerRadius = 3.0;
        _tagBorderWidth = 1.0;
        _tagBorderColor = [UIColor colorWithRed:0.4 green:0.6 blue:1 alpha:1];
        
        _textFieldFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _textFieldTextColor = [UIColor darkGrayColor];
        _textFieldBackgroundColor = [UIColor whiteColor];
        _placeHolder = @"Enter key";
        
    }
    return self;
}

# pragma mark - Public Methods
- (void) getFocus {
    [self.editingField becomeFirstResponder];
}

- (void) reload {
    for (UIView *view in self.tokenViews) {
        [view removeFromSuperview];
    }
    self.editingField.text = @"";
    self.editingField.textAlignment = NSTextAlignmentLeft;
    self.alreadyEmpty = YES;
    self.tokenViews = [NSMutableArray array];
    
    NSInteger tokenCount = [self.datasource numberOfTokens];
    for (NSInteger i = 0; i < tokenCount; i++) {
        UILabel *tagView = [self createTagWithText:[self.datasource tokenField:self tokenForIndex:i]];
        
        [self.tokenViews addObject:tagView];
    }
    [self.tokenViews addObject:self.editingField];
    
    CGFloat x = _horizontalPadding, y = _verticalPadding, currentFrameHeight = 2 * _verticalPadding + _tagHeight;
    for (UIView *tokenView in self.tokenViews) {
        CGSize viewSize = [tokenView sizeThatFits:CGSizeMake(self.bounds.size.width - 2 * _horizontalPadding, _tagHeight)];
        if ([tokenView isKindOfClass:[UILabel class]]) {
            viewSize.width += _tagMargin;
        }
        viewSize.width = MIN(viewSize.width, self.bounds.size.width - 2 * _horizontalPadding);
        
        if ([self viewWidth:viewSize.width fitCurrentLineWithStartingPoint:CGPointMake(x, y)]) {
            tokenView.frame = CGRectMake(x, y, viewSize.width, _tagHeight);
            
            x += viewSize.width + _tagSpace;
        } else {
            x = _horizontalPadding;
            y += _tagHeight + _lineSpace;
            
            tokenView.frame = CGRectMake(x, y, viewSize.width, _tagHeight);
            
            x += viewSize.width + _tagSpace;
            currentFrameHeight += _tagHeight + _lineSpace;
        }
        [self addSubview:tokenView];
    }
    
    self.newFrameSize = CGSizeMake(self.bounds.size.width, currentFrameHeight);
    [self getFocus];
    [self invalidateIntrinsicContentSize];
}

# pragma mark - Getter & Setter
- (void) setDelegate:(id<ZSTokenFieldDelegate>)delegate {
    _delegate = delegate;
    
    _delegateFlags.didTextChangeInTextField = [delegate respondsToSelector:@selector(tokenField:didTextChangeInTextField:)];
    _delegateFlags.didUserPressedEnterInTextField = [delegate respondsToSelector:@selector(tokenField:didUserPressedEnterInTextField:)];
}

- (void) setDatasource:(id<ZSTokenFieldDatasource>)datasource {
    _datasource = datasource;
    
    NSAssert([datasource respondsToSelector:@selector(numberOfTokens)], @"ZFTokenField's datasource doesn't implement selector: numberOfTokens");
    NSAssert([datasource respondsToSelector:@selector(tokenField:tokenForIndex:)], @"ZFTokenField's datasource doesn't implement selector: tokenField:tokenForIndex:");
}

- (ZSTextField *) editingField {
    if (!_editingField) {
        _editingField = [ZSTextField new];
        
        _editingField.delegate = self;
        _editingField.mDelegate = self;
        [_editingField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        _editingField.font = _textFieldFont;
        _editingField.textColor = _textFieldTextColor;
        _editingField.backgroundColor = _textFieldBackgroundColor;
        _editingField.placeholder = _placeHolder;
    }
    return _editingField;
}

- (void) setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    self.editingField.placeholder = placeHolder;
}

# pragma mark - Layout Methods
- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (_firstLoad) {
        [self reload];
        _firstLoad = NO;
    }
}

- (CGSize) intrinsicContentSize {
    return self.newFrameSize;
}

- (BOOL) viewWidth:(CGFloat)viewWidth fitCurrentLineWithStartingPoint:(CGPoint)point {
    if (point.x + viewWidth <= self.bounds.size.width - _horizontalPadding) {
        return YES;
    } else {
        return NO;
    }
}



- (UILabel *) createTagWithText:(NSString *)text {
    UILabel *tagView = [UILabel new];
    tagView.textAlignment = NSTextAlignmentCenter;
    
    tagView.font = _tagFont;
    tagView.textColor = _tagTextColor;
    tagView.backgroundColor = _tagBackgroundColor;
    tagView.layer.cornerRadius = _tagCornerRadius;
    tagView.clipsToBounds = YES;
    tagView.layer.borderWidth = _tagBorderWidth;
    tagView.layer.borderColor = _tagBorderColor.CGColor;
    
    tagView.text = text;
    
    return tagView;
}

# pragma mark - Text Processing
- (void) processTextChangeInTextField:(ZSTextField *)textfield {
    if (!textfield.markedTextRange) { // Make sure the textfield is in commited stage
        if (_delegateFlags.didTextChangeInTextField) {
            [self.delegate tokenField:self didTextChangeInTextField:textfield];
        }
    }
}

# pragma mark - ZSTextField Event Handler

- (void) textFieldDidChange:(ZSTextField *)sender {
    BOOL frameChanged = NO;
    if (sender.text.length > 0) {
        self.alreadyEmpty = NO;
    }
    
    CGSize newSize = [sender sizeThatFits:CGSizeMake(self.bounds.size.width - 2 * _horizontalPadding, _tagHeight)];
    if (newSize.width < self.bounds.size.width - 2 * _horizontalPadding) {
        sender.textAlignment = NSTextAlignmentLeft;
    } else {
        sender.textAlignment = NSTextAlignmentRight;
    }
    
    newSize.width = MIN(newSize.width, self.bounds.size.width - 2 * _horizontalPadding);
    if (newSize.width < sender.frame.size.width) {
        NSUInteger tokenCount = _tokenViews.count;
        if (tokenCount > 1) {
            UIView *previousTokenView = _tokenViews[tokenCount - 2];
            CGRect previousTokenFrame = previousTokenView.frame;
            if (previousTokenFrame.origin.y < sender.frame.origin.y) {
                if (previousTokenFrame.origin.x + previousTokenFrame.size.width + _tagSpace + newSize.width <= self.bounds.size.width - _horizontalPadding) {
                    sender.frame = CGRectMake(previousTokenFrame.origin.x + previousTokenFrame.size.width + _tagSpace, previousTokenFrame.origin.y, newSize.width, _tagHeight);
                    frameChanged = YES;
                    
                    _newFrameSize.height -= _tagHeight + _lineSpace;
                    [self invalidateIntrinsicContentSize];
                }
            }
        }
    } else if (newSize.width > sender.frame.size.width && sender.frame.origin.x > _horizontalPadding) {
        if (sender.frame.origin.x + newSize.width > self.bounds.size.width - _horizontalPadding) {
            sender.frame = CGRectMake(_horizontalPadding, sender.frame.origin.y + _tagHeight + _lineSpace, newSize.width, _tagHeight);
            frameChanged = YES;
            
            _newFrameSize.height += _lineSpace + _tagHeight;
            [self invalidateIntrinsicContentSize];
        }
    }
    
    
    if (!frameChanged && newSize.width != sender.frame.size.width) {
        sender.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, newSize.width, _tagHeight);
        frameChanged = YES;
    }
    
    
    [self processTextChangeInTextField:sender];
}

# pragma mark - ZSTextField Delegate

- (void) textField:(ZSTextField *)textField didDeleteWithRemainingText:(NSString *)text {
    if (text.length == 0){
        if (self.isEditingFieldAlreadyEmpty) {
            NSUInteger tokenCount = self.tokenViews.count;
            if (tokenCount > 1) {
                [self.datasource tokenField:self removeTokenAtIndex:tokenCount - 2];
                [self reload];
            }
        } else {
            self.alreadyEmpty = YES;
        }
    }
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (_delegateFlags.didUserPressedEnterInTextField) {
        [self.delegate tokenField:self didUserPressedEnterInTextField:self.editingField];
    }
    return YES;
}


@end
