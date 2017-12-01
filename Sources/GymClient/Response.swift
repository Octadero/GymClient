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

//MARK: Structures
public struct StepResult: Decodable {
    public let observation: [[[UInt8]]]
    public let reward: Double
    public let done: Bool
    public var info = [String : Any]()
    
    enum CodingKeys: String, CodingKey {
        case observation
        case reward
        case done
        case info
    }
    
    enum InfoKeys: String, CodingKey {
        case aleLives = "ale.lives"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let infoContainer = try container.nestedContainer(keyedBy: InfoKeys.self, forKey: .info)
        info[InfoKeys.aleLives.stringValue] = try infoContainer.decode(Int.self, forKey: .aleLives)
        
        observation = try container.decode([[[UInt8]]].self, forKey: .observation)
        reward = try container.decode(Double.self, forKey: .reward)
        done = try container.decode(Bool.self, forKey: .done)
    }
}

public struct Action: Decodable {
    public let value: Int
    public init(value: Int) {
        self.value = value
    }
    enum CodingKeys: String, CodingKey {
        case value = "action"
    }
}

public struct Observation: Decodable {
    public let observation: [[[UInt8]]]
    enum CodingKeys: String, CodingKey {
        case observation = "observation"
    }
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        var nestedUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: .observation)
//        while true {
//            let value = try nestedUnkeyedContainer.nestedUnkeyedContainer()
//            if value.count == nil {
//                break
//            }
//            nestedUnkeyedContainer = value
//        }
//        observation = [Double]()
//    }
}

public struct EnvironmentInstances: Decodable {
    public let list: [String : String]
    enum CodingKeys: String, CodingKey {
        case list = "all_envs"
    }
}

public struct Contained: Decodable {
    public let member: Bool
}

public struct SessionInstance: Decodable {
    public let identifier: String
    enum CodingKeys: String, CodingKey {
        case identifier = "instance_id"
    }
}

public struct ActionSpace: Decodable, CustomStringConvertible {
    public var description: String {
        return "ActionSpace: \(name), n: \(n)"
    }
    
    // Properties for Discrete spaces.
    public let n: Int
    
    // Name is the name of the space, such as "Box", "HighLow",
    // or "Discrete".
    public let name: String
}

public struct ActionSpaceInfo: Decodable, CustomStringConvertible {
    public let info: ActionSpace
    
    public var description: String {
        return "ActionSpaceInfo: \(info)"
    }
}

public struct ObservationSpace: Decodable , CustomStringConvertible {
    public var description: String {
        return "ObservationSpace: shape {\(shape)}\n low{\(low)}\n high{\(high)}\n numberOfRows:{\(numberOfRows ?? 0)}\n matrix:{\(matrix ?? [])}\n"
    }
    
    // Properties for Box spaces.
    public let shape: [Int]
    public let low: [Double]
    public let high: [Double]
    
    // Properties for HighLow spaces.
    public let numberOfRows: Int?
    public let matrix: [Double]?
    
    enum CodingKeys: String, CodingKey {
        case shape
        case low
        case high
        case numberOfRows = "num_rows"
        case matrix
    }
}

public struct ObservationSpaceInfo: Decodable, CustomStringConvertible {
    public var description: String {
        return "ObservationSpaceInfo[ \(info) ]"
    }
    
    public let info: ObservationSpace
}
