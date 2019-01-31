//
//  TableViewController.swift
//
//  Created by Abdulrahman Al Shathry on 15/05/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit

class TableViewController: ContainerViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override var locationsData: LocationsData? {
        didSet {
            guard let locationsData = locationsData else { return }
            locations = locationsData.studentLocations
        }
    }
    var locations: [StudentLocation] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

}


extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let location = locations[indexPath.row]
        
        let first = location.firstName ?? ""
        let last = location.lastName ?? ""
        
        cell.textLabel?.text = first + " " + last
        return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let application = UIApplication.shared
        if let destination = locations[indexPath.row].mediaURL, let url = URL(string: destination), application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

