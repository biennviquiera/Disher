//
//  ListContentViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/19/22.
//

#import "ListContentViewController.h"
#import "ListContentCell.h"
#import "Parse/Parse.h"
#import "Recipe.h"
#import "UIKit+AFNetworking.h"


@interface ListContentViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *listName;
@property (weak, nonatomic) IBOutlet UIImageView *listImg;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ListContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.listName.text = self.passedList.listName;
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.passedList.recipes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListContentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ListContentCell"];
    NSString *recipeID = (NSString *)self.passedList.recipes[indexPath.row];
    Recipe *currRecipe = [Recipe getRecipeWithID:recipeID];
    cell.recipe = currRecipe;
    cell.nameLabel.text = currRecipe.dishName;
    cell.recipeSource.text = currRecipe.source;
    NSURL *imageURL = [NSURL URLWithString:currRecipe.imageURL];
    [cell.recipeImg setImageWithURL:imageURL];
    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadListRecipes];
    [self.tableView reloadData]; // to reload selected cell
}

- (void) reloadListRecipes {
    NSString *listID = self.passedList.objectId;
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    self.passedList = [query getObjectWithId:listID];
}


/*
#pragma mark - Navigation
//TODO: Pass data from id lookup
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
