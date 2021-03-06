#import "JitsiPlugin.h"
#import <JitsiMeet/JitsiMeetView.h>
#import <JitsiMeet/JitsiMeetUserInfo.h>

@implementation JitsiPlugin

CDVPluginResult *pluginResult = nil;

- (void)join:(CDVInvokedUrlCommand *)command {
    NSString* serverUrl = [command.arguments objectAtIndex:0];
    NSString* room = [command.arguments objectAtIndex:1];
    Boolean isAudioOnly = [[command.arguments objectAtIndex:2] boolValue];
    NSString* subject = [command.arguments objectAtIndex:3];
    NSString* userName = [command.arguments objectAtIndex:4];
    commandBack = command;
    jitsiMeetView = [[JitsiMeetView alloc] initWithFrame:self.viewController.view.frame];
    jitsiMeetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    jitsiMeetView.delegate = self;

    JitsiMeetUserInfo* userInfo = [[JitsiMeetUserInfo alloc] initWithDisplayName:userName andEmail: nil andAvatar: nil];

    JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
        builder.serverURL = [NSURL URLWithString: serverUrl];
        builder.room = room;
        builder.welcomePageEnabled = NO;
        builder.audioOnly = isAudioOnly;
        builder.subject = subject ?: @" ";
        builder.userInfo = userInfo;
        builder.welcomePageEnabled = NO;
        builder.audioMuted = NO;
        builder.videoMuted = NO;
        [builder setFeatureFlag:@"chat.enabled" withBoolean:false];
        [builder setFeatureFlag:@"invite.enabled" withBoolean:false];
        [builder setFeatureFlag:@"calendar.enabled" withBoolean:false];
        [builder setFeatureFlag:@"pip.enabled" withBoolean:false];
        [builder setFeatureFlag:@"call-integration.enabled" withBoolean:false];
        [builder setFeatureFlag:@"live-streaming.enabled" withBoolean: false];
        [builder setFeatureFlag:@"meeting-password.enabled" withBoolean: false];
        [builder setFeatureFlag:@"raise-hand.enabled" withBoolean: false];
        [builder setFeatureFlag:@"recording.enabled" withBoolean: false];
        [builder setFeatureFlag:@"video-share.enabled" withBoolean: false];
        [builder setFeatureFlag:@"add-people.enabled" withBoolean: false];
    }];

    [jitsiMeetView join: options];
    [self.viewController.view addSubview:jitsiMeetView];
}


- (void)destroy:(CDVInvokedUrlCommand *)command {
    if(jitsiMeetView){
        [jitsiMeetView removeFromSuperview];
        jitsiMeetView = nil;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"DESTROYED"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)backButtonPressed:(CDVInvokedUrlCommand *)command {

}

void _onJitsiMeetViewDelegateEvent(NSString *name, NSDictionary *data) {
    NSLog(
        @"[%s:%d] JitsiMeetViewDelegate %@ %@",
        __FILE__, __LINE__, name, data);

}

- (void)conferenceFailed:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_FAILED", data);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"CONFERENCE_FAILED"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandBack.callbackId];
}

- (void)conferenceJoined:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_JOINED", data);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"CONFERENCE_JOINED"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandBack.callbackId];
}

- (void)conferenceLeft:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_LEFT", data);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"CONFERENCE_LEFT"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandBack.callbackId];

}

- (void)conferenceWillJoin:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_WILL_JOIN", data);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"CONFERENCE_WILL_JOIN"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandBack.callbackId];
}

- (void)conferenceTerminated:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_TERMINATED", data);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"CONFERENCE_TERMINATED"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandBack.callbackId];
}

- (void)loadConfigError:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"LOAD_CONFIG_ERROR", data);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"LOAD_CONFIG_ERROR"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandBack.callbackId];
}


@end
