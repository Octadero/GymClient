import XCTest
import GymClient

class GymClientTests: XCTestCase {
    static var client: GymClient!
    static var identifier: String = ""
    
    func test0CreateClient(){
        do {
            // Create a client
            GymClientTests.client = try GymClient()
        } catch {
            XCTFail("Can't init client")
        }
    }
    
    func test1GetSessionID(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        // Make a new environment with the CartPole task or Pong-v0
        GymClientTests.client.create(environment: .pongv0) { (session, error) in
            if let id = session?.identifier {
                GymClientTests.identifier = id
            }
            print(#function, session ?? "", error ?? "")
            anExpectation.fulfill()
        }
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test2GetActionSpace(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        // Verify action and observation space
        GymClientTests.client?.actionSpace(InstanceIdentifier: GymClientTests.identifier) { (info, error) in
            print(#function, info ?? "", error ?? "")
            anExpectation.fulfill()
        }
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test3GetObservationSpace(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        GymClientTests.client?.observationSpace(InstanceIdentifier: GymClientTests.identifier) { (info, error) in
            print(#function, "Shape: ", info?.info.shape ?? "", error ?? "")
            anExpectation.fulfill()
        }
        
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test4GetEnvironmentInstances(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        
        GymClientTests.client?.environmentInstances(callback: { (list, error) in
            print(#function, list ?? "")
            anExpectation.fulfill()
        })
        
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test5ContainsObservation(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        //containsAction
        //print(client.containsObservation(InstanceIdentifier: id, observations: ))
        GymClientTests.client?.containsObservation(InstanceIdentifier: GymClientTests.identifier, observations: ["name":"Box"], callback: { (cont, error) in
            print(#function, cont?.member ?? "")
        })
        anExpectation.fulfill()

        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test51ContainsAction(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        GymClientTests.client?.containsAction(InstanceIdentifier: GymClientTests.identifier, action: Action(value: 0), callback: { (cont, error) in
            print(#function, cont?.member ?? "")
        })
        
        anExpectation.fulfill()
        
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test6StartMonitor(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        let baseDirectory = "/tmp/swift-example-agent"
        // Start recording, and wipe out old recordings
        GymClientTests.client?.startMonitor(InstanceIdentifier: GymClientTests.identifier, directory: baseDirectory, force: true, resume: false, videoCallable: true)
        anExpectation.fulfill()
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test7Reset(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        // Refresh to get our first observation
        GymClientTests.client?.reset(InstanceIdentifier: GymClientTests.identifier, callback: { (observation, error) in
            XCTAssertNil(error, error?.localizedDescription ?? "")
            anExpectation.fulfill()
        })
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test71Actions(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        // Find a random action purely as a demonstration. Replace with an action chosen by your algorithm.
        GymClientTests.client?.sampleAction(InstanceIdentifier: GymClientTests.identifier, callback: { (action, error) in
            print(#function, "sampleAction: ", action ?? "")
        })
        anExpectation.fulfill()
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test8Work() {
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")

            // Execute the action in the environment
            GymClientTests.client?.step(InstanceIdentifier: GymClientTests.identifier, action: Action(value: 0), render: false, callbak: { (result, error) in
                print(#function, "Result reward: ", result?.reward ?? "" )
                XCTAssertNil(error, error?.localizedDescription ?? "")
                anExpectation.fulfill()
            })
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Download timeout.")
        }
    }
    
    func test9CloseMonitor(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        // Refresh to get our first observation
        GymClientTests.client?.closeMonitor(InstanceIdentifier: GymClientTests.identifier)
        anExpectation.fulfill()

        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }

    func test91CloseSession(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        // Refresh to get our first observation
        
        GymClientTests.client?.close(InstanceIdentifier: GymClientTests.identifier)
        anExpectation.fulfill()
        
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    func test92Upload(){
        let anExpectation = expectation(description: "TestInvalidatingWithExecution \(#function)")
        // Refresh to get our first observation
        
        // Get your api key from https://gym.openai.com/users/{your_name}
        // client.uploadResults(directory: baseDirectory, apiKey: nil, algorithmID: nil)
        anExpectation.fulfill()
        
        waitForExpectations(timeout: HTTPClient.defaultTimeoutInterval) { error in
            XCTAssertNil(error, "Timeout.")
        }
    }
    
    static var allTests = [
		("test0CreateClient", test0CreateClient),
		("test1GetSessionID", test1GetSessionID),
		("test2GetActionSpace", test2GetActionSpace),
		("test3GetObservationSpace",test3GetObservationSpace ),
		("test4GetEnvironmentInstances", test4GetEnvironmentInstances),
		("test5ContainsObservation", test5ContainsObservation),
		("test51ContainsAction", test51ContainsAction),
		("test6StartMonitor", test6StartMonitor),
		("test7Reset", test7Reset),
		("test71Actions", test71Actions),
		("test8Work", test8Work),
		("test9CloseMonitor", test9CloseMonitor),
		("test91CloseSession", test91CloseSession),
		("test92Upload", test92Upload)
    ]
}
