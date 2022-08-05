//
//  Recipe.h
//  Disher
//
//  Created by Bienn Viquiera on 7/7/22.
//

#import <Parse/Parse.h>


NS_ASSUME_NONNULL_BEGIN

@interface Recipe : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *dishName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *recipeID;
@property (nonatomic, strong) NSArray *cuisine;

+ (Recipe *) initWithRecipe:(NSString *)name withURL:(NSString *)imgURL withSource:(NSString *)dishSource withID:(NSString *)recipeNum withCuisine:(NSArray *)cuisine;
+ (void) getRecipeInfo:(NSString *)recipeID withSource:(NSString *)source withCompletion:(void(^)(NSDictionary *recipeInformation))completionHandler;
@end



NS_ASSUME_NONNULL_END
