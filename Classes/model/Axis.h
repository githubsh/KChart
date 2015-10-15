//
//  YAxis.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XAxis : NSObject

//  -------------------------------------

@property(nonatomic) CGRect frame;              //边界

@property(nonatomic) bool   isUsed;             //是否被使用
@property(nonatomic) bool   isBaseValueSticky;  //基值固定
@property(nonatomic) bool   isSymmetrical;      //对称的,匀称的

@property(nonatomic) float  max;                //最大
@property(nonatomic) float  min;                //最小
@property(nonatomic) float  extend;             //放大倍数
@property(nonatomic) float  baseValue;          //基值
@property(nonatomic) float  paddingTop;         //顶部填充

@property(nonatomic) int    tickInterval;       //tick间隔
@property(nonatomic) int    pos;                //位置
@property(nonatomic) int    decimal;            //小数

@end



@interface YAxis : NSObject

//  -------------------------------------

@property(nonatomic) CGRect frame;              //边界

@property(nonatomic) bool   isUsed;             //是否被使用
@property(nonatomic) bool   isBaseValueSticky;  //基值固定
@property(nonatomic) bool   isSymmetrical;      //对称的,匀称的

@property(nonatomic) float  max;                //最大
@property(nonatomic) float  min;                //最小
@property(nonatomic) float  extend;             //放大倍数
@property(nonatomic) float  baseValue;          //基值
@property(nonatomic) float  paddingTop;         //顶部填充

@property(nonatomic) int    tickInterval;       //tick间隔
@property(nonatomic) int    pos;                //位置
@property(nonatomic) int    decimal;            //小数


@end
