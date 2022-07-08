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
@end


@implementation RecipesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self queryMealDB:@"Chicken" completionHandler:^(NSArray *meals) {
        self.mealDBresults = meals;
        [self.tableView reloadData];
    }];
    
    
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 5;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mealDBresults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecipeCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.recipeName.text = self.mealDBresults[indexPath.row][@"strMeal"];
    cell.recipeDescription.text = self.mealDBresults[indexPath.row][@"strArea"];
    NSString *imageLink = self.mealDBresults[indexPath.row][@"strMealThumb"];
    NSURL *imageURL = [NSURL URLWithString:imageLink];
    
    [cell.recipeImage setImageWithURL:imageURL];
    return cell;
}

- (IBAction)didTapLogout:(id)sender {
    NSLog(@"pressed logout");
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
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot reach MealDB"
                                          message:@"Please try again."
                                          preferredStyle:UIAlertControllerStyleAlert];

               UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                   [self viewDidLoad];
               }];

               [alert addAction:defaultAction];
               [self presentViewController:alert animated: YES completion: nil];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               completionHandler(dataDictionary[@"meals"]);

           }
    }];
    [task resume];
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
