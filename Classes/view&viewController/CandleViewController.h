//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "ChartView.h"
#import "YAxis.h"
#import "AutoCompleteTableDelegate.h"

typedef NS_ENUM(NSInteger, BtnType) {
    kBtnTypeNotification = 1,
    kBtnTypeSel = 2,
    kBtnType1d = 26,//一天
    kBtnType1w = 27,//一周
    kBtnType1m = 28,//一月
};

typedef NS_ENUM(NSInteger, TradeStatus) {//交易状态
    kTradeStatusOpen = 1,   //开盘
    kTradeStatusClose = 0,  //收盘
};

typedef NS_ENUM(NSInteger, ChartMode) {     //图表类型
    kChartModeCandleVolume = 0,             //蜡烛图 成交量
    kChartModeCandleVolumeIndicators = 1,   //蜡烛图 成交量 副图指标
};

@interface CandleViewController : UIViewController<UISearchBarDelegate>

@property (nonatomic,strong) ChartView                  *chartView;
@property (nonatomic,strong) UITableView                *autoCompleteTableView;
@property (nonatomic,strong) UIView                     *topView;
@property (nonatomic,strong) UISearchBar                *searchBar;
@property (nonatomic,strong) UIView                     *freqView;
@property (nonatomic,strong) AutoCompleteTableDelegate  *autoCompleteTableDelegate;
@property (nonatomic,strong) UILabel                    *statusLabel;

@property (nonatomic,strong) NSTimer                    *timer;

@property (nonatomic) ChartMode chartMode;
@property (nonatomic) TradeStatus tradeStatus;

@property (nonatomic,copy) NSString                     *lastTime;
@property (nonatomic,copy) NSString                     *offlineContentString;

@property (nonatomic,copy) NSString                     *req_freq;//周期
@property (nonatomic,copy) NSString                     *req_type;//请求类型  @"H" @"T" @"L"
@property (nonatomic,copy) NSString                     *req_url_format;//网址
@property (nonatomic,copy) NSString                     *req_security_id;//股票代码

@end
