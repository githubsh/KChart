//
//  Section.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.

//  图像分组 总共是3个分区
//  从上到下 分别是0 K线、1 成交量、2 指标线

#import "YAxis.h"

@interface Section : NSObject

@property (nonatomic) CGRect frame;          //边界

@property (nonatomic) bool   isHidden;       //是否隐藏
@property (nonatomic) bool   isInitialized;  //是否初始化
@property (nonatomic) bool   isPaging;       //是否分页 指标区域 点击换页

@property (nonatomic) int    selectedIndex;  //当前选中的指标索引
//RSI 0 KDJ 1 WR 2 VR 3

@property (nonatomic) float  paddingLeft;    //左边填充
@property (nonatomic) float  paddingRight;   //右边填充
@property (nonatomic) float  paddingTop;     //顶部填充
@property (nonatomic) float  paddingBottom;  //底部填充

@property (nonatomic,strong) NSMutableArray *paddingArray; //填充
@property (nonatomic,strong) NSMutableArray *seriesArray;  //序列
@property (nonatomic,strong) NSMutableArray *xAxisesArray; //x轴
@property (nonatomic,strong) NSMutableArray *yAxisesArray; //y轴

//  methods

-(void)addYAxis:(int)pos;
//-(void)removeYAxisAtIndex:(int)index;

//-(void)addYAxisesCount:(int)count at:(int)pos;
//-(void)removeAllYAxises;

-(void)initYAxises;
-(void)nextPage;

@end
