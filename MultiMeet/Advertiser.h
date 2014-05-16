#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>



@interface Advertiser : NSObject <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>
+ (id) sharedAdvertiser;

- (void)startAdvertising:(NSString *)foodChoice;
@end