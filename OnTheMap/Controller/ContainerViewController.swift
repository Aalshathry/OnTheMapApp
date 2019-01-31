//
//  ContainerViewController.swift
//
//  Created by Abdulrahman Al Shathry on 15/05/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var locationsData: LocationsData? 

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStudentLocations()
    }
    
    func setupUI() {
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logoutTapped(_:)))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addLocationTapped(_:)))
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshLocationsTapped(_:)))

        navigationItem.rightBarButtonItems = [addButton, refreshButton]
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    @objc private func addLocationTapped(_ sender: Any) {
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocationNavigationController") as! UINavigationController
        
        present(VC, animated: true, completion: nil)
    }
    
    @objc private func refreshLocationsTapped(_ sender: Any) {
        loadStudentLocations()
    }
    
    
    private func loadStudentLocations() {
        API.Parser.getStudentLocations { (data) in
            guard let data = data else {
                self.showAlert(title: "Error", message: "Check your internet connection")
                return
            }
            guard data.studentLocations.count > 0 else {
                self.showAlert(title: "Error", message: "No pins found")
                return
            }
            self.locationsData = data
        }
    }
    
    @objc private func logoutTapped(_ sender: Any) {
        API.deleteSession(){ (errString) in
            guard errString == nil else {
                self.showAlert(title: "Error", message: errString!)
                return
            }
            DispatchQueue.main.async {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC")
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
}
