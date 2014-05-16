#import "MMChatViewController.h"
#import "MMMessageCollectionViewCell.h"
#import "MMMessagesCollectionViewLayout.h"
#import "UIView+FLKAutoLayout.h"
#import "Advertiser.h"


@interface MMChatViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (nonatomic) NSMutableArray *messages;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UITextField *textField;

@property (nonatomic) NSLayoutConstraint *textFieldBottomLayoutConstraint;
@end

@implementation MMChatViewController

static NSString *const MMChatViewControllerMessageCellIdentifier = @"messageCell";

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;

    self.messages = [[NSMutableArray alloc] init];

//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddMessage:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageNotification:) name:kMultiMeetMessage object:nil];

    return self;
}

- (void)onMessageNotification:(NSNotification *)notification
{
    
    __block NSString *message = notification.userInfo[@"message"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addMessage:message];
    });
    
}

- (void)onAddMessage:(id)onAddMessage
{


    [self addMessage:@"bla"];

}

- (void)sendMessage:(NSString *)message
{
    [[Advertiser sharedAdvertiser] sendMessage:message];    
}

- (void)addMessage:(NSString *)message
{
    if ([message length] <= 0) return;

    __block NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:[_messages count] inSection:0];

    [_collectionView performBatchUpdates:^{

        [_collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];

        [_messages addObject:message];

    } completion:^(BOOL finished) {

        [_collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];

    }];

}

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];

    MMMessagesCollectionViewLayout *flowLayout = [[MMMessagesCollectionViewLayout alloc] init];

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;

    [collectionView registerClass:[MMMessageCollectionViewCell class] forCellWithReuseIdentifier:MMChatViewControllerMessageCellIdentifier];

    [containerView addSubview:collectionView];
    self.collectionView = collectionView;

    [collectionView alignTop:@"" leading:@"" bottom:@"-50" trailing:@"" toView:containerView];

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor whiteColor];
    textField.delegate = self;

    [containerView addSubview:textField];
    self.textField = textField;

    [textField alignLeading:@"" trailing:@"" toView:containerView];
    self.textFieldBottomLayoutConstraint = [[textField alignBottomEdgeWithView:containerView predicate:@""] firstObject];
    [textField constrainHeight:@"50"];

    self.view = containerView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self registerForKeyboardNotifications];

    [_textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self unregisterFromKeyboardNotifications];
}

- (void)unregisterFromKeyboardNotifications
{

}

- (void)registerForKeyboardNotifications
{

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self selector:@selector(onKeyboardFrameWillChangeNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)onKeyboardFrameWillChangeNotification:(NSNotification *)notification
{

    CGRect newFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    _textFieldBottomLayoutConstraint.constant = -CGRectGetHeight(newFrame);
    _collectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.f, CGRectGetHeight(newFrame), 0.f);
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.f, CGRectGetHeight(newFrame), 0.f);

    [UIView animateKeyframesWithDuration:duration delay:0. options:MMChatViewControllerAnimationOptionsFromCurve(animationCurve) animations:^{

        [_textField.superview layoutIfNeeded];

    } completion:^(BOOL finished) {

    }];

}

static UIViewAnimationOptions MMChatViewControllerAnimationOptionsFromCurve(UIViewAnimationCurve curve)
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
    }
}

#pragma mark UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = _messages[indexPath.item];

    return [MMMessageCollectionViewCell sizeForMessage:message maxWidth:CGRectGetWidth(collectionView.bounds)];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_messages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MMMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MMChatViewControllerMessageCellIdentifier forIndexPath:indexPath];


    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(MMMessageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

    cell.textLabel.text = _messages[indexPath.item];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [self sendMessage:textField.text];

    textField.text = @"";

    return YES;
}


@end