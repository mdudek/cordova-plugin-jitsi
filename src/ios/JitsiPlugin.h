#import <Cordova/CDVPlugin.h>
#import <JitsiMeet/JitsiMeetView.h>
#import <JitsiMeet/JitsiMeetViewDelegate.h>

@interface JitsiPlugin : CDVPlugin<JitsiMeetViewDelegate> {
	JitsiMeetView* jitsiMeetView;
	CDVInvokedUrlCommand* commandBack;
}

- (void)join:(CDVInvokedUrlCommand *)command;
- (void)destroy:(CDVInvokedUrlCommand *)command;
- (void)backButtonPressed:(CDVInvokedUrlCommand *)command;
- (void)conferenceFailed:(NSDictionary *)data;
- (void)conferenceJoined:(NSDictionary *)data;
- (void)conferenceLeft:(NSDictionary *)data;
- (void)conferenceWillJoin:(NSDictionary *)data;
- (void)conferenceTerminated:(NSDictionary *)data;
- (void)loadConfigError:(NSDictionary *)data;

@end
