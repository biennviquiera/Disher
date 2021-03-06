//
//  List.m
//  Disher
//
//  Created by Bienn Viquiera on 7/8/22.
//

#import "List.h"
#import <Parse/Parse.h>

@implementation List
@dynamic listName;
@dynamic recipes;
@dynamic image;

+ (nonnull NSString *)parseClassName {
    return @"List";
}

+ (void) createList:(NSString *) name completionHandler:(nonnull void (^)(void))completionHandler{
    List *newList = [List new];
    newList.listName = name;
    newList.recipes = @[];
    
    [newList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            PFUser *current = [PFUser currentUser];

            [current addObject:newList.objectId forKey:@"lists"];
            [current saveInBackground];
            completionHandler();
        }
    }];
}


@end
