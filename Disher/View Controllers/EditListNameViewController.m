//
//  EditListNameViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 8/9/22.
//

#import "EditListNameViewController.h"
#import "Parse/Parse.h"
@import Parse;

@interface EditListNameViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *listImage;
@property (weak, nonatomic) IBOutlet UITextField *listNameField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation EditListNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.listNameField.delegate = self;
    [self.listImage setImage:self.passedImage];
}
- (IBAction)didPressSave:(id)sender {
    self.saveButton.enabled = NO;
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    List *currentList = [query getObjectWithId:self.passedListID];
    currentList[@"listName"] = self.listNameField.text;
    [currentList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [self.listContentDelegate didUpdateName:self.listNameField.text];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.listDelegate didCreateList];
        }
        else {
            self.saveButton.enabled = YES;
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self didPressSave:nil];
    return YES;
}

@end
