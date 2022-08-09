//
//  ListsViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 7/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ListDelegate <NSObject>
- (void)didCreateList:(NSString *) listName;
@end

@interface ListsViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
