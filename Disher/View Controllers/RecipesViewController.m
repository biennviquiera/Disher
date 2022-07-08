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

@interface RecipesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) NSArray *mealDBresults;
@property (nonatomic, strong) NSArray *spoonResults;
@end


@implementation RecipesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //Update global results arrays
    [self queryAPIs:@"banana" completionHandler:^() {
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
        cell.recipeName.text = self.mealDBresults[indexPath.row][@"strMeal"];
        NSString *imageLink = self.mealDBresults[indexPath.row][@"strMealThumb"];
        NSURL *imageURL = [NSURL URLWithString:imageLink];
        [cell.recipeImage setImageWithURL:imageURL];
    }
    else if (indexPath.row >= self.mealDBresults.count) {
        cell.recipeName.text = self.spoonResults[indexPath.row - self.mealDBresults.count][@"title"];
        NSString *imageLink = self.spoonResults[indexPath.row - self.mealDBresults.count][@"image"];
        NSURL *imageURL = [NSURL URLWithString:imageLink];
        [cell.recipeImage setImageWithURL:imageURL];
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
    [self querySearchSpoonacular:input completionHandler:^(NSArray *returnedMeals) {
        self.spoonResults = returnedMeals;
        completionHandler();
    }];
    [self queryMealDB:input completionHandler:^(NSArray *returnedMeals) {
        self.mealDBresults = returnedMeals;
        completionHandler();
    }];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
