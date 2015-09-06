//
//  ZSTokenField.h
//  ZSTokenField
//
//  Created by Zhu Shengqi on 9/3/15.
//  Copyright (c) 2015 DSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSTokenField;
@protocol ZSTokenFieldDelegate <NSObject>


@optional
- (void) tokenField:(ZSTokenField *)tokenField didTextChangeInTextField:(UITextField *)textField;
- (void) tokenField:(ZSTokenField *)tokenField didUserPressedEnterInTextField:(UITextField *)textField;

@end

@protocol ZSTokenFieldDatasource <NSObject>

@required
- (NSInteger) numberOfTokens;
- (NSString *) tokenField:(ZSTokenField *)tokenField tokenForIndex:(NSInteger)index;
- (void) tokenField:(ZSTokenField *)tokenField removeTokenAtIndex:(NSInteger)index;

@end

@interface ZSTokenField : UIView

@property (nonatomic, weak) id<ZSTokenFieldDelegate> delegate;
@property (nonatomic, weak) id<ZSTokenFieldDatasource> datasource;

#pragma mark - Space Parameters
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, assign) CGFloat tagHeight;
@property (nonatomic, assign) CGFloat tagMargin;
@property (nonatomic, assign) CGFloat tagSpace;
@property (nonatomic, assign) CGFloat horizontalPadding;
@property (nonatomic, assign) CGFloat verticalPadding;

#pragma mark - UI Parameters
@property (nonatomic, strong) UIFont *tagFont;
@property (nonatomic, strong) UIColor *tagTextColor;
@property (nonatomic, strong) UIColor *tagBackgroundColor;
@property (nonatomic, assign) CGFloat tagCornerRadius;
@property (nonatomic, assign) CGFloat tagBorderWidth;
@property (nonatomic, strong) UIColor *tagBorderColor;

@property (nonatomic, strong) UIFont *textFieldFont;
@property (nonatomic, strong) UIColor *textFieldTextColor;
@property (nonatomic, strong) UIColor *textFieldBackgroundColor;
@property (nonatomic, strong) NSString *placeHolder;



- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (void) getFocus;
- (void) reload;

@end
