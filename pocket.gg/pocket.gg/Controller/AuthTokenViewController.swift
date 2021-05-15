//
//  AuthTokenViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-09-23.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class AuthTokenViewController: UIViewController {
    
    var stackView = UIStackView(frame: .zero)
    let authTokenField = UITextField(frame: .zero)
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupKeyboardToolbar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.widthAnchor.constraint(equalToConstant: stackView.bounds.width).isActive = true
    }
    
    deinit {
        print("AuthTokenViewController deinit")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        let logoImageView = UIImageView(image: UIImage(named: "placeholder"))
        let appNameLabel = UILabel(frame: .zero)
        appNameLabel.text = "pocket.gg"
        appNameLabel.font = UIFont(name: "Baskerville-Bold", size: 50)
        
        stackView = UIStackView(arrangedSubviews: [logoImageView, appNameLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        view.addSubview(stackView)
        stackView.setAxisConstraints(xAnchor: view.centerXAnchor)
        stackView.setEdgeConstraints(top: view.topAnchor, padding: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0))
        
        authTokenField.placeholder = "Auth Token"
        authTokenField.textAlignment = .center
        authTokenField.borderStyle = .roundedRect
        authTokenField.clearButtonMode = .whileEditing
        authTokenField.addTarget(self, action: #selector(verifyAuthToken), for: .editingDidEndOnExit)
        view.addSubview(authTokenField)
        authTokenField.frame = CGRect(x: 0, y: 0, width: stackView.bounds.width, height: 300)
        authTokenField.setAxisConstraints(yAnchor: view.centerYAnchor)
        authTokenField.setEdgeConstraints(leading: stackView.leadingAnchor, trailing: stackView.trailingAnchor)
    }
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let pasteItem = UIBarButtonItem(title: "Paste", style: .plain, target: self, action: #selector(pasteClipboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([pasteItem, flexibleSpace, doneItem], animated: false)
        authTokenField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    
    @objc private func pasteClipboard() {
        guard UIPasteboard.general.hasStrings else { return }
        guard let contents = UIPasteboard.general.string else { return }
        authTokenField.text = (authTokenField.text ?? "") + contents
    }
    
    @objc private func dismissKeyboard() {
        authTokenField.resignFirstResponder()
    }
    
    @objc private func verifyAuthToken() {
        dismissKeyboard()
        UserDefaults.standard.set(authTokenField.text, forKey: k.UserDefaults.authToken)
        ApolloService.shared.updateApolloClient()
        NetworkService.isAuthTokenValid { [weak self] valid in
            if valid {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                guard let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                guard let window = sceneDelegate.window else { return }
                
                let tabBarItems = [UITabBarItem(title: "Tournaments", image: UIImage(named: "tournament"), tag: 0),
                                   UITabBarItem(title: "Settings", image: UIImage(named: "settings"), tag: 1)]
                let tabBarVCs = [UINavigationController(rootViewController: MainViewController(style: .grouped)),
                                 UINavigationController(rootViewController: SettingsViewController(style: .insetGrouped))]
                let tabBarController = UITabBarController()
                tabBarController.viewControllers = tabBarVCs.enumerated().map({ (index, navController) -> UINavigationController in
                    navController.navigationBar.prefersLargeTitles = true
                    navController.tabBarItem = tabBarItems[index]
                    return navController
                })
                tabBarController.selectedIndex = 0
                
                // TODO: Clean up animation
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
                
            } else {
                let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.invalidAuthToken, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
        }
    }
}
