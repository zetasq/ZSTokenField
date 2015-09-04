//
//  ViewController.m
//  ZSTokenField
//
//  Created by Zhu Shengqi on 9/3/15.
//  Copyright (c) 2015 DSoftware. All rights reserved.
//

#import "ViewController.h"
#import "Masonry/Masonry.h"
#import "ZSTokenField.h"

@interface ViewController () <ZSTokenFieldDelegate, ZSTokenFieldDatasource>

@property (nonatomic, strong) ZSTokenField *tokenField;
@property (nonatomic, strong) NSMutableArray *sourceArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeRight|UIRectEdgeBottom;
    
    self.sourceArray = [NSMutableArray arrayWithArray:@[@"廣式點心", @"麵点", @"中式糕点", @"西點", @"和菓子", @"韩果", @"琉球果子", @"餜子"]];
    
    self.tokenField = [ZSTokenField new];
    [self.view addSubview:self.tokenField];
    
    NSLog(@"%@", @(self.topLayoutGuide.length));
    [self.tokenField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tokenField.superview).with.offset(10);
        make.left.equalTo(_tokenField.superview).with.offset(10);
        make.right.equalTo(_tokenField.superview).with.offset(-10);
        make.height.mas_greaterThanOrEqualTo(@100);
    }];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tokenField.backgroundColor = [UIColor lightGrayColor];
    self.tokenField.delegate = self;
    self.tokenField.datasource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - ZSTokenField Delegate & Datasource

- (NSInteger) numberOfTokens {
    return self.sourceArray.count;
}

- (NSString *) tokenField:(ZSTokenField *)tokenField tokenForIndex:(NSInteger)index {
    return self.sourceArray[index];
}

- (void) tokenField:(ZSTokenField *)tokenField removeTokenAtIndex:(NSInteger)index {
    [self.sourceArray removeObjectAtIndex:index];
}


// use space to generate new tag
- (void) tokenField:(ZSTokenField *)tokenField didTextChangeInTextField:(UITextField *)textField {
    if (textField.text.length > 0) {
        if ([[textField.text substringWithRange:NSMakeRange(textField.text.length - 1, 1)] isEqualToString:@" "]) {
            NSString *trimmedString = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - 1)];
            if (trimmedString.length > 0) {
                [self.sourceArray addObject:trimmedString];
                [tokenField reload];
            } else {
                textField.text = trimmedString;
                NSLog(@"Cannot make tag with space only.");
            }
        }
    }
}

- (void) tokenField:(ZSTokenField *)tokenField didUserPressedEnterInTextField:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self.sourceArray addObject:textField.text];
        [tokenField reload];
    }
}

@end
