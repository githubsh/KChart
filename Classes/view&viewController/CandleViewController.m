//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//  //  @"©2011 https://github.com/zhiyu/chartee";

#import "CandleViewController.h"
#import "CandleViewController+Data.h"
#import "JSONKit.h"
#import "ResourceHelper.h"
#import "ASIHTTPRequest.h"

@implementation CandleViewController

//  创建按钮
- (UIButton *)createButtonWithTag:(NSUInteger)tag
                            frame:(CGRect)frame
                       imageNamed:(NSString *)imageName
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    button.frame = frame;
    [button setImage:[ResourceHelper loadImage:imageName] forState:UIControlStateNormal];
    [button setImage:[ResourceHelper loadImage:[imageName stringByAppendingFormat:@"_%@",@"selected"]] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//  切换周期
- (void)addFreqView
{
    self.freqView = [[UIView alloc] initWithFrame:CGRectMake(80, -160, 120, 120)];//先隐藏在上面
    [self.freqView setBackgroundColor:[[UIColor alloc] initWithRed:0/255.f green:0/255.f blue:255/255.f alpha:1]];
    [self.view addSubview:self.freqView];
    
    //  一天
    [self.freqView addSubview:
     [self createButtonWithTag:kBtnType1d frame:CGRectMake(0, 0, 120, 40) imageNamed:@"k1d"]];
    
    //  一周
    [self.freqView addSubview:
     [self createButtonWithTag:kBtnType1w frame:CGRectMake(0,40, 120, 40) imageNamed:@"k1w"]];
    
    //  一月
    [self.freqView addSubview:
     [self createButtonWithTag:kBtnType1m frame:CGRectMake(0,80, 120, 40) imageNamed:@"k1m"]];
}

//  搜索条
- (void)addTopView
{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    [self.view addSubview:self.topView];
    
    //  status label
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 200, 40)];
    self.statusLabel.font = [UIFont systemFontOfSize:15];
    self.statusLabel.backgroundColor = [UIColor redColor];
    self.statusLabel.textColor = [UIColor whiteColor];
    [self.topView addSubview:self.statusLabel];
    
    //  searchBar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.topView.frame.size.width-250, 0, 250, 40)];
    [searchBar setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0]];
    searchBar.delegate = self.autoCompleteTableDelegate;
    if ([searchBar respondsToSelector:@selector(barTintColor)]) {
        [searchBar setBarTintColor:[UIColor clearColor]];
    }
    searchBar.barStyle = UIBarStyleBlackTranslucent;
    searchBar.placeholder = @"输入证券代码";
    searchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    searchBar.autocapitalizationType = NO;
    [self.topView addSubview:searchBar];
    self.searchBar = searchBar;
    
    //  选择品种 菜单按钮
    [self.topView addSubview:
     [self createButtonWithTag:kBtnTypeSel frame:CGRectMake(0,0, 80, 40) imageNamed:@"candle_chart"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    /// 竖屏专用 宽高对调
//    self.view.frame = CGRectMake(0,
//                                 0,
//                                 [[UIScreen mainScreen] bounds].size.height,
//                                 [[UIScreen mainScreen] bounds].size.width);
    
    self.view.backgroundColor = [UIColor blackColor];
    
	//  notification addObserver
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //  autocompTime = nil
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:nil forKey:@"autocompTime"];
    [ud synchronize];
	
    //  图表视图
    self.chartView = [[ChartView alloc]init];//init中 resetData initModels
    self.chartView.frame = CGRectMake(0,
                                      40,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height-40);
    self.chartView.multipleTouchEnabled = YES;
    
	[self.view addSubview:self.chartView];

    //  搜索条
    [self addTopView];

    //  切换周期
    [self addFreqView];
    
    //  初始化表格
    [self initChart];
    
    //  搜索
	self.autoCompleteTableDelegate = [[AutoCompleteTableDelegate alloc]initWithBar:self.searchBar];

	self.autoCompleteTableView = [[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-240, 40,240, 0)];
	self.autoCompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.autoCompleteTableView.showsVerticalScrollIndicator = YES;
    self.autoCompleteTableView.dataSource = self.autoCompleteTableDelegate; //数据源 设置成别的类
	self.autoCompleteTableView.delegate = self.autoCompleteTableDelegate;   //代理 设置成别的类
	self.autoCompleteTableView.hidden = YES;//
	[self.view addSubview:self.autoCompleteTableView];
	
    //  加载股市代码基本资料
    
    //  init vars
    self.chartMode  = kChartModeCandleVolumeIndicators;
    self.tradeStatus= kTradeStatusOpen;
    self.req_freq   = @"d";
    self.req_type   = @"H";
    self.req_url_format = @"http://ichart.yahoo.com/table.csv?s=%@&g=%@";
    
    [self getAutoCompleteData];
    
    //  加载默认股票代码并执行搜索功能
    self.searchBar.text = @"中信证券（600030.SS）";
	[self searchBarSearchButtonClicked:self.searchBar];
}

-(void)initChart
{
    //(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
	self.chartView.paddingArray = [NSMutableArray arrayWithObjects:@"20",@"5",@"20",@"5",nil];

    //  添加section
	[self.chartView addSectionsCount:3 withRatios:@[@"4",@"1",@"1"]];
//    for (int i=0; i < 3; i++)
//    {
//        Section *sec = [[Section alloc]init];//init中resetData
//        [self.chartView.sectionsArray addObject:sec];
//        [self.chartView.sectionsRatiosArray addObject:@[@"4",@"1",@"1"][i]];
//    }
    
    //  添加Y轴
    Section *sec = self.chartView.sectionsArray[0];
    [sec addYAxis:0];
//    YAxis *yaxis = [[YAxis alloc] init];
//    yaxis.pos = 0;
//    [sec.yAxisesArray addObject:yaxis];
    sec = self.chartView.sectionsArray[1];
    [sec addYAxis:0];
    
    sec = self.chartView.sectionsArray[2];
    sec.isHidden = YES;//  section2 指标区隐藏
    [sec addYAxis:0];
	
    YAxis *yaxis = [self.chartView getYAxisInSection:2 atIndex:0];
//    Section *sec = self.chartView.sectionsArray[2];
//    YAxis *yaxis = sec.yAxisesArray[0];
    yaxis.isBaseValueSticky = NO;   //基值固定      NO
    yaxis.isSymmetrical     = NO;   //对称的,均匀的  NO
    
    yaxis = [self.chartView getYAxisInSection:0 atIndex:0];
	yaxis.extend = 0.05;//放大倍数
    
    //  配置参数序列
	NSMutableArray *secOne = [[NSMutableArray alloc] init];
    NSMutableArray *secTwo = [[NSMutableArray alloc] init];
    
    #pragma mark secOne
    
    //price
	NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
    {
        serie[@"name"]                  = @"price";
        serie[@"label"]                 = @"Price";
        serie[@"data"]                  = [[NSMutableArray alloc] init];
        serie[@"type"]                  = @"candle";
        serie[@"yAxis"]                 = @"0";
        serie[@"section"]               = @"0";
        serie[@"color"]                 = @"249,222,170";
        serie[@"negativeColor"]         = @"249,222,170";
        serie[@"selectedColor"]         = @"249,222,170";
        serie[@"negativeSelectedColor"] = @"249,222,170";
        serie[@"labelColor"]            = @"176,52,52";
        serie[@"labelNegativeColor"]    = @"77,143,42";
    }
    [secOne addObject:serie];
	
	//MA10
	serie = [[NSMutableDictionary alloc] init];
    {
        serie[@"name"]                  = @"ma10";
        serie[@"label"]                 = @"MA10";
        serie[@"data"]                  = [[NSMutableArray alloc] init];
        serie[@"type"]                  = @"line";
        serie[@"yAxis"]                 = @"0";
        serie[@"section"]               = @"0";
        serie[@"color"]                 = @"255,255,255";
        serie[@"negativeColor"]         = @"255,255,255";
        serie[@"selectedColor"]         = @"255,255,255";
        serie[@"negativeSelectedColor"] = @"255,255,255";
    }
	[secOne addObject:serie];
    
	//MA30
	serie = [[NSMutableDictionary alloc] init];
    {
        serie[@"name"]                  = @"ma30";
        serie[@"label"]                 = @"MA30";
        serie[@"data"]                  = [[NSMutableArray alloc] init];
        serie[@"type"]                  = @"line";
        serie[@"yAxis"]                 = @"0";
        serie[@"section"]               = @"0";
        serie[@"color"]                 = @"250,232,115";
        serie[@"negativeColor"]         = @"250,232,115";
        serie[@"selectedColor"]         = @"250,232,115";
        serie[@"negativeSelectedColor"] = @"250,232,115";
    }
	[secOne addObject:serie];
	
	//MA60
	serie = [[NSMutableDictionary alloc] init];
    {
        serie[@"name"]                  = @"ma60";
        serie[@"label"]                 = @"MA60";
        serie[@"data"]                  = [[NSMutableArray alloc] init];
        serie[@"type"]                  = @"line";
        serie[@"yAxis"]                 = @"0";
        serie[@"section"]               = @"0";
        serie[@"color"]                 = @"232,115,250";
        serie[@"negativeColor"]         = @"232,115,250";
        serie[@"selectedColor"]         = @"232,115,250";
        serie[@"negativeSelectedColor"] = @"232,115,250";
    }
	[secOne addObject:serie];

    #pragma mark secTwo
    
	//VOL
	serie = [[NSMutableDictionary alloc] init];
    {
        serie[@"name"]                  = @"vol";
        serie[@"label"]                 = @"VOL";
        serie[@"data"]                  = [[NSMutableArray alloc] init];
        serie[@"type"]                  = @"volume";
        serie[@"yAxis"]                 = @"0";
        serie[@"section"]               = @"1";
        serie[@"decimal"]               = @"0";
        serie[@"color"]                 = @"176,52,52";
        serie[@"negativeColor"]         = @"77,143,42";
        serie[@"selectedColor"]         = @"176,52,52";
        serie[@"negativeSelectedColor"] = @"77,143,42";
    }
	[secTwo addObject:serie];
    
    //  series
    NSMutableArray *series = [[NSMutableArray alloc] init];
    [series addObjectsFromArray:secOne];
    [series addObjectsFromArray:secTwo];
    
    //NSLog(@"secOne=%@",secOne);
    //NSLog(@"secTwo=%@",secTwo);
    //NSLog(@"series=%@",series);
    
    /*
     series=(
         {
             color = "249,222,170";
             data =         (
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
         },
         {
             color = "255,255,255";
             data =         (
             );
             label = MA10;
             name = ma10;
             negativeColor = "255,255,255";
             negativeSelectedColor = "255,255,255";
             section = 0;
             selectedColor = "255,255,255";
             type = line;
             yAxis = 0;
         },
         {
             color = "250,232,115";
             data =         (
             );
             label = MA30;
             name = ma30;
             negativeColor = "250,232,115";
             negativeSelectedColor = "250,232,115";
             section = 0;
             selectedColor = "250,232,115";
             type = line;
             yAxis = 0;
         },
         {
             color = "232,115,250";
             data =         (
             );
             label = MA60;
             name = ma60;
             negativeColor = "232,115,250";
             negativeSelectedColor = "232,115,250";
             section = 0;
             selectedColor = "232,115,250";
             type = line;
             yAxis = 0;
         },
         {
             color = "176,52,52";
             data =         (
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
     )
     
     secOne=(
         {
             color = "249,222,170";
             data =         (
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
         },
         {
             color = "255,255,255";
             data =         (
             );
             label = MA10;
             name = ma10;
             negativeColor = "255,255,255";
             negativeSelectedColor = "255,255,255";
             section = 0;
             selectedColor = "255,255,255";
             type = line;
             yAxis = 0;
         },
         {
             color = "250,232,115";
             data =         (
             );
             label = MA30;
             name = ma30;
             negativeColor = "250,232,115";
             negativeSelectedColor = "250,232,115";
             section = 0;
             selectedColor = "250,232,115";
             type = line;
             yAxis = 0;
         },
         {
             color = "232,115,250";
             data =         (
             );
             label = MA60;
             name = ma60;
             negativeColor = "232,115,250";
             negativeSelectedColor = "232,115,250";
             section = 0;
             selectedColor = "232,115,250";
             type = line;
             yAxis = 0;
         }
     )
     
     secTwo=(
         {
             color = "176,52,52";
             data =         (
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
     )
     */
    
#pragma mark secThree
    //(未加入seriesArray中)
    NSMutableArray *secThree = [[NSMutableArray alloc] init];
    
    //  总序列
    self.chartView.seriesArray = series;

    //  section0
    Section *section = self.chartView.sectionsArray[0];
    section.seriesArray = secOne;
    
    //  section1
    section = self.chartView.sectionsArray[1];
    section.seriesArray = secTwo;
    
    //  section2
    section = self.chartView.sectionsArray[2];
    section.seriesArray = secThree;
    section.isPaging = YES;//指标区分页
	
    //  指标序列
    NSString *path = [[NSBundle mainBundle] pathForResource:@"indicators" ofType:@"json"];
    
	NSString *indicatorsString =
    [NSString stringWithContentsOfFile:path
                              encoding:NSUTF8StringEncoding error:nil];
    
	if(indicatorsString != nil)
    {
		id indicators = [indicatorsString objectFromJSONString];
        //NSLog(@"indicators=%@",indicators);
        
		for(id indicator in indicators)//array2 array3 dict dict
        {
			if([indicator isKindOfClass:[NSArray class]])
            {
				NSMutableArray *arr = [[NSMutableArray alloc] init];
                
				for(NSDictionary *indic in indicator)
                {
					NSMutableDictionary *serie = [[NSMutableDictionary alloc] init]; 
                    [self setSerie:serie fromOptions:indic];
					[arr addObject:serie];
				}
                [self.chartView addSerie:arr];
			}
            else if([indicator isKindOfClass:[NSDictionary class]])
            {
				NSDictionary *indic = (NSDictionary *)indicator;
				NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
                [self setSerie:serie fromOptions:indic];
				[self.chartView addSerie:serie];
			}
		}
	}

    /*
    //  总序列
    NSLog(@"self.chartView.seriesArray=%@",self.chartView.seriesArray);
    //  总分区
    NSLog(@"self.chartView.sectionsArray=%@",self.chartView.sectionsArray);
    //  每个分区序列
    for (Section *sec in self.chartView.sectionsArray) {
        NSLog(@"sec.seriesArray=%@",sec.seriesArray);
    }
     */
    
    //  表示 这里我们分3个点说明动画的顺序  strokeEnd从结尾开始清除 首先整条路径先清除后2/3，接着清除1/3 效果就是正方向画出路径
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 10.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.chartView.layer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
}

-(void)setSerie:(NSMutableDictionary *)serie fromOptions:(NSDictionary *)options;
{
    serie[@"name"]                  = options[@"name"];
    serie[@"label"]                 = options[@"label"];
    serie[@"type"]                  = options[@"type"];
    serie[@"yAxis"]                 = options[@"yAxis"];
    serie[@"section"]               = options[@"section"];
    serie[@"color"]                 = options[@"color"];
    serie[@"negativeColor"]         = options[@"negativeColor"];
    serie[@"selectedColor"]         = options[@"selectedColor"];
    serie[@"negativeSelectedColor"] = options[@"negativeSelectedColor"];
}

#pragma mark - willEnterForegroundNotification
//通知回调函数 由后台->前台
- (void)willEnterForegroundNotification:(NSNotification *)notification
{
    UIButton *selBtn = (UIButton *)[self.topView viewWithTag:kBtnTypeNotification];//1
    
    NSLog(@"selBtn=%@",selBtn);//selBtn=(null)
    [self buttonPressed:selBtn];
}

//  切换周期按钮点击
-(void)buttonPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
	int tag = btn.tag;
	btn.selected = YES;
    
	if(tag != kBtnTypeSel)//收起 self.freqView
    {
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
        {
            CGRect rect = self.freqView.frame;
            rect.origin.y = -160;
            self.freqView.frame = rect;
        }
		[UIView commitAnimations];
	}
	
	if(kBtnType1d <= tag && tag <= kBtnType1m)
    {
		for (UIView *subview in self.freqView.subviews)
        {
			UIButton *btn = (UIButton *)subview;
			btn.selected = NO;
		}
	}
	
    switch (tag)
    {
		case kBtnTypeNotification:{
			UIButton *sel = (UIButton *)[self.topView viewWithTag:kBtnTypeSel];
			sel.selected    = NO;
			self.chartMode  = kChartModeCandleVolume;
			self.req_freq   = @"1m";
			self.req_type   = @"T";
            
			[self getDataFromServer];
			break;
	    }
        case kBtnTypeSel:{
			UIButton *sel = (UIButton *)[self.topView viewWithTag:kBtnTypeNotification];
			sel.selected = NO;
            
			CGContextRef context = UIGraphicsGetCurrentContext();
			[UIView beginAnimations:nil context:context];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:0.3];
            {
                CGRect rect = [self.freqView frame];
                if(rect.origin.y == 0){
                    rect.origin.y = - 160;
                    [self.freqView setFrame:rect];
                }else{
                    rect.origin.y =  0;
                    [self.freqView setFrame:rect];
                    btn.selected = NO;
                    sel.selected = NO;
                }
            }
			[UIView commitAnimations];
			break;
		}
        //  切换周期
        case kBtnType1d:{
			UIButton *sel = (UIButton *)[self.topView viewWithTag:2];
			sel.selected = NO;
			self.chartMode  = kChartModeCandleVolumeIndicators;
			self.req_freq   = @"d";
			self.req_type   = @"H";
            
			[self getDataFromServer];
			break;
	    }
		case kBtnType1w:{
			UIButton *sel = (UIButton *)[self.topView viewWithTag:2];
			sel.selected = NO;
			self.chartMode  = kChartModeCandleVolumeIndicators;
			self.req_freq   = @"w";
			self.req_type   = @"H";
            
			[self getDataFromServer];
			break;
	    }
		case kBtnType1m:{
			UIButton *sel = (UIButton *)[self.topView viewWithTag:2];
			sel.selected = NO;
			self.chartMode  = kChartModeCandleVolumeIndicators;
			self.req_freq   = @"m";
			self.req_type   = @"H";
            
			[self getDataFromServer];
			break;
	    }
//		case 50:{
//			UIGraphicsBeginImageContext(self.chartView.bounds.size);
//			[self.chartView.layer renderInContext:UIGraphicsGetCurrentContext()];
//			UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();    
//			UIGraphicsEndImageContext();
//			UIImageWriteToSavedPhotosAlbum(anImage,nil,nil,nil);
//			break;
//	    }
		default:
			break;
    }
}

- (void)getAutoCompleteData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"securities" ofType:@"json"];
    NSString *securities = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *array = [securities mutableObjectFromJSONString];
    
    //NSLog(@"array=%@",array);
    
    self.autoCompleteTableDelegate.items = array;
}

#pragma mark - UISearchBarDelegate

//  文字开始编辑

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.autoCompleteTableDelegate.selectedItems = self.autoCompleteTableDelegate.items.mutableCopy;
    self.autoCompleteTableView.hidden = NO;
	
	if([self isCodesExpired])
    {
	    [self getAutoCompleteData];
	}
    
    //  显示  autoCompleteTableView
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
    {
        [self showAutoCompleteTableView];
    }
	[UIView commitAnimations];
}

- (BOOL)isCodesExpired
{
    NSDate *date = [NSDate date];
    double now = [date timeIntervalSince1970];
    double last = now;
    NSString *autocompTime = (NSString *)[ResourceHelper getUserDefaults:@"autocompTime"];
    if(autocompTime != nil)
    {
        last = autocompTime.doubleValue;
        if(now - last > 3600*8){
            return YES;
        } else {
            return NO;
        }
    }
    else
    {
        return YES;
    }
}

//  文字已经改变
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self.autoCompleteTableDelegate.selectedItems removeAllObjects];
    for(NSArray *item in self.autoCompleteTableDelegate.items)
    {
	    if([item[0] hasPrefix:searchText]){
			[self.autoCompleteTableDelegate.selectedItems addObject:item];
		}
	}
	[self.autoCompleteTableView reloadData];
}

//  文字结束编辑
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //  隐藏
    [self hideAutoCompleteTableView];
    
    if(![searchBar.text isEqualToString:@""]){
        //["600695.SS","多伦股份"]
        //  多伦股份(600695.SS)
        
        NSArray *arr = [searchBar.text componentsSeparatedByString:@"（"];
        NSArray *arr2 = [arr[1] componentsSeparatedByString:@"）"];
        self.req_security_id = arr2[0];
        [self getDataFromServer];
    }
}

//  点击取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    NSLog(@"searchBarCancelButtonClicked");
}

//  搜索按钮点击
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
    
    //["600695.SS","多伦股份"]
    //  多伦股份(600695.SS)
    
    self.req_security_id = [[searchBar.text componentsSeparatedByString:@"（"][1] componentsSeparatedByString:@"）"][0];
	//  600695.SS
    NSLog(@"req_security_id=%@",self.req_security_id);
    
    [self getDataFromServer];
}

- (void)hideAutoCompleteTableView
{
    CGRect rect = self.autoCompleteTableView.frame;
    rect.size.height = 0;
    self.autoCompleteTableView.frame = rect;
    self.autoCompleteTableView.hidden = YES;
}

- (void)showAutoCompleteTableView
{
    CGRect rect = self.autoCompleteTableView.frame;
    rect.size.height = 300;
    self.autoCompleteTableView.frame = rect;
}

#pragma mark - autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    return;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.timer invalidate];
}

@end
