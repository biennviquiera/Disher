//
//  Recipe.h
//  Disher
//
//  Created by Bienn Viquiera on 7/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Recipe : NSObject

@property (nonatomic, strong) NSString *dishName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *source;
@property (nonatomic) int *recipeID;

@end

NS_ASSUME_NONNULL_END
