//
//  ListContentViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/19/22.
//

#import "ListContentViewController.h"
#import "ListContentCell.h"
#import <Parse/Parse.h>
#import "Recipe.h"
#import "ListContentCell.h"
#import "UIKit+AFNetworking.h"
#import "RecipeInListViewController.h"
#import "ListsViewController.h"
#import "EditListNameViewController.h"

@import Parse;

@interface ListContentViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ListContentDelegate>
@property (weak, nonatomic) IBOutlet UILabel *listName;
@property (weak, nonatomic) IBOutlet PFImageView *listImg;
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
    UILongPressGestureRecognizer *photoHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self  action:@selector(heldPhoto:)];
    [self.listImg addGestureRecognizer:photoHold];
    photoHold.minimumPressDuration = 0.5;
    
    if (self.passedList[@"listImage"]) {
        self.listImg.file = self.passedList[@"listImage"];
        [self.listImg loadInBackground];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.passedList.recipes.count;
}
- (void) heldPhoto:(UILongPressGestureRecognizer *)gesture {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    List *currentList = self.passedList;
    [self.listImg setImage:editedImage];
    PFFileObject *img = [PFFileObject fileObjectWithName:@"listImage.png" data:UIImagePNGRepresentation(editedImage)];
    currentList[@"listImage"] = img;
    [currentList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.listDelegate didCreateList];
    }];
    self.listImg.file = currentList[@"listImage"];
    [self.listImg loadInBackground];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self reloadListRecipesWithBlock:^(NSArray *returnedRecipes) {
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
- (void)reloadListRecipesWithBlock:(void(^)(NSArray *returnedRecipes))completionHandler{
    PFQuery *query = [PFQuery queryWithClassName:@"Recipe"];
    [query whereKey:@"objectId" containedIn:self.recipeListIDs];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            completionHandler(objects);
        }
    }];
}
- (void)didUpdateName:(NSString *)name withImage:(UIImage *)image{
    self.listName.text = name;
    self.listImg.image = image;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"listRecipeSegue"]) {
        RecipeInListViewController *newVC = [segue destinationViewController];
        newVC.passedRecipe = sender;
    }
    if ([[segue identifier] isEqualToString:@"editListNameSegue"]) {
        EditListNameViewController *newVC = [segue destinationViewController];
        newVC.listContentDelegate = self;
        newVC.passedListID = self.passedList.objectId;
        newVC.listDelegate = self.listDelegate;
        newVC.passedImage = self.listImg.image;
        newVC.passedListName = self.listName.text;
    }
}
@end
