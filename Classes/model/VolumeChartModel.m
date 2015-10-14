//
//  VolumeChartModel.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 lwork.com All rights reserved.
//

#import "VolumeChartModel.h"
#import "YAxis.h"
#import "ChartView.h"

@implementation VolumeChartModel

-(void)drawSerieInChartView:(ChartView *)chartView
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
         decimal = 0;
         label = VOL;
         name = vol;
         negativeColor = "77,143,42";
         negativeSelectedColor = "77,143,42";
         section = 1;
         selectedColor = "176,52,52";
         type = volume;
         yAxis = 0;
     }
     */
    
    if(serie[@"data"] == nil ||
       [serie[@"data"] count] == 0){
	    return;
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, YES);
	CGContextSetLineWidth(context, 1.0f);
	
	NSMutableArray *data          = serie[@"data"];
	int            yAxis          = [serie[@"yAxis"] intValue];
	int            section        = [serie[@"section"] intValue];
	NSString       *color         = serie[@"color"];
	NSString       *negativeColor = serie[@"negativeColor"];
	NSString       *selectedColor = serie[@"selectedColor"];
	NSString       *negativeSelectedColor = serie[@"negativeSelectedColor"];
    
	YAxis *yaxis = [chartView.sectionsArray[section] yAxisesArray][yAxis];
	
	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;
    
	float NR  = [[negativeColor componentsSeparatedByString:@","][0] floatValue]/255;
	float NG  = [[negativeColor componentsSeparatedByString:@","][1] floatValue]/255;
	float NB  = [[negativeColor componentsSeparatedByString:@","][2] floatValue]/255;
	
    float SR  = [[selectedColor componentsSeparatedByString:@","][0] floatValue]/255;
	float SG  = [[selectedColor componentsSeparatedByString:@","][1] floatValue]/255;
	float SB  = [[selectedColor componentsSeparatedByString:@","][2] floatValue]/255;
	
    float NSR = [[negativeSelectedColor componentsSeparatedByString:@","][0] floatValue]/255;
	float NSG = [[negativeSelectedColor componentsSeparatedByString:@","][1] floatValue]/255;
	float NSB = [[negativeSelectedColor componentsSeparatedByString:@","][2] floatValue]/255;
    
	Section *sec = chartView.sectionsArray[section];
	
    if(chartView.selectedIndex != -1 &&
       chartView.selectedIndex < data.count &&
       data[chartView.selectedIndex] != nil)
    {
        float value = [data[chartView.selectedIndex][0] floatValue];
        CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
        CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(chartView.selectedIndex-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2, sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(chartView.selectedIndex-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
        CGContextStrokePath(context);
        
        CGContextSetShouldAntialias(context, YES);
        CGContextBeginPath(context);
        CGContextSetRGBFillColor(context, R, G, B, 1.0);
        if(!isnan([chartView getLocalY:value withSection:section withAxis:yAxis])){
            CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(chartView.selectedIndex-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2, [chartView getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
        }
        CGContextFillPath(context);
    }
    
    CGContextSetShouldAntialias(context, NO);
    for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++){
        if(i == data.count){
            break;
        }
        if(data[i] == nil){
            continue;
        }
        
        float value = [data[i][0] floatValue];
        float ix  = sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth;
        float iy = [chartView getLocalY:value withSection:section withAxis:yAxis];
        
        if(value < yaxis.baseValue){
            if(i == chartView.selectedIndex){
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:NSR green:NSG blue:NSB alpha:1.0].CGColor);
                CGContextSetRGBFillColor(context, NSR, NSG, NSB, 1.0); 
            }else{
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:NR green:NG blue:NB alpha:1.0].CGColor);
                CGContextSetRGBFillColor(context, NR, NG, NB, 1.0); 
            }
        }else{
            if(i == chartView.selectedIndex){
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:SR green:SG blue:SB alpha:1.0].CGColor);
                CGContextSetRGBFillColor(context, SR, SG, SB, 1.0); 
            }else{
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
                CGContextSetRGBFillColor(context, R, G, B, 1.0); 
            } 
        }
        
        
        CGContextFillRect (context, CGRectMake (ix+chartView.plotPadding, iy, chartView.plotWidth-2*chartView.plotPadding,[chartView getLocalY:yaxis.baseValue withSection:section withAxis:yAxis]-iy));
    }
	
}

-(void)setValuesForYAxisInChartView:(ChartView *)chartView
                          withSerie:(NSDictionary *)serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"serie=%@",serie);
    /*
     serie={
         color = "176,52,52";
         data =     (
         );
         decimal = 0;
         label = VOL;
         name = vol;
         negativeColor = "77,143,42";
         negativeSelectedColor = "77,143,42";
         section = 1;
         selectedColor = "176,52,52";
         type = volume;
         yAxis = 0;
     }
     */
    
    if([serie[@"data"] count] == 0){
		return;
	}
	
	NSMutableArray *data    = serie[@"data"];
	NSString       *yAxis   = serie[@"yAxis"];
	NSString       *section = serie[@"section"];
	
	YAxis *yaxis = [chartView.sectionsArray[[section intValue]] yAxisesArray][[yAxis intValue]];
	if(serie[@"decimal"] != nil){
		yaxis.decimal = [serie[@"decimal"] intValue];
	}
	
	float value = [data[chartView.rangeFromInt][0] floatValue];
	if(!yaxis.isUsed){
        [yaxis setMax:value];
        [yaxis setMin:value];
        yaxis.isUsed = YES;
    }
    for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++){
        if(i == data.count){
            break;
        }
        if(data[i] == nil){
            continue;
        }
        
        float value = [data[i][0] floatValue];
        if(value > [yaxis max])
            [yaxis setMax:value];
        if(value < [yaxis min])
            [yaxis setMin:value];
    }

}

-(void)setLabelInChartView:(ChartView *)chartView
                  forLabel:(NSMutableArray *)label
                 withSerie:(NSMutableDictionary *) serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"label=%@",label);
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "176,52,52";
         data =     (
         );
         decimal = 0;
         label = VOL;
         name = vol;
         negativeColor = "77,143,42";
         negativeSelectedColor = "77,143,42";
         section = 1;
         selectedColor = "176,52,52";
         type = volume;
         yAxis = 0;
     }
     */
    
    if(serie[@"data"] == nil || [serie[@"data"] count] == 0){
	    return;
	}
	
	NSMutableArray *data          = serie[@"data"];
	NSString       *lbl           = serie[@"label"];
	int            yAxis          = [serie[@"yAxis"] intValue];
	int            section        = [serie[@"section"] intValue];
	NSString       *color         = serie[@"color"];
	
	YAxis *yaxis = [chartView.sectionsArray[section] yAxisesArray][yAxis];
	NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];
	
    NSArray *colorArray = [color componentsSeparatedByString:@","];
	float R   = [colorArray[0] floatValue]/255;
	float G   = [colorArray[1] floatValue]/255;
	float B   = [colorArray[2] floatValue]/255;
	
    if(chartView.selectedIndex!=-1 &&
       chartView.selectedIndex < data.count &&
       data[chartView.selectedIndex]!=nil)
    {
        float value = [data[chartView.selectedIndex][0] floatValue];
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        NSMutableString *l = [[NSMutableString alloc] init];
        NSString *fmt = [@"%@:" stringByAppendingFormat:@"%@",format];
        [l appendFormat:fmt,lbl,value];
        [tmp setObject:l forKey:@"text"];
        
        NSMutableString *clr = [[NSMutableString alloc] init];
        [clr appendFormat:@"%f,",R];
        [clr appendFormat:@"%f,",G];
        [clr appendFormat:@"%f",B];
        [tmp setObject:clr forKey:@"color"];
        
        [label addObject:tmp];
    }
}

@end
