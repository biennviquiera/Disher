//
//  LoginViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/5/22.
//

#import "LoginViewController.h"
@import Parse;


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameFIeld;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

- (IBAction)didTapLogin:(id)sender {
}

- (IBAction)didTapSignup:(id)sender {
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
