#import "Advertiser.h"

#define FOOD_CHOICE @"foodChoice"

@implementation Advertiser {
    MCPeerID *_localPeerID;
    MCSession *_session;
    NSString *_foodChoice;
}



-(void)startAdvertising:(NSString *)foodChoice{
    _foodChoice = foodChoice;
    _localPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    _session = [[MCSession alloc] initWithPeer:_localPeerID
                              securityIdentity:nil
                          encryptionPreference:MCEncryptionNone];

    _session.delegate = self;

    MCNearbyServiceAdvertiser *advertiser =
        [[MCNearbyServiceAdvertiser alloc] initWithPeer:_localPeerID
                                          discoveryInfo:nil
                                            serviceType:[self serviceName]];
    advertiser.delegate = self;
    [advertiser startAdvertisingPeer];

    MCNearbyServiceBrowser *browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_localPeerID serviceType:[self serviceName]];
    browser.delegate = self;
    [browser startBrowsingForPeers];
}

- (NSString *)serviceName {
    return [NSString stringWithFormat:@"MultiMeet%@", _foodChoice];
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler {

    invitationHandler(YES, _session);

}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {

    [browser invitePeer:peerID toSession:_session withContext:nil timeout:30];

}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {

}


#pragma SESSION API

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSLog(@"peer %@ connected with state: %li", peerID, state);
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {

}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {

}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {

}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {

}


@end