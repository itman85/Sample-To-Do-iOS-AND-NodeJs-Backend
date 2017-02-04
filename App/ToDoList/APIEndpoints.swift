//
//  APIEndpoints.swift
//  ToDoList
//
//  Created by Phan Nguyen on 6/25/16.
//  Copyright © 2016 Omebee. All rights reserved.
//

import Foundation

class APIEndpoints {
    private static let baseURL = "http://192.168.1.3:3001/todo"
    static let signupURL = "\(baseURL)/signup"
    static let signinURL = "\(baseURL)/signin"
    static let getImagePostURL = "\(baseURL)/get_image_upload_token"
    
    static func todosURL (_ userId: String) -> String {
        return "\(baseURL)/users/\(userId)/todos"
    }
    static func todoURL (_ userId: String, todoId: String) -> String {
        return "\(baseURL)/users/\(userId)/todos/\(todoId)"
    }
}
