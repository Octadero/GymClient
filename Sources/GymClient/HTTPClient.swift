/* Copyright 2017 The Octadero Authors. All Rights Reserved.
 Created by Volodymyr Pavliukevych on 2017.
 
 Licensed under the Apache License 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://github.com/Octadero/GymClient/blob/master/LICENSE
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

open class HTTPClient {
    let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    public static let defaultTimeoutInterval: Double = 20
    
    public func get(url: URL, callback: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = HTTPClient.defaultTimeoutInterval
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse, [200, 204].contains(response.statusCode) {
                callback(data, error)
            }else {
                callback(data, URLError(.badServerResponse))
            }
        }
        task.resume()
    }
    
    public func post(url: URL, parameter: Data?, callback: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = HTTPClient.defaultTimeoutInterval
        
        if let parameter = parameter {
            request.httpBody = parameter
        }
        
        let task = urlSession.dataTask(with:request) { (data, response, error) in
            if let response = response as? HTTPURLResponse, [200, 204].contains(response.statusCode) {
                callback(data, error)
            }else {
                callback(data, URLError(.badServerResponse))
            }
        }
        task.resume()
    }
}
