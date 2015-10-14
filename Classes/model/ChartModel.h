//
//  ChartModel.h
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 lwork.com All rights reserved.
//

@class ChartView;

@interface ChartModel:NSObject

// abstract methods for overriden by subclasses

- (void)drawSerieInChartView:(ChartView *)chartView
                  withSerie:(NSMutableDictionary *) serie;

- (void)setValuesForYAxisInChartView:(ChartView *)chartView
                          withSerie:(NSDictionary *) serie;

- (void)setLabelInChartView:(ChartView *)chartView
                  forLabel:(NSMutableArray *)label
                 withSerie:(NSMutableDictionary *) serie;

- (void)drawTipsInChartView:(ChartView *)chartView
                 withSerie:(NSMutableDictionary *) serie;

@end
