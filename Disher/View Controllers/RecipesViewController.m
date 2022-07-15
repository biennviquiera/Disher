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

@interface RecipesViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UITableViewDelegate, INSSearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) NSArray *mealDBresults;
@property (nonatomic, strong) NSArray *spoonResults;
@property (nonatomic, strong) NSMutableArray<Recipe *> *tableViewRecipes;
@property (nonatomic, strong) NSString *searchQuery;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) INSSearchBar *searchBarWithDelegate;
@property BOOL searchingFlag;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentedControl;

@end


@implementation RecipesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewRecipes = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchQuery = @"chicken";
    
    //Update global results arrays
    [self queryAPIs:self.searchQuery withOption:0 completionHandler:^{
        // merge two results into tableViewRecipes
        [self.tableView reloadData];
    }];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.000 green:0.418 blue:0.673 alpha:1.000];
    self.searchBarWithDelegate = [[INSSearchBar alloc] initWithFrame:CGRectMake(20.0, 100.0, 44.0, 34.0)];
    self.searchBarWithDelegate.delegate = self;
    [self.view addSubview:self.searchBarWithDelegate];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 5;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.spoonResults.count + self.mealDBresults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecipeCell" forIndexPath:indexPath];
    cell.delegate = self;
    NSString *recipeName;
    NSString *imageLink;
    NSString *mealID;
    NSString *source;
    // loop through mealdb results first, then go to spoonacular results
    if (indexPath.row < self.mealDBresults.count) {
        recipeName = self.mealDBresults[indexPath.row][@"strMeal"];
        imageLink = self.mealDBresults[indexPath.row][@"strMealThumb"];
        mealID = self.mealDBresults[indexPath.row][@"idMeal"];
        source = @"TheMealDB";
    }
    else {
        recipeName = self.spoonResults[indexPath.row - self.mealDBresults.count][@"title"];
        imageLink = self.spoonResults[indexPath.row - self.mealDBresults.count][@"image"];
        mealID = [NSString stringWithFormat:@"%@", self.spoonResults[indexPath.row - self.mealDBresults.count][@"id"]];
        source = @"Spoonacular";
    }
    Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:source withID:mealID];
    cell.index = self.tableViewRecipes.count;
    [self.tableViewRecipes addObject:newRecipe];
    cell.recipe = newRecipe;
    cell.recipeName.text = newRecipe.dishName;
    NSURL *imageURL = [NSURL URLWithString:newRecipe.imageURL];
    [cell.recipeImage setImageWithURL:imageURL];
    cell.recipeSource.text = newRecipe.source;
    cell.rightUtilityButtons = [self rightButtons];
    return cell;
}

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
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.themealdb.com/api/json/v1/1/filter.php?i=%@", name]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {//TODO: add error message
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if (dataDictionary[@"meals"] == [NSNull null] ) {
                   NSLog(@"null detected form mealdb");
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
    if (option == 0) { // normal search
        queryURL = [NSString stringWithFormat:@"https://api.spoonacular.com/recipes/complexSearch?query=\"%@\"%@", name, apiKeyArg];
        queryURL = [queryURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else { //ingredient search
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
    self.searchingFlag = YES;
    [self.tableViewRecipes removeAllObjects];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self querySearchSpoonacular:input withOption:option completionHandler:^(NSArray *returnedMeals) {
            self.spoonResults = returnedMeals;
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self queryMealDB:input withOption:option completionHandler:^(NSArray *returnedMeals) {
            self.mealDBresults = returnedMeals;
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        // All group blocks have now completed
        NSLog(@"completion");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchingFlag = NO;
            completionHandler();
        });
    });
}

//Ingredient Search



//Table View Cell Methods
- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.0f green:0.92f blue:0.24f alpha:0.0]
                                                 icon: [UIImage systemImageNamed:@"heart.fill"]];
    return rightUtilityButtons;
}



- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)swipeableTableViewCell:(RecipeCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: { //click on save button
            //TODO: Check for existing entry in database
            [self performSegueWithIdentifier:@"saveSegue" sender:cell];
//            [cell.recipe saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                if (!error) {
//                    NSLog(@"%@ was saved", cell.recipe.dishName);
//                }
//                else {
//                    NSLog(@"Error, %@", error.localizedDescription);
//                }
//            }];
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
    if (self.searchSegmentedControl.selectedSegmentIndex == 0) {
        [self queryAPIs:searchBar.searchField.text withOption:0 completionHandler:^{
            [self.tableView reloadData];
        }];
    }
    else {
        [self queryAPIs:searchBar.searchField.text withOption:1 completionHandler:^{
            [self.tableView reloadData];
        }];
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.passedRecipe = self.tableViewRecipes[(((RecipeCell *)[self.tableView cellForRowAtIndexPath:(NSIndexPath *)sender]).index)];
    }
    if ([[segue identifier] isEqualToString:@"saveSegue"]) {
        SaveViewController *saveVC = [segue destinationViewController];
        saveVC.passedRecipe = ((RecipeCell *)sender).recipe;
    }
}


@end
