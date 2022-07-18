//
//  CreateListViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 7/18/22.
//

#import "CreateListViewController.h"
#import "List.h"

@import Parse;
@interface CreateListViewController ()
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation CreateListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didTapCreate:(id)sender {
    [self.createButton setEnabled:NO];
    [List createList:self.textField.text completionHandler:^() {
        [self dismissViewControllerAnimated:YES completion:nil];
        //reload after creating list
        [self.delegate didCreateList:self.textField.text];
    }];
}

@end
