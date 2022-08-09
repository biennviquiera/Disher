//
//  ListContentViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "List.h"
#import "ListsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListContentViewController : UIViewController
@property (strong, nonatomic) List *passedList;
@property (weak, nonatomic) id <ListDelegate> listDelegate;
@end

NS_ASSUME_NONNULL_END
