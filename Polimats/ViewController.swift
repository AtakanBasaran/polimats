import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    let webUrl = "https://polimats.com/"
    private var imageView: UIImageView!
    private var imageViewBackground: UIImageView!
    private var shouldShowAnimation = true
    private var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpBackgroundImage()
        setUpLabel()
        performAnimation()
        loadWebPage()
        setUpBackButton()
        setUpShareButton()
        navigationItem.leftBarButtonItem?.customView?.isHidden = true
        navigationItem.rightBarButtonItem?.customView?.isHidden = true
        gestureRecognizer()
        

    }
    
    
    //MARK: - Swipe Action
    
    private func gestureRecognizer() {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
        gestureRecognizer.direction = .right
        webView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            goBack()
        }
    }
    
    //MARK: - Loading Screen methods
    
    private func setUpBackgroundImage() {
        
        imageViewBackground = UIImageView(image: UIImage(named: "white"))
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
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 100), // Adjust the width as needed
                imageView.heightAnchor.constraint(equalToConstant: 100) // Adjust the height as needed
            ])
    }
    
    private func setUpLabel() {
        label = UILabel()
        label.text = "Berkeyi sikim"
        label.textColor = .black
        label.backgroundColor = .white
        
        view.addSubview(label)
        imageView.bringSubviewToFront(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 60),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { //Removing images and animation
        DispatchQueue.main.async {
            self.imageViewBackground.isHidden = true
            self.imageView.isHidden = true
            self.imageView.layer.removeAllAnimations()
        }
    }

    //MARK: - WebPage Methods
    
    override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
    }

    func loadWebPage() {
        if let url = URL(string: webUrl) {
            let myRequest = URLRequest(url: url)
            webView.load(myRequest)
//            navigationItem.title = "Polimats"
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
        navigationItem.leftBarButtonItem?.customView?.isHidden = !canGoBack
        navigationItem.rightBarButtonItem?.customView?.isHidden = !canGoBack
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
        UIView.transition(with: webView, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            if self.webView.canGoBack {
                self.webView.goBack()
            }
        }, completion: nil)
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
