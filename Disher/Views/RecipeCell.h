//
//  RecipeCell.h
//  Disher
//
//  Created by Bienn Viquiera on 7/6/22.
//

#import <UIKit/UIKit.h>
@import Parse;


NS_ASSUME_NONNULL_BEGIN

@interface RecipeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *recipeName;
@property (weak, nonatomic) IBOutlet UILabel *recipeDescription;
@property (weak, nonatomic) IBOutlet UIImageView *recipeImage;

@end

NS_ASSUME_NONNULL_END
