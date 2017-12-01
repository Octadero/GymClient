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

//MARK: - Commands

public struct CreateEnvironmentCommand: Encodable {
    let environmentID: String
    
    enum CodingKeys: String, CodingKey {
        case environmentID = "env_id"
    }
    
    init(environment: Environment) {
        environmentID = environment.id
    }
}

public struct MonitorCommand: Encodable {
    let directory: String
    let force: Bool
    let resume: Bool
    let videoCallable: Bool
    
    enum CodingKeys: String, CodingKey {
        case directory
        case force
        case resume
        case videoCallable = "video_callable"
    }
}

public struct StepCommand: Encodable {
    public let action: Int
    public let render: Bool
    
    public init(action: Int, render: Bool) {
        self.action = action
        self.render = render
    }
}
