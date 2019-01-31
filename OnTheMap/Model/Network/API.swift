//
//  API.swift
//
//  Created by Abdulrahman Al Shathry on 15/05/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation

class API {
    
    private static var userInfo = UserInfo()
    private static var sessionId: String?
    
    static func postSession(username: String, password: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("URL is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let json = try? JSONSerialization.jsonObject(with: newData!, options: []),
                        let dict = json as? [String:Any],
                        let sessionDict = dict["session"] as? [String: Any],
                        let accountDict = dict["account"] as? [String: Any]  {
                        
                        self.userInfo.key = accountDict["key"] as? String
                        self.sessionId = sessionDict["id"] as? String
                       
                    } else {
                        errString = "Parsing was not successful"
                    }
                } else {
                    errString = "Login credintials is not successful"
                }
            } else {
                errString = "Check your internet connection"
            }
            DispatchQueue.main.async {
                completion(errString)
            }
        }
        task.resume()
    }
    
    class Parser {
        
        static func getStudentLocations(limit: Int = 100, skip: Int = 0, orderBy: SLParam = .updatedAt , completion: @escaping (LocationsData?)->Void) {
            guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                var studentLocations: [StudentLocation] = []
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if statusCode >= 200 && statusCode < 300 {
                        
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                            let dict = json as? [String:Any],
                            let results = dict["results"] as? [Any] {
                            
                            for location in results {
                                let data = try! JSONSerialization.data(withJSONObject: location)
                                let studentLocation = try! JSONDecoder().decode(StudentLocation.self, from: data)
                                studentLocations.append(studentLocation)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(LocationsData(studentLocations: studentLocations))
                }
                
            }
            task.resume()
        }
        
        static func postLocation(_ location: StudentLocation, completion: @escaping (String?)->Void) {
            
            guard let UserID = userInfo.key, let url = URL(string: "\(APIConstants.STUDENT_LOCATION)") else {
                completion("URL is invalid")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue

            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            request.httpBody = "{\"uniqueKey\": \"\(UserID)\", \"firstName\": \"\(location.firstName ?? "Russel")\", \"lastName\": \"\(location.lastName ?? "Wilson")\", \"mapString\": \"\(location.mapString!)\", \"mediaURL\": \"\(location.mediaURL!)\", \"latitude\": \(location.latitude!), \"longtiude\": \(location.longitude!)}".data(using: .utf8)
            
            let session = URLSession.shared

            let task = session.dataTask(with: request) { data, response, error in

                var err: String?
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if statusCode >= 400{
                        print(statusCode)
                        err = "Error in posting location"
                    }
                } else {
                    err = "Please check your internet connection"
                }
                DispatchQueue.main.async {
                    completion(err)
                }

            }
            task.resume()
        
            
        }
        
    }
    
    
    static func deleteSession(completion: @escaping (String?)->Void) {
        
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("URL is invalid")
            return
        }
        var request = URLRequest(url: url)

        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie}
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
            
            let newData = data?.subdata(in: 5..<data!.count)
            print(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
        
        task.resume()
        }
}
