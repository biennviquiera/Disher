//
//  CreateListViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 7/18/22.
//

#import <UIKit/UIKit.h>
#import "ListsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CreateListViewController : UIViewController
@property (weak, nonatomic) id <ListDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
