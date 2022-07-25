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
#import "ListContentCell.h"
#import "UIKit+AFNetworking.h"
#import "RecipeInListViewController.h"

@interface ListContentViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *listName;
@property (weak, nonatomic) IBOutlet UIImageView *listImg;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *recipeListIDs;
@property (strong, nonatomic) NSArray *recipeList;

@end

@implementation ListContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.listName.text = self.passedList.listName;
    self.recipeListIDs = self.passedList.recipes;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.passedList.recipes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListContentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ListContentCell"];
    Recipe *currRecipe = self.recipeList[indexPath.row];
    cell.recipe = currRecipe;
    cell.nameLabel.text = currRecipe.dishName;
    cell.recipeSource.text = currRecipe.source;
    NSURL *imageURL = [NSURL URLWithString:currRecipe.imageURL];
    [cell.recipeImg setImageWithURL:imageURL];
    return cell;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PFQuery *new = [PFQuery queryWithClassName:@"List"];
    self.passedList = [new getObjectWithId:self.passedList.objectId];
    self.recipeListIDs = self.passedList.recipes;
    [self reloadListRecipes:(id)nil completionHandler:^(NSArray *returnedRecipes) {
        self.recipeList = returnedRecipes;
        [self.tableView reloadData];
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Recipe *selectedRecipe = ((ListContentCell *)[self.tableView cellForRowAtIndexPath:indexPath]).recipe;
    [self performSegueWithIdentifier:@"listRecipeSegue" sender:selectedRecipe];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFQuery *query = [PFQuery queryWithClassName:@"List"];
        List *listToUpdate = [query getObjectWithId:self.passedList.objectId];
        NSString *recipeToRemove = ((ListContentCell *)[self.tableView cellForRowAtIndexPath:indexPath]).recipe.objectId;
        [listToUpdate removeObject:recipeToRemove forKey:@"recipes"];
        [listToUpdate saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self viewWillAppear:YES];
        }];
    }
}

- (void) reloadListRecipes:(id)something completionHandler:(void(^)(NSArray *returnedRecipes))completionHandler{
    PFQuery *query = [PFQuery queryWithClassName:@"Recipe"];
    [query whereKey:@"objectId" containedIn:self.recipeListIDs];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            completionHandler(objects);
        }
    }];
}



#pragma mark - Navigation
//TODO: Pass data from id lookup
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"listRecipeSegue"]) {
        RecipeInListViewController *newVC = [segue destinationViewController];
        newVC.passedRecipe = sender;
    }
    
}


@end
