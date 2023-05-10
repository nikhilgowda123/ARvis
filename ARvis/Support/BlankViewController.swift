//  Scene.swift
//  ARvis
//  Created by Nikhil, Ayush.
//  Copyright © 2023 Apple. All rights reserved.
//

class BlankViewController: UIViewController {
    
    weak var delegate: BlankViewControllerDelegate?
    override func viewDidLoad() {
        
        super.viewDidLoad()
               
               // Set the background color to white
               view.backgroundColor = .white
               
               // Create a button
               let button = UIButton(type: .system)
               button.setTitle("Tap to Scan Movie Poster!", for: .normal)
               button.setTitleColor(.white, for: .normal)
               button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
               button.backgroundColor = .systemBlue
               button.layer.cornerRadius = 10
               button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
               view.addSubview(button)
               
               // Add ARvis heading title above the button
               let titleLabel = UILabel()
               titleLabel.text = "ARvis"
                titleLabel.textColor = UIColor.black
               titleLabel.font = UIFont.systemFont(ofSize: 70, weight: .bold)
               view.addSubview(titleLabel)
               
               // Add image view on top of title label
               let imageView = UIImageView(image: UIImage(named: "application"))
               imageView.contentMode = .scaleAspectFit
               view.addSubview(imageView)
               
               // Position the title label, image view, and button in the center of the view
               titleLabel.translatesAutoresizingMaskIntoConstraints = false
               imageView.translatesAutoresizingMaskIntoConstraints = false
               button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -80),

            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80 * 0.7 * 0.25), // updated constraint
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 200 * 0.55), // updated constraint
            button.widthAnchor.constraint(equalTo: button.titleLabel!.widthAnchor, constant: 20),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])



    }
    
    @objc func buttonPressed() {
        guard let parentViewController = parent as? ViewController else {
            fatalError("Could not get parent view controller")
        }
        parentViewController.setupOverlayScene()
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
}
    
    @objc func dismissViewController() {
            dismiss(animated: true) {
                self.delegate?.blankViewControllerDidDismiss()
            }
        }
    
}
