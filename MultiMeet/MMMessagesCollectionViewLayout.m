#import "MMMessagesCollectionViewLayout.h"


@interface MMMessagesCollectionViewLayout ()

@property (nonatomic, copy) NSDictionary *frames;
@property (nonatomic) CGSize contentSize;

@end

@implementation MMMessagesCollectionViewLayout

- (void)prepareLayout
{
    [super prepareLayout];

    NSMutableDictionary *frames = [[NSMutableDictionary alloc] init];

    CGFloat contentHeight = 0.f;
    CGFloat fullHeight = CGRectGetHeight(self.collectionView.bounds) - 64.f;

    NSInteger items = [self.collectionView numberOfItemsInSection:0];

    id<UICollectionViewDelegateFlowLayout> delegate = self.collectionView.delegate;

    for (NSInteger item = 0; item < items; item++) {

        CGFloat Height = 50.f;

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];

        CGSize size = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];

        CGRect frame = CGRectMake(CGRectGetWidth(self.collectionView.bounds) - size.width - 10.f, contentHeight, size.width, size.height);

        frames[indexPath] = [NSValue valueWithCGRect:frame];

        contentHeight += CGRectGetHeight(frame) + 10.f;

    }

    if (contentHeight < fullHeight) {

        CGFloat offset = fullHeight - contentHeight;

        for (NSIndexPath *indexPath in [frames allKeys]) {

            CGRect frame = [frames[indexPath] CGRectValue];
            frames[indexPath] = [NSValue valueWithCGRect:CGRectOffset(frame , 0.f, offset)];

        }

    }

    self.frames = frames;
    self.contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), MAX(contentHeight, fullHeight));

}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    layoutAttributes.frame = [_frames[indexPath] CGRectValue];
    return layoutAttributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *collectedLayoutAttributes = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in [_frames allKeys]) {

        CGRect frame = [_frames[indexPath] CGRectValue];
        if (CGRectIntersectsRect(frame, rect)) {

            [collectedLayoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];

        }

    }
    return collectedLayoutAttributes;
}

@end