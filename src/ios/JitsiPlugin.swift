import Foundation
import AVFoundation
import JitsiMeet

@objc(JitsiPlugin)
class JitsiPlugin : CDVPlugin {
    
    var pluginResult: CDVPluginResult!
    var jitsiMeetView: JitsiMeetView!;
    fileprivate var pipViewCoordinator: PiPViewCoordinator?
    
    override init() { }
    @objc(pluginInitialize) override func pluginInitialize() { NSLog("JitsiPlugin#pluginInitialize()") }
    
    fileprivate func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
    }
    
    @objc(join:) func join(_ command: CDVInvokedUrlCommand) {
        NSLog("JitsiPlugin#join()")
        let serverUrl:String = command.arguments[0] as! String
        let room: String = command.arguments[1] as! String
        let isAudioOnly: Bool = command.arguments[2] as! Bool
        jitsiMeetView = JitsiMeetView.init(frame: self.viewController.view.frame)
        jitsiMeetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        jitsiMeetView.delegate = self
        
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.welcomePageEnabled = false
            builder.serverURL = URL(string: serverUrl)
            builder.room = room;
            builder.subject = "";
            builder.audioOnly = isAudioOnly;
            builder.setFeatureFlag("pip.enabled", withBoolean: true)
        }
        jitsiMeetView.join(options)
        
        let viewController = UIApplication.shared.windows.first!.rootViewController as! CDVViewController

        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: viewController.view)
    }

}

extension JitsiPlugin: JitsiMeetViewDelegate {
    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide() { _ in
                self.cleanUp()
            }
        }
    }

    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.enterPictureInPicture()
        }
    }
}
