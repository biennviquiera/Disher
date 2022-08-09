//
//  SaveCell.h
//  Disher
//
//  Created by Bienn Viquiera on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "List.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface SaveCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *listName;
@property (weak, nonatomic) IBOutlet PFImageView *listImage;
@property (strong, nonatomic) List *list;
@end

NS_ASSUME_NONNULL_END
