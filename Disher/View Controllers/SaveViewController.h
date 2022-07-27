//
//  SaveViewController.h
//  Disher
//
//  Created by Bienn Viquiera on 7/14/22.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SaveDelegate <NSObject>

- (void)didCreateList;

@end

@interface SaveViewController : UIViewController
@property (strong, nonatomic) Recipe *passedRecipe;
@end

NS_ASSUME_NONNULL_END
