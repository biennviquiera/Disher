//
//  SaveViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/14/22.
//

#import "SaveViewController.h"
#import "List.h"
#import "SaveCell.h"
#import "Parse/Parse.h"

@interface SaveViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *listName;
@property (nonatomic, strong) NSArray *lists;
@end

@implementation SaveViewController
- (IBAction)didTouchExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.lists = [List queryLists];
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SaveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaveCell" forIndexPath:indexPath];
    List *currentList = self.lists[indexPath.row];
    cell.list = currentList;
    cell.listName.text = currentList[@"listName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Recipe *selectedRecipe = self.passedRecipe;
    PFQuery *query = [PFQuery queryWithClassName:@"Recipe"];
    [query whereKey:@"recipeID" equalTo:selectedRecipe.recipeID];
    [query whereKey:@"dishName" equalTo:selectedRecipe.dishName];
    [query whereKey:@"source" equalTo:selectedRecipe.source];

    Recipe *foundObject = [query getFirstObject];
    if (foundObject) {
        List *selectedList = self.lists[indexPath.row];
        [selectedList addUniqueObject:foundObject.objectId forKey:@"recipes"];
        [selectedList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
    else {
        [selectedRecipe saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            List *selectedList = self.lists[indexPath.row];
            [selectedList addUniqueObject:selectedRecipe.objectId forKey:@"recipes"];
            [selectedList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }];
    }
}


@end
