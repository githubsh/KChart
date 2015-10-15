//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "AutoCompleteTableDelegate.h"

@implementation AutoCompleteTableDelegate

#pragma mark - 初始化SearchBar

- (id)initWithBar:(UISearchBar *)bar
{
	if(self = [super init])
    {
		self.searchBar = bar;
	}
	return self;
}

#pragma mark - UITableViewDataSource
//  组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//  行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"autoCompleteTableView self.selectedItems=%@",self.selectedItems);
    return self.selectedItems.count;
}

//  单元格 cellForRowAtIndexPath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
		CGRect cellFrame = cell.frame;
        cell.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, 20);
        cell.textLabel.font = [UIFont systemFontOfSize:16];
		cell.showsReorderControl = YES;
    }
	
	cell.textLabel.backgroundColor = [UIColor clearColor];

	if (self.selectedItems != nil) {
        NSUInteger row = indexPath.row;
        NSString *str = self.selectedItems[row][1];
        NSString *str2 = self.selectedItems[row][0];
	    cell.textLabel.text = [str stringByAppendingFormat:@"   %@",str2];
	} else {
		cell.textLabel.text = @"正在加载数据...";
	}
    return cell;
}

#pragma mark - UITableViewDelegate

//  将显示单元格 willDisplayCell
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2 ==0){
		cell.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:1];
	} else {
		cell.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:0 alpha:1];
	}
}

//  选中行 didSelectRowAtIndexPath
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//  附属按钮点击 accessoryButtonTappedForRowWithIndexPath
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString *str = self.selectedItems[row][1];
    NSString *str2 = self.selectedItems[row][0];
    self.searchBar.text = [str stringByAppendingFormat:@"（%@）",str2];
}

@end

