//
//  UILabel+WSScaleLabel.m
//  12306foriPhone
//
//  Created by WS on 2017/6/22.
//  Copyright © 2017年 WS. All rights reserved.
//

#import "UILabel+WSScaleLabel.h"
#import "_2306foriPhone-Swift.h"

@implementation UILabel (WSScaleLabel)

+ (void)load {
    
    Class cls = [self class];
    SEL originalSel = @selector(initWithCoder:);
    SEL swizzledSel = @selector(myInitWithCoder:);
    
    Method imp = class_getInstanceMethod(cls, @selector(initWithCoder:));
    Method myImp = class_getInstanceMethod(cls, @selector(myInitWithCoder:));
    
    BOOL isSuccess = class_addMethod(cls, originalSel, method_getImplementation(myImp), method_getTypeEncoding(myImp));
    if (isSuccess) {
        class_replaceMethod(cls, swizzledSel, method_getImplementation(imp), method_getTypeEncoding(imp));
    }else{
        method_exchangeImplementations(imp, myImp);
    }
}

- (instancetype)myInitWithCoder:(NSCoder *)aDecoder {
    [self myInitWithCoder:aDecoder];
    
    if (self) {
        CGFloat fontSize = self.font.pointSize;
        self.font = [UIFont systemFontOfSize:fontSize * WSConfig.SizeScale];
    }
    return self;
}
@end
