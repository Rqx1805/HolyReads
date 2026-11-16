//
//  ReadList_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class ReadList_IpadVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tblReadList: UITableView!
    @IBOutlet weak var viewMenu: UIView!
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tblReadList.rowHeight = UITableView.automaticDimension
        tblReadList.estimatedRowHeight = 35
        viewMenu.addShadowView()
    }
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadList_IpadCell", for: indexPath) as! ReadList_IpadCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "Read_IpadVC") as! Read_IpadVC
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    
}
