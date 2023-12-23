import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var label: UILabel!
    
    var webView: WKWebView!
    private let webUrl = "https://polimats.com/"
    private var imageView: UIImageView!
    private var imageViewBackground: UIImageView!
    private var modeScreen: Bool!
    private var refreshControl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackground()
        setUpBackgroundImage()
        setUpLabel()
        performAnimation()
        loadWebPage()
        setUpBackButton()
        setUpShareButton()
        navigationController?.setNavigationBarHidden(true, animated: false)
        gestureRecognizer()
        refreshPage()
      
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
    
    //MARK: - Loading Screen methods
    
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


        imageView = UIImageView(image: UIImage(named: "loading"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -imageView.frame.height / 5),
                imageView.widthAnchor.constraint(equalToConstant: view.bounds.width / 3),
                imageView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3)
            ])
    }
    
    private func setUpLabel() {
        
        label.text = "Bildiğinizden daha fazlası"
        label.textAlignment = .center
        label.textColor = modeScreen ? .white : .black
        label.backgroundColor = .none
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.bounds.height / 3)
            ])
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBackground()
        webView.reload()
    }
    
    private func updateBackground() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        modeScreen = userInterfaceStyle == .dark
    }

    private func performAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi * 2.0
        rotationAnimation.duration = 3.0
        rotationAnimation.repeatCount = .infinity

        imageView.layer.add(rotationAnimation, forKey: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { //Removing images and animation
        
        DispatchQueue.main.async {
            self.imageViewBackground.isHidden = true
            self.imageView.isHidden = true
            self.imageView.layer.removeAllAnimations()
            self.label.isHidden = true
            self.refreshControl.endRefreshing()
        }
        if webView.canGoBack {
            webView.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    

    //MARK: - WebPage Methods
    
    override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
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
        }
    }

    private func updateBackButtonVisibility(canGoBack: Bool) { //There is no back button in the main page
        navigationController?.setNavigationBarHidden(!canGoBack, animated: false)

    }

    deinit {
        // To prevent potential memory leaks when the view controller is deallocated
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
    }

    private func setUpBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.setTitleColor(.tintColor, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc private func goBack() {
    
        if self.webView.canGoBack {
            UIView.transition(with: webView, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                self.webView.goBack()
            }, completion: nil)
        }
    }
    
    @objc private func goForward() {
        
        if self.webView.canGoForward {
            UIView.transition(with: webView, duration: 0.6, options: .transitionFlipFromRight, animations: {
                self.webView.goForward()
            }, completion: nil)
        }
    }
    
    private func setUpShareButton() {
        let shareButton = UIButton(type: .custom)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.setTitleColor(.tintColor, for: .normal)
        shareButton.addTarget(self, action: #selector(shareUrl), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
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
