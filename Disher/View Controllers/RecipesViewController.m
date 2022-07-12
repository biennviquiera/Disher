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

@interface RecipesViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) NSArray *mealDBresults;
@property (nonatomic, strong) NSArray *spoonResults;
@property (nonatomic, strong) NSMutableArray<Recipe *> *tableViewRecipes;
@property (nonatomic, strong) NSString *searchQuery;
@end


@implementation RecipesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewRecipes = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchQuery = @"chicken";
    
    //Update global results arrays
    [self queryAPIs:self.searchQuery completionHandler:^() {
        [self.tableView reloadData];
    }];
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
    
    // loop through mealdb results first, then go to spoonacular results
    if (indexPath.row < self.mealDBresults.count) {
        NSString *recipeName = self.mealDBresults[indexPath.row][@"strMeal"];
        NSString *imageLink = self.mealDBresults[indexPath.row][@"strMealThumb"];
        NSString *mealID = self.mealDBresults[indexPath.row][@"idMeal"];
        cell.recipeName.text = recipeName;
        NSURL *imageURL = [NSURL URLWithString:imageLink];
        [cell.recipeImage setImageWithURL:imageURL];
        cell.recipeSource.text = @"TheMealDB";
        //create uniform data model for mealdb
        Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:@"mealdb" withID:mealID];
        [self.tableViewRecipes addObject:newRecipe];
        cell.recipe = newRecipe;
        cell.rightUtilityButtons = [self rightButtons];
        
    }
    else {
        NSString *recipeName = self.spoonResults[indexPath.row - self.mealDBresults.count][@"title"];
        NSString *mealID = [NSString stringWithFormat:@"%@", self.spoonResults[indexPath.row - self.mealDBresults.count][@"id"]];
        cell.recipeName.text = recipeName;
        NSString *imageLink = self.spoonResults[indexPath.row - self.mealDBresults.count][@"image"];
        NSURL *imageURL = [NSURL URLWithString:imageLink];
        [cell.recipeImage setImageWithURL:imageURL];cell.recipeSource.text = @"Spoonacular";
        //create uniform data model for spoonacular
        Recipe *newRecipe = [Recipe initWithRecipe:recipeName withURL:imageLink withSource:@"spoonacular" withID:mealID];
        [self.tableViewRecipes addObject:newRecipe];
        cell.recipe = newRecipe;

    }
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
- (void) queryMealDB:(NSString *) name completionHandler:(void(^)(NSArray *returnedMeals))completionHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.themealdb.com/api/json/v1/1/search.php?s=%@", name]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {//TODO: add error message
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               if (dataDictionary[@"meals"] == [NSNull null] ) {
                   NSLog(@"null detected form mealdb");
               }
               else {
                   completionHandler(dataDictionary[@"meals"]);
               }

           }
    }];
    [task resume];
}

- (void) querySearchSpoonacular:(NSString *) name completionHandler:(void(^)(NSArray *returnedMeals))completionHandler {
    //Use API Key in Keys.plist file
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"spoon_key"];
    NSString *apiKeyArg = [NSString stringWithFormat:@"&apiKey=%@", key];
    NSString *queryURL = [NSString stringWithFormat:@"https://api.spoonacular.com/recipes/complexSearch?query=\"%@\"%@", name, apiKeyArg];
    queryURL = [queryURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:queryURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) { //TODO: Add error message
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               if (![(NSArray *)dataDictionary[@"results"] count]) {
                   NSLog(@"null detected from spoonacular");
               }
               else {
                   completionHandler(dataDictionary[@"results"]);
               }
           }
    }];
    [task resume];
}

- (void) queryAPIs:(NSString *) input completionHandler:(void(^)(void))completionHandler {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self querySearchSpoonacular:input completionHandler:^(NSArray *returnedMeals) {
            self.spoonResults = returnedMeals;
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self queryMealDB:input completionHandler:^(NSArray *returnedMeals) {
            self.mealDBresults = returnedMeals;
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        // All group blocks have now completed
        NSLog(@"completion");
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    });
}

//Table View Cell Methods
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Save to List"];
    return rightUtilityButtons;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"detailSegue" sender:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.passedRecipe = self.tableViewRecipes[((NSIndexPath *)sender).row];
    }
}


@end
