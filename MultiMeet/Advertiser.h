#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define kMultiMeetCount @"MultiMeetClientCount"
#define kMultiMeetStart @"MultiMeetStartChating"
#define kMultiMeetMessage @"MultiMeetChatMessage"

@interface Advertiser : NSObject <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>
+ (instancetype) sharedAdvertiser;

- (void)startAdvertising:(NSString *)foodChoice;

- (NSInteger) numberOfConnectedPeers;

- (void)startChatting;

- (void)sendMessage:(NSString *)message;

@property NSString *peerName;
@end