//
//  EditListNameViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 8/9/22.
//

#import <UIKit/UIKit.h>
#import "ListContentViewController.h"
#import "ListsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditListNameViewController : UIViewController
@property (weak, nonatomic) id <ListContentDelegate> listContentDelegate;
@property (weak, nonatomic) id <ListDelegate> listDelegate;
@property (strong, nonatomic) NSString *passedListID;
@property (strong, nonatomic) UIImage *passedImage;

@end

NS_ASSUME_NONNULL_END
