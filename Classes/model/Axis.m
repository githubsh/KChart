//
//  YAxis.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "Axis.h"

@implementation XAxis

- (id)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

//  初始化
- (void)initData
{
    self.isUsed = NO;
    self.min = MAXFLOAT;
    self.max = MAXFLOAT;
    self.extend = 0;
    self.baseValue = 0;
    self.isBaseValueSticky = NO;
    self.isSymmetrical = NO;
    self.paddingTop = 15;
    self.tickInterval = 6;
    self.pos = 0;
    self.decimal = 2;
}

@end

@implementation YAxis

- (id)init
{
	self = [super init];
    if (self) {
		[self initData];
    }
	return self;
}

//  初始化
- (void)initData
{
	self.isUsed = NO;
	self.min = MAXFLOAT;
	self.max = MAXFLOAT;
	self.extend = 0;
	self.baseValue = 0;
    self.isBaseValueSticky = NO;
	self.isSymmetrical = NO;
	self.paddingTop = 15;
	self.tickInterval = 6;
	self.pos = 0;
	self.decimal = 2;
}

@end
