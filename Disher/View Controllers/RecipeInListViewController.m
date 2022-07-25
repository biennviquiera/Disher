//
//  RecipeInListViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/21/22.
//

#import "RecipeInListViewController.h"
#import "Recipe.h"
#import "UIKit+AFNetworking.h"

@interface RecipeInListViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dishTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dishImageView;

@end

@implementation RecipeInListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.passedRecipe.source isEqualToString:@"Spoonacular"]) {
        [Recipe getRecipeInfo:self.passedRecipe.recipeID withSource:@"Spoonacular" withCompletion:^(NSDictionary * _Nonnull recipeInformation) {
            self.dishTitleLabel.text = [recipeInformation objectForKey:@"title"];
            self.descriptionLabel.text = [self flattenHtml:[recipeInformation objectForKey:@"instructions"]];
            NSString *imageLink = [recipeInformation objectForKey:@"image"];
            NSURL *imageURL = [NSURL URLWithString:imageLink];
            [self.dishImageView setImageWithURL:imageURL];
            
        }];
    }
    else if ([self.passedRecipe.source isEqualToString:@"TheMealDB"]) {
        [Recipe getRecipeInfo:self.passedRecipe.recipeID withSource:@"TheMealDB" withCompletion:^(NSDictionary * _Nonnull recipeInformation) {
            self.dishTitleLabel.text = [recipeInformation objectForKey:@"strMeal"];
            self.descriptionLabel.text = [recipeInformation objectForKey:@"strInstructions"];
            NSString *imageLink = [recipeInformation objectForKey:@"strMealThumb"];
            NSURL *imageURL = [NSURL URLWithString:imageLink];
            [self.dishImageView setImageWithURL:imageURL];
        }];
    }
}

- (NSString *)flattenHtml: (NSString *) html {
        NSScanner *theScanner;
        NSString *text = nil;
        theScanner = [NSScanner scannerWithString: html];
        while ([theScanner isAtEnd] == NO) {
                [theScanner scanUpToString: @"<" intoString: NULL];
                [theScanner scanUpToString: @">" intoString: &text];
                html = [html stringByReplacingOccurrencesOfString:
                        [NSString stringWithFormat: @"%@>", text]
                        withString: @" "];
        }
        return html;
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
