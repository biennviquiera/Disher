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
@dynamic cuisine;

+ (NSString *) parseClassName {
    return @"Recipe";
}
+ (Recipe *) initWithRecipe:(NSString *) name withURL:(NSString *) imgURL withSource:(NSString *) dishSource withID:(NSString *) recipeNum withCuisine:(nonnull NSArray *)cuisine{
    Recipe *newRecipe = [Recipe new];
    newRecipe.dishName = name;
    newRecipe.imageURL = imgURL;
    newRecipe.source = dishSource;
    newRecipe.recipeID = recipeNum;
    newRecipe.cuisine = cuisine;
    return newRecipe;
}
+ (void) getRecipeInfo:(NSString *)recipeID withSource:(NSString *)source withCompletion:(void(^)(NSDictionary *recipeInformation))completionHandler {
    NSURL *url;
    if ([source isEqualToString:@"Spoonacular"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
        NSString *key = [dict objectForKey: @"spoon_key"];
        NSString *apiKeyArg = [NSString stringWithFormat:@"?apiKey=%@", key];
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spoonacular.com/recipes/%@/information%@", recipeID, apiKeyArg]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completionHandler(dataDictionary);
            
        }];
        [task resume];
    }
    else if ([source isEqualToString:@"TheMealDB"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.themealdb.com/api/json/v1/1/lookup.php?i=%@", recipeID]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completionHandler(dataDictionary[@"meals"][0]);
        }];
        [task resume];
    }
}
@end
