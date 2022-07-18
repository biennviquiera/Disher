//
//  LoginViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/5/22.
//

#import "LoginViewController.h"
#import "List.h"
@import Parse;

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)dismissKeyboard {
     [self.view endEditing:YES];
}

//BUTTON ACTIONS
- (IBAction)didTapLogin:(id)sender {
    [self.loginButton setEnabled:NO];
    [self.signupButton setEnabled:NO];
    [self loginUser];
}

- (IBAction)didTapSignup:(id)sender {
    [self.signupButton setEnabled:NO];
    [self.loginButton setEnabled:NO];
    [self registerUser];
}

//HELPER METHODS
- (void) loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSString *errorString = [error userInfo][@"error"];
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error logging in"
                                                                           message:errorString
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try again"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            [self.loginButton setEnabled:YES];
            [self.signupButton setEnabled:YES];
        }
        else {
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

- (void) registerUser {
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser[@"lists"] = @[];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSString *errorString = [error userInfo][@"error"];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error signing up"
                                                                           message:errorString
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try again"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            [self.signupButton setEnabled:YES];
            [self.loginButton setEnabled:YES];
        }
        else {
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

@end
