//
//  User.swift
//  ToDoList
//
//  Created by Phan Nguyen on 6/25/16.
//  Copyright © 2016 Omebee. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class User {
    
    private static var id: String {
        get {
            return UserDefaults.standard.value(forKey: "userId") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userId")
        }
    }
    private static var token: String {
        get {
            return UserDefaults.standard.value(forKey: "token") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "token")
        }
    }
    static var todosDictionary: [String:[String:String]]? {
        get {
            return UserDefaults.standard.value(forKey: "todosDictionary") as? [String:[String:String]]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "todosDictionary")
        }
    }
    static var todoIds: [String]? {
        get {
            if let todosDictionary = todosDictionary {
                return Array(todosDictionary.keys) as [String]?
            } else {
                return [String]()
            }
        }
    }
    
    static func create(email: String, password: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        User.postCredentials(endpoint: APIEndpoints.signupURL, email: email, password: password) { (success) in
            completionHandler(success)
        }
    }
    static func signIn(email: String, password: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        User.postCredentials(endpoint: APIEndpoints.signinURL, email: email, password: password) { (success) in
            completionHandler(success)
        }
    }
    
    static func refreshTodos(completionHandler: @escaping (_ success: Bool) -> ()) {
        Alamofire.request(APIEndpoints.todosURL(User.id), method:.get, encoding: JSONEncoding.default, headers: ["authorization": User.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        var todosDictionary = [String:[String:String]]()
                        if let array = json["todos"].arrayObject {
                            for item in array {
                                if let item = item as? [String:String] {
                                    if let id = item["_id"], let text = item["text"] {
                                       // if let id = id , let text = text{
                                            var dictionaryToStore = [
                                                "text": text
                                            ]
                                            if let imageURL = item["imageURL"] {
                                                dictionaryToStore["imageURL"] = imageURL
                                            }
                                            
                                            todosDictionary[id] = dictionaryToStore
                                      //  }
                                    }
                                }
                            }
                        }
                        User.todosDictionary = todosDictionary
                        completionHandler(true)
                        return
                    }
                case .failure (let error):
                    print("ERR \(response) \(error)")
                }
                completionHandler(false)
        }
    }
    
    static func deleteTodo(id: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        Alamofire.request(APIEndpoints.todoURL(User.id, todoId: id), method:.delete, encoding: JSONEncoding.default, headers: ["authorization": User.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let todosDictionary = User.todosDictionary {
                        var todosDictionary = todosDictionary
                        todosDictionary.removeValue(forKey: id)
                        User.todosDictionary = todosDictionary
                        
                        completionHandler(true)
                        return
                    }
                case .failure (let error):
                    print("ERR \(response) \(error)")
                }
                completionHandler(false)
        }
    }
    
    
    
    
    static func uploadImage(image: UIImage, url: String, completionHandler: @escaping (_ success:Bool) -> ()) {
        if let imageData = UIImageJPEGRepresentation(image, 0.3) {
            Alamofire.upload(imageData,to: url,method:.put, headers: ["Content-Type":"image/jpeg"])
            .validate()
            .response { response in
                if response.error != nil{
                    print("ERR \(response.error)")
                    DispatchQueue.main.async(execute: {
                        completionHandler(false)
                    })
                }else{
                    DispatchQueue.main.async(execute: {
                        completionHandler(true)
                    })
                }
                
            }
            /*.responseJSON { response in
                switch response.result {
                case .success:
                    DispatchQueue.main.async(execute: {
                        completionHandler(true)
                    })
               case .failure (let error):
                    print("ERR \(response) \(error)")
                    DispatchQueue.main.async(execute: {
                        completionHandler(false)
                    })
                }
            }*/
        }
    }
    
    
    static func createTodo(text: String, image: UIImage?, completionHandler: @escaping (_ success: Bool) -> ()) {
        let parameters = [
            "text":text,
            "imagePresent": (image != nil) ? true : false
        ] as [String : Any]
        Alamofire.request(APIEndpoints.todosURL(User.id), method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: ["authorization": User.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        
                        var todos: [String:[String:String]]
                        if let todosDictionary = User.todosDictionary {
                            todos = todosDictionary
                        } else {
                            todos = [String:[String:String]]()
                        }
                        
                        if let todoText = json["text"].string, let todoId = json["id"].string {
                            var dictionaryToStore = [
                                "text": todoText
                            ]
                            if let imageURL = json["getURL"].string {
                                dictionaryToStore["imageURL"] = imageURL
                            }
                            todos[todoId] = dictionaryToStore
                        }
                        
                        
                        User.todosDictionary = todos
                        
                        if (image == nil) {
                            completionHandler(true)
                            return
                        } else {
                            if let postURL = json["postURL"].string {
                                print(postURL)
                                if let image = image {
                                    User.uploadImage(image: image, url: postURL, completionHandler: completionHandler)
                                }
                            }
                        }
                        
                        
                    }
                case .failure (let error):
                    print("ERR \(response) \(error)")
                    completionHandler(false)
                }
        }
    }
    
    private static func postCredentials(endpoint: String, email: String, password: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(endpoint,method:.post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    print(response)
                    if let value = response.result.value {
                        let json = JSON(value)
                        User.id = json["userId"].string!
                        User.token = json["token"].string!
                        
                        var todosDictionary = [String:[String:String]]()
                        if let array = json["todos"].arrayObject {
                            for item in array {
                                if let item = item as? [String:String] {
                                    if let id = item["_id"], let text = item["text"] {
                                        if let url = item["imageURL"]{
                                            todosDictionary[id] = ["text":text,"imageURL":url]
                                        }else{
                                            todosDictionary[id] = ["text":text]
                                        }
                                        
                                    }
                                }
                            }
                        }
                        User.todosDictionary = todosDictionary
                        completionHandler(true)
                        return
                    }
                case .failure(let error):
                    print(error)
                }
                
                completionHandler(false)
        }
    }
}
