import Foundation
import AVFoundation
import JitsiMeet

class JitsiPlugin : CDVPlugin, JitsiMeetViewDelegate {
    
    var jitsiMeetView: JitsiMeetView!;
    var callbackId: String!
    fileprivate var pipViewCoordinator: PiPViewCoordinator?

    fileprivate func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
    }

    @objc(join:) func join(_ command: CDVInvokedUrlCommand) {
        callbackId = command.callbackId
        let serverUrl:String = command.arguments[0] as! String
        let room: String = command.arguments[1] as! String
        let isAudioOnly: Bool = command.arguments[2] as! Bool
        let subject: String = command.arguments[3] as! String
        let userName: String = command.arguments[4] as! String

        jitsiMeetView = JitsiMeetView.init(frame: self.viewController.view.frame)
        jitsiMeetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        jitsiMeetView.delegate = self

        let userInfo = JitsiMeetUserInfo.init(displayName: userName, andEmail: nil, andAvatar: nil );
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.welcomePageEnabled = false
            builder.serverURL = URL(string: serverUrl)
            builder.room = room
            builder.subject = subject
            builder.userInfo = userInfo
            builder.audioOnly = isAudioOnly
            builder.audioMuted = false
            builder.videoMuted = false
            builder.setFeatureFlag("pip.enabled", withBoolean: false)
            builder.setFeatureFlag("chat.enabled", withBoolean: false)
            builder.setFeatureFlag("invite.enabled", withBoolean: false)
            builder.setFeatureFlag("calendar.enabled", withBoolean: false)
            builder.setFeatureFlag("call-integration.enabled", withBoolean: false)
            builder.setFeatureFlag("live-streaming.enabled", withBoolean: false)
            builder.setFeatureFlag("meeting-password.enabled", withBoolean: false)
            builder.setFeatureFlag("raise-hand.enabled", withBoolean: false)
            builder.setFeatureFlag("recording.enabled", withBoolean: false)
            builder.setFeatureFlag("video-share.enabled", withBoolean: false)
            builder.setFeatureFlag("add-people.enabled", withBoolean: false)
        }
        jitsiMeetView.join(options)
        
        let viewController = UIApplication.shared.windows.first!.rootViewController as! CDVViewController

        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: viewController.view)
    }

    @objc(destroy:) func destroy(_ command: CDVInvokedUrlCommand) {
        if((jitsiMeetView) != nil) {
            jitsiMeetView.removeFromSuperview()
            jitsiMeetView = nil
        }
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "DESTROYED")
        self.emit(callbackId, result: pluginResult!)
    }

    @objc(backButtonPressed:) func backButtonPressed(_ command: CDVInvokedUrlCommand) {
    }
    
    func _onJitsiMeetViewDelegateEvent(name: NSString, _ data: [AnyHashable : Any]!) {
            NSLog(
                "[%s:%d] JitsiMeetViewDelegate %@ %@",
                #file, #line, name, data);
    }
    
    func conferenceFailed(_ data: [AnyHashable : Any]!) {
        if((jitsiMeetView) != nil) {
            jitsiMeetView.removeFromSuperview()
            jitsiMeetView = nil
        }

        _onJitsiMeetViewDelegateEvent(name: "CONFERENCE_FAILED", data);
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "CONFERENCE_FAILED")
        pluginResult!.setKeepCallbackAs(true)
        self.emit(callbackId, result: pluginResult!)
    }

    func conferenceJoined(_ data: [AnyHashable : Any]!) {
        _onJitsiMeetViewDelegateEvent(name: "CONFERENCE_JOINED", data);
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "CONFERENCE_JOINED")
        pluginResult!.setKeepCallbackAs(true)
        self.emit(callbackId, result: pluginResult!)
    }

    func conferenceLeft(_ data: [AnyHashable : Any]!) {
        _onJitsiMeetViewDelegateEvent(name: "CONFERENCE_LEFT", data);
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "CONFERENCE_LEFT")
        pluginResult!.setKeepCallbackAs(true)
        self.emit(callbackId, result: pluginResult!)
    }

    func conferenceWillJoin(_ data: [AnyHashable : Any]!) {
        _onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_JOIN", data);
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "CONFERENCE_WILL_JOIN")
        pluginResult!.setKeepCallbackAs(true)
        self.emit(callbackId, result: pluginResult!)
    }

    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        _onJitsiMeetViewDelegateEvent(name: "CONFERENCE_TERMINATED", data);
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "CONFERENCE_TERMINATED")
        pluginResult!.setKeepCallbackAs(true)
        self.emit(callbackId, result: pluginResult!)

        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide() { _ in
                self.cleanUp()
            }
        }
    }
    
    private func loadConfigError(_ data: [AnyHashable : Any]!) {
        _onJitsiMeetViewDelegateEvent(name: "LOAD_CONFIG_ERROR", data);
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "LOAD_CONFIG_ERROR")
        pluginResult!.setKeepCallbackAs(true)
        self.commandDelegate.send(pluginResult, callbackId: callbackId)
    }
    
    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.enterPictureInPicture()
        }
    }
    
    fileprivate func emit(_ callbackId: String, result: CDVPluginResult) {
        DispatchQueue.main.async {
            self.commandDelegate!.send(result, callbackId: callbackId)
        }
    }
}
