//
//  LineChartModel.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 lwork.com All rights reserved.
//

#import "LineChartModel.h"
#import "Axis.h"
#import "ChartView.h"

@implementation LineChartModel

-(void)drawSerieInChartView:(ChartView *)chartView
                  withSerie:(NSMutableDictionary *)serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "255,255,255";
         data =     (
         );
         label = MA10;
         name = ma10;
         negativeColor = "255,255,255";
         negativeSelectedColor = "255,255,255";
         section = 0;
         selectedColor = "255,255,255";
         type = line;
         yAxis = 0;
     }
     */
    
    if(serie[@"data"] == nil || [serie[@"data"] count] == 0){
	    return;
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, YES);
	CGContextSetLineWidth(context, 1.0f);
	
	NSMutableArray *data          = serie[@"data"];
	int            yAxis          = [serie[@"yAxis"] intValue];
	int            section        = [serie[@"section"] intValue];
	NSString       *color         = serie[@"color"];
	
	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;
    
	Section *sec = chartView.sectionsArray[section];
	
    
    if(chartView.selectedIndex!=-1 &&
       chartView.selectedIndex < data.count &&
       data[chartView.selectedIndex]!=nil)
    {
        float value = [data[chartView.selectedIndex][0] floatValue];
        CGContextSetShouldAntialias(context, NO);
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
    
    CGContextSetShouldAntialias(context, YES);
    for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++){
        if(i == data.count-1){
            break;
        }
        if(data[i] == nil){
            continue;
        }
        if (i<chartView.rangeToInt-1 && data[i+1] != nil) {
            float value = [data[i][0] floatValue];
            float ix = sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth;
            float iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-chartView.rangeFromInt)*chartView.plotWidth;
            float iy = [chartView getLocalY:value withSection:section withAxis:yAxis];
            CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
            CGContextMoveToPoint(context, ix+chartView.plotWidth/2, iy);
            
            float y = [chartView getLocalY:([data[(i+1)][0] floatValue]) withSection:section withAxis:yAxis];
            if(!isnan(y)){
                CGContextAddLineToPoint(context, iNx+chartView.plotWidth/2, y);
            }
            
            CGContextStrokePath(context);
        }	
    }

}

-(void)setValuesForYAxisInChartView:(ChartView *)chartView
                          withSerie:(NSDictionary *)serie
{
    //NSLog(@"%s",__func__);
    
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "255,255,255";
         data =     (
         );
         label = MA10;
         name = ma10;
         negativeColor = "255,255,255";
         negativeSelectedColor = "255,255,255";
         section = 0;
         selectedColor = "255,255,255";
         type = line;
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
    
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "255,255,255";
         data =     (
         );
         label = MA10;
         name = ma10;
         negativeColor = "255,255,255";
         negativeSelectedColor = "255,255,255";
         section = 0;
         selectedColor = "255,255,255";
         type = line;
         yAxis = 0;
     }
     */
    
    if(serie[@"data"] == nil || [serie[@"data"] count] == 0){
	    return;
	}
	
	NSMutableArray *data          = serie[@"data"];
	//NSString       *type          = serie[@"type"];
	NSString       *lbl           = serie[@"label"];
	int            yAxis          = [serie[@"yAxis"] intValue];
	int            section        = [serie[@"section"] intValue];
	NSString       *color         = serie[@"color"];
	
	YAxis *yaxis = [chartView.sectionsArray[section] yAxisesArray][yAxis];
	NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];
	
	float R = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B = [[color componentsSeparatedByString:@","][2] floatValue]/255;

    if(chartView.selectedIndex != -1 &&
       chartView.selectedIndex < data.count &&
       data[chartView.selectedIndex] != nil)
    {
        float value = [data[chartView.selectedIndex][0] floatValue ];
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
