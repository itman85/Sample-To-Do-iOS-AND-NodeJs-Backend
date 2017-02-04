//
//  ViewController.swift
//  ToDoList
//
//  Created by Phan Nguyen on 6/25/16.
//  Copyright © 2016 Omebee. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.hidesBackButton = true;
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)

    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signInAction(_ sender: Any) {
        let loader = SwiftLoading()
        loader.showLoading()
        if let email = emailTextField.text, let password = passwordTextField.text {
            User.signIn(email: email, password: password, completionHandler: { (success) in
                if (success) {
                    self.navigationController?.performSegue(withIdentifier: "showTodosViewController", sender: nil)
                } else {
                    print("Sign up failed")
                }
                loader.hideLoading()
            })
        }
    }

    
    
    @IBAction func signUpAction(_ sender: Any) {
        let loader = SwiftLoading()
        loader.showLoading()
        if let email = emailTextField.text, let password = passwordTextField.text {
            User.create(email: email, password: password, completionHandler: { (success) in
                if (success) {
                    self.navigationController?.performSegue(withIdentifier: "showTodosViewController", sender: nil)
                } else {
                    print("Sign up failed")
                }
                loader.hideLoading()
            })
        }
    }

}

