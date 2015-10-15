//
//  ddd.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 lwork.com All rights reserved.
//

#import "BaseChartModel.h"

@implementation BaseChartModel

// abstract methods to overriden by subclasses

- (void)drawSerieInChartView:(ChartView *)chartView
                   withSerie:(NSMutableDictionary *) serie
{
    NSLog(@"%s",__func__);//no called
}

- (void)setValuesForYAxisInChartView:(ChartView *)chartView
                           withSerie:(NSDictionary *) serie;
{
    NSLog(@"%s",__func__);//no called
}

- (void)setLabelInChartView:(ChartView *)chartView
                   forLabel:(NSMutableArray *)label
                  withSerie:(NSMutableDictionary *) serie
{
    NSLog(@"%s",__func__);//no called
}

- (void)drawTipsInChartView:(ChartView *)chartView
                  withSerie:(NSMutableDictionary *)serie;
{
    //NSLog(@"%s",__func__);//called
}

@end
