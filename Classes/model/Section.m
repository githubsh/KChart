//
//  Section.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "Section.h"

@implementation Section

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
    self.isHidden        = NO;
    self.isInitialized   = NO;
    self.isPaging        = NO;
    self.selectedIndex   = 0;
    
    self.paddingLeft     = 60;
    self.paddingRight    = 0;
    self.paddingTop      = 20;
    self.paddingBottom   = 0;
    
    self.paddingArray    = nil;

    self.seriesArray     = [[NSMutableArray alloc] init];
    self.xAxisesArray    = [[NSMutableArray alloc] init];
    self.yAxisesArray    = [[NSMutableArray alloc] init];
}

//  增加一条Y轴 在某一个位置
- (void)addYAxis:(int)pos
{
    NSLog(@"pos=%zd",pos);//pos=0
    
    YAxis *yaxis = [[YAxis alloc]init];
	yaxis.pos = pos;
	[self.yAxisesArray addObject:yaxis];
}

////  移除一条Y轴
//- (void)removeYAxisAtIndex:(int)index  // not used
//{
//    [self.yAxisesArray removeObjectAtIndex:index];
//}
//
////  移除多条Y轴
//- (void)removeAllYAxises // not used
//{
//    [self.yAxisesArray removeAllObjects];
//}
//
////  增加多条Y轴
//- (void)addYAxisesCount:(int)count at:(int)pos // not used
//{
//
//}

//  初始化所有Y轴
- (void)initYAxises //切换指标的时候用到
{
    for(YAxis *yaxis in self.yAxisesArray) {
        yaxis.isUsed = NO;
	}
}

//  换页
- (void)nextPage //点击指标切换的时候调用
{
	if(self.selectedIndex < self.seriesArray.count - 1){
		self.selectedIndex++;
	} else {
		self.selectedIndex = 0;
	}

    NSLog(@"isHidden=%zd",self.isHidden);//0
    NSLog(@"isInitialized=%zd",self.isInitialized);//0
    NSLog(@"isPaging=%zd",self.isPaging);//1
    NSLog(@"selectedIndex=%zd",self.selectedIndex);//0 1 2 3
    
	[self initYAxises];
}

@end
