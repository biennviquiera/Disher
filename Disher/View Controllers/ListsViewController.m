//
//  ListsViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/6/22.
//

#import "ListsViewController.h"
#import "CreateListViewController.h"
#import "ListContentViewController.h"
#import "ListCell.h"
#import "List.h"
#import "Parse/Parse.h"

@interface ListsViewController () <UITableViewDelegate, UITableViewDataSource, ListDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *lists;
@property(nonatomic,strong) UIRefreshControl *refreshControl;
@end

@implementation ListsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.031 green:0.403 blue:0.533 alpha:1.000];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.rightBarButtonItem = nil;
    self.lists = [NSMutableArray new];
    [self.lists setArray:[List queryLists]];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    List *currentList = self.lists[indexPath.row];
    cell.listName.text = currentList[@"listName"];
    cell.list = currentList;
    cell.listImage.file = currentList[@"listImage"];
    [cell.listImage loadInBackground];
    return cell;
}
- (void)didCreateList {
    [self refreshData];
}
- (void)refreshData {
    [self.lists setArray:[List queryLists]];
    [self.tableView reloadData];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFQuery *query = [PFQuery queryWithClassName:@"List"];
        List *listToRemove = [query getObjectWithId:((ListCell *)[self.tableView cellForRowAtIndexPath:indexPath]).list.objectId];
        [listToRemove deleteInBackground];
        [self.lists removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}
- (void)beginRefresh:(UIRefreshControl *) refreshControl {
    [refreshControl beginRefreshing];
    [self refreshData];
    [refreshControl endRefreshing];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createSegue"]) {
        CreateListViewController *newVC = [segue destinationViewController];
        newVC.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"listContentSegue"]) {
        ListContentViewController *newVC = [segue destinationViewController];
        newVC.passedList = ((ListCell *)sender).list;
        newVC.listDelegate = self;
        newVC.hidesBottomBarWhenPushed = YES;
    }
}
@end
