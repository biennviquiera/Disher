//
//  RecipesViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/6/22.
//

#import "RecipesViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "RecipeCell.h"
#import "UIKit+AFNetworking.h"
#import "Recipe.h"
#import "DetailViewController.h"
#import "SaveViewController.h"
#import "INSSearchBar.h"

@interface RecipesViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UITableViewDelegate, INSSearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) NSArray *mealDBresults;
@property (nonatomic, strong) NSArray *spoonResults;
@property (nonatomic, strong) NSMutableArray<Recipe *> *tableViewRecipes;
@property (nonatomic, strong) NSString *searchQuery;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) INSSearchBar *searchBarWithDelegate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentedControl;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *cuisineField;
@property (nonatomic, strong) NSMutableArray *cuisines;
@property (nonatomic, strong) NSMutableSet *cuisinesSet;
@property (nonatomic, strong) NSArray<Recipe *> *unfilteredTableViewRecipes;
@property (nonatomic, strong) NSArray<Recipe *> *filteredTableViewRecipes;
@property NSArray *temp;
@property BOOL seenIngredientMsg;
@end

@implementation RecipesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewRecipes = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.cuisineField.delegate = self;
    self.cuisineField.tintColor = [UIColor clearColor];
    self.cuisines = [NSMutableArray new];
    self.cuisinesSet = [NSMutableSet new];
    self.searchQuery = @"chicken";
    self.cuisineField.inputView = self.pickerView;
    self.view.backgroundColor = [UIColor colorWithRed:0.000 green:0.418 blue:0.673 alpha:1.000];
    self.searchBarWithDelegate = [[INSSearchBar alloc] initWithFrame:CGRectMake(20.0, 100.0, 44.0, 34.0)];
    self.searchBarWithDelegate.delegate = self;
    [self.view addSubview:self.searchBarWithDelegate];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.searchSegmentedControl addTarget:self action:@selector(didTapSearchByIngredient:) forControlEvents:UIControlEventTouchUpInside];
    
    [self queryAPIs:self.searchQuery withOption:0 completionHandler:^{
        [self refreshData];
    }];
}
- (IBAction)didTapSearchByIngredient:(UISegmentedControl *)sender {
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    if (selectedSegment == 1 && !self.seenIngredientMsg) {
        NSString *message = @"Input ingredients separated by commas. \n ex: garlic,eggs,rice";
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ingredient Search"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        self.seenIngredientMsg = 1;
    }
}


#pragma mark - Table view data source
// Table View Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewRecipes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecipeCell" forIndexPath:indexPath];
    cell.delegate = self;
    Recipe *currRecipe = self.tableViewRecipes[indexPath.row];
    cell.recipe = currRecipe;
    cell.recipeName.text = currRecipe.dishName;
    NSURL *imageURL = [NSURL URLWithString:currRecipe.imageURL];
    [cell.recipeImage setImageWithURL:imageURL];
    cell.recipeSource.text = currRecipe.source;
    cell.rightUtilityButtons = [self rightButtons];
    return cell;
}

// Picker View Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.cuisines.count + 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"";
    }
    else {
        return self.cuisines[row - 1];
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == 0) {
        self.cuisineField.text = @"";
        [self.tableViewRecipes setArray:self.unfilteredTableViewRecipes];
        [self refreshData];
    }
    else {
        NSString *selectedCuisine = self.cuisines[row - 1];
        self.cuisineField.text = selectedCuisine;
        [self.tableViewRecipes setArray:self.unfilteredTableViewRecipes];
        self.filteredTableViewRecipes = [self.tableViewRecipes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Recipe* object, NSDictionary *bindings) {
            if ([object.cuisine containsObject:self.cuisineField.text]) {
                return YES;
            }
            else {
                return NO;
            }
        }]];
        [self.tableViewRecipes setArray:self.filteredTableViewRecipes];
        [self refreshData];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}

// Button Methods
- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        [self.logoutButton setEnabled:NO];
        if (error) { //TODO: Add error alert for logout
            [self.logoutButton setEnabled:YES];
        }
        else {
            SceneDelegate *myDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
            UIStoryboard *current = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *newVC = [current instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [UIView transitionWithView:myDelegate.window duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{myDelegate.window.rootViewController = newVC;} completion:nil];
        }
    }];
}

// API Querying Methods
- (void) queryMealDB:(NSString *)name withOption:(NSInteger)option completionHandler:(void(^)(NSArray *returnedMeals))completionHandler {
    NSURL *url;
    if (option == 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.themealdb.com/api/json/v1/1/search.php?s=%@", name]];
    }
    else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.themealdb.com/api/json/v2/9973533/filter.php?i=%@", name]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {//TODO: add error message
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dataDictionary[@"meals"] == [NSNull null] ) {
                NSLog(@"null detected from mealdb");
                completionHandler(@[]);
            }
            else {
                completionHandler(dataDictionary[@"meals"]);
            }
        }
    }];
    [task resume];
}

- (void) querySearchSpoonacular:(NSString *)name withOption:(NSInteger)option completionHandler:(void(^)(NSArray *returnedMeals))completionHandler {
    //Use API Key in Keys.plist file
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"spoon_key"];
    NSString *apiKeyArg = [NSString stringWithFormat:@"&apiKey=%@", key];
    NSString *queryURL;
    if (option == 0) {
        queryURL = [NSString stringWithFormat:@"https://api.spoonacular.com/recipes/complexSearch?query=\"%@\"%@&addRecipeInformation=TRUE", name, apiKeyArg];
        queryURL = [queryURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else {
        name = [self ingredientFormatSpoonacular:name];
        queryURL = [NSString stringWithFormat:@"https://api.spoonacular.com/recipes/findByIngredients?ingredients=\"%@\"%@", name, apiKeyArg];
        queryURL = [queryURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSURL *url = [NSURL URLWithString:queryURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) { //TODO: Add error message
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (option == 0) {
                if (![(NSArray *)dataDictionary[@"results"] count]) {
                    completionHandler(@[]);
                    NSLog(@"null detected from spoonacular");
                }
                else {
                    completionHandler(dataDictionary[@"results"]);
                }
            }
            else if (option == 1) {
                NSArray *arr = (NSArray *)dataDictionary;
                completionHandler(arr);
            }
        }
    }];
    [task resume];
}

- (void) queryAPIs:(NSString *) input withOption:(NSInteger) option completionHandler:(void(^)(void))completionHandler {
    [self.tableViewRecipes removeAllObjects];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self querySearchSpoonacular:input withOption:option completionHandler:^(NSArray *returnedMeals) {
            self.spoonResults = returnedMeals;
            NSString *recipeName;
            NSString *imageLink;
            NSString *mealID;
            NSString *source;
            NSArray<NSString *> *cuisine;
            if (option == 0) {
                for (NSDictionary *meal in returnedMeals) {
                    recipeName = meal[@"title"];
                    imageLink = meal[@"image"];
                    mealID = [NSString stringWithFormat:@"%@", meal[@"id"]];
                    source = @"Spoonacular";
                    if (((NSArray *)meal[@"cuisines"]).count) {
                        cuisine = meal[@"cuisines"];
                        for (NSString *cuisine in meal[@"cuisines"]) {
                            [self.cuisines addObject:cuisine];
                        }
                    }
                    else {
                        cuisine = @[@"Unknown"];
                        [self.cuisines addObject:@"Unknown"];
                    }
                    Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:source withID:mealID withCuisine:cuisine];
                    [self.tableViewRecipes addObject:newRecipe];
                    self.unfilteredTableViewRecipes = [self.tableViewRecipes copy];
                    [self refreshData];
                }
            }
            else if (option == 1) {
                for (NSDictionary *meal in returnedMeals) {
                    recipeName = meal[@"title"];
                    imageLink = meal[@"image"];
                    mealID = [NSString stringWithFormat:@"%@", meal[@"id"]];
                    source = @"Spoonacular";
                    [Recipe getRecipeInfo:mealID withSource:source withCompletion:^(NSDictionary * _Nonnull recipeInformation) {
                        NSArray *cuisine;
                        if (((NSArray *)recipeInformation[@"cuisines"]).count) {
                            cuisine = recipeInformation[@"cuisines"];
                            for (NSString *individualCuisine in recipeInformation[@"cuisines"]) {
                                [self.cuisines addObject:individualCuisine];
                            }
                        }
                        else {
                            cuisine = @[@"Unknown"];
                            [self.cuisines addObject:@"Unknown"];
                        }
                        Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:source withID:mealID withCuisine:cuisine];
                        [self.tableViewRecipes addObject:newRecipe];
                        self.unfilteredTableViewRecipes = [self.tableViewRecipes copy];
                        [self refreshData];
                    }];
                }
            }
            
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self queryMealDB:input withOption:option completionHandler:^(NSArray *returnedMeals) {
            self.mealDBresults = returnedMeals;
            NSString *recipeName;
            NSString *imageLink;
            NSString *mealID;
            NSString *source;
            NSArray<NSString *> *cuisine;
            if (option == 0) {
                for (NSDictionary *meal in returnedMeals) {
                    recipeName = meal[@"strMeal"];
                    imageLink = meal[@"strMealThumb"];
                    mealID = meal[@"idMeal"];
                    source = @"TheMealDB";
                    cuisine = @[meal[@"strArea"]];
                    [self.cuisines addObject:meal[@"strArea"]];
                    Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:source withID:mealID withCuisine:cuisine];
                    [self.tableViewRecipes addObject:newRecipe];
                    self.unfilteredTableViewRecipes = [self.tableViewRecipes copy];
                    [self refreshData];
                }
            }
            else if (option == 1) {
                for (NSDictionary *meal in returnedMeals) {
                    recipeName = meal[@"strMeal"];
                    imageLink = meal[@"strMealThumb"];
                    mealID = meal[@"idMeal"];
                    source = @"TheMealDB";
                    [Recipe getRecipeInfo:mealID withSource:@"TheMealDB" withCompletion:^(NSDictionary * _Nonnull recipeInformation) {
                        [self.cuisines addObject:recipeInformation[@"strArea"]];
                        self.temp = @[recipeInformation[@"strArea"]];
                        NSArray *cuisine = self.temp;
                        Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:source withID:mealID withCuisine:cuisine];
                        [self.tableViewRecipes addObject:newRecipe];
                        self.unfilteredTableViewRecipes = [self.tableViewRecipes copy];
                        [self refreshData];
                    }];
                }
            }
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    });
}

- (NSString *) ingredientFormatSpoonacular:(NSString *)input {
    NSString *newString = input;
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@","];
    return newString;
}

//Table View Cell Methods
- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    UIColor *color = [UIColor whiteColor];
    UIImage *image = [UIImage systemImageNamed:@"heart.fill"];// Image to mask with
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.0f green:0.92f blue:0.24f alpha:1.0]
                                                 icon: coloredImg];
    return rightUtilityButtons;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)swipeableTableViewCell:(RecipeCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: { //click on save button
            [self performSegueWithIdentifier:@"saveSegue" sender:cell];
            break;
        }
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"detailSegue" sender:indexPath];
}

//search bar delegate methods
- (CGRect)destinationFrameForSearchBar:(INSSearchBar *)searchBar {
    return CGRectMake(20.0, 100.0, CGRectGetWidth(self.view.bounds) - 40.0, 34.0);
}

- (void)searchBarDidTapReturn:(INSSearchBar *)searchBar {
    //clear picker view
    [self.cuisinesSet removeAllObjects];
    [self.cuisines removeAllObjects];
    self.cuisineField.text = @"";
    [self.pickerView reloadAllComponents];
    if (self.searchSegmentedControl.selectedSegmentIndex == 0) {
        [self queryAPIs:searchBar.searchField.text withOption:0 completionHandler:^{
            [self refreshData];
        }];
    }
    else {
        [self queryAPIs:searchBar.searchField.text withOption:1 completionHandler:^{
            [self refreshData];
        }];
    }
}

- (void) refreshData {
    [self.tableView reloadData];
    [self.cuisinesSet addObjectsFromArray:self.cuisines];
    [self.cuisines setArray:[self.cuisinesSet allObjects]];
    [self.cuisines setArray:[self.cuisines sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.pickerView reloadAllComponents];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.passedRecipe = ((RecipeCell *)[self.tableView cellForRowAtIndexPath:(NSIndexPath *)sender]).recipe;
    }
    if ([[segue identifier] isEqualToString:@"saveSegue"]) {
        SaveViewController *saveVC = [segue destinationViewController];
        saveVC.passedRecipe = ((RecipeCell *)sender).recipe;
    }
}


@end
