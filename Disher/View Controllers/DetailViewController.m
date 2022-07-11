//
//  DetailViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/11/22.
//

#import "DetailViewController.h"
#import "Recipe.h"
#import "Parse.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textlabel;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textlabel.text = self.passedRecipe.dishName;
    [self.passedRecipe saveInBackground];
    // Do any additional setup after loading the view.
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
