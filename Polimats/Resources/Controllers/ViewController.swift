import UIKit
import WebKit
import UserNotifications
import Network

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var backButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var shareButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var interfaceButton: UIBarButtonItem!
    @IBOutlet weak var forwardButtonOutlet: UIBarButtonItem!
    
    var webView: WKWebView!
    private let webUrl = "https://polimats.com/"
    private var imageView: UIImageView!
    private var imageViewBackground: UIImageView!
    private var modeScreen: Bool!
    private var refreshControl = UIRefreshControl()
    private var toolBar = true
    var network = Network()
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkConnection()
        updateBackground()
        setUpBackgroundImage()
        setUpLabels()
        performAnimation()
        loadWebPage()
        gestureRecognizer()
        refreshPage()
        webView.scrollView.delegate = self
        hideToolbar()
        backButtonOutlet.isEnabled = false
        forwardButtonOutlet.isEnabled = false
        
    }
    
    //MARK: - Check Connection
    
    func checkConnection() {
        
        network.checkConnection { isConntected in
            if !isConntected {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Bağlantı hatası", message: "Sunucuya bağlanılamıyor. İnternet bağlantını kontrol et ve tekrar dene.", preferredStyle: .alert)
                    let button = UIAlertAction(title: "Tekrar dene", style: .default) { action in
                        self.restartApp()
                    }
                    alertController.addAction(button)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                self.network.monitor.cancel()
                return
            }
        }
    }
    
    //MARK: - Restart the app
    
    func restartApp() {
        if let window = self.view.window {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController()
            window.rootViewController = viewController
        }
    }
    //MARK: - Scroll view behaviour
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
          hideToolbar()
       } else {
           if !toolBar {
               showToolbar()
           }
       }
    }

    func hideToolbar() {
        if navigationController?.isToolbarHidden == false {
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }

    func showToolbar() {
        if navigationController?.isToolbarHidden == true {
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    //MARK: - Refreshing the page
    
    func refreshPage() {
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }

    @objc func reload() {
        webView.reload()
    }
    
    //MARK: - Swipe Action
    
    private func gestureRecognizer() {
        
        let gestureRecognizerBack = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeBack(_ :)))
        gestureRecognizerBack.direction = .right
        webView.addGestureRecognizer(gestureRecognizerBack)
        
        let gestureRecognizerForward = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeForward(_ :)))
        gestureRecognizerForward .direction = .left
        webView.addGestureRecognizer(gestureRecognizerForward )
    }
    
    @objc private func handleSwipeBack(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            goBack()
        }
    }
    
    @objc private func handleSwipeForward(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            goForward()
        }
    }
    //MARK: - Loading screen methods
    
    private func setUpBackgroundImage() {
        
        imageViewBackground = modeScreen ? UIImageView(image: UIImage(named: "dark")) : UIImageView(image: UIImage(named: "white"))
        imageViewBackground.contentMode = .scaleAspectFill
        imageViewBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageViewBackground)
        
        NSLayoutConstraint.activate([
            imageViewBackground.topAnchor.constraint(equalTo: view.topAnchor),
            imageViewBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageViewBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageViewBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])


        imageView = modeScreen ? UIImageView(image: UIImage(named: "polimats-white")) : UIImageView(image: UIImage(named: "polimats-black"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: view.bounds.width / 2.5),
                imageView.heightAnchor.constraint(equalToConstant: view.bounds.height / 2.5)
            ])
    }
    
    private func setUpLabels() {
        
        label.text = "polimats.com"
        label.font = UIFont(name: "Roboto-Bold", size: 18)
        label.textAlignment = .center
        label.textColor = modeScreen ? .white : .black
        label.backgroundColor = .none
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: label2.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
        
        label2.text = "Bildiğinizden daha fazlası"
        label2.font = UIFont(name: "Roboto-Regular", size: 18)
        label2.textAlignment = .center
        label2.textColor = modeScreen ? .white : .black
        label2.backgroundColor = .none
        label2.numberOfLines = 0
        
        label2.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label2)
        
        NSLayoutConstraint.activate([
            label2.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label2.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label2.bottomAnchor.constraint(equalTo: label.topAnchor, constant: view.bounds.height / 6)
            ])
    }
    
    private func performAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi * 2.0
        rotationAnimation.duration = 3.0
        rotationAnimation.repeatCount = .infinity

        imageView.layer.add(rotationAnimation, forKey: nil)
    }
    

    
    //MARK: - Dark or light mode
    
    private func updateBackground() {
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        modeScreen = userInterfaceStyle == .dark
        navigationController?.toolbar.barTintColor = modeScreen ? .black : .white
        shareButtonOutlet.tintColor = modeScreen ? .white : .systemBlue
        interfaceButton.tintColor = modeScreen ? .white : .systemBlue
        interfaceButton.image = UIImage(systemName: "circle.lefthalf.filled")

        if !backButtonOutlet.isEnabled {
            backButtonOutlet.tintColor = .gray
        } else {
            backButtonOutlet.tintColor = modeScreen ? .white : .systemBlue
        }
        
        if !forwardButtonOutlet.isEnabled {
            forwardButtonOutlet.tintColor = .gray
        } else {
            forwardButtonOutlet.tintColor = modeScreen ? .white : .systemBlue
        }
        
    }
    
    @IBAction func changeInterface(_ sender: UIBarButtonItem) {
        if modeScreen {
            overrideUserInterfaceStyle = .light
            
        } else {
            overrideUserInterfaceStyle = .dark
        }
        webView.reload()
        updateBackground()
        feedbackGenerator.impactOccurred()
    }
    
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { //Removing images and animation
        
        DispatchQueue.main.async {
            self.imageViewBackground.isHidden = true
            self.imageView.isHidden = true
            self.imageView.layer.removeAllAnimations()
            self.label.isHidden = true
            self.label2.isHidden = true
            self.refreshControl.endRefreshing()
            self.showToolbar()
            self.toolBar = false
            self.updateBackground()
        }
    }
    
    //MARK: - WebPage Methods
    
    override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil) //Adding observers for the navigations
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)

    }

    func loadWebPage() {
        if let url = URL(string: webUrl) {
            let myRequest = URLRequest(url: url)
            webView.load(myRequest)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.canGoBack) {
            if let newValue = change?[.newKey] as? Bool {
                updateBackButtonVisibility(canGoBack: newValue)
            }
        } else if keyPath == #keyPath(WKWebView.canGoForward) {
            if let newValue = change?[.newKey] as? Bool {
                updateForwardButtonVisibility(canGoForward: newValue)
            }
        }
    }

    private func updateBackButtonVisibility(canGoBack: Bool) {
        backButtonOutlet.isEnabled = canGoBack ? true : false
        interfaceButton.isHidden = canGoBack ? true : false
        updateBackground()
    }
    
    private func updateForwardButtonVisibility(canGoForward: Bool) {
        forwardButtonOutlet.isEnabled = canGoForward ? true : false
        updateBackground()
    }
    
    
    deinit {
        // To prevent potential memory leaks when the view controller is deallocated
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
    }

    //MARK: - Toolbar buttons
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        goBack()
    }
    
    @IBAction func forwardButton(_ sender: UIBarButtonItem) {
        goForward()
    }
    
     private func goBack() {
        if self.webView.canGoBack {
            UIView.transition(with: webView, duration: 0.6, options: .transitionFlipFromLeft, animations:  {
                self.webView.goBack()
            }, completion: nil)
        }
    }
    
     private func goForward() {
        
        if self.webView.canGoForward {
            UIView.transition(with: webView, duration: 0.6, options: .transitionFlipFromRight, animations: {
                self.webView.goForward()
            }, completion: nil)
        }
    }
    
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        feedbackGenerator.impactOccurred()
        shareUrl()
        
    }
    
    @objc private func shareUrl() {
        
        if let currentURL = webView.url {
            let activityViewController = UIActivityViewController(activityItems: [currentURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } else {
            print("url cannot be retrieved")
        }
    }
    
    
}
