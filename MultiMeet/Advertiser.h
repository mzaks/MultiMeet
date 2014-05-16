#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define kMultiMeetCount @"MultiMeetClientCount"

@interface Advertiser : NSObject <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>
+ (id) sharedAdvertiser;

- (void)startAdvertising:(NSString *)foodChoice;

- (NSInteger) numberOfConnectedPeers;
@end