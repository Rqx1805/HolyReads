//
//  TabBarController.swift
//  Holy Reads
//
//  Created by mac-14 on 11/10/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       // self.delegate = self
        self.tabBarController?.delegate = self
        self.delegate = self
    }
    // MARK: - ViewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let HomeViewController = HomeVC()
//        HomeViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
//
//        let DiscoverViewController = DiscoverVC()
//        DiscoverViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
//
//        let MyLibraryViewController = MyLibraryVC()
//        MyLibraryViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
//
//        let SettingViewController = SettingVCViewController()
//        SettingViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 3)
//
//        self.viewControllers = [HomeViewController, DiscoverViewController, MyLibraryViewController, SettingViewController]
    }
    
    // UITabBarControllerDelegate method
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("Selected \(viewController.title!)")
//    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[1] {
            UserDefaults.standard.set(0, forKey: "SelectedCategory")
            return true
        }
        else{
            return true
        }
    }
  
    
//    viewControllers = tabBarList
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
