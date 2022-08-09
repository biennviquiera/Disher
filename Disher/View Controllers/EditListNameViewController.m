//
//  EditListNameViewController.m
//  Disher
//
//  Created by Bienn Viquiera on 8/9/22.
//

#import "EditListNameViewController.h"
#import "Parse/Parse.h"
@import Parse;

@interface EditListNameViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *listImage;
@property (weak, nonatomic) IBOutlet UITextField *listNameField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation EditListNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.listNameField.delegate = self;
    self.listNameField.text = self.passedListName;
    [self.listImage setImage:self.passedImage];
}
- (IBAction)didPressSave:(id)sender {
    self.saveButton.enabled = NO;
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    List *currentList = [query getObjectWithId:self.passedListID];
    currentList[@"listName"] = self.listNameField.text;
    PFFileObject *img = [PFFileObject fileObjectWithName:@"listImage.png" data:UIImagePNGRepresentation(self.listImage.image)];
    currentList[@"listImage"] = img;
    [currentList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [self.listContentDelegate didUpdateName:self.listNameField.text withImage:self.listImage.image];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.listDelegate didCreateList];
        }
        else {
            self.saveButton.enabled = YES;
        }
    }];
}
- (IBAction)didPressEditImage:(id)sender {
    [self profilePicAction:nil];
}

- (IBAction)profilePicAction:(id)sender {
  UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"" message:@"Change Profile image" preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction *takePhoto=[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
      picker.delegate = self;
      picker.allowsEditing = YES;
      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
      [self presentViewController:picker animated:YES completion:NULL];
      [alertController dismissViewControllerAnimated:YES completion:nil];
  }];
  [alertController addAction:takePhoto];
  UIAlertAction *choosePhoto=[UIAlertAction actionWithTitle:@"Select From Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
      pickerView.allowsEditing = YES;
      pickerView.delegate = self;
      [pickerView setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
      [self presentViewController:pickerView animated:YES completion:nil];
      [alertController dismissViewControllerAnimated:YES completion:nil];
  }];
  [alertController addAction:choosePhoto];
  UIAlertAction *actionCancel=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
     [alertController dismissViewControllerAnimated:YES completion:nil];
  }];
  [alertController addAction:actionCancel];
  [self presentViewController:alertController animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.listImage.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self didPressSave:nil];
    return YES;
}

@end
