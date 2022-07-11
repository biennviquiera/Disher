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

@property (nonatomic, strong) NSNumber *listID;
@property (nonatomic, strong) NSArray<Recipe *> *recipes;

@end

NS_ASSUME_NONNULL_END
