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
#import "CreateListViewController.h"

@interface SaveViewController () <UITableViewDelegate, UITableViewDataSource, SaveDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *listName;
@property (nonatomic, strong) NSMutableArray *lists;
@end

@implementation SaveViewController
- (IBAction)didTapCreate:(id)sender {
    [self performSegueWithIdentifier:@"saveToCreateSegue" sender:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.lists = [NSMutableArray new];
    [self.lists setArray:[List queryLists]];
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
    List *selectedList = self.lists[indexPath.row];
    PFQuery *query = [PFQuery queryWithClassName:@"Recipe"];
    [query whereKey:@"recipeID" equalTo:selectedRecipe.recipeID];
    [query whereKey:@"dishName" equalTo:selectedRecipe.dishName];
    [query whereKey:@"source" equalTo:selectedRecipe.source];
    Recipe *foundObject = [query getFirstObject];
    if (foundObject) {
        [self uploadRecipeToList:foundObject withList:selectedList];
    }
    else {
        [selectedRecipe saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self uploadRecipeToList:selectedRecipe withList:selectedList];
        }];
    }
}

- (void) uploadRecipeToList:(Recipe *)recipe withList:(List *)list {
    [list addUniqueObject:recipe.objectId forKey:@"recipes"];
    [list saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else { //TODO: alert user
            NSLog(@"Could not upload recipe to list");
        }
    }];
}

// delegate methods for creating a new list inside of the save view controller
- (void) didCreateList {
    [self refreshData];
}

- (void) refreshData {
    [self.lists setArray:[List queryLists]];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"saveToCreateSegue"]) {
        CreateListViewController *newVC = [segue destinationViewController];
        newVC.saveDelegate = self;
    }
}


@end
