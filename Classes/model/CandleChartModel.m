//
//  CandleChartModel.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 lwork.com All rights reserved.
//

#import "CandleChartModel.h"
#import "YAxis.h"
#import "ChartView.h"

@implementation CandleChartModel

-(void)drawSerieInChartView:(ChartView *)chartView
                  withSerie:(NSMutableDictionary *)serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"chartView=%@",chartView);
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "249,222,170";
         data =     (
         );
         label = Price;
         labelColor = "176,52,52";
         labelNegativeColor = "77,143,42";
         name = price;
         negativeColor = "249,222,170";
         negativeSelectedColor = "249,222,170";
         section = 0;
         selectedColor = "249,222,170";
         type = candle;
         yAxis = 0;
     }
     */
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, NO);//Antialias 平滑
    CGContextSetLineWidth(context, 1.0f);
    
    NSMutableArray *data          = serie[@"data"];
    int            yAxis          = [serie[@"yAxis"] intValue];
    int            section        = [serie[@"section"] intValue];
    
    //  重置一些颜色
    serie[@"color"] = @"176,52,52";
    serie[@"negativeColor"] = @"77,143,42";
    serie[@"selectedColor"] = @"176,52,52";
    serie[@"negativeSelectedColor"] = @"77,143,42";
    
    //  获取颜色字符串
    NSString       *color         = serie[@"color"];
    NSString       *negativeColor = serie[@"negativeColor"];
    NSString       *selectedColor = serie[@"selectedColor"];
    NSString       *negativeSelectedColor = serie[@"negativeSelectedColor"];
    
    //  按照,切割成字符串数组
    NSArray *colorArray = [color componentsSeparatedByString:@","];
    NSArray *negativeColorArray = [negativeColor componentsSeparatedByString:@","];
    NSArray *selectedColorArray = [selectedColor componentsSeparatedByString:@","];
    NSArray *negativeSelectedColorArray = [negativeSelectedColor componentsSeparatedByString:@","];
    
    //  获取浮点值，转化为颜色0-1浮点值
    float R   = [colorArray[0] floatValue]/255;
    float G   = [colorArray[1] floatValue]/255;
    float B   = [colorArray[2] floatValue]/255;
    
    float NR  = [negativeColorArray[0] floatValue]/255;
    float NG  = [negativeColorArray[1] floatValue]/255;
    float NB  = [negativeColorArray[2] floatValue]/255;
    
    float SR  = [selectedColorArray[0] floatValue]/255;
    float SG  = [selectedColorArray[1] floatValue]/255;
    float SB  = [selectedColorArray[2] floatValue]/255;
    
    float NSR = [negativeSelectedColorArray[0] floatValue]/255;
    float NSG = [negativeSelectedColorArray[1] floatValue]/255;
    float NSB = [negativeSelectedColorArray[2] floatValue]/255;
    
    //  获取分区
    Section *sec = chartView.sectionsArray[section];
    
    //  打印栈
    /*
    NSLog(@"chartView.rangeFromInt=%d",chartView.rangeFromInt);//chartView.rangeFromInt=3061
    NSLog(@"chartView.rangeToInt=%d",chartView.rangeToInt);//chartView.rangeToInt=3181
    NSLog(@"chartView.rangeInt=%d",chartView.rangeInt);//chartView.rangeInt=120
    NSLog(@"chartView.selectedIndex=%d",chartView.selectedIndex);//chartView.selectedIndex=-1
    NSLog(@"chartView.touchFlag=%f",chartView.touchFlag);//chartView.touchFlag=0
    NSLog(@"chartView.touchFlagTwo=%f",chartView.touchFlagTwo);//chartView.touchFlagTwo=0
    
    NSLog(@"chartView.paddingTop=%f",chartView.paddingTop);//chartView.paddingTop=20.000000
    NSLog(@"chartView.paddingLeft=%f",chartView.paddingLeft);//chartView.paddingLeft=5.000000
    NSLog(@"chartView.paddingBottom=%f",chartView.paddingBottom);//chartView.paddingBottom=20.000000
    NSLog(@"chartView.paddingRight=%f",chartView.paddingRight);//chartView.paddingRight=5.000000
    
    NSLog(@"chartView.borderWidth=%f",chartView.borderWidth);//chartView.borderWidth=0.000000
    NSLog(@"chartView.plotWidth=%f",chartView.plotWidth);//chartView.plotWidth=inf
    NSLog(@"chartView.plotPadding=%f",chartView.plotPadding);//chartView.plotPadding=1.000000
    NSLog(@"chartView.plotCount=%f",chartView.plotCount);//chartView.plotCount=0.000000
    
    NSLog(@"chartView.paddingArray=%@",chartView.paddingArray);//chartView.paddingArray=(20,5,20,5)
    NSLog(@"chartView.seriesArray=%@",chartView.seriesArray);//
    NSLog(@"chartView.sectionsArray=%@",chartView.sectionsArray);//chartView.sectionsArray=("<Section: 0x787648d0>","<Section: 0x78941df0>","<Section: 0x78941f90>")
    NSLog(@"chartView.ratiosArray=%@",chartView.ratiosArray);//chartView.ratiosArray=(4,1,1)
    
    NSLog(@"chartView.isEnableSelection=%d",chartView.isEnableSelection);//chartView.isEnableSelection=1
    NSLog(@"chartView.isInitialized=%d",chartView.isInitialized);//chartView.isInitialized=1
    NSLog(@"chartView.isSectionInitialized=%d",chartView.isSectionInitialized);//chartView.isSectionInitialized=1
    
    NSLog(@"chartView.models=%@",chartView.models);
     //chartView.models={
     area = "<AreaChartModel: 0x7a67ffa0>";
     candle = "<CandleChartModel: 0x7a61e000>";
     line = "<LineChartModel: 0x7a67d290>";
     volume = "<VolumeChartModel: 0x7a67feb0>";
     }
    NSLog(@"chartView.borderColor=%@",chartView.borderColor);//chartView.borderColor=(null)
    NSLog(@"chartView.title=%@",chartView.title);//chartView.title=(null)
    */
    
    //[chartView.rangeFromInt, chartView.rangeToInt)
    for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++)
    {
        if(i == data.count){
            break;
        }
        if(data[i] == nil){
            continue;
        }
        
        float open  = [data[i][0] floatValue];
        float close = [data[i][1] floatValue];
        float high  = [data[i][2] floatValue];
        float low   = [data[i][3] floatValue];
        
        float ix  = sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth;
        float iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-chartView.rangeFromInt)*chartView.plotWidth;
        float iyo = [chartView getLocalY:open withSection:section withAxis:yAxis];
        float iyc = [chartView getLocalY:close withSection:section withAxis:yAxis];
        float iyh = [chartView getLocalY:high withSection:section withAxis:yAxis];
        float iyl = [chartView getLocalY:low withSection:section withAxis:yAxis];
        
        if(i == chartView.selectedIndex &&
           chartView.selectedIndex < data.count &&
           data[chartView.selectedIndex] != nil)
        {
            CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
            CGContextMoveToPoint(context, ix+chartView.plotWidth/2, sec.frame.origin.y+sec.paddingTop);
            CGContextAddLineToPoint(context, ix+chartView.plotWidth/2, sec.frame.size.height+sec.frame.origin.y);
            CGContextStrokePath(context);
        }
        
        //  画上下影线和K线实体
        if(close == open){ // 横盘.十字星
            if(i == chartView.selectedIndex){
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:SR green:SG blue:SB alpha:1.0].CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
            }
        } else if(close < open) { // 下跌
            if(i == chartView.selectedIndex){
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:NSR green:NSG blue:NSB alpha:1.0].CGColor);
                CGContextSetRGBFillColor(context, NSR, NSG, NSB, 1.0); 
            } else {
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:NR green:NG blue:NB alpha:1.0].CGColor);
                CGContextSetRGBFillColor(context, NR, NG, NB, 1.0); 
            }
        } else { // close > open // 上涨
            if(i == chartView.selectedIndex){
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:SR green:SG blue:SB alpha:1.0].CGColor);
                CGContextSetRGBFillColor(context, SR, SG, SB, 1.0); 
            } else {
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
                CGContextSetRGBFillColor(context, R, G, B, 1.0); 
            } 
        }
        
        //  画上下影线和K线实体
        if(close == open) { // 横盘.十字星
            CGContextMoveToPoint(context, ix+chartView.plotPadding, iyo);
            CGContextAddLineToPoint(context, iNx-chartView.plotPadding,iyo);
            CGContextStrokePath(context);
        } else if(close < open) { // 下跌
            CGContextFillRect (context, CGRectMake (ix+chartView.plotPadding, iyo, chartView.plotWidth-2*chartView.plotPadding,iyc-iyo));
        } else { // close > open // 上涨
            CGContextFillRect (context, CGRectMake (ix+chartView.plotPadding, iyc, chartView.plotWidth-2*chartView.plotPadding, iyo-iyc));
        }
        
        CGContextMoveToPoint(context, ix+chartView.plotWidth/2, iyh);
        CGContextAddLineToPoint(context,ix+chartView.plotWidth/2,iyl);
        CGContextStrokePath(context);
    }
}

-(void)setValuesForYAxisInChartView:(ChartView *)chartView
                   withSerie:(NSDictionary *)serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"chartView=%@",chartView);
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "249,222,170";
         data =     (
         );
         label = Price;
         labelColor = "176,52,52";
         labelNegativeColor = "77,143,42";
         name = price;
         negativeColor = "249,222,170";
         negativeSelectedColor = "249,222,170";
         section = 0;
         selectedColor = "249,222,170";
         type = candle;
         yAxis = 0;
     }
     */
    
    if([serie[@"data"] count] == 0){
		return;
	}
	
	NSMutableArray *data    = serie[@"data"];
	NSString       *yAxis   = serie[@"yAxis"];
	NSString       *section = serie[@"section"];
	
    Section *sec = chartView.sectionsArray[[section intValue]];
	YAxis *yaxis = [sec yAxisesArray][[yAxis intValue]];
	
    float high = [data[chartView.rangeFromInt][2] floatValue];
    float low = [data[chartView.rangeFromInt][3] floatValue];
    
    if(!yaxis.isUsed){
        [yaxis setMax:high];
        [yaxis setMin:low];
        yaxis.isUsed = YES;
    }
    
    for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++){
        if(i == data.count){
            break;
        }
        if(data[i] == nil){
            continue;
        }
        
        float high = [data[i][2] floatValue];
        float low = [data[i][3] floatValue];
        if(high > [yaxis max])
            [yaxis setMax:high];
        if(low < [yaxis min])
            [yaxis setMin:low];
    }
}

-(void)setLabelInChartView:(ChartView *)chartView
          forLabel:(NSMutableArray *)label
       withSerie:(NSMutableDictionary *)serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"chartView=%@",chartView);
    //NSLog(@"label=%@",label);
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "176,52,52";
         data =     (
         );
         label = Price;
         labelColor = "176,52,52";
         labelNegativeColor = "77,143,42";
         name = price;
         negativeColor = "77,143,42";
         negativeSelectedColor = "77,143,42";
         section = 0;
         selectedColor = "176,52,52";
         type = candle;
         yAxis = 0;
     }
     */

    if(serie[@"data"] == nil ||
       [serie[@"data"] count] == 0)
    {
	    return;
	}
	
	NSMutableArray *data          = serie[@"data"];
	NSString       *color         = serie[@"color"];
	NSString       *negativeColor = serie[@"negativeColor"];
	
	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;
	
    float NR  = [[negativeColor componentsSeparatedByString:@","][0] floatValue]/255;
	float NG  = [[negativeColor componentsSeparatedByString:@","][1] floatValue]/255;
	float NB  = [[negativeColor componentsSeparatedByString:@","][2] floatValue]/255;
	
	float ZR  = 1;
	float ZG  = 1;
	float ZB  = 1;
	
    if(chartView.selectedIndex!=-1 &&
       chartView.selectedIndex < data.count
       && data[chartView.selectedIndex]!=nil)
    {
        float high  = [data[chartView.selectedIndex][2] floatValue];
        float low   = [data[chartView.selectedIndex][3] floatValue];
        float open  = [data[chartView.selectedIndex][0] floatValue];
        float close = [data[chartView.selectedIndex][1] floatValue];
        float inc   =  (close-open)*100/open;
        
        //  Open
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        NSMutableString *l = [[NSMutableString alloc] init];
        [l appendFormat:@"O:%.2f",open];
        [tmp setObject:l forKey:@"text"];
        NSMutableString *clr = [[NSMutableString alloc] init];
        [clr appendFormat:@"%f,",ZR];
        [clr appendFormat:@"%f,",ZG];
        [clr appendFormat:@"%f",ZB];
        [tmp setObject:clr forKey:@"color"];
        [label addObject:tmp];
    
        //  High
        tmp = [[NSMutableDictionary alloc] init];
        l = [[NSMutableString alloc] init];
        [l appendFormat:@"H:%.2f",high];
        [tmp setObject:l forKey:@"text"];
        clr = [[NSMutableString alloc] init];
        if(high>open){
            [clr appendFormat:@"%f,",R];
            [clr appendFormat:@"%f,",G];
            [clr appendFormat:@"%f",B];
        }else{
            [clr appendFormat:@"%f,",ZR];
            [clr appendFormat:@"%f,",ZG];
            [clr appendFormat:@"%f",ZB];
        }
        [tmp setObject:clr forKey:@"color"];
        [label addObject:tmp];
        
        //  Low
        tmp = [[NSMutableDictionary alloc] init];
        l = [[NSMutableString alloc] init];
        [l appendFormat:@"L:%.2f",low];
        [tmp setObject:l forKey:@"text"];
        clr = [[NSMutableString alloc] init];
        if(low>open){
            [clr appendFormat:@"%f,",R];
            [clr appendFormat:@"%f,",G];
            [clr appendFormat:@"%f",B];
        }else if(low<open){
            [clr appendFormat:@"%f,",NR];
            [clr appendFormat:@"%f,",NG];
            [clr appendFormat:@"%f",NB];
        }else{
            [clr appendFormat:@"%f,",ZR];
            [clr appendFormat:@"%f,",ZG];
            [clr appendFormat:@"%f",ZB];
        }
        [tmp setObject:clr forKey:@"color"];
        [label addObject:tmp];
        
        //  Close
        tmp = [[NSMutableDictionary alloc] init];
        l = [[NSMutableString alloc] init];
        [l appendFormat:@"C:%.2f",close];
        [tmp setObject:l forKey:@"text"];
        clr = [[NSMutableString alloc] init];
        if(close>open){
            [clr appendFormat:@"%f,",R];
            [clr appendFormat:@"%f,",G];
            [clr appendFormat:@"%f",B];
        } else if (close < open) {
            [clr appendFormat:@"%f,",NR];
            [clr appendFormat:@"%f,",NG];
            [clr appendFormat:@"%f",NB];
        } else{
            [clr appendFormat:@"%f,",ZR];
            [clr appendFormat:@"%f,",ZG];
            [clr appendFormat:@"%f",ZB];
        }
        [tmp setObject:clr forKey:@"color"];
        [label addObject:tmp];

        //  Change
        tmp = [[NSMutableDictionary alloc] init];
        l = [[NSMutableString alloc] init];
        [l appendFormat:@"Ch:%.2f%%",inc];
        [tmp setObject:l forKey:@"text"];
        clr = [[NSMutableString alloc] init];
        if(inc > 0){
            [clr appendFormat:@"%f,",R];
            [clr appendFormat:@"%f,",G];
            [clr appendFormat:@"%f",B];
        }else if(inc < 0){
            [clr appendFormat:@"%f,",NR];
            [clr appendFormat:@"%f,",NG];
            [clr appendFormat:@"%f",NB];
        }else{
            [clr appendFormat:@"%f,",ZR];
            [clr appendFormat:@"%f,",ZG];
            [clr appendFormat:@"%f",ZB];
        }
        [tmp setObject:clr forKey:@"color"];
        [label addObject:tmp];
    }
}

#pragma mark 只有此模板有这个方法

-(void)drawTipsInChartView:(ChartView *)chartView
                 withSerie:(NSMutableDictionary *)serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"chartView=%@",chartView);
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "176,52,52";
         data =     (
         );
         label = Price;
         labelColor = "176,52,52";
         labelNegativeColor = "77,143,42";
         name = price;
         negativeColor = "77,143,42";
         negativeSelectedColor = "77,143,42";
         section = 0;
         selectedColor = "176,52,52";
         type = candle;
         yAxis = 0;
     }
     */
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO);
	CGContextSetLineWidth(context, 1.0f);
	
	NSMutableArray *data          = serie[@"data"];
	NSString       *type          = serie[@"type"];
	NSString       *name          = serie[@"name"];
	int            section        = [serie[@"section"] intValue];
	NSMutableArray *category      = serie[@"category"];
	Section *sec = chartView.sectionsArray[section];
	
    //  画十字星右边的标示
	if([type isEqualToString:@"candle"])
    {
		for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++)
        {
			if(i == data.count){
				break;
			}
			if(data[i] == nil){
			    continue;
			}
			
			float ix = sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth;
			
			if(i == chartView.selectedIndex &&
               chartView.selectedIndex < data.count &&
               data[chartView.selectedIndex]!=nil)
            {
				CGContextSetShouldAntialias(context, YES);
				CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 0.8); 
				CGSize size = [category[chartView.selectedIndex] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
				
				int x = ix+chartView.plotWidth/2;
				int y = sec.frame.origin.y+sec.paddingTop;
				if(x+size.width > sec.frame.size.width+sec.frame.origin.x){
					x= x-(size.width+4);
				}
				CGContextFillRect (context, CGRectMake (x, y, size.width+4,size.height+2)); 
				CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0); 
				[category[chartView.selectedIndex] drawAtPoint:CGPointMake(x+2,y+1) withFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
				CGContextSetShouldAntialias(context, NO);	
			}
		}
	}
	
	if([type isEqualToString:@"line"] &&
       [name isEqualToString:@"price"]) //没有执行??
    {
		for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++)
        {
			if(i == data.count){
				break;
			}
			if(data[i] == nil){
			    continue;
			}
			
			float ix = sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth;
			
			if(i == chartView.selectedIndex &&
               chartView.selectedIndex < data.count &&
               data[chartView.selectedIndex]!=nil)
            {
				CGContextSetShouldAntialias(context, YES);
				CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 0.8); 
				CGSize size = [category[chartView.selectedIndex] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
				
				int x = ix+chartView.plotWidth/2;
				int y = sec.frame.origin.y+sec.paddingTop;
				if(x+size.width > sec.frame.size.width+sec.frame.origin.x){
					x = x-(size.width+4);
				}
				CGContextFillRect (context, CGRectMake (x, y, size.width+4,size.height+2)); 
				CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0); 
				[category[chartView.selectedIndex] drawAtPoint:CGPointMake(x+2,y+1) withFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
				CGContextSetShouldAntialias(context, NO);	
			}
		}
	}
}

@end
