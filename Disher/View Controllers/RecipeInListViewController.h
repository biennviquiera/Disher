//
//  RecipeInListViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 7/21/22.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecipeInListViewController : UIViewController
@property (nonatomic, strong) Recipe *passedRecipe;

@end

NS_ASSUME_NONNULL_END
