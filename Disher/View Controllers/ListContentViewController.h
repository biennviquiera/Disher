//
//  ListContentViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "List.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListContentViewController : UIViewController
@property (strong, nonatomic) List *passedList;
@end

NS_ASSUME_NONNULL_END
