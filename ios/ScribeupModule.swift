import Foundation
import ScribeUpSDK
import React

// MARK: - Error Codes (shared between iOS and Android)
fileprivate enum ErrorCodes {
  static let unknown = -1
  static let invalidUrl = 1001
  static let activityNull = 1002
  static let invalidActivityType = 1003
  static let noRootViewController = 1004
  static let sdkError = 2001
}

@objc(Scribeup)
class Scribeup: RCTEventEmitter {

  // MARK: - RCTEventEmitter Methods

  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc
  override func supportedEvents() -> [String] {
    return ["ScribeupOnExit"]
  }

  // MARK: - Properties

  internal var resolver: RCTPromiseResolveBlock?
  internal var rejecter: RCTPromiseRejectBlock?
  private var subscriptionListener: SubscriptionManagerListener?
  private var hasListeners: Bool = false

  // MARK: - Public Methods

  @objc(presentWithUrl:withProductName:resolver:rejecter:)
  func presentWithParams(url: String, productName: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    self.resolver = resolver
    self.rejecter = rejecter

    let listener = ScribeupSubscriptionListener(delegate: self)
    self.subscriptionListener = listener

    DispatchQueue.main.async {
      guard let rootVC = UIApplication.shared.delegate?.window??.rootViewController else {
        self.rejecter?(String(ErrorCodes.noRootViewController), "Cannot find root view controller", nil)
        return
      }

      let subscriptionVC = SubscriptionManagerViewController(
        url: url,
        productName: productName,
        listener: self.subscriptionListener
      )

      rootVC.present(subscriptionVC, animated: true)
    }
  }

  func sendExitEvent(error: SubscriptionManagerError?) {
    if self.hasListeners {
      var body: [String: Any] = [:]

      if let error = error {
        body["error"] = ["code": ErrorCodes.sdkError, "message": error.message]
      }

      self.sendEvent(withName: "ScribeupOnExit", body: body)
    }
  }

  override func startObserving() {
    self.hasListeners = true
  }

  override func stopObserving() {
    self.hasListeners = false
  }
}

class ScribeupSubscriptionListener: NSObject, SubscriptionManagerListener {
    weak var delegate: Scribeup?

    init(delegate: Scribeup) {
        self.delegate = delegate
    }

    func onExit(_ error: SubscriptionManagerError?) {
        if let delegate = self.delegate {
            if let error = error {
                delegate.rejecter?(String(error.code), error.message, nil)
            } else {
                delegate.resolver?(nil)
            }

            delegate.resolver = nil
            delegate.rejecter = nil
        }

        self.delegate?.sendExitEvent(error: error)
    }
}
