//
//  Recipe.m
//  Disher
//
//  Created by Bienn Viquiera on 7/7/22.
//

#import "Recipe.h"

@implementation Recipe

@dynamic dishName;
@dynamic imageURL;
@dynamic source;
@dynamic recipeID;

+ (NSString *) parseClassName {
    return @"Recipe";
}

+ (Recipe *) initWithRecipe:(NSString *) name withURL:(NSString *) imgURL withSource:(NSString *) dishSource withID:(NSString *) recipenum {
    Recipe *newRecipe = [Recipe new];
    newRecipe.dishName = name;
    newRecipe.imageURL = imgURL;
    newRecipe.source = dishSource;
    newRecipe.recipeID = recipenum;
    return newRecipe;
}

@end
