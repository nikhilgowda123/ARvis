//  Scene.swift
//  ARvis
//  Created by Nikhil, Ayush.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import ARKit

class StatusViewController: UIViewController {
    // MARK: - Types
    
    enum MessageType {
        case trackingStateEscalation
        case planeEstimation
        case contentPlacement
        case focusSquare
        
        static var all: [MessageType] = [
            .trackingStateEscalation,
            .planeEstimation,
            .contentPlacement,
            .focusSquare
        ]
    }

    @IBOutlet weak private var messagePanel: UIVisualEffectView!
    
    @IBOutlet weak private var messageLabel: UILabel!
    
    @IBOutlet weak private var restartExperienceButton: UIButton!

    var restartExperienceHandler: () -> Void = {}

    private let displayDuration: TimeInterval = 6
    
    private var messageHideTimer: Timer?
    
    private var timers: [MessageType: Timer] = [:]
    
    func showMessage(_ text: String, autoHide: Bool = true) {
        messageHideTimer?.invalidate()
        messageLabel.text = text
        setMessageHidden(false, animated: true)
        if autoHide {
            messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false, block: { [weak self] _ in
                self?.setMessageHidden(true, animated: true)
            })
        }
    }
    
    func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
        cancelScheduledMessage(for: messageType)
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] timer in
            self?.showMessage(text)
            timer.invalidate()
        })
        
        timers[messageType] = timer
    }
    
    func cancelScheduledMessage(`for` messageType: MessageType) {
        timers[messageType]?.invalidate()
        timers[messageType] = nil
    }
    
    func cancelAllScheduledMessages() {
        for messageType in MessageType.all {
            cancelScheduledMessage(for: messageType)
        }
    }
    func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
        showMessage(trackingState.presentationString, autoHide: autoHide)
    }
    
    func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
        cancelScheduledMessage(for: .trackingStateEscalation)
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [unowned self] _ in
            self.cancelScheduledMessage(for: .trackingStateEscalation)
            
            var message = trackingState.presentationString
            if let recommendation = trackingState.recommendation {
                message.append(": \(recommendation)")
            }
            
            self.showMessage(message, autoHide: false)
        })
        
        timers[.trackingStateEscalation] = timer
    }
    @IBAction private func restartExperience(_ sender: UIButton) {
        restartExperienceHandler()
    }

    private func setMessageHidden(_ hide: Bool, animated: Bool) {
        // The panel starts out hidden, so show it before animating opacity.
        messagePanel.isHidden = false
        
        // Get the right constraint of the message panel.
        let rightConstraint = messagePanel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: messagePanel.bounds.width-130)
        
        guard animated else {
            messagePanel.alpha = hide ? 0 : 1
            rightConstraint.isActive = !hide
            messageLabel.textAlignment = .center
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.messagePanel.alpha = hide ? 0 : 1
            self.messagePanel.backgroundColor = hide ? UIColor.clear : UIColor.white.withAlphaComponent(0.2)
            self.messageLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            rightConstraint.isActive = !hide
            self.messageLabel.textAlignment =  .center
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if !hide {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    self.setMessageHidden(true, animated: true)
                }
            }
        })
    }



}
extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "Scanning not Available"
        case .normal:
            return "Scanning! Dont move the Phone"
        case .limited(.excessiveMotion):
            return "Cannot Scan\nToo much motion"
        case .limited(.insufficientFeatures):
            return "Cannot Scan\nLow detail"
        case .limited(.initializing):
            return "Scanning the Poster"
        case .limited(.relocalizing):
            return "Re-Scanning"
        }
    }
    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "Try slowing down your movement, or reset the session."
        case .limited(.insufficientFeatures):
            return "Try pointing at a flat surface, or reset the session."
        case .limited(.relocalizing):
            return "Return to the location where you left off or try resetting the session."
        default:
            return nil
        }
    }
}
