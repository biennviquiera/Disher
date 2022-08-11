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
    if ([self.passedRecipe.source isEqualToString:@"Spoonacular"]) {
        [Recipe getRecipeInfo:self.passedRecipe.recipeID withSource:@"Spoonacular" withCompletion:^(NSDictionary * _Nonnull recipeInformation) {
            self.dishTitleLabel.text = [recipeInformation objectForKey:@"title"];
            if ([recipeInformation objectForKey:@"instructions"] != [NSNull null]) {
                self.descriptionLabel.text = [self flattenHtml:[recipeInformation objectForKey:@"instructions"]];
            }
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
    [self.dishImageView.layer setShadowRadius: 8];
    [self.dishImageView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
    [self.dishImageView.layer setShadowOpacity:1];
    [self.dishImageView.layer setShadowOffset:CGSizeMake(0,0)];
    self.dishImageView.layer.masksToBounds = NO;
    self.dishImageView.clipsToBounds = NO;
}
- (NSString *)flattenHtml: (NSString *) html {
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString: html];
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString: @"<" intoString: NULL];
        [theScanner scanUpToString: @">" intoString: &text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat: @"%@>", text]
                                               withString: @" "];
    }
    return html;
}
@end
