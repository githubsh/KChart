//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

@interface AutoCompleteTableDelegate : NSObject <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UISearchBar * searchBar;

@property (nonatomic, strong) NSMutableArray * items;//所有数据
@property (nonatomic, strong) NSMutableArray * selectedItems;//数据源(搜索结果)

- (id)initWithBar:(UISearchBar *) bar;

@end
