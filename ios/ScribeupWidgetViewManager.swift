import Foundation
import ScribeUpSDK
import React

@objc(ScribeupWidgetViewManager)
class ScribeupWidgetViewManager: RCTViewManager {

  override func view() -> UIView! {
    return ScribeupWidgetView()
  }

  @objc override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc func reload(_ reactTag: NSNumber) {
    DispatchQueue.main.async {
      self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
        if let view = viewRegistry?[reactTag] as? ScribeupWidgetView {
          view.reload()
        }
      }
    }
  }
  
  @objc func loadURL(_ reactTag: NSNumber, url: String) {
    DispatchQueue.main.async {
      self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
        if let view = viewRegistry?[reactTag] as? ScribeupWidgetView {
          view.loadURL(url)
        }
      }
    }
  }
}

class ScribeupWidgetView: UIView {
  
  private var widgetView: SubscriptionManagerWidgetView?
  private var _url: String = ""
  
  @objc var url: String = "" {
    didSet {
      _url = url
      updateWidgetView()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    backgroundColor = UIColor.clear
  }
  
  private func updateWidgetView() {
    // Remove existing widget view if any
    widgetView?.removeFromSuperview()
    widgetView = nil
    
    // Create new widget view if URL is provided
    if !_url.isEmpty {
      widgetView = SubscriptionManagerWidgetView(url: _url)
      
      if let widgetView = widgetView {
        addSubview(widgetView)
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
          widgetView.topAnchor.constraint(equalTo: topAnchor),
          widgetView.bottomAnchor.constraint(equalTo: bottomAnchor),
          widgetView.leadingAnchor.constraint(equalTo: leadingAnchor),
          widgetView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
      }
    }
  }
  
  // MARK: - Public Methods for React Native
  
  @objc func reload() {
    widgetView?.reload()
  }
  
  @objc func loadURL(_ urlString: String) {
    widgetView?.loadURL(urlString)
  }
}