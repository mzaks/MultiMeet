#import "Advertiser.h"

#define FOOD_CHOICE @"foodChoice"

@implementation Advertiser {
    MCPeerID *_localPeerID;
    MCSession *_session;
    NSString *_foodChoice;
    MCNearbyServiceAdvertiser *_advertiser;
    MCNearbyServiceBrowser *_browser;
    NSSet *_friends;
}

+ (instancetype) sharedAdvertiser {
  static Advertiser* advertiser;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    advertiser = [[Advertiser alloc] init];
  });
  return advertiser;
}

-(void)startAdvertising:(NSString *)foodChoice{
    [_session disconnect];
    _foodChoice = foodChoice;
    _localPeerID = [[MCPeerID alloc] initWithDisplayName:_peerName];
    _session = [[MCSession alloc] initWithPeer:_localPeerID
                              securityIdentity:nil
                          encryptionPreference:MCEncryptionNone];

    _session.delegate = self;

    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_localPeerID
                                          discoveryInfo:nil
                                            serviceType:[self serviceName]];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];

    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_localPeerID serviceType:[self serviceName]];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
}

- (NSString *)serviceName {
    return [NSString stringWithFormat:@"multimeet%@", _foodChoice];
}

- (NSInteger) numberOfConnectedPeers {
  return [[_session connectedPeers] count];
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler {

    BOOL isFriend = !_friends || [_friends containsObject:peerID];
    
    invitationHandler(YES, _session);

}

- (void)startChatting {
    _friends = [NSSet setWithArray:_session.connectedPeers];

    NSData *startChattingMessage = [@"S_" dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;

    [_session sendData:startChattingMessage toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&error];

    if(error){
        NSLog(@"Could not send start chatting message: %@", error);
    }

}

-(void)sendMessage:(NSString *)message {
    NSData *messageData = [[NSString stringWithFormat:@"M_%@", message] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;

    [_session sendData:messageData toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&error];

    if(error){
        NSLog(@"Could not send chat message: %@", error);
    } else {
      [[NSNotificationCenter defaultCenter] postNotificationName:kMultiMeetMessage object:self userInfo:@{
                                                                                                          @"message" : message,
                                                                                                          @"sender" : _localPeerID.displayName
                                                                                                          }];

    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {

    [browser invitePeer:peerID toSession:_session withContext:nil timeout:300];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {

}


#pragma SESSION API
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSLog(@"peer %@ connected with state: %li", peerID, state);
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kMultiMeetCount object:self];
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {

    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"Received message: %@", message);

    if([message hasPrefix:@"S_"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:kMultiMeetStart object:self];
    } else if([message hasPrefix:@"M_"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:kMultiMeetMessage object:self userInfo:@{
            @"message" : [message substringFromIndex:2],
            @"sender" : peerID.displayName
        }];
    }

}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {

}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {

}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {

}


@end