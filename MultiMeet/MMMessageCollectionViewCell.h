#import <Foundation/Foundation.h>


@interface MMMessageCollectionViewCell : UICollectionViewCell

+ (CGSize)sizeForMessage:(NSString *)message maxWidth:(CGFloat)maxWidth;

@property (nonatomic, weak, readonly) UILabel *usernameLabel;
@property (nonatomic, weak, readonly) UIImageView *userAvatarImageView;
@property (nonatomic, weak, readonly) UILabel *messageDateLabel;
@property (nonatomic, weak, readonly) UILabel *textLabel;

@end