//
//  LoginViewController.swift
//
//  Created by Abdulrahman Al Shathry on 15/05/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotificationsObserver()
    }
    
    private func setupUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func logInTapped(_ sender: UIButton) {
        API.postSession(username: emailTextField.text!, password: passwordTextField.text!) { (errString) in
            guard errString == nil else {
                self.showAlert(title: "Error", message: errString!)
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
        }
    }
}
