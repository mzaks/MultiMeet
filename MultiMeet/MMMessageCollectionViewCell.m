#import "MMMessageCollectionViewCell.h"


@interface MMMessageCollectionViewCell ()

@property (nonatomic, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) UILabel *usernameLabel;
@property (nonatomic, weak) UIImageView *userAvatarImageView;
@property (nonatomic, weak) UILabel *messageDateLabel;

@end

@implementation MMMessageCollectionViewCell

+ (CGSize)sizeForMessage:(NSString *)message maxWidth:(CGFloat)maxWidth
{
    CGRect rect = [message boundingRectWithSize:CGSizeMake(maxWidth - 50.f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12.f] } context:nil];

    CGSize size = rect.size;

    UIEdgeInsets insets = UIEdgeInsetsMake(10.f, 15.f, 10.f, 30.f);
    size.width += insets.left + insets.right;
    size.height += insets.top + insets.bottom;

    return size;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.image = [UIImage imageNamed:@"Bubble"];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    
    [self.contentView addSubview:backgroundImageView];
    self.backgroundImageView = backgroundImageView;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont systemFontOfSize:12.f];

    [self.contentView addSubview:textLabel];
    self.textLabel = textLabel;

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _backgroundImageView.frame = self.contentView.bounds;
    _textLabel.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(10.f, 15.f, 10.f, 30.f));
}

@end