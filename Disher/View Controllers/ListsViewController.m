//
//  ListsViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/6/22.
//

#import "ListsViewController.h"
#import "CreateListViewController.h"
#import "ListCell.h"
#import "List.h"

@interface ListsViewController () <UITableViewDelegate, UITableViewDataSource, ListDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *lists;
@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self queryLists];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    List *currentList = self.lists[indexPath.row];
    cell.listName.text = currentList[@"listName"];
    return cell;
}

- (void) queryLists {
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    [query orderByDescending:@"updatedAt"];
    [query includeKey:@"listName"];
    [query includeKey:@"recipes"];
    [query includeKey:@"objectID"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            self.lists = objects;
            [self.tableView reloadData];
        }
        else {
            
        }
    }];
}

- (void) didCreateList:(NSString *) listName {
    [self refreshData];
}

- (void) refreshData {
    [self queryLists];
    [self.tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([[segue identifier] isEqualToString:@"createSegue"]) {
        CreateListViewController *newVC = [segue destinationViewController];
        newVC.delegate = self;
    }
}


@end
