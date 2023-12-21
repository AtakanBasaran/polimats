//
//  LaunchViewController.swift
//  Polimats
//
//  Created by Atakan Başaran on 21.12.2023.
//

import UIKit

class LaunchViewController: UIViewController {
    
    private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpImage()
        performAnimation()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.performSegue(withIdentifier: "toVC", sender: nil)
        }
    }
    
    private func setUpImage() {
        imageView = UIImageView(image: UIImage(named: "polimats"))
        imageView.contentMode = .scaleAspectFit
        imageView.center = view.center
        view.addSubview(imageView)
    }
    
    private func performAnimation() {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi * 2.0
        rotationAnimation.duration = 3.0
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.repeatCount = .infinity
        
        imageView.layer.add(rotationAnimation, forKey: nil)
    }
    
    
    

}
