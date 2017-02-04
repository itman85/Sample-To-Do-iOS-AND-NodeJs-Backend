//
//  NewToDoViewController.swift
//  ToDoList
//
//  Created by Phan Nguyen on 6/26/16.
//  Copyright © 2016 Omebee. All rights reserved.
//

import UIKit

class NewToDoViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var todoTextField: UITextField!
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         imagePicker.delegate = self
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func addImageButtonPress(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPress(_ sender: Any) {
        
        let loader = SwiftLoading()
        loader.showLoading()
        if let text = todoTextField.text {
            User.createTodo(text: text, image: imagePreview.image, completionHandler: { (success) in
                if (success) {
                    self.navigationController!.performSegue(withIdentifier: "showTodosViewController", sender: nil)
                } else {
                    print("Couldn't create todo")
                }
                loader.hideLoading()
            })
        } else {
            print("No text!")
            loader.hideLoading()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePreview.contentMode = .scaleAspectFit
            imagePreview.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
   }
