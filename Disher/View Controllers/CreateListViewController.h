//
//  CreateListViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 7/18/22.
//

#import <UIKit/UIKit.h>
#import "ListsViewController.h"
#import "SaveViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CreateListViewController : UIViewController
@property (weak, nonatomic) id <ListDelegate> delegate;
@property (weak, nonatomic) id <SaveDelegate> saveDelegate;
@end

NS_ASSUME_NONNULL_END
