//
//  AreaChartModel.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 lwork.com All rights reserved.
//

#import "AreaChartModel.h"
#import "Axis.h"
#import "ChartView.h"

@implementation AreaChartModel

-(void)drawSerieInChartView:(ChartView *)chartView
                  withSerie:(NSMutableDictionary *)serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "250,232,115";
         data =     (
             (
             "16.924376"
             ),
             (
             "6.741542"
             ),
             (
             "2.081245"
             ),
             ...
         );
         label = WR;
         name = wr;
         negativeColor = "250,232,115";
         negativeSelectedColor = "250,232,115";
         section = 2;
         selectedColor = "250,232,115";
         type = area;
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
    
	YAxis *yaxis = [chartView.sectionsArray[section] yAxisesArray][yAxis];
	
	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;
	float NR  = [[negativeColor componentsSeparatedByString:@","][0] floatValue]/255;
	float NG  = [[negativeColor componentsSeparatedByString:@","][1] floatValue]/255;
	float NB  = [[negativeColor componentsSeparatedByString:@","][2] floatValue]/255;

	Section *sec = chartView.sectionsArray[section];

    CGPoint startPoint,endPoint; 
    float prevValue = 0;
    float nextValue = 0;
    float ix        = 0;
    float iy        = 0;
    float iPx       = 0;
    float iPy       = 0;
    float iNx       = 0;
    float iNy       = 0;
    int   found     = 0;
    
    float iBy = [chartView getLocalY:yaxis.baseValue withSection:section withAxis:yAxis];
    
    if(chartView.selectedIndex!=-1 && chartView.selectedIndex < data.count && data[chartView.selectedIndex]!=nil)
    {
        float value = [data[chartView.selectedIndex][0] floatValue];
        if(value>=yaxis.baseValue){
            CGContextSetRGBFillColor(context, R, G, B, 1.0);
        }else{ 
            CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
        }
        
        CGContextSetShouldAntialias(context, NO);
        CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
        CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(chartView.selectedIndex-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2, sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(chartView.selectedIndex-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
        CGContextStrokePath(context);
        
        CGContextSetShouldAntialias(context, YES);
        CGContextBeginPath(context);
        CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(chartView.selectedIndex-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2, [chartView getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
        CGContextFillPath(context);
    }
    
    CGContextSetShouldAntialias(context, YES);
    /*
     Start:drawing positive values
     */
    CGContextBeginPath(context);
    CGContextSetRGBFillColor(context, R, G, B, 1.0);
    for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++){
        if(i == data.count-1){
            break;
        }
        if(data[i] == nil){
            continue;
        }
        
        float value = [data[i][0] floatValue];
        
        if(value >= yaxis.baseValue){
            ix  = sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth;
            iy = [chartView getLocalY:value withSection:section withAxis:yAxis];
            
            if(found == 0){
                found = 1;
                if(i==chartView.rangeFromInt){
                    CGContextMoveToPoint(context, ix+chartView.plotWidth/2, iy);
                    startPoint = CGPointMake(ix+chartView.plotWidth/2, iy);
                }else if(i>chartView.rangeFromInt){
                    prevValue = [data[(i-1)][0] floatValue];
                    iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-chartView.rangeFromInt)*chartView.plotWidth;
                    iPy = [chartView getLocalY:prevValue withSection:section withAxis:yAxis];
                    if(prevValue < yaxis.baseValue){
                        float baseX = (yaxis.baseValue-prevValue)*chartView.plotWidth/(value-prevValue)+(sec.frame.origin.x+sec.paddingLeft+(i-1-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2);
                        CGContextMoveToPoint(context, baseX,iBy);
                        CGContextAddLineToPoint(context, ix+chartView.plotWidth/2, iy);
                        startPoint = CGPointMake(baseX, iBy);
                        endPoint = CGPointMake(ix+chartView.plotWidth/2,iy);
                    }
                }
            }else if(i>chartView.rangeFromInt){
                prevValue = [data[(i-1)][0] floatValue];
                iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-chartView.rangeFromInt)*chartView.plotWidth;
                iPy = [chartView getLocalY:prevValue withSection:section withAxis:yAxis];
                if(prevValue < yaxis.baseValue){
                    float baseX = (yaxis.baseValue-prevValue)*chartView.plotWidth/(value-prevValue)+(sec.frame.origin.x+sec.paddingLeft+(i-1-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2);
                    CGContextAddLineToPoint(context, baseX,iBy);
                    CGContextAddLineToPoint(context, ix+chartView.plotWidth/2,iy);
                    endPoint = CGPointMake(ix+chartView.plotWidth/2,iy);
                }
            }
            
            if (i < chartView.rangeToInt-1  && data[(i+1)] != nil) {
                nextValue = [data[(i+1)][0] floatValue];
                iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-chartView.rangeFromInt)*chartView.plotWidth;
                iNy = [chartView getLocalY:nextValue withSection:section withAxis:yAxis];
                
                if(nextValue < yaxis.baseValue){
                    float baseX = (value-yaxis.baseValue)*chartView.plotWidth/(value-nextValue)+(sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2);
                    CGContextAddLineToPoint(context, baseX,iBy);
                    endPoint = CGPointMake(baseX, iBy);
                }else{
                    CGContextAddLineToPoint(context, iNx+chartView.plotWidth/2,iNy);
                    endPoint = CGPointMake(iNx+chartView.plotWidth/2,iNy);
                }
            }
        }
        
    }
    if(found == 1){
        CGContextAddLineToPoint(context, endPoint.x,iBy);
        CGContextAddLineToPoint(context, startPoint.x,iBy);
        CGContextFillPath(context);
    }
    /*
     End:drawing positive values
     */
    
    /*
     Start:drawing negative values
     */
    found = 0;
    CGContextBeginPath(context);
    CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
    for(int i=chartView.rangeFromInt;i<chartView.rangeToInt;i++){
        if(i == data.count-1){
            break;
        }
        if(data[i] == nil){
            continue;
        }
        
        float value = [data[i][0] floatValue];
        if(value < yaxis.baseValue){
            ix  = sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth;
            iy = [chartView getLocalY:value withSection:section withAxis:yAxis];
            
            if(found == 0){
                found = 1;
                if(i==chartView.rangeFromInt){
                    CGContextMoveToPoint(context, ix+chartView.plotWidth/2, iy);
                    startPoint = CGPointMake(ix+chartView.plotWidth/2, iy);
                }else if(i>chartView.rangeFromInt){
                    prevValue = [data[(i-1)][0] floatValue];
                    iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-chartView.rangeFromInt)*chartView.plotWidth;
                    iPy = [chartView getLocalY:prevValue withSection:section withAxis:yAxis];
                    if(prevValue > yaxis.baseValue){
                        float baseX = (prevValue-yaxis.baseValue)*chartView.plotWidth/(prevValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-1-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2);
                        CGContextMoveToPoint(context, baseX,iBy);
                        CGContextAddLineToPoint(context, ix+chartView.plotWidth/2, iy);
                        startPoint = CGPointMake(baseX, iBy);
                        endPoint = CGPointMake(ix+chartView.plotWidth/2,iy);
                    }
                }
            }else if(i>chartView.rangeFromInt){
                prevValue = [data[(i-1)][0] floatValue];
                iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-chartView.rangeFromInt)*chartView.plotWidth;
                iPy = [chartView getLocalY:prevValue withSection:section withAxis:yAxis];
                if(prevValue > yaxis.baseValue){
                    float baseX = (prevValue-yaxis.baseValue)*chartView.plotWidth/(prevValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-1-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2);
                    CGContextAddLineToPoint(context, baseX,iBy);
                    CGContextAddLineToPoint(context, ix+chartView.plotWidth/2,iy);
                    endPoint = CGPointMake(ix+chartView.plotWidth/2,iy);
                }
            }
            
            if (i < chartView.rangeToInt-1 && data[(i+1)] != nil) {
                nextValue = [data[(i+1)][0] floatValue];
                iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-chartView.rangeFromInt)*chartView.plotWidth;
                iNy = [chartView getLocalY:nextValue withSection:section withAxis:yAxis];
                if(nextValue > yaxis.baseValue){
                    float baseX = (yaxis.baseValue-value)*chartView.plotWidth/(nextValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-chartView.rangeFromInt)*chartView.plotWidth+chartView.plotWidth/2);
                    CGContextAddLineToPoint(context, baseX,iBy);
                    endPoint = CGPointMake(baseX, iBy);
                }else{
                    CGContextAddLineToPoint(context, iNx+chartView.plotWidth/2,iNy);
                    endPoint = CGPointMake(iNx+chartView.plotWidth/2,iNy);
                }
            }
        }
    }
    
    if(found == 1){
        CGContextAddLineToPoint(context, endPoint.x,iBy);
        CGContextAddLineToPoint(context, startPoint.x,iBy);
        CGContextAddLineToPoint(context, startPoint.x,startPoint.y);
        CGContextFillPath(context);
    }
    
    /*
     End:drawing negative values
     */
}

-(void)setValuesForYAxisInChartView:(ChartView *)chartView
                          withSerie:(NSDictionary *)serie
{
    //NSLog(@"%s",__func__);
    //NSLog(@"serie=%@",serie);
    
    /*
     serie={
         color = "250,232,115";
         data =     (
             (
             "16.924376"
             ),
         
             (
             "6.741542"
             ),
             
             ...
             
             (
             "95.884796"
             )
         );
         
         label = WR;
         name = wr;
         negativeColor = "250,232,115";
         negativeSelectedColor = "250,232,115";
         
         section = 2;
         selectedColor = "250,232,115";
         type = area;
         yAxis = 0;
     }
     */
    
    if([serie[@"data"] count] == 0){
		return;
	}
	
	NSMutableArray *data    = serie[@"data"];
	NSString       *yAxis   = serie[@"yAxis"];
	NSString       *section = serie[@"section"];
	
    Section *sec =  chartView.sectionsArray[[section intValue]];
	YAxis *yaxis = [sec yAxisesArray][[yAxis intValue]];
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
         color = "250,232,115";
         data =     (
             (
             "16.924376"
             ),
             (
             "6.741542"
             ),
             ......
             (
             "95.884796"
             )
         );

         label = WR;
         name = wr;
         negativeColor = "250,232,115";
         negativeSelectedColor = "250,232,115";
         section = 2;
         selectedColor = "250,232,115";
         type = area;
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
	
	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;

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
