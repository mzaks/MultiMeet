#import <Foundation/Foundation.h>


@interface Advertiser : NSObject <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>
- (void)startAdvertising:(NSString *)foodChoice;
@end