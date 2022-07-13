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
    // Do any additional setup after loading the view.
    NSURL *cellImg = [NSURL URLWithString:self.passedRecipe.imageURL];
    [self.recipeCover setImageWithURL:cellImg];
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
