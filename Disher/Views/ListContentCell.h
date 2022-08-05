//
//  ListContentCell.h
//  Disher
//
//  Created by Bienn Viquiera on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"
#import <SWTableViewCell.h>


NS_ASSUME_NONNULL_BEGIN

@interface ListContentCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recipeImg;
@property (weak, nonatomic) IBOutlet UILabel *recipeSource;
@property (strong, nonatomic) Recipe *recipe;
@end

NS_ASSUME_NONNULL_END
