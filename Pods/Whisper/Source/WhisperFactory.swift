import UIKit

public enum WhisperAction: String {
  case Present = "Whisper.PresentNotification"
  case Show = "Whisper.ShowNotification"
}

let whisperFactory: WhisperFactory = WhisperFactory()

public func Whisper(message: Message, to: UINavigationController, action: WhisperAction = .Show) {
  whisperFactory.craft(message: message, navigationController: to, action: action)
}

public func Silent(controller: UINavigationController, after: TimeInterval = 0) {
  whisperFactory.silentWhisper(controller: controller, after: after)
}

class WhisperFactory: NSObject {

  struct AnimationTiming {
    static let movement: TimeInterval = 0.3
    static let switcher: TimeInterval = 0.1
    static let popUp: TimeInterval = 1.5
    static let loaderDuration: TimeInterval = 0.7
    static let totalDelay: TimeInterval = popUp + movement * 2
  }

  var navigationController = UINavigationController()
  var edgeInsetHeight: CGFloat = 0
  var whisperView: WhisperView!
  var delayTimer = Timer()
  var presentTimer = Timer()
  var navigationStackCount = 0

  // MARK: - Initializers

  override init() {
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(WhisperFactory.orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }

  func craft(message: Message, navigationController: UINavigationController, action: WhisperAction) {
    self.navigationController = navigationController
    self.navigationController.delegate = self
    presentTimer.invalidate()

    var containsWhisper = false
    for subview in navigationController.navigationBar.subviews {
      if let whisper = subview as? WhisperView {
        whisperView = whisper
        containsWhisper = true
        break
      }
    }

    if !containsWhisper {
      whisperView = WhisperView(height: navigationController.navigationBar.frame.height, message: message)
      whisperView.frame.size.height = 0
      var maximumY = navigationController.navigationBar.frame.height

      whisperView.transformViews.forEach {
        $0.frame.origin.y = -10
        $0.alpha = 0
      }

      for subview in navigationController.navigationBar.subviews {
        if subview.frame.maxY > maximumY && subview.frame.height > 0 { maximumY = subview.frame.maxY }
      }

      whisperView.frame.origin.y = maximumY
      navigationController.navigationBar.addSubview(whisperView)
    }

    if containsWhisper {
      changeView(message: message, action: action)
    } else {
      switch action {
      case .Present:
        presentView()
      case .Show:
        showView()
      }
    }
  }

  func silentWhisper(controller: UINavigationController, after: TimeInterval) {
    navigationController = controller

    var whisperSubview: WhisperView? = nil
    for subview in navigationController.navigationBar.subviews {
      if let whisper = subview as? WhisperView {
        whisperSubview = whisper
        break
      }
    }

    if whisperSubview == nil {
        return
    }

    whisperView = whisperSubview
    delayTimer.invalidate()
    delayTimer = Timer.scheduledTimer(timeInterval: after, target: self,
      selector: #selector(WhisperFactory.delayFired), userInfo: nil, repeats: false)
  }

  // MARK: - Presentation

  func presentView() {
    moveControllerViews(down: true)

    UIView.animate(withDuration: AnimationTiming.movement, animations: {
      self.whisperView.frame.size.height = WhisperView.Dimensions.height
      for subview in self.whisperView.transformViews {
        subview.frame.origin.y = 0

        if subview == self.whisperView.complementImageView {
          subview.frame.origin.y = (WhisperView.Dimensions.height - WhisperView.Dimensions.imageSize) / 2
        }

        subview.alpha = 1
      }
    })
  }

  func showView() {
    moveControllerViews(down: true)

    UIView.animate(withDuration: AnimationTiming.movement, animations: {
      self.whisperView.frame.size.height = WhisperView.Dimensions.height
      for subview in self.whisperView.transformViews {
        subview.frame.origin.y = 0

        if subview == self.whisperView.complementImageView {
          subview.frame.origin.y = (WhisperView.Dimensions.height - WhisperView.Dimensions.imageSize) / 2
        }

        subview.alpha = 1
      }
      }, completion: { _ in
        self.delayTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self,
          selector: #selector(WhisperFactory.delayFired), userInfo: nil, repeats: false)
    })
  }

  func changeView(message: Message, action: WhisperAction) {
    presentTimer.invalidate()
    delayTimer.invalidate()
    hideView()

    let title = message.title
    let textColor = message.textColor
    let backgroundColor = message.backgroundColor
    let action = action.rawValue

    var array = ["title": title, "textColor" : textColor, "backgroundColor": backgroundColor, "action": action] as [String : Any]
    if let images = message.images { array["images"] = images }

    presentTimer = Timer.scheduledTimer(timeInterval: AnimationTiming.movement * 1.1, target: self,
      selector: #selector(WhisperFactory.presentFired), userInfo: array, repeats: false)
  }

  func hideView() {
    moveControllerViews(down: false)

    UIView.animate(withDuration: AnimationTiming.movement, animations: {
      self.whisperView.frame.size.height = 0
      for subview in self.whisperView.transformViews {
        subview.frame.origin.y = -10
        subview.alpha = 0
      }
      }, completion: { _ in
        self.whisperView.removeFromSuperview()
    })
  }

  // MARK: - Timer methods

  func delayFired(timer: Timer) {
    hideView()
  }

  func presentFired(timer: Timer) {
    guard case let userInfo = timer.userInfo as? [String:Any],
      let title = userInfo?["title"] as? String,
      let textColor = userInfo?["textColor"] as? UIColor,
      let backgroundColor = userInfo?["backgroundColor"] as? UIColor,
      let actionString = userInfo?["action"] as? String else { return }

    var images: [UIImage]? = nil

    if let imageArray = userInfo?["images"] as? [UIImage]? { images = imageArray }

    let action = WhisperAction(rawValue: actionString)
    let message = Message(title: title, textColor: textColor, backgroundColor: backgroundColor, images: images)

    whisperView = WhisperView(height: navigationController.navigationBar.frame.height, message: message)
    navigationController.navigationBar.addSubview(whisperView)
    whisperView.frame.size.height = 0

    var maximumY = navigationController.navigationBar.frame.height

    for subview in navigationController.navigationBar.subviews {
      if subview.frame.maxY > maximumY && subview.frame.height > 0 { maximumY = subview.frame.maxY }
    }

    whisperView.frame.origin.y = maximumY

    action == .Present ? presentView() : showView()
  }

  // MARK: - Animations

  func moveControllerViews(down: Bool) {
    guard let visibleController = navigationController.visibleViewController
      , Config.modifyInset
      else { return }

    let stackCount = navigationController.viewControllers.count

    if down {
      navigationStackCount = stackCount
    } else if navigationStackCount != stackCount {
      return
    }

    if !(edgeInsetHeight == WhisperView.Dimensions.height && down) {
      edgeInsetHeight = down ? WhisperView.Dimensions.height : -WhisperView.Dimensions.height

      UIView.animate(withDuration: AnimationTiming.movement, animations: {
        self.performControllerMove(viewController: visibleController)
      })
    }
  }

  func performControllerMove(viewController: UIViewController) {
    guard Config.modifyInset else { return }

    if let tableView = viewController.view as? UITableView
      , viewController is UITableViewController {
        tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top + edgeInsetHeight, 0, 0, 0)
    } else if let collectionView = viewController.view as? UICollectionView
      , viewController is UICollectionViewController {
        collectionView.contentInset = UIEdgeInsetsMake(collectionView.contentInset.top + edgeInsetHeight, 0, 0, 0)
    } else {
      for view in viewController.view.subviews {
        if let scrollView = view as? UIScrollView {
          scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top + edgeInsetHeight, 0, 0, 0)
        }
      }
    }
  }

  // MARK: - Handling screen orientation

  func orientationDidChange() {
    for subview in navigationController.navigationBar.subviews {
      guard let whisper = subview as? WhisperView else { continue }

      var maximumY = navigationController.navigationBar.frame.height
      for subview in navigationController.navigationBar.subviews where subview != whisper {
        if subview.frame.maxY > maximumY && subview.frame.height > 0 { maximumY = subview.frame.maxY }
      }

      whisper.frame = CGRect(
        x: whisper.frame.origin.x,
        y: maximumY,
        width: UIScreen.main.bounds.width,
        height: whisper.frame.size.height)
      whisper.setupFrames()
    }
  }
}

// MARK: UINavigationControllerDelegate

extension WhisperFactory: UINavigationControllerDelegate {

  func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    var maximumY = navigationController.navigationBar.frame.maxY - UIApplication.shared.statusBarFrame.height

    for subview in navigationController.navigationBar.subviews {
      if subview is WhisperView { navigationController.navigationBar.bringSubview(toFront: subview) }

      if subview.frame.maxY > maximumY && !(subview is WhisperView) {
        maximumY = subview.frame.maxY
      }
    }

    whisperView.frame.origin.y = maximumY
  }

  func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {

    for subview in navigationController.navigationBar.subviews where subview is WhisperView {
      moveControllerViews(down: true)

      if let index = navigationController.viewControllers.index(of: viewController) , index > 0 {
        edgeInsetHeight = -WhisperView.Dimensions.height
        performControllerMove(viewController: navigationController.viewControllers[Int(index) - 1])
        break
      }
    }
  }
}