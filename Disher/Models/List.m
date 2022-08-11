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
@dynamic listImage;

+ (nonnull NSString *)parseClassName {
    return @"List";
}
+ (void)createList:(NSString *)name completionHandler:(nonnull void (^)(void))completionHandler{
    List *newList = [List new];
    newList.listName = name;
    newList.recipes = @[];
    UIImage *placeholderImage = [UIImage systemImageNamed:@"questionmark.app"];
    PFFileObject *placeholder = [PFFileObject fileObjectWithName:@"placeholder.png" data:UIImagePNGRepresentation(placeholderImage)];
    newList.listImage = placeholder;
    
    [newList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            PFUser *current = [PFUser currentUser];
            [current addObject:newList.objectId forKey:@"lists"];
            [current saveInBackground];
            completionHandler();
        }
    }];
}
+ (NSArray *)queryLists {
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    [query orderByDescending:@"updatedAt"];
    NSArray *userLists = [PFUser currentUser][@"lists"];
    [query whereKey:@"objectId" containedIn:userLists];
    NSArray *objects = [query findObjects:nil];
    return objects;
}
@end
