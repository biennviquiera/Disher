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

@end
