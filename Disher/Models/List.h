//
//  List.h
//  Disher
//
//  Created by Bienn Viquiera on 7/8/22.
//

#import <Parse/Parse.h>
#import "Recipe.h"

NS_ASSUME_NONNULL_BEGIN

@interface List : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *listName;
@property (nonatomic, strong) NSArray<Recipe *> *recipes;
@property (nonatomic, strong) PFFileObject *listImage;

+ (void)createList:(NSString *)name completionHandler:(void(^)(void))completionHandler;
+ (NSArray *)queryLists;
@end

NS_ASSUME_NONNULL_END
