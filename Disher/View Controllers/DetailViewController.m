//
//  DetailViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/11/22.
//

#import "DetailViewController.h"
#import "Recipe.h"
#import "UIKit+AFNetworking.h"
#import "Parse.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ingredientsLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recipeCover;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.passedRecipe.dishName;
    self.descriptionLabel.text = self.passedRecipe.source;
    NSURL *cellImg = [NSURL URLWithString:self.passedRecipe.imageURL];
    [self.recipeCover setImageWithURL:cellImg];
}

@end
