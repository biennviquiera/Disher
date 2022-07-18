//
//  RecipeCell.h
//  Disher
//
//  Created by Bienn Viquiera on 7/6/22.
//

#import <UIKit/UIKit.h>
@import Parse;
#import "Recipe.h"
#import "SWTableViewCell.h"


NS_ASSUME_NONNULL_BEGIN

@interface RecipeCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *recipeName;
@property (weak, nonatomic) IBOutlet UIImageView *recipeImage;
@property (weak, nonatomic) IBOutlet UILabel *recipeSource;
@property (strong, nonatomic) Recipe *recipe;
@property NSUInteger index;
@end

NS_ASSUME_NONNULL_END
