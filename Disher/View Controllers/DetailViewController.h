//
//  DetailViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController
@property (strong, nonatomic) Recipe *passedRecipe;

@end

NS_ASSUME_NONNULL_END
