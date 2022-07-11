//
//  RecipeCell.h
//  Disher
//
//  Created by Bienn Viquiera on 7/6/22.
//

#import <UIKit/UIKit.h>
@import Parse;
#import "Recipe.h"


NS_ASSUME_NONNULL_BEGIN

@interface RecipeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *recipeName;
@property (weak, nonatomic) IBOutlet UIImageView *recipeImage;
@property (weak, nonatomic) IBOutlet UILabel *recipeSource;
@property (strong, nonatomic) Recipe *recipe;
@end

NS_ASSUME_NONNULL_END
