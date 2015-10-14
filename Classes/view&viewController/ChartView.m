//
//  Chart.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "ChartView.h"

#define MIN_INTERVAL  3

@implementation ChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initData];
        
        [self initModels];
    }
    return self;
}

- (void)initData
{
    self.isEnableSelection = YES;
    self.isInitialized   = NO;
    self.isSectionInitialized   = NO;
    self.selectedIndex   = -1;
    
    self.paddingArray         = nil;
    self.paddingTop      = 0;
    self.paddingRight    = 0;
    self.paddingBottom   = 0;
    self.paddingLeft     = 0;
    
    self.rangeFromInt       = 0;
    self.rangeToInt         = 0;
    self.rangeInt           = 120;
    
    self.touchFlag       = 0;
    self.touchFlagTwo    = 0;
    
    self.sectionsRatiosArray     = [[NSMutableArray alloc] init];
    self.sectionsArray   = [[NSMutableArray alloc] init];
    self.modelsDict      = [[NSMutableDictionary alloc] init];
}

//  初始化模板
- (void)initModels
{
    //candle
    ChartModel *model = [[CandleChartModel alloc] init];
    [self.modelsDict setObject:model forKey:@"candle"];
    
    //line
    model = [[LineChartModel alloc] init];
    [self.modelsDict setObject:model forKey:@"line"];
    
    //volume
    model = [[VolumeChartModel alloc] init];
    [self.modelsDict setObject:model forKey:@"volume"];
    
    //area
    model = [[AreaChartModel alloc] init];
    [self.modelsDict setObject:model forKey:@"area"];
    
    NSLog(@"self.modelsDict=%@",self.modelsDict);
    
    /*
     self.modelsDict={
         candle = "<CandleChartModel: 0x7b920cf0>";
         line = "<LineChartModel: 0x7b919900>";
         volume = "<VolumeChartModel: 0x7b923580>";
         area = "<AreaChartModel: 0x7b929eb0>";
     }
     */
}

- (ChartModel *)getModel:(NSString *)name //not used
{
    return self.modelsDict[name];
}

#pragma mark - getLocalY:withSection:withAxis:

- (float)getLocalY:(float)val withSection:(int)sectionIndex withAxis:(int)yAxisIndex
{
	Section *section = self.sectionsArray[sectionIndex];
	YAxis *yaxis = section.yAxisesArray[yAxisIndex];
    
	CGRect frame = section.frame;
	float  max = yaxis.max;
	float  min = yaxis.min;

    float minus=val-min;
    if (max == min) {
        return frame.size.height;
    }
    
    float ret = frame.size.height - (frame.size.height-section.paddingTop) * (minus)/(max-min)+frame.origin.y;
    if (ret == 0) {
        return 0;
    }
    
    return ret;
}

- (void)drawRect:(CGRect)rect
{
    [self initChart];
    [self initSections];
    [self initXAxis];
    [self initYAxis];
    
    [self drawXAxis];
    [self drawYAxis];
    [self drawChart];
}

#pragma mark - init
- (void)initChart
{
	if(!self.isInitialized){
		self.plotPadding = 1.f;
		if(self.paddingArray != nil)
        {
            //(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
			self.paddingTop  = [self.paddingArray[0] floatValue];
			self.paddingLeft = [self.paddingArray[1] floatValue];
			self.paddingBottom = [self.paddingArray[2] floatValue];
			self.paddingRight = [self.paddingArray[3] floatValue];
		}
		
		if(self.seriesArray!=nil){
			self.rangeToInt = [self.seriesArray[0][@"data"] count];
			if(self.rangeToInt-self.rangeInt >= 0){
				self.rangeFromInt = self.rangeToInt-self.rangeInt;
			}else{
			    self.rangeFromInt = 0;
			}
		}else{
			self.rangeToInt   = 0;
			self.rangeFromInt = 0;
		}
		self.selectedIndex = self.rangeToInt-1;
		self.isInitialized = YES;
	}

	if(self.seriesArray!=nil){
		self.plotCount = [[self seriesArray][0][@"data"] count];
	}
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0); 
    CGContextFillRect (context, CGRectMake (0, 0, self.bounds.size.width,self.bounds.size.height)); 
}

-(void)reset
{
	self.isInitialized = NO;
}

- (void)initXAxis
{

}

- (void)initYAxis
{
	for(int secIndex=0;secIndex<[self.sectionsArray count];secIndex++){
		Section *sec = self.sectionsArray[secIndex];
		for(int sIndex=0;sIndex<[sec.yAxisesArray count];sIndex++){
			YAxis *yaxis = sec.yAxisesArray[sIndex];
			yaxis.isUsed = NO;
		}
	}
	
	for(int secIndex=0;secIndex<[self.sectionsArray count];secIndex++){
		Section *sec = self.sectionsArray[secIndex];
		if(sec.isPaging){
			NSArray *serie = [sec seriesArray][sec.selectedIndex];
			if([serie isKindOfClass:[NSArray class]]){
				for(int i=0;i<[serie count];i++){
					[self setValuesForYAxis:serie[i]];
				}
			} else {
				[self setValuesForYAxis:serie];
			}
		}else{
			for(int sIndex=0;sIndex<[sec.seriesArray count];sIndex++){
				NSArray *serie = [sec seriesArray][sIndex];
				if([serie isKindOfClass:[NSArray class]]){
					for(int i=0;i<[serie count];i++){
						[self setValuesForYAxis:serie[i]];
					}
				}else {
					[self setValuesForYAxis:serie];
				}
			}
		}
		
		for(int i = 0;i<sec.yAxisesArray.count;i++){
			YAxis *yaxis = sec.yAxisesArray[i];
			yaxis.max += (yaxis.max-yaxis.min)*yaxis.extend;
			yaxis.min -= (yaxis.max-yaxis.min)*yaxis.extend;
			
			if(!yaxis.isBaseValueSticky){
				if(yaxis.max >= 0 && yaxis.min >= 0){
					yaxis.baseValue = yaxis.min;
				}else if(yaxis.max < 0 && yaxis.min < 0){
					yaxis.baseValue = yaxis.max;
				}else{
					yaxis.baseValue = 0;
				}
			}else{
				if(yaxis.baseValue < yaxis.min){
					yaxis.min = yaxis.baseValue;
				}
				
				if(yaxis.baseValue > yaxis.max){
					yaxis.max = yaxis.baseValue;
				}
			}
			
			if(yaxis.isSymmetrical == YES){
				if(yaxis.baseValue > yaxis.max){
					yaxis.max =  yaxis.baseValue + (yaxis.baseValue-yaxis.min);
				}else if(yaxis.baseValue < yaxis.min){
					yaxis.min =  yaxis.baseValue - (yaxis.max-yaxis.baseValue);
				}else {
					if((yaxis.max-yaxis.baseValue) > (yaxis.baseValue-yaxis.min)){
						yaxis.min =  yaxis.baseValue - (yaxis.max-yaxis.baseValue);
					}else{
						yaxis.max =  yaxis.baseValue + (yaxis.baseValue-yaxis.min);
					}
				}
			}	
		}
	}
}

-(void)setValuesForYAxis:(id)serie
{
    NSString   *type  = serie[@"type"];
    ChartModel *model = self.modelsDict[type];
    [model setValuesForYAxisInChartView:self withSerie:serie];
}

#pragma mark - drawChart
-(void)drawChart
{
    for(int secIndex=0;secIndex<self.sectionsArray.count;secIndex++){
		Section *sec = self.sectionsArray[secIndex];
		if(sec.isHidden){
		    continue;
		}
		self.plotWidth = (sec.frame.size.width-sec.paddingLeft)/(self.rangeToInt-self.rangeFromInt);
		for(int sIndex=0;sIndex<sec.seriesArray.count;sIndex++){
			NSArray *serie = sec.seriesArray[sIndex];
			
			if(sec.isHidden){
				continue;
			}
			
			if(sec.isPaging){
				if (sec.selectedIndex == sIndex) {
					if([serie isKindOfClass:[NSArray class]]){
						for(int i=0;i<[serie count];i++){
							[self drawSerie:serie[i]];
						}
					}else{
						[self drawSerie:serie];
					}
					break;
				}
			}else{
				if([serie isKindOfClass:[NSArray class]]){
					for(int i=0;i<[serie count];i++){
						[self drawSerie:serie[i]];
					}
				}else{
					[self drawSerie:serie];
				}
			}			
		}
	}	
	[self drawLabels];
}

-(void)drawLabels
{
	for(int i=0;i<self.sectionsArray.count;i++){
		Section *sec = self.sectionsArray[i];
		if(sec.isHidden){
		    continue;
		}
		
		float w = 0;
		for(int s=0;s<sec.seriesArray.count;s++){
			NSMutableArray *label =[[NSMutableArray alloc] init];
		    NSArray *serie = sec.seriesArray[s];
			
			if(sec.isPaging){
				if (sec.selectedIndex == s) {
					if([serie isKindOfClass:[NSArray class]]){
						for(int i=0;i<[serie count];i++){
							[self setLabel:label forSerie:serie[i]];
						}
					}else{
						[self setLabel:label forSerie:serie];
					}
				}
			}else{
				if([serie isKindOfClass:[NSArray class]]){
					for(int i=0;i<[serie count];i++){
						[self setLabel:label forSerie:serie[i]];
					}
				}else{
					[self setLabel:label forSerie:serie];
				}
			}	
			for(int j=0;j<label.count;j++){
				NSMutableDictionary *lbl = label[j];
				NSString *text  = lbl[@"text"];
				NSString *color = lbl[@"color"];
				NSArray *colors = [color componentsSeparatedByString:@","];
				CGContextRef context = UIGraphicsGetCurrentContext();
				CGContextSetShouldAntialias(context, YES);
				CGContextSetRGBFillColor(context, [colors[0] floatValue], [colors[1] floatValue], [colors[2] floatValue], 1.0);
				[text drawAtPoint:CGPointMake(sec.frame.origin.x+sec.paddingLeft+2+w,sec.frame.origin.y) withFont:[UIFont systemFontOfSize: 14]];
				w += [text sizeWithFont:[UIFont systemFontOfSize:14]].width;
			}
			
		}
	}
}

-(void)setLabel:(NSMutableArray *)label forSerie:(id) serie
{
	NSString   *type  = serie[@"type"];
    ChartModel *model = self.modelsDict[type];
    [model setLabelInChartView:self forLabel:label withSerie:serie];
}

-(void)drawSerie:(id)serie
{
    NSString   *type  = serie[@"type"];
    ChartModel *model = self.modelsDict[type];
    [model drawSerieInChartView:self withSerie:serie];
    
    NSEnumerator *enumerator = [self.modelsDict keyEnumerator];
    id key;  
    while ((key = [enumerator nextObject])){  
        ChartModel *m = self.modelsDict[key];
        [m drawTipsInChartView:self withSerie:serie];
    }
}

-(void)drawYAxis
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO );
	CGContextSetLineWidth(context, 1.0f);
	
	for(int secIndex=0;secIndex<[self.sectionsArray count];secIndex++){
		Section *sec = self.sectionsArray[secIndex];
		if(sec.isHidden){
			continue;
		}
		CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.origin.y+sec.paddingTop);
		CGContextAddLineToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.size.height+sec.frame.origin.y);
		CGContextMoveToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.origin.y+sec.paddingTop);
		CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.size.height+sec.frame.origin.y);
		CGContextStrokePath(context);
	}
	
	CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0);
	CGFloat dash[] = {5};
	CGContextSetLineDash (context,0,dash,1);  

	for(int secIndex=0;secIndex<self.sectionsArray.count;secIndex++){
		Section *sec = self.sectionsArray[secIndex];
		if(sec.isHidden){
			continue;
		}
		for(int aIndex=0;aIndex<sec.yAxisesArray.count;aIndex++){
			YAxis *yaxis = sec.yAxisesArray[aIndex];
			NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];
			
			float baseY = [self getLocalY:yaxis.baseValue withSection:secIndex withAxis:aIndex];
			CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
            CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,baseY);
            
            if(!isnan(baseY)){
                CGContextAddLineToPoint(context, sec.frame.origin.x+sec.paddingLeft-2, baseY);
            }
            CGContextStrokePath(context);
			
			[[@"" stringByAppendingFormat:format,yaxis.baseValue] drawAtPoint:CGPointMake(sec.frame.origin.x-1,baseY-7) withFont:[UIFont systemFontOfSize: 12]];
			
			CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
			CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,baseY);
			if(!isnan(baseY)){
                CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width,baseY);
            }
            
			if (yaxis.tickInterval%2 == 1) {
				yaxis.tickInterval +=1;
			}
			
			float step = (float)(yaxis.max-yaxis.min)/yaxis.tickInterval;
			for(int i=1; i<= yaxis.tickInterval+1;i++){
				if(yaxis.baseValue + i*step <= yaxis.max){
					float iy = [self getLocalY:(yaxis.baseValue + i*step) withSection:secIndex withAxis:aIndex];
					
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
					CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
					if(!isnan(iy)){
                        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft-2,iy);
					}
                    CGContextStrokePath(context);
					
					[[@"" stringByAppendingFormat:format,yaxis.baseValue+i*step] drawAtPoint:CGPointMake(sec.frame.origin.x-1,iy-7) withFont:[UIFont systemFontOfSize: 12]];
					
					if(yaxis.baseValue + i*step < yaxis.max){
						CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
						CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
						CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width,iy);
					}
					
					CGContextStrokePath(context);
				}
			}
			for(int i=1; i <= yaxis.tickInterval+1;i++){
				if(yaxis.baseValue - i*step >= yaxis.min){
					float iy = [self getLocalY:(yaxis.baseValue - i*step) withSection:secIndex withAxis:aIndex];
					
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
					CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
					if(!isnan(iy)){
                        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft-2,iy);
					}
                    CGContextStrokePath(context);
					
					[[@"" stringByAppendingFormat:format,yaxis.baseValue-i*step] drawAtPoint:CGPointMake(sec.frame.origin.x-1,iy-7) withFont:[UIFont systemFontOfSize: 12]];
					
					if(yaxis.baseValue - i*step > yaxis.min){
						CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
						CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
						CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width,iy);
					}
					
					CGContextStrokePath(context);
				}
			}
		}
	}	
	CGContextSetLineDash (context,0,NULL,0); 
}

-(void)drawXAxis
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO);
	CGContextSetLineWidth(context, 1.f);
	CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
	for(int secIndex=0;secIndex<self.sectionsArray.count;secIndex++){
		Section *sec = self.sectionsArray[secIndex];
		if(sec.isHidden){
			continue;
		}
		CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,sec.frame.size.height+sec.frame.origin.y);
		CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.size.height+sec.frame.origin.y);
		
		CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,sec.frame.origin.y+sec.paddingTop);
		CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.origin.y+sec.paddingTop);
	}
	CGContextStrokePath(context);
}

- (void)setSelectedIndexByPoint:(CGPoint) point
{
	if([self getIndexOfSection:point] == -1){
		return;
	}
	Section *sec = self.sectionsArray[[self getIndexOfSection:point]];
	
	for(int i=self.rangeFromInt;i<self.rangeToInt;i++){
		if((self.plotWidth*(i-self.rangeFromInt))<=(point.x-sec.paddingLeft-self.paddingLeft) &&
           (point.x-sec.paddingLeft-self.paddingLeft)<self.plotWidth*((i-self.rangeFromInt)+1))
        {
			if (self.selectedIndex != i) {
				self.selectedIndex = i;
				[self setNeedsDisplay];
			}
			
			return;
		}
	}
}



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



/*
 * Sections
 */
- (Section *)getSectionAtIndex:(int) index
{
    NSLog(@"getSection=%d",index);
    return self.sectionsArray[index];
}

- (int)getIndexOfSection:(CGPoint)point
{
    for(int i=0;i<self.sectionsArray.count;i++)
    {
	    Section *sec = self.sectionsArray[i];
        
        //bool CGRectContainsPoint(CGRect rect, CGPoint point)
		if (CGRectContainsPoint(sec.frame, point))
        {
            NSLog(@"getIndexOfSection=%d",i);
            
		    return i;
		}
	}
	return -1;//未获取到 section索引
}

#pragma mark - series

- (NSMutableDictionary *)getSerieFromName:(NSString *)name
{
	NSMutableDictionary *serie = nil;
    for(NSMutableDictionary *ser in self.seriesArray)
    {
		if([ser[@"name"] isEqualToString:name]){
			serie = ser;
			break;
		}
	}
	return serie;
}

- (void)addSerie:(id)serie
{
	if([serie isKindOfClass:[NSArray class]]) // rsi6 rsi12       // kdj_k kdj_d kdj_j
    {
		int section = 0;
	    for (NSDictionary *ser in serie) {
		    section = [ser[@"section"] intValue];
            //  总seriesArray 加入
			[self.seriesArray addObject:ser];
		}
        Section *sec = self.sectionsArray[section];
        //  单分区加入
        [sec.seriesArray addObject:serie];
	}
    else if ([serie isKindOfClass:[NSDictionary class]])// wr // vr
    {
		int section = [serie[@"section"] intValue];
        //  总seriesArray加入
		[self.seriesArray addObject:serie];
        
        Section *sec = self.sectionsArray[section];
        //  当分区加入
        [sec.seriesArray addObject:serie];
	}
}

#pragma mark - section

- (void)addSectionWithRatio:(NSString *)ratio
{
	Section *sec = [[Section alloc] init];
    [self.sectionsArray addObject:sec];
	
	[self.sectionsRatiosArray addObject:ratio];
}

- (void)removeSectionAtIndex:(int)index
{
    [self.sectionsArray removeObjectAtIndex:index];
	[self.sectionsRatiosArray removeObjectAtIndex:index];
}

//[self.chartView addSectionsCount:3 withRatios:rats]; /* rats=(4,1,1)//@"4",@"1",@"1" */

- (void)addSectionsCount:(int)num withRatios:(NSArray *)rats
{
	for (int i=0; i < num; i++)
    {
		Section *sec = [[Section alloc]init];
		[self.sectionsArray addObject:sec];
		[self.sectionsRatiosArray addObject:rats[i]];
	}
    
    NSLog(@"self.sectionsArray=%@",self.sectionsArray);
    NSLog(@"self.sectionsRatiosArray=%@",self.sectionsRatiosArray);
    /*
     self.sections=(
         "<Section: 0x79e687a0>",
         "<Section: 0x79e67b50>",
         "<Section: 0x79e679b0>"
     ),
     self.sectionsRatiosArray=(4,1,1)//@"4",@"1",@"1"
     */
}

- (void)removeSections
{
    [self.sectionsArray removeAllObjects];
	[self.sectionsRatiosArray removeAllObjects];
}

- (void)initSections
{
    float height = self.frame.size.height-(self.paddingTop+self.paddingBottom);
    float width  = self.frame.size.width-(self.paddingLeft+self.paddingRight);
    
    int total = 0;
    for (int i=0; i < self.sectionsRatiosArray.count; i++) {
        if([self.sectionsArray[i] isHidden]){
            continue;
        }
        int ratio = [self.sectionsRatiosArray[i] intValue];
        total+=ratio;
    }
    
    Section *prevSec = nil;
    for (int i=0; i < self.sectionsArray.count; i++) {
        Section *sec = self.sectionsArray[i];
        
        int ratio = [self.sectionsRatiosArray[i] intValue];
        
        if([sec isHidden]){
            continue;
        }
        float h = height * ratio / total;
        float w = width;
        
        if(i==0){
            sec.frame = CGRectMake(0+self.paddingLeft, 0+self.paddingTop, w,h);
        }else{
            if(i==([self.sectionsArray count]-1))
            {
                sec.frame = CGRectMake(0+self.paddingLeft,
                                       prevSec.frame.origin.y+prevSec.frame.size.height,
                                       w,
                                       self.paddingTop+height-(prevSec.frame.origin.y+prevSec.frame.size.height));
            }
            else
            {
                sec.frame = CGRectMake(0+self.paddingLeft,
                                       prevSec.frame.origin.y+prevSec.frame.size.height,
                                       w,
                                       h);
            }
        }
        prevSec = sec;
        
    }
    self.isSectionInitialized = YES;
}

#pragma mark - YAxis

-(YAxis *)getYAxisInSection:(int)section atIndex:(int)index
{
	Section *sec = self.sectionsArray[section];
	YAxis *yaxis = sec.yAxisesArray[index];
    return yaxis;
}

#pragma mark - touches event

/* 
 float absolute
 fabs 功能：求浮点数x的绝对值  说明：计算|x|, 当x不为负时返回 x，否则返回 -x
 */

//  手势开始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *ts = [touches allObjects];

	if (ts.count==1)//  单点触摸
    {
        self.touchFlag = 0;//float
        
		UITouch *touch = ts[0];
        CGPoint point = [touch locationInView:self];
		if(point.x < 40){
		    self.touchFlag = point.y;
		}
        
        NSLog(@"self.touchFlag=%f",self.touchFlag);
	}
    
    else if (ts.count==2)//  双点触摸
    {
        self.touchFlag = 0;     //float
        self.touchFlagTwo = 0;  //float
        
        CGPoint point0 = [ts[0] locationInView:self];
        CGPoint point1 = [ts[1] locationInView:self];
        
		self.touchFlag = point0.x;
		self.touchFlagTwo = point1.x;
        
        NSLog(@"self.touchFlag=%f",self.touchFlag);
        NSLog(@"self.touchFlagTwo=%f",self.touchFlagTwo);
	}
}

//  手势移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *ts = [touches allObjects];
    
    //  单点触摸
	if(ts.count==1)
    {
        CGPoint point = [ts[0] locationInView:self];
		
        int i = [self getIndexOfSection:point];
        
		if(i!=-1)
        {
			Section *sec = self.sectionsArray[i];
			if(point.x > sec.paddingLeft)
				[self setSelectedIndexByPoint:point];
			int interval = 5;
			if(point.x < sec.paddingLeft){
				if(fabs(point.y - self.touchFlag) >= MIN_INTERVAL){
					if(point.y - self.touchFlag > 0){
						if(self.plotCount > (self.rangeToInt-self.rangeFromInt)){
							if(self.rangeFromInt - interval >= 0){
								self.rangeFromInt -= interval;
								self.rangeToInt -= interval;
								if(self.selectedIndex >= self.rangeToInt){
									self.selectedIndex = self.rangeToInt-1;
								}
							} else {
								self.rangeFromInt = 0;
								self.rangeToInt -= self.rangeFromInt;
								if(self.selectedIndex >= self.rangeToInt){
									self.selectedIndex = self.rangeToInt-1;
								}
							}
							[self setNeedsDisplay];
						}
					}else{
						if(self.plotCount > (self.rangeToInt-self.rangeFromInt)){
							if(self.rangeToInt + interval <= self.plotCount){
								self.rangeFromInt += interval;
								self.rangeToInt += interval;
								if(self.selectedIndex < self.rangeFromInt){
									self.selectedIndex = self.rangeFromInt;
								}
							} else {
								self.rangeFromInt  += self.plotCount-self.rangeToInt;
								self.rangeToInt = self.plotCount;
								
								if(self.selectedIndex < self.rangeFromInt){
									self.selectedIndex = self.rangeFromInt;
								}
							}
							[self setNeedsDisplay];
						}
					}
					self.touchFlag = point.y;
				}
			}
		}
	}
    
    //  双点触摸
    else if (ts.count==2)
    {
        CGPoint point0 = [ts[0] locationInView:self];
        CGPoint point1 = [ts[1] locationInView:self];
        
		float currFlag = point0.x;
		float currFlagTwo = point1.x;
        
		if(self.touchFlag == 0){
		    self.touchFlag = currFlag;
			self.touchFlagTwo = currFlagTwo;
		} else {
			int interval = 5;
			
			if((currFlag - self.touchFlag) > 0 &&
               (currFlagTwo - self.touchFlagTwo) > 0)
            {
				if(self.plotCount > (self.rangeToInt-self.rangeFromInt)){
					if(self.rangeFromInt - interval >= 0){
						self.rangeFromInt -= interval;
						self.rangeToInt   -= interval;
						if(self.selectedIndex >= self.rangeToInt){
							self.selectedIndex = self.rangeToInt-1;
						}
					}else {
						self.rangeFromInt = 0;
						self.rangeToInt  -= self.rangeFromInt;
						if(self.selectedIndex >= self.rangeToInt){
							self.selectedIndex = self.rangeToInt-1;
						}
					}
					[self setNeedsDisplay];
				}
			}
            else if((currFlag - self.touchFlag) < 0 &&
                    (currFlagTwo - self.touchFlagTwo) < 0)
            {
				if(self.plotCount > (self.rangeToInt-self.rangeFromInt)){
					if(self.rangeToInt + interval <= self.plotCount){
						self.rangeFromInt += interval;
						self.rangeToInt += interval;
						if(self.selectedIndex < self.rangeFromInt){
							self.selectedIndex = self.rangeFromInt;
						}
					}else {
						self.rangeFromInt  += self.plotCount-self.rangeToInt;
						self.rangeToInt     = self.plotCount;
						
						if(self.selectedIndex < self.rangeFromInt){
							self.selectedIndex = self.rangeFromInt;
						}
					}
					[self setNeedsDisplay];
				}
			} else {
				if(fabs(fabs(currFlagTwo-currFlag)-fabs(self.touchFlagTwo-self.touchFlag)) >= MIN_INTERVAL)
                {
					if(fabs(currFlagTwo-currFlag)-fabsf(self.touchFlagTwo-self.touchFlag) > 0)
                    {
						if(self.plotCount>self.rangeToInt-self.rangeFromInt){
							if(self.rangeFromInt + interval < self.rangeToInt){
								self.rangeFromInt += interval;
							}
							if(self.rangeToInt - interval > self.rangeFromInt){
								self.rangeToInt -= interval;
							}
						}else{
							if(self.rangeToInt - interval > self.rangeFromInt){
								self.rangeToInt -= interval;
							}
						}
						[self setNeedsDisplay];
					}
                    else
                    {
						if(self.rangeFromInt - interval >= 0){
							self.rangeFromInt -= interval;
						}else{
							self.rangeFromInt = 0;
						}
						self.rangeToInt += interval;
						[self setNeedsDisplay];
					}
				}
			}
		}
		self.touchFlag = currFlag;
		self.touchFlagTwo = currFlagTwo;
	}
}

//  手势结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *ts = [touches allObjects];
	UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];
    
	if(ts.count == 1){
		int i = [self getIndexOfSection:point];
		if(i!=-1){
			Section *sec = self.sectionsArray[i];
			if(point.x > sec.paddingLeft){
				if(sec.isPaging){
					[sec nextPage];
					[self setNeedsDisplay];
				}else{
					[self setSelectedIndexByPoint:[touch locationInView:self]];
				}
			}
		}
	}
	self.touchFlag = 0;
}


@end
