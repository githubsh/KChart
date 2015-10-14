//
//  CandleViewController+Request.m
//  chartee
//
//  Created by steven on 15/8/22.
//
//

#import "CandleViewController+Data.h"
#import "ASIHTTPRequest.h"

@implementation CandleViewController (Data)

#pragma mark - 获取网络数据

-(void)getDataFromServer
{
    self.statusLabel.text = @"Loading...";
    if(self.chartMode == kChartModeCandleVolume) // 蜡烛图 + 成交量
    {
        Section *sec = self.chartView.sectionsArray[2];
        sec.isHidden = YES;
    }
    else if (self.chartMode == kChartModeCandleVolumeIndicators) // 蜡烛图 + 成交量 + 指标线
    {
        [self.chartView getSectionAtIndex:2].isHidden = NO;
    }
    
    NSString *urlString = [[NSString alloc] initWithFormat:self.req_url_format,self.req_security_id,self.req_freq];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"urlString=%@",urlString);
    
    //  urlString=http://ichart.yahoo.com/table.csv?s=600030.SS&g=d
    //  urlString=http://ichart.yahoo.com/table.csv?s=000030.SZ&g=w
    //  urlString=http://ichart.yahoo.com/table.csv?s=300030.SZ&g=m
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    //  ASIHTTPRequest
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 5;
    request.delegate = self;
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"requestFailed");
    
    self.statusLabel.text = @"Error!";

    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"本地content=%@",content);
    self.offlineContentString = content;
    
    [self requestFinished:nil];
}

/*
 日期         开盘   最高    最低    收盘   成交量      复权收盘价
 Date,       Open,  High,  Low,   Close, Volume,    Adj Close
 2015-07-24, 24.56, 24.65, 23.87, 23.90, 235272800, 23.90
 */

/*
 Date,Open,High,Low,Close,Volume,Adj Close
 2015-07-24,24.56,24.65,23.87,23.90,235272800,23.90
 2015-07-23,24.03,24.79,24.00,24.54,246820400,24.54
 2015-07-22,24.21,24.58,23.87,24.01,192779100,24.01
 2015-07-21,24.30,25.13,23.90,24.45,281629700,24.45
 2015-07-20,25.20,25.34,24.36,24.55,276692300,24.55
 ...
 */

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.statusLabel.text = @"获取成功!";
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *category = [[NSMutableArray alloc] init];//Date 日期
    
    //  响应字符串
    NSString *content = request.responseString;
    //NSLog(@"content=%@",content);
    
    //  如果连不上服务器就加载离线数据
    if (self.offlineContentString != nil)
    {
        content = self.offlineContentString;
    }
    
    //  按换行符切换成数组
    NSArray *linesArray = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    //NSLog(@"linesArray=%@",linesArray);
    
    //  新日期在前面旧日期在后，按 先旧后新 顺序 压入数组
    for (NSInteger idx = linesArray.count-1; idx > 0; idx--)
    {
        //  取出每一行
        NSString *line = linesArray[idx];
        if([line isEqualToString:@""])//空行跳过去
        {
            continue;
        }
        
        //  Date,Open,High,Low,Close,Volume,Adj Close
        //  0,   1,   2,   3,  4,    5,     6
        
        //  Date open close  high low volume
        
        //  按,分割成数组
        NSArray *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        
        //  日期
        [category addObject:arr[0]];
        
        //  开盘 收盘 最高 最低 成交量
        NSMutableArray *oneData =[[NSMutableArray alloc] init];
        [oneData addObject:arr[1]];//Open
        [oneData addObject:arr[4]];//Close
        [oneData addObject:arr[2]];//High
        [oneData addObject:arr[3]];//Low
        [oneData addObject:arr[5]];//Volume
        
        [data addObject:oneData];
    }
    
    if(data.count==0) {
        self.statusLabel.text = @"Error!";
        return;
    }
    
    NSLog(@"category=%@",category);
    /*
     category=(
         "2003-01-06",
         "2003-01-07",
         "2003-01-08",
     )
     */
    
    NSLog(@"data=%@",data);
    
    /*
     data=(
         (
         "5.52999",     //Open
         "5.01",        //Close
         "5.58",        //High
         "4.97001",     //Low
         582865600      //Volume
         ),
         (
         "4.95999",     //Open
         "4.85001",     //Close
         "5.04999",     //High
         "4.82001",     //Low
         176933100      //Volume
         ),
     )
     */
    
    
    
    if (self.chartMode == kChartModeCandleVolume)
    {
        if([self.req_type isEqualToString:@"T"]){
            if(self.timer != nil)
                [self.timer invalidate];
            
            [self.chartView reset];//self.chartView.isInitialized = NO;
            [self clearData];
            [self clearCategory];
            
            if([self.req_freq hasSuffix:@"m"]){ //请求月线可能较慢 每隔5秒重复请求获取数据
                self.req_type = @"L";
                self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getDataFromServer) userInfo:nil repeats:YES];
            }
        } else {
            NSString *time = category[0];
            if([time isEqualToString:self.lastTime])
            {
                if([time hasSuffix:@"1500"]){ //下午收盘
                    if(self.timer != nil)
                        [self.timer invalidate];
                }
                return;
            }
            if ([time hasSuffix:@"1130"] || //hasSuffix 已..结尾
                [time hasSuffix:@"1500"])   //中午收盘 下午收盘
            {
                if(self.tradeStatus == kTradeStatusOpen){
                    self.tradeStatus = kTradeStatusClose;
                }
            } else {
                self.tradeStatus = kTradeStatusOpen;
            }
        }
    }
    else
    {
        if(self.timer != nil)
            [self.timer invalidate];
        
        [self.chartView reset];
//      self.isInitialized = NO;
        [self clearData];
        [self clearCategory];
    }
    
    self.lastTime = [category lastObject];
    
    //  data 生成 dic
    NSMutableDictionary *dic = [self generateDicFromData:data];
    
    //  设置dic 到 self.chartView
    [self setDic:dic];
    
    if(self.chartMode == kChartModeCandleVolume)
    {
        [self setCategory:category];
    }
    else
    {
        NSMutableArray *cate = [[NSMutableArray alloc] init];
        for(int i=60; i<category.count; i++){
            [cate addObject:category[i]];
        }
        [self setCategory:cate];
    }
    
    #pragma mark - 显示重绘 setNeedsDisplay
    
    [self.chartView setNeedsDisplay];
}

static const int confirmDay = 60;

#pragma mark - 生成数据
//  移动平均线 ma 算法
- (NSMutableArray *)caculateMaFromData:(NSArray *)data withDays:(int)days
{
    NSMutableArray *maArray = [NSMutableArray arrayWithCapacity:0];
    
    for(int i = confirmDay;i < data.count;i++){
        float val = 0;
        for(int j=i;j>i-days;j--){
            val += [data[j][1] floatValue];
        }
        val = val/days;
        NSMutableArray *item = [[NSMutableArray alloc] init];
        [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
        [maArray addObject:item];
    }
    
    return maArray;
}

//  相对强弱线 RSI 算法
- (NSMutableArray *)caculateRsiFromData:(NSArray *)data withDays:(int)days
{
    NSMutableArray *rsiArray = [NSMutableArray arrayWithCapacity:0];
    
    for(int i = confirmDay;i < data.count;i++){
        float incVal  = 0;
        float decVal = 0;
        float rs = 0;
        for(int j=i;j>i-days;j--){
            float interval = [data[j][1] floatValue]-[data[j][0] floatValue];
            if(interval >= 0){
                incVal += interval;
            }else{
                decVal -= interval;
            }
        }
        
        rs = incVal/decVal;
        float rsi =100-100/(1+rs);
        
        NSMutableArray *item = [[NSMutableArray alloc] init];
        [item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
        [rsiArray addObject:item];
    }
    
    return rsiArray;
}

- (NSMutableDictionary *)generateDicFromData:(NSArray *)data
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    if(self.chartMode == kChartModeCandleVolumeIndicators)
    {
        //  price
        NSMutableArray *price = [[NSMutableArray alloc] init];
        for(int i = confirmDay;i < data.count;i++){
            [price addObject:data[i]];
        }
        dic[@"price"] = price;
        
        //  vol
        NSMutableArray *vol = [[NSMutableArray alloc] init];
        for(int i = confirmDay;i < data.count;i++){
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",[data[i][4] floatValue]/100]];//1手=100
            
            [vol addObject:item];
        }
        dic[@"vol"] = vol;
        
        //  ma 10
        NSMutableArray *ma10 = [self caculateMaFromData:data withDays:10];
        dic[@"ma10"] = ma10;
        
        //  ma 30
        NSMutableArray *ma30 = [self caculateMaFromData:data withDays:30];
        dic[@"ma30"] = ma30;
        
        //  ma 60
        NSMutableArray *ma60 = [self caculateMaFromData:data withDays:60];
        dic[@"ma60"] = ma60;
        
        //  RSI6
        NSMutableArray *rsi6 = [self caculateRsiFromData:data withDays:6];
        dic[@"rsi6"] = rsi6;
        
        //  RSI12
        NSMutableArray *rsi12 = [self caculateRsiFromData:data withDays:12];
        dic[@"rsi12"] = rsi12;
        
        //  WR
        NSMutableArray *wr = [[NSMutableArray alloc] init];
        for(int i = confirmDay;i < data.count;i++){
            float h = [data[i][2] floatValue];
            float l = [data[i][3] floatValue];
            float c = [data[i][1] floatValue];
            for(int j=i;j>i-10;j--){
                if([data[j][2] floatValue] > h){
                    h = [data[j][2] floatValue];
                }
                
                if([data[j][3] floatValue] < l){
                    l = [data[j][3] floatValue];
                }
            }
            
            float val = (h-c)/(h-l)*100;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [wr addObject:item];
        }
        dic[@"wr"] = wr;
        
        //  KDJ
        NSMutableArray *kdj_k = [[NSMutableArray alloc] init];
        NSMutableArray *kdj_d = [[NSMutableArray alloc] init];
        NSMutableArray *kdj_j = [[NSMutableArray alloc] init];
        float prev_k = 50;
        float prev_d = 50;
        float rsv = 0;
        for(int i = confirmDay;i < data.count;i++){
            float h  = [data[i][2] floatValue];
            float l = [data[i][3] floatValue];
            float c = [data[i][1] floatValue];
            for(int j=i;j>i-10;j--){
                if([data[j][2] floatValue] > h){
                    h = [data[j][2] floatValue];
                }
                
                if([data[j][3] floatValue] < l){
                    l = [data[j][3] floatValue];
                }
            }
            
            if(h!=l)
                rsv = (c-l)/(h-l)*100;
            float k = 2*prev_k/3+1*rsv/3;
            float d = 2*prev_d/3+1*k/3;
            float j = d+2*(d-k);
            
            prev_k = k;
            prev_d = d;
            
            NSMutableArray *itemK = [[NSMutableArray alloc] init];
            [itemK addObject:[@"" stringByAppendingFormat:@"%f",k]];
            [kdj_k addObject:itemK];
            
            NSMutableArray *itemD = [[NSMutableArray alloc] init];
            [itemD addObject:[@"" stringByAppendingFormat:@"%f",d]];
            [kdj_d addObject:itemD];
            
            NSMutableArray *itemJ = [[NSMutableArray alloc] init];
            [itemJ addObject:[@"" stringByAppendingFormat:@"%f",j]];
            [kdj_j addObject:itemJ];
        }
        dic[@"kdj_k"] = kdj_k;
        dic[@"kdj_d"] = kdj_d;
        dic[@"kdj_j"] = kdj_j;
        
        //  VR
        NSMutableArray *vr = [[NSMutableArray alloc] init];
        for(int i = confirmDay;i < data.count;i++){
            float inc = 0;
            float dec = 0;
            float eq  = 0;
            for(int j=i;j>i-24;j--){
                float o = [data[j][0] floatValue];
                float c = [data[j][1] floatValue];
                
                if(c > o){
                    inc += [data[j][4] intValue];
                }else if(c < o){
                    dec += [data[j][4] intValue];
                }else{
                    eq  += [data[j][4] intValue];
                }
            }
            
            float val = (inc+1*eq/2)/(dec+1*eq/2);
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [vr addObject:item];
        }
        dic[@"vr"] = vr;
    }
    else // 价格 + 成交量
    {
        //  price
        NSMutableArray *price = [[NSMutableArray alloc] init];
        for(int i = 0;i < data.count;i++){
            [price addObject: data[i]];
        }
        dic[@"price"] = price;
        
        //  VOL
        NSMutableArray *vol = [[NSMutableArray alloc] init];
        for(int i = 0;i < data.count;i++){
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",[data[i][4] floatValue]/100]];
            [vol addObject:item];
        }
        dic[@"vol"] = vol;
    }
    
    //NSLog(@"生成的图表数据 dic=%@",dic);

    return dic;
}

-(void)setDic:(NSDictionary *)dic
{
    [self appendData:dic[@"price"] forName:@"price"];
    [self appendData:dic[@"vol"] forName:@"vol"];
    
    [self appendData:dic[@"ma10"] forName:@"ma10"];
    [self appendData:dic[@"ma30"] forName:@"ma30"];
    [self appendData:dic[@"ma60"] forName:@"ma60"];
    
    [self appendData:dic[@"rsi6"] forName:@"rsi6"];
    [self appendData:dic[@"rsi12"] forName:@"rsi12"];
    
    [self appendData:dic[@"wr"] forName:@"wr"];
    [self appendData:dic[@"vr"] forName:@"vr"];
    
    [self appendData:dic[@"kdj_k"] forName:@"kdj_k"];
    [self appendData:dic[@"kdj_d"] forName:@"kdj_d"];
    [self appendData:dic[@"kdj_j"] forName:@"kdj_j"];
    
    NSMutableDictionary *serie = [self.chartView getSerieFromName:@"price"];
    if (serie == nil) {
        return;
    }
    
    if(self.chartMode == kChartModeCandleVolumeIndicators){
        serie[@"type"] = @"candle";
    } else {
        serie[@"type"] = @"line";
    }
}

-(void)setCategory:(NSArray *)category
{
    [self appendCategory:category forName:@"price"];
    [self appendCategory:category forName:@"line"];
}

#pragma mark - data
- (void)appendData:(NSArray *)data forName:(NSString *)name
{
    for(NSMutableDictionary *dict in self.chartView.seriesArray)
    {
        if([dict[@"name"] isEqualToString:name])
        {
            if (dict[@"data"] == nil) {
                dict[@"data"] = [[NSMutableArray alloc] init];
            }
            
            [dict[@"data"] addObjectsFromArray:data];
        }
    }
}

- (void)setData:(NSMutableArray *)data forName:(NSString *)name
{
    for(NSMutableDictionary *dict in self.chartView.seriesArray)
    {
        if([dict[@"name"] isEqualToString:name]){
            dict[@"data"] = data;
        }
    }
}

- (void)clearDataforName:(NSString *)name
{
    for(NSDictionary *dict in self.chartView.seriesArray)
    {
        if([dict[@"name"] isEqualToString:name])
        {
            NSMutableArray *data = dict[@"data"];
            if(data != nil){
                [data removeAllObjects];
            }
        }
    }
}

- (void)clearData
{
    for(NSDictionary *dict in self.chartView.seriesArray)
    {
        NSMutableArray *data = dict[@"data"];
        [data removeAllObjects];
    }
}

#pragma mark - Category
- (void)appendCategory:(NSArray *)category forName:(NSString *)name
{
    for(NSMutableDictionary *dict in self.chartView.seriesArray)
    {
        if([dict[@"name"] isEqualToString:name])
        {
            if(dict[@"category"] == nil){
                dict[@"category"] = [[NSMutableArray alloc] init];
            }
            
            [dict[@"category"] addObjectsFromArray:category];
        }
    }
}

- (void)setCategory:(NSMutableArray *)category forName:(NSString *)name
{
    for(NSMutableDictionary *dict in self.chartView.seriesArray)
    {
        if([dict[@"name"] isEqualToString:name]){
            dict[@"category"] = category;
        }
    }
}

-(void)clearCategoryforName:(NSString *)name
{
    for(NSMutableDictionary *dict in self.chartView.seriesArray){
        if([dict[@"name"] isEqual:name])
        {
            NSMutableArray *category = dict[@"category"];
            
            if(category != nil){
                [category removeAllObjects];
            }
        }
    }
}

- (void)clearCategory
{
    for(NSMutableDictionary *dict in self.chartView.seriesArray)
    {
        [dict[@"category"] removeAllObjects];
    }
}

@end
