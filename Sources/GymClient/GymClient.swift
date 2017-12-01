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

public typealias InstanceIdentifier = String
public typealias CompletionCallback = (_ error: Error?) -> Void

public enum GymClientError: Error {
    case canNotComputeBaseURL
    case responseDataIsEmpty
}

open class GymClient: HTTPClient {
    /// The URL for the Gym HTTP server
    public let baseURL: URL
    
    /// Creates an instance for interfacing with the Gym HTTP client.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    /// Creates an instance from default server url
    public init(urlString: String = "http://localhost:5000") throws {
        guard let url = URL(string: urlString) else {
            throw GymClientError.canNotComputeBaseURL
        }
        self.baseURL = url
    }
    
    /// Create a new environment with a gym environment ID string i.e. "CartPole-v0"
    /// - returns : An InstanceIdentifier to be used to uniquely identify the environment to be manipulated
    open func create(environment: Environment, callback: @escaping (_ session: SessionInstance?, _ error: Error?) -> Void)  {
        let command = CreateEnvironmentCommand(environment: environment)
        post(pathComponent: "/v1/envs/", command: command, callback: callback)
    }
    
    /// Get all existing environment instances. The list is reset each time the server is reset.
    /// - returns : A dictionary of InstanceIdentifiers and the gym environment ID they are made from
    open func environmentInstances(callback: @escaping (_ instances: EnvironmentInstances?, _ error: Error?) -> Void) {
        get(pathComponent: "/v1/envs/", callback: callback)        
    }
    
    /// Reset the state of the environment
    /// The resulting observation type may vary.
    /// For discrete spaces, it is an Int.
    /// For vector spaces, it is a [Double].
    /// - returns : An initial observation
    open func reset(InstanceIdentifier: InstanceIdentifier, callback: @escaping (_ observation: Observation?, _ error: Error?) -> Void) {
        post(pathComponent: "/v1/envs/\(InstanceIdentifier)/reset/", callback: callback)
    }
    
    /// Run one timestep of the environment's dynamics.
    /// - parameter action : An action to take. For discrete spaces, it should be an Int. For vector spaces, it should be a [Double].
    /// - parameter render : Undocumented functionality XD
    /// - returns : StepResult includes an observation of the current environment, amount of reward after the action, if the simulation is done, and any meta data
    open func step(InstanceIdentifier:InstanceIdentifier, action: Action, render: Bool = false, callbak: @escaping (_ stepResult: StepResult?, _ error: Error?) -> Void) {
        let command = StepCommand(action: action.value, render: render)
        post(pathComponent: "/v1/envs/\(InstanceIdentifier)/step/", command: command, callback: callbak)
    }
    
    /// Sample an action randomly from all possible actions in the environment
    open func sampleAction(InstanceIdentifier:InstanceIdentifier, callback: @escaping (_ action: Action?, _ error: Error?) -> Void) {
        get(pathComponent: "/v1/envs/\(InstanceIdentifier)/action_space/sample", callback: callback)
    }
    
    /// Close the environment instance. Must be done before upload.
    open func close(InstanceIdentifier:InstanceIdentifier, completion: ((_ error: Error?) -> Void)? = nil) {
        post(pathComponent: "/v1/envs/\(InstanceIdentifier)/close/", completion: completion)
    }
    
    /// Stop recording and flush all data to disk.
    /// Two files will be created a meta data file like "openaigym.manifest.5.40273.manifest.json" and a performance file like "openaigym.episode_batch.11.40273.stats.json"
    open func closeMonitor(InstanceIdentifier:InstanceIdentifier, completion: ((_ error: Error?) -> Void)? = nil) {
        post(pathComponent: "/v1/envs/\(InstanceIdentifier)/monitor/close/", completion: completion)
    }
    
    /// Upload the results of training (as automatically recorded by your env's monitor) to OpenAI Gym.
    /// - parameter directory : Absolute path of directory containing recorder files i.e. "/tmp/swift-gym-agent"
    /// - parameter apiKey : Unique key from openai.com on your account page. Can be ignored if already contained in the environment.
    /// - parameter algorithmID : A unique identifer for the algorithm. You can safely leave this nil and it will be autogenerated.
    open func uploadResults(directory:String, apiKey:String?, algorithmID:String? = nil) {
        /*
         let vars = getenv(key)
         guard let apiKey = apiKey ?? environmentVariable(key:"OPENAI_GYM_API_KEY") else { fatalError("No API Key") }
         var data:[String:String] = ["training_dir": directory, "api_key": apiKey]
         if let algorithmID = algorithmID {
         data["algorithm_id"] = algorithmID
         }
         post(url: baseURL.appendingPathComponent("/v1/upload/"), parameter: data)
         */
    }
    
    /// Shut down the server
    open func shutdown() {
        post(pathComponent: "/v1/shutdown/",  completion: nil)
    }
    
    /// Start recording.
    /// - parameter directory : Location to write files. The server will create the directory if it does not exist.
    /// - parameter force : Clear out existing training data from this directory (by deleting every file prefixed with "openaigym.")
    /// - parameter resume : Retain the training data already in this directory, which will be merged with our new data
    open func startMonitor(InstanceIdentifier: InstanceIdentifier, directory: String, force: Bool, resume: Bool, videoCallable: Bool, completion: CompletionCallback?) {
        let command = MonitorCommand(directory: directory, force: force, resume: resume, videoCallable: videoCallable)
        post(pathComponent: "/v1/envs/\(InstanceIdentifier)/monitor/start/", command: command, completion: completion)
    }
    
    /// Checks if observations are all contained in the observation space.
    open func containsObservation(InstanceIdentifier: InstanceIdentifier, observations: [String : String], callback: @escaping (_ contained: Contained?, _ error: Error?) -> Void) {
        post(pathComponent: "/v1/envs/\(InstanceIdentifier)/observation_space/contains", command: observations, callback: callback)
    }
    
    /// Checks if an action is contained in the action space. Currently, only int action types are supported
    open func containsAction(InstanceIdentifier:InstanceIdentifier, action:Action, callback: @escaping (_ contained: Contained?, _ error: Error?) -> Void){
        post(pathComponent: "/v1/envs/\(InstanceIdentifier)/action_space/contains/\(action.value)", callback: callback)
    }
    
    /// Get information (name and dimensions/bounds) of the env's observation_space
    open func observationSpace(InstanceIdentifier: InstanceIdentifier, callback: @escaping (_ info: ObservationSpaceInfo?, _ error: Error?)-> Void) {
        get(pathComponent: "/v1/envs/\(InstanceIdentifier)/observation_space/", callback: callback)
    }
    
    /// Get information (name and dimensions/bounds) of the env's action_space
    open func actionSpace(InstanceIdentifier: InstanceIdentifier, callback: @escaping (_ info: ActionSpaceInfo?, _ error: Error?)-> Void) {
        get(pathComponent: "/v1/envs/\(InstanceIdentifier)/action_space/", callback: callback)
    }
    
    //MARK: - Internal processing
    private func process<T: Decodable>(data: Data?, error: Error?, callback: ((_ object: T?, _ error: Error?) -> Void)?) {
        guard error == nil else {
            if let data = data {
                print(String(data: data, encoding: .utf8) ?? "")
            }
            callback?(nil, error)
            return
        }
        
        guard let data = data else {
            callback?(nil, GymClientError.responseDataIsEmpty)
            return
        }
        
        do {
            if let callback = callback {
                let decoder = JSONDecoder()
                let object: T = try decoder.decode(T.self, from: data)
                callback(object, nil)
            }
        } catch {
            callback?(nil, error)
        }
    }
    
    private func post<T: Decodable, C: Encodable>(pathComponent:String = "", command: C, callback: ((_ object: T?, _ error: Error?) -> Void)? = nil) {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let json = try jsonEncoder.encode(command)
            post(url: baseURL.appendingPathComponent(pathComponent), parameter: json, callback: {(data: Data?, error: Error?) in
                self.process(data: data, error: error, callback: callback)
            })
        } catch {
            callback?(nil, error)
        }
    }
    
    private func post<T: Decodable>(pathComponent:String = "", callback: ((_ object: T?, _ error: Error?) -> Void)? = nil) {
        post(url: baseURL.appendingPathComponent(pathComponent), parameter: nil, callback: {(data: Data?, error: Error?) in
            self.process(data: data, error: error, callback: callback)
        })
    }
    
    private func post<C: Encodable>(pathComponent:String = "", command: C? = nil, completion: CompletionCallback?) {
        do {
            var data: Data? = nil
            if let command = command {
                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = .prettyPrinted
                data = try jsonEncoder.encode(command)
            }
            
            post(url: baseURL.appendingPathComponent(pathComponent), parameter: data, callback: {(data: Data?, error: Error?) in
                completion?(error)
            })
        } catch {
            completion?(error)
        }
    }

    private func post(pathComponent:String = "", completion: CompletionCallback?) {
        post(url: baseURL.appendingPathComponent(pathComponent), parameter: nil, callback: {(data: Data?, error: Error?) in
            completion?(error)
        })
    }
    
    private func get<T: Decodable>(pathComponent:String = "", callback: ((_ object: T?, _ error: Error?) -> Void)?) {
        get(url: baseURL.appendingPathComponent(pathComponent), callback: {(data: Data?, error: Error?) in
            self.process(data: data, error: error, callback: callback)
        })
    }
}
