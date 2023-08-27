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
#import "SaveViewController.h"
#import "INSSearchBar.h"
#import "RecipeInListViewController.h"

@interface RecipesViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UITableViewDelegate, INSSearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
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
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *mealDBMatches;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *mealDBMatchesValues;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *spoonacularMatches;
@property (weak, nonatomic) IBOutlet UIButton *randomizeButton;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *spoonacularMatchesValues;
@property NSArray *temp;
@property BOOL seenIngredientMsg;
@property BOOL showIngredientMatch;
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
    self.mealDBMatches = [NSMutableDictionary new];
    self.mealDBMatchesValues = [NSMutableDictionary new];
    self.spoonacularMatches = [NSMutableDictionary new];
    self.spoonacularMatchesValues = [NSMutableDictionary new];
    self.searchQuery = @"chicken";
    self.cuisineField.inputView = self.pickerView;
    self.view.backgroundColor = [UIColor colorWithRed:0.031 green:0.403 blue:0.533 alpha:1.000];
    self.searchBarWithDelegate = [[INSSearchBar alloc] initWithFrame:CGRectMake(20.0, 92.0, 44.0, 34.0)];
    self.searchBarWithDelegate.delegate = self;
    [self.view addSubview:self.searchBarWithDelegate];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.searchSegmentedControl addTarget:self action:@selector(didTapSearchByIngredient:) forControlEvents:UIControlEventTouchUpInside];
    [self getRandomRecipesWithCompletion:^{
        [self refreshData];
    }];
}
- (IBAction)didTapRandomize:(id)sender {
    [self killScroll];
    [self clearPickerView];
    self.randomizeButton.enabled = NO;
    [self getRandomRecipesWithCompletion:^{
        [self refreshData];
        self.randomizeButton.enabled = YES;
    }];
}
- (void)killScroll {
    CGPoint offset = self.tableView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [self.tableView setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [self.tableView setContentOffset:offset animated:NO];
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
    cell.contentView.exclusiveTouch = YES;
    cell.exclusiveTouch = YES;
    Recipe *currRecipe = self.tableViewRecipes[indexPath.row];
    cell.recipe = currRecipe;
    cell.recipeName.text = currRecipe.dishName;
    NSURL *imageURL = [NSURL URLWithString:currRecipe.imageURL];
    [cell.recipeImage setImageWithURL:imageURL];
    cell.recipeSource.text = currRecipe.source;
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    if (!self.showIngredientMatch) {
        cell.matchLabel.text = @"";
    }
    else if ([cell.recipe.source isEqualToString:@"Spoonacular"]) {
        cell.matchLabel.text = [self.spoonacularMatches objectForKey:cell.recipe.recipeID];
    }
    else if ([cell.recipe.source isEqualToString:@"TheMealDB"]){
        cell.matchLabel.text = [self.mealDBMatches objectForKey:cell.recipe.recipeID];
    }
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
        if (error) {
            NSString *message = @"Unable to log out. Please try again.";
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
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
- (void)queryMealDB:(NSString *)name withOption:(NSInteger)option completionHandler:(void(^)(NSArray *returnedMeals))completionHandler {
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
        if (!error) {
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
- (void)querySearchSpoonacular:(NSString *)name withOption:(NSInteger)option completionHandler:(void(^)(NSArray *returnedMeals))completionHandler {
    //Use API Key in Keys.plist file
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"spoon_key"];
    NSString *apiKeyArg = [NSString stringWithFormat:@"&apiKey=%@", key];
    NSString *queryURL;
    if (option == 0) {
        queryURL = [NSString stringWithFormat:@"https://api.spoonacular.com/recipes/complexSearch?query=\"%@\"%@&addRecipeInformation=TRUE&number=99", name, apiKeyArg];
        queryURL = [queryURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else {
        name = [self ingredientFormatSpoonacular:name];
        queryURL = [NSString stringWithFormat:@"https://api.spoonacular.com/recipes/findByIngredients?ingredients=\"%@\"%@&number=99", name, apiKeyArg];
        queryURL = [queryURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    NSURL *url = [NSURL URLWithString:queryURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (option == 0) {
                if (![(NSArray *)dataDictionary[@"results"] count]) {
                    completionHandler(@[]);
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
- (void)queryAPIs:(NSString *)input withOption:(NSInteger)option completionHandler:(void(^)(void))completionHandler {
    [self.tableViewRecipes removeAllObjects];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self querySearchSpoonacular:input withOption:option completionHandler:^(NSArray *returnedMeals) {
            if (option == 0) {
                self.showIngredientMatch = NO;
                [self handleSimpleSearch:@"Spoonacular" withMeals:returnedMeals];
            }
            else if (option == 1) {
                self.showIngredientMatch = YES;
                [self handleIngredientSearch:@"Spoonacular" withMeals:returnedMeals withInput:input];
            }
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self queryMealDB:input withOption:option completionHandler:^(NSArray *returnedMeals) {
            if (option == 0) {
                [self handleSimpleSearch:@"TheMealDB" withMeals:returnedMeals];
            }
            else if (option == 1) {
                [self handleIngredientSearch:@"TheMealDB" withMeals:returnedMeals withInput:input];
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
- (void)getRandomRecipesWithCompletion:(void(^)(void))completionHandler {
    [self.tableViewRecipes removeAllObjects];
    self.showIngredientMatch = NO;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self getRandomSpoonacularMealsWithCompletion:^(NSArray *returnedMeals) {
            [self handleSimpleSearch:@"Spoonacular" withMeals:returnedMeals];
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self getRandomMealDBMealsWithCompletion:^(NSArray *returnedMeals) {
            [self handleSimpleSearch:@"TheMealDB" withMeals:returnedMeals];
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    });
}
- (void)getRandomSpoonacularMealsWithCompletion:(void(^)(NSArray *returnedMeals))completionHandler {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"spoon_key"];
    NSString *apiKeyArg = [NSString stringWithFormat:@"&apiKey=%@", key];
    NSString *queryURL;
    queryURL = [NSString stringWithFormat:@"https://api.spoonacular.com/recipes/random?number=100&%@", apiKeyArg];
    queryURL = [queryURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"url is %@", queryURL);
    NSURL *url = [NSURL URLWithString:queryURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completionHandler(dataDictionary[@"recipes"]);
        }
    }];
    [task resume];
}
- (void)getRandomMealDBMealsWithCompletion:(void(^)(NSArray *returnedMeals))completionHandler {
    NSURL *url;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.themealdb.com/api/json/v2/9973533/randomselection.php"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completionHandler(dataDictionary[@"meals"]);
        }
    }];
    [task resume];
}
// Table View Cell Methods
- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    UIColor *color = [UIColor whiteColor];
    UIImage *image = [UIImage systemImageNamed:@"heart.fill"];
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
    [cell hideUtilityButtonsAnimated:YES];
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
    return CGRectMake(5.0, 92.0, CGRectGetWidth(self.view.bounds) - 10.0, 34.0);
}
- (void)searchBarDidTapReturn:(INSSearchBar *)searchBar {
    [self clearPickerView];
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
//sorting
- (void)sortIngredients {
    NSArray *sortedArray = [self.tableViewRecipes sortedArrayUsingComparator: ^(Recipe *obj1, Recipe *obj2) {
        NSNumber *firstPercentage;
        NSNumber *secondPercentage;
        if ([obj1.source isEqualToString:@"Spoonacular"]) {
            firstPercentage = [self.spoonacularMatchesValues objectForKey:obj1.recipeID];
        }
        else if ([obj1.source isEqualToString:@"TheMealDB"]) {
            firstPercentage = [self.mealDBMatchesValues objectForKey:obj1.recipeID];
        }
        if ([obj2.source isEqualToString:@"Spoonacular"]) {
            secondPercentage = [self.spoonacularMatchesValues objectForKey:obj2.recipeID];
        }
        else if ([obj2.source isEqualToString:@"TheMealDB"]) {
            secondPercentage = [self.mealDBMatchesValues objectForKey:obj2.recipeID];
        }
        return [secondPercentage compare:firstPercentage];
    }];
    [self.tableViewRecipes setArray:sortedArray];
}
//API Helper methods
- (NSString *)ingredientFormatSpoonacular:(NSString *)input {
    NSString *newString = input;
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@","];
    return newString;
}
- (void) handleSimpleSearch:(NSString *)type withMeals:(NSArray *)meals {
    if ([type isEqualToString:@"Spoonacular"]) {
        for (NSDictionary *meal in meals) {
            [self createRecipe:@"Spoonacular" withDictionary:meal];
        }
    }
    else if ([type isEqualToString:@"TheMealDB"]) {
        for (NSDictionary *meal in meals) {
            [self createRecipe:@"TheMealDB" withDictionary:meal];
        }
    }
}
- (void)createRecipe:(NSString *)type withDictionary:(NSDictionary *)recipe {
    NSString *recipeName;
    NSString *imageLink;
    NSString *mealID;
    NSString *source;
    NSArray<NSString *> *cuisine;
    if ([type isEqualToString:@"TheMealDB"]) {
            recipeName = recipe[@"strMeal"];
            imageLink = recipe[@"strMealThumb"];
            mealID = recipe[@"idMeal"];
            source = @"TheMealDB";
            cuisine = @[recipe[@"strArea"]];
            [self.cuisines addObject:recipe[@"strArea"]];
    }
    else if ([type isEqualToString:@"Spoonacular"]) {
        recipeName = recipe[@"title"];
        imageLink = recipe[@"image"];
        mealID = [NSString stringWithFormat:@"%@", recipe[@"id"]];
        source = @"Spoonacular";
        if (((NSArray *)recipe[@"cuisines"]).count) {
            cuisine = recipe[@"cuisines"];
            for (NSString *cuisine in recipe[@"cuisines"]) {
                [self.cuisines addObject:cuisine];
            }
        }
        else {
            cuisine = @[@"Unknown"];
            [self.cuisines addObject:@"Unknown"];
        }
    }
    Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:source withID:mealID withCuisine:cuisine];
    [self.tableViewRecipes addObject:newRecipe];
    self.unfilteredTableViewRecipes = [self.tableViewRecipes copy];
    [self refreshData];
}
- (void)handleIngredientSearch:(NSString *)type withMeals:(NSArray *)meals withInput:(NSString *) input {
    NSString *recipeName;
    NSString *imageLink;
    NSString *mealID;
    NSString *source;
    if ([type isEqualToString:@"Spoonacular"]) {
        for (NSDictionary *meal in meals) {
            recipeName = meal[@"title"];
            imageLink = meal[@"image"];
            mealID = [NSString stringWithFormat:@"%@", meal[@"id"]];
            source = @"Spoonacular";
            [Recipe getRecipeInfo:mealID withSource:source withCompletion:^(NSDictionary * _Nonnull recipeInformation) {
                NSArray *cuisines = [self handleCuisineFilteringWithDictionary:recipeInformation withSource:@"Spoonacular"];
                Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:source withID:mealID withCuisine:cuisines];
                [self.tableViewRecipes addObject:newRecipe];
                [self handleIngredientMatching:meal withMealID:mealID withSource:@"Spoonacular" withInput:input];
                self.unfilteredTableViewRecipes = [self.tableViewRecipes copy];
                [self refreshData];
            }];
        }
    }
    else if ([type isEqualToString:@"TheMealDB"]) {
        for (NSDictionary *meal in meals) {
            recipeName = meal[@"strMeal"];
            imageLink = meal[@"strMealThumb"];
            mealID = meal[@"idMeal"];
            source = @"TheMealDB";
            [Recipe getRecipeInfo:mealID withSource:@"TheMealDB" withCompletion:^(NSDictionary * _Nonnull recipeInformation) {
                NSArray *cuisine = [self handleCuisineFilteringWithDictionary:recipeInformation withSource:@"TheMealDB"];
                Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:source withID:mealID withCuisine:cuisine];
                [self handleIngredientMatching:recipeInformation withMealID:mealID withSource:@"TheMealDB" withInput:input];
                [self.tableViewRecipes addObject:newRecipe];
                self.unfilteredTableViewRecipes = [self.tableViewRecipes copy];
                [self refreshData];
            }];
        }
    }
}
- (NSArray *)handleCuisineFilteringWithDictionary:(NSDictionary *)recipeInformation withSource:(NSString *)source {
    if ([source isEqualToString:@"Spoonacular"]) {
        NSArray<NSString *> *cuisine;
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
        return cuisine;
    }
    else if ([source isEqualToString:@"TheMealDB"]) {
        [self.cuisines addObject:recipeInformation[@"strArea"]];
        NSArray *cuisine = @[recipeInformation[@"strArea"]];
        return cuisine;
    }
    return @[@"Unknown"];
}
- (void)handleIngredientMatching:(NSDictionary *)meal withMealID:(NSString *)mealID withSource:(NSString *)source withInput:(NSString *)input{
    if ([source isEqualToString:@"Spoonacular"]) {
        float numeratorFloat = [meal[@"usedIngredientCount"] floatValue];
        float denominatorFloat = [meal[@"usedIngredientCount"] floatValue] + [meal[@"missedIngredientCount"] floatValue];
        NSNumber *percentMatch = [NSNumber numberWithFloat:numeratorFloat / denominatorFloat];
        
        NSUInteger numerator = [meal[@"usedIngredientCount"] integerValue];
        NSUInteger denominator = [meal[@"usedIngredientCount"] integerValue] + [meal[@"missedIngredientCount"] integerValue];
        NSString *matchString = [NSString stringWithFormat:@"You have %lu/%lu ingredients", numerator, denominator];
        [self.spoonacularMatches setObject:matchString forKey:mealID];
        [self.spoonacularMatchesValues setValue:percentMatch forKey:mealID];
    }
    else if ([source isEqualToString:@"TheMealDB"]) {
        NSArray *ownedIngredientsArray = [input componentsSeparatedByString:@","];
        NSMutableArray *recipeIngredients = [NSMutableArray new];
        NSInteger i = 1;
        BOOL nullFound = NO;
        while (!nullFound) {
            NSString *ingredient = meal[[NSString stringWithFormat:@"strIngredient%ld", i]];
            if (ingredient != nil && ![ingredient isEqualToString:@""]) {
                [recipeIngredients addObject:ingredient];
                i++;
            }
            else {
                nullFound = YES;
            }
        }
        NSUInteger ingredientTotal = recipeIngredients.count;
        NSUInteger ownedTotal = 0;
        for (NSString *ingredient in ownedIngredientsArray) {
            for (NSString *usedIngredient in recipeIngredients) {
                if ([usedIngredient rangeOfString:ingredient options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    ownedTotal++;
                }
            }
        }
        float numeratorFloat = ownedTotal;
        float denominatorFloat = ingredientTotal;
        NSNumber *percentMatch = [NSNumber numberWithFloat:numeratorFloat / denominatorFloat];
        [self.mealDBMatchesValues setValue:percentMatch forKey:mealID];
        NSString *matchDescriptor = [NSString stringWithFormat:@"You have %lu/%lu ingredients", ownedTotal, ingredientTotal];
        [self.mealDBMatches setObject:matchDescriptor forKey:mealID];
    }
    [self sortIngredients];
}
- (void)refreshData {
    [self.tableView reloadData];
    [self.cuisinesSet addObjectsFromArray:self.cuisines];
    [self.cuisines setArray:[self.cuisinesSet allObjects]];
    [self.cuisines setArray:[self.cuisines sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.pickerView reloadAllComponents];
}
-(void)clearPickerView {
    [self.cuisinesSet removeAllObjects];
    [self.cuisines removeAllObjects];
    self.cuisineField.text = @"";
    [self.pickerView reloadAllComponents];
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
}
- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        RecipeInListViewController *detailVC = [segue destinationViewController];
        detailVC.passedRecipe = ((RecipeCell *)[self.tableView cellForRowAtIndexPath:(NSIndexPath *)sender]).recipe;
    }
    if ([[segue identifier] isEqualToString:@"saveSegue"]) {
        SaveViewController *saveVC = [segue destinationViewController];
        saveVC.passedRecipe = ((RecipeCell *)sender).recipe;
    }
}
@end
