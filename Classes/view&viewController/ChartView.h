//
//  Chart.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "YAxis.h"
#import "Section.h"

#import "ChartModel.h"
#import "AreaChartModel.h"
#import "CandleChartModel.h"
#import "VolumeChartModel.h"
#import "LineChartModel.h"

@class ChartModel;

@interface ChartView : UIView

@property (nonatomic)        bool  isEnableSelection;
@property (nonatomic)        bool  isInitialized;
@property (nonatomic)        bool  isSectionInitialized;

@property (nonatomic)        float borderWidth;
@property (nonatomic)        float plotWidth;
@property (nonatomic)        float plotPadding;
@property (nonatomic)        float plotCount;

@property (nonatomic)        float paddingTop;
@property (nonatomic)        float paddingLeft;
@property (nonatomic)        float paddingBottom;
@property (nonatomic)        float paddingRight;

@property (nonatomic)        int   rangeFromInt;
@property (nonatomic)        int   rangeToInt;
@property (nonatomic)        int   rangeInt;

@property (nonatomic)        int   selectedIndex;

@property (nonatomic)        float touchFlag;
@property (nonatomic)        float touchFlagTwo;

@property (nonatomic,strong) NSMutableArray *paddingArray;
@property (nonatomic,strong) NSMutableArray *seriesArray;
@property (nonatomic,strong) NSMutableArray *sectionsArray;
@property (nonatomic,strong) NSMutableArray *sectionsRatiosArray;

@property (nonatomic,strong) NSMutableDictionary *modelsDict;

@property (nonatomic,strong) UIColor *borderColor;

@property (nonatomic,strong) NSString *titleString;


-(float)getLocalY:(float)val withSection:(int)sectionIndex withAxis:(int)yAxisIndex;
-(void)setSelectedIndexByPoint:(CGPoint) point;
-(void)reset;

/* init */
-(void)initChart;
-(void)initXAxis;
-(void)initYAxis;
-(void)initModels;

/* draw */
-(void)drawChart;
-(void)drawXAxis;
-(void)drawYAxis;
-(void)drawSerie:(id)serie;
-(void)drawLabels;
-(void)setLabel:(NSMutableArray *)label forSerie:(id) serie;

/* data */
//-(void)appendToData:(NSArray *)data forName:(NSString *)name;
//-(void)clearDataforName:(NSString *)name;
//-(void)clearData;
//-(void)setData:(NSMutableArray *)data forName:(NSString *)name;

/* category */
//-(void)appendToCategory:(NSArray *)category forName:(NSString *)name;
//-(void)clearCategoryforName:(NSString *)name;
//-(void)clearCategory;
//-(void)setCategory:(NSMutableArray *)category forName:(NSString *)name;

/* series */
-(NSMutableDictionary *)getSerieFromName:(NSString *)name;
-(void)addSerie:(NSObject *)serie;

/* section */
-(Section *)getSectionAtIndex:(int)index;
-(int)getIndexOfSection:(CGPoint) point;
-(void)addSectionWithRatio:(NSString *)ratio;
-(void)removeSectionAtIndex:(int)index;
-(void)addSectionsCount:(int)num withRatios:(NSArray *)rats;
-(void)removeSections;
-(void)initSections;

/* YAxis */
-(YAxis *)getYAxisInSection:(int)section atIndex:(int) index;
-(void)setValuesForYAxis:(id)serie;

@end
