//
//  CloudKitOperationTests.swift
//  Operations
//
//  Created by Daniel Thorpe on 05/01/2016.
//
//

import XCTest
import CloudKit
@testable import Operations

class CloudKitOperationTests: OperationTests { }

// MARK: CKOperation Tests

class TestCloudOperation: NSOperation, CKOperationType {
    var container: String? // just a test
}

class CloudOperationTests: CloudKitOperationTests {

    var target: TestCloudOperation!
    var operation: CloudKitOperation<TestCloudOperation>!

    override func setUp() {
        super.setUp()
        target = TestCloudOperation()
        operation = CloudKitOperation(target)
    }

    func test__get_countainer() {
        let container = "I'm a test container!"
        target.container = container
        XCTAssertEqual(operation.container, container)
    }

    func test__set_database() {
        let container = "I'm a test container!"
        operation.container = container
        XCTAssertEqual(target.container, container)
    }
}

// MARK: CKDatabaseOperation Tests

class TestDatabaseOperation: TestCloudOperation, CKDatabaseOperationType {
    var database: String? // just a test
}

class DatabaseOperationTests: CloudKitOperationTests {

    var target: TestDatabaseOperation!
    var operation: CloudKitOperation<TestDatabaseOperation>!

    override func setUp() {
        super.setUp()
        target = TestDatabaseOperation()
        operation = CloudKitOperation(target)
    }

    func test__get_database() {
        let db = "I'm a test database!"
        target.database = db
        XCTAssertEqual(operation.database, db)
    }

    func test__set_database() {
        let db = "I'm a test database!"
        operation.database = db
        XCTAssertEqual(target.database, db)
    }
}

// MARK: CKDiscoverAllContactsOperation Tests

class TestDiscoverAllContactsOperation: TestCloudOperation, CKDiscoverAllContactsOperationType {

    var result: [CKDiscoveredUserInfo]?
    var error: NSError?
    var discoverAllContactsCompletionBlock: (([CKDiscoveredUserInfo]?, NSError?) -> Void)? = .None

    init(result: [CKDiscoveredUserInfo]? = .None, error: NSError? = .None) {
        self.result = result
        self.error = error
        super.init()
    }

    override func main() {
        discoverAllContactsCompletionBlock?(result, error)
    }
}

class DiscoverAllContactsOperationTests: CloudKitOperationTests {

    var target: TestDiscoverAllContactsOperation!
    var operation: CloudKitOperation<TestDiscoverAllContactsOperation>!

    override func setUp() {
        super.setUp()
        target = TestDiscoverAllContactsOperation(result: [])
        operation = CloudKitOperation(target)
    }

    func test__setting_completion_block() {
        operation.setDiscoverAllContactsCompletionBlock { _ in
            // etc
        }
        XCTAssertNotNil(operation.configure)
    }

    func test__setting_completion_block_to_nil() {
        operation.setDiscoverAllContactsCompletionBlock(.None)
        XCTAssertNil(operation.configure)
    }

    func test__execution_after_cancellation() {
        operation.cancel()
        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertTrue(operation.cancelled)
    }

    func test__successful_execution_without_completion_block() {

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
    }

    func test__error_without_completion_block() {
        target.error = NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: nil)

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
    }

    func test__success_with_completion_block() {
        var result: [CKDiscoveredUserInfo]? = .None
        operation.setDiscoverAllContactsCompletionBlock { userInfos in
            result = userInfos
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertNotNil(result)
        XCTAssertTrue(result!.isEmpty)
    }

    func test__error_with_completion_block() {
        target.error = NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: nil)

        operation.setDiscoverAllContactsCompletionBlock { userInfos in
            // etc
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertEqual(operation.errors.count, 1)
    }

    func test__error_with_recovery_block() {
        target.error = NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: nil)

        var receivedError: ErrorType? = .None
        operation = CloudKitOperation(target) { _, error in
            receivedError = error
            return TestDiscoverAllContactsOperation(result: [])
        }

        var result: [CKDiscoveredUserInfo]? = .None
        operation.setDiscoverAllContactsCompletionBlock { userInfos in
            result = userInfos
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertNotNil(receivedError)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.isEmpty)
    }
}

// MARK: CKDiscoverUserInfosOperation Tests

class TestDiscoverUserInfosOperation: TestCloudOperation, CKDiscoverUserInfosOperationType {

    var emailAddresses: [String]?
    var userRecordIDs: [CKRecordID]?
    var userInfosByEmailAddress: [String: CKDiscoveredUserInfo]?
    var userInfoByRecordID: [CKRecordID: CKDiscoveredUserInfo]?
    var error: NSError?
    var discoverUserInfosCompletionBlock: (([String: CKDiscoveredUserInfo]?, [CKRecordID: CKDiscoveredUserInfo]?, NSError?) -> Void)?

    init(userInfosByEmailAddress: [String: CKDiscoveredUserInfo]? = .None, userInfoByRecordID: [CKRecordID: CKDiscoveredUserInfo]? = .None, error: NSError? = .None) {
        self.userInfosByEmailAddress = userInfosByEmailAddress
        self.userInfoByRecordID = userInfoByRecordID
        self.error = error
        super.init()
    }

    override func main() {
        discoverUserInfosCompletionBlock?(userInfosByEmailAddress, userInfoByRecordID, error)
    }
}

class DiscoverUserInfosOperationTests: CloudKitOperationTests {

    var target: TestDiscoverUserInfosOperation!
    var operation: CloudKitOperation<TestDiscoverUserInfosOperation>!

    override func setUp() {
        super.setUp()
        target = TestDiscoverUserInfosOperation(userInfosByEmailAddress: [:], userInfoByRecordID: [:])
        operation = CloudKitOperation(target)
    }

    func test__get_email_addresses() {
        target.emailAddresses = [ "hello@world.com" ]
        XCTAssertNotNil(operation.emailAddresses)
        XCTAssertEqual(operation.emailAddresses!.count, 1)
        XCTAssertEqual(operation.emailAddresses!, [ "hello@world.com" ])
    }

    func test__set_email_addresses() {
        operation.emailAddresses = [ "hello@world.com" ]
        XCTAssertNotNil(target.emailAddresses)
        XCTAssertEqual(target.emailAddresses!.count, 1)
        XCTAssertEqual(target.emailAddresses!, [ "hello@world.com" ])
    }

    func test__get_user_record_ids() {
        target.userRecordIDs = [ CKRecordID(recordName: "Hello World") ]
        XCTAssertNotNil(operation.userRecordIDs)
        XCTAssertEqual(operation.userRecordIDs!.count, 1)
        XCTAssertEqual(operation.userRecordIDs!, [ CKRecordID(recordName: "Hello World") ])
    }

    func test__set_user_record_ids() {
        operation.userRecordIDs = [ CKRecordID(recordName: "Hello World") ]
        XCTAssertNotNil(target.userRecordIDs)
        XCTAssertEqual(target.userRecordIDs!.count, 1)
        XCTAssertEqual(target.userRecordIDs!, [ CKRecordID(recordName: "Hello World") ])
    }

    func test__setting_completion_block() {
        operation.setDiscoverUserInfosCompletionBlock { _ in
            // etc
        }
        XCTAssertNotNil(operation.configure)
    }

    func test__setting_completion_block_to_nil() {
        operation.setDiscoverUserInfosCompletionBlock(.None)
        XCTAssertNil(operation.configure)
    }

    func test__success_with_completion_block() {
        var userInfosByAddress: [String: CKDiscoveredUserInfo]? = .None
        var userInfosByRecordID: [CKRecordID: CKDiscoveredUserInfo]? = .None

        operation.setDiscoverUserInfosCompletionBlock { byAddress, byRecordID in
            userInfosByAddress = byAddress
            userInfosByRecordID = byRecordID
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertNotNil(userInfosByAddress)
        XCTAssertTrue(userInfosByAddress!.isEmpty)

        XCTAssertNotNil(userInfosByRecordID)
        XCTAssertTrue(userInfosByRecordID!.isEmpty)
    }

    func test__error_with_completion_block() {
        target.error = NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: nil)

        operation.setDiscoverUserInfosCompletionBlock { byAddress, byRecordID in
            // etc
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertEqual(operation.errors.count, 1)
    }
}

// MARK: CKFetchNotificationChangesOperation Tests

class TestFetchNotificationChangesOperation: TestCloudOperation, CKFetchNotificationChangesOperationType {

    var error: NSError?
    var finalPreviousServerChangeToken: CKServerChangeToken?

    var previousServerChangeToken: CKServerChangeToken? = .None
    var resultsLimit: Int = 100
    var moreComing: Bool = false
    var notificationChangedBlock: (CKNotification -> Void)? = .None
    var fetchNotificationChangesCompletionBlock: ((CKServerChangeToken?, NSError?) -> Void)? = .None

    init(token: CKServerChangeToken? = .None, error: NSError? = .None) {
        self.finalPreviousServerChangeToken = token
        self.error = error
        super.init()
    }

    override func main() {
        fetchNotificationChangesCompletionBlock?(finalPreviousServerChangeToken, error)
    }
}

class FetchNotificationChangesOperationTests: CloudKitOperationTests {

    var target: TestFetchNotificationChangesOperation!
    var operation: CloudKitOperation<TestFetchNotificationChangesOperation>!

    override func setUp() {
        super.setUp()
        target = TestFetchNotificationChangesOperation(token: .None)
        operation = CloudKitOperation(target)
    }
    
    func test__get_previous_server_change_token() {
        XCTAssertNil(operation.previousServerChangeToken)
    }

    func test__set_previous_server_change_token() {
        operation.previousServerChangeToken = .None
        XCTAssertNil(operation.previousServerChangeToken)
    }

    func test__get_results_limit() {
        target.resultsLimit = 10
        XCTAssertEqual(operation.resultsLimit, 10)
    }

    func test__set_results_limits() {
        operation.resultsLimit = 10
        XCTAssertEqual(target.resultsLimit, 10)
    }

    func test__get_more_coming() {
        target.moreComing = true
        XCTAssertTrue(operation.moreComing)
    }

    func test__get_set_notification_charged_block() {

        var didItWork = false
        operation.notificationChangedBlock = { _ in
            didItWork = true
        }

        guard let block = operation.notificationChangedBlock else {
            XCTFail("Notification Changed Block was not set.")
            return
        }

        let note = CKNotification(fromRemoteNotificationDictionary: [:])
        block(note)
        XCTAssertTrue(didItWork)
    }

    func test__setting_completion_block() {
        operation.setFetchNotificationChangesCompletionBlock { _ in
            // etc
        }
        XCTAssertNotNil(operation.configure)
    }

    func test__setting_completion_block_to_nil() {
        operation.setFetchNotificationChangesCompletionBlock(.None)
        XCTAssertNil(operation.configure)
    }

    func test__success_with_completion_block() {
        var didCallCompletionBlock = false
        operation.setFetchNotificationChangesCompletionBlock { _ in
            // note: It's not possible to create CKServerChangeToken
            // so we can't fully test receiving one.
            didCallCompletionBlock = true
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(didCallCompletionBlock)
    }

    func test__error_with_completion_block() {
        target.error = NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: nil)

        operation.setFetchNotificationChangesCompletionBlock { _ in
            // etc
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertEqual(operation.errors.count, 1)
    }
}

// MARK: - CKMarkNotificationsReadOperation Tests

class TestMarkNotificationsReadOperation: TestCloudOperation, CKMarkNotificationsReadOperationType {

    var notificationIDs: [String]
    var error: NSError?

    var markNotificationsReadCompletionBlock: (([String]?, NSError?) -> Void)?

    init(markIDsToRead: [String] = [], error: NSError? = .None) {
        self.notificationIDs = markIDsToRead
        self.error = error
        super.init()
    }

    override func main() {
        markNotificationsReadCompletionBlock?(notificationIDs, error)
    }
}

class MarkNotificationsReadOperationTests: CloudKitOperationTests {

    var target: TestMarkNotificationsReadOperation!
    var operation: CloudKitOperation<TestMarkNotificationsReadOperation>!

    override func setUp() {
        super.setUp()
        target = TestMarkNotificationsReadOperation(markIDsToRead: [ "this-is-an-id" ])
        operation = CloudKitOperation(target)
    }

    func test__get_notification_id() {
        target.notificationIDs = [ "this-is-an-id" ]
        XCTAssertEqual(operation.notificationIDs, [ "this-is-an-id" ])
    }

    func test__set_notification_id() {
        operation.notificationIDs = [ "this-is-an-id" ]
        XCTAssertEqual(operation.notificationIDs, [ "this-is-an-id" ])
    }

    func test__setting_completion_block() {
        operation.setMarkNotificationReadCompletionBlock { _ in
            // etc
        }
        XCTAssertNotNil(operation.configure)
    }

    func test__setting_completion_block_to_nil() {
        operation.setMarkNotificationReadCompletionBlock(.None)
        XCTAssertNil(operation.configure)
    }

    func test__success_with_completion_block() {
        var receivedNotificationIDs: [String]?
        operation.setMarkNotificationReadCompletionBlock { notificationID in
            receivedNotificationIDs = notificationID
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertEqual(receivedNotificationIDs!, [ "this-is-an-id" ])
    }

    func test__error_with_completion_block() {
        target.error = NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: nil)

        operation.setMarkNotificationReadCompletionBlock { _ in
            // etc
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertEqual(operation.errors.count, 1)
    }
}

// MARK: - CKModifyBadgeOperation Tests

class TestModifyBadgeOperation: TestCloudOperation, CKModifyBadgeOperationType {

    var badgeValue: Int
    var error: NSError?

    var modifyBadgeCompletionBlock: ((NSError?) -> Void)?

    init(value: Int = 0, error: NSError? = .None) {
        self.badgeValue = value
        self.error = error
    }

    override func main() {
        modifyBadgeCompletionBlock?(error)
    }
}

class ModifyBadgeOperationTests: CloudKitOperationTests {

    var target: TestModifyBadgeOperation!
    var operation: CloudKitOperation<TestModifyBadgeOperation>!

    override func setUp() {
        super.setUp()
        target = TestModifyBadgeOperation(value: 9)
        operation = CloudKitOperation(target)
    }

    func test__get_badge_value() {
        XCTAssertEqual(operation.badgeValue, 9)
    }
    
    func test__set_badge_value() {
        operation.badgeValue = 4
        XCTAssertEqual(target.badgeValue, 4)
    }

    func test__setting_completion_block() {
        operation.setModifyBadgeCompletionBlock { _ in
            // etc
        }
        XCTAssertNotNil(operation.configure)
    }

    func test__setting_completion_block_to_nil() {
        operation.setModifyBadgeCompletionBlock(.None)
        XCTAssertNil(operation.configure)
    }

    func test__success_with_completion_block() {
        var blockDidRun = false
        operation.setModifyBadgeCompletionBlock { notificationID in
            blockDidRun = true
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(blockDidRun)
    }

    func test__error_with_completion_block() {
        target.error = NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: nil)

        operation.setModifyBadgeCompletionBlock { _ in
            // etc
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertEqual(operation.errors.count, 1)
    }
}

// MARK: - CKFetchRecordChangesOperation Tests

class TestFetchRecordChangesOperation: TestDatabaseOperation, CKFetchRecordChangesOperationType {

    typealias RecordZoneID = String
    typealias ServerChangeToken = String

    var token: String?
    var data: NSData?
    var error: NSError?

    var recordZoneID: RecordZoneID = "zone-id"
    var previousServerChangeToken: ServerChangeToken? = .None
    var desiredKeys: [String]? = .None
    var resultsLimit: Int = 100
    var recordChangedBlock: ((CKRecord) -> Void)? = .None
    var recordWithIDWasDeletedBlock: ((CKRecordID) -> Void)? = .None
    var fetchRecordChangesCompletionBlock: ((ServerChangeToken?, NSData?, NSError?) -> Void)? = .None
    var moreComing: Bool = false

    init(token: String? = "new-token", data: NSData? = .None, error: NSError? = .None) {
        self.token = token
        self.data = data
        self.error = error
    }

    override func main() {
        fetchRecordChangesCompletionBlock?(token, data, error)
    }

}

class FetchRecordChangesOperationTests: CloudKitOperationTests {

    var target: TestFetchRecordChangesOperation!
    var operation: CloudKitOperation<TestFetchRecordChangesOperation>!

    override func setUp() {
        super.setUp()
        target = TestFetchRecordChangesOperation()
        operation = CloudKitOperation(target)
    }

    func test__get_record_zone_id() {
        XCTAssertEqual(operation.recordZoneID, "zone-id")
    }

    func test__set_record_zone_id() {
        operation.recordZoneID = "a-different-zone-id"
        XCTAssertEqual(target.recordZoneID, "a-different-zone-id")
    }

    func test__get_desired_keys() {
        let keys = [ "desired-key-1",  "desired-key-2" ]
        target.desiredKeys = keys
        XCTAssertNotNil(operation.desiredKeys)
        XCTAssertEqual(operation.desiredKeys!, keys)
    }

    func test__set_desired_keys() {
        let keys = [ "desired-key-1",  "desired-key-2" ]
        operation.desiredKeys = keys
        XCTAssertNotNil(target.desiredKeys)
        XCTAssertEqual(target.desiredKeys!, keys)
    }

    func test__get_record_changed_block() {
        target.recordChangedBlock = { _ in }
        XCTAssertNotNil(operation.recordChangedBlock)
    }
    
    func test__set_record_changed_block() {
        operation.recordChangedBlock = { _ in }
        XCTAssertNotNil(target.recordChangedBlock)
    }

    func test__get_record_with_id_was_deleted_block() {
        target.recordWithIDWasDeletedBlock = { _ in }
        XCTAssertNotNil(operation.recordWithIDWasDeletedBlock)
    }

    func test__set_record_with_id_was_deleted_block() {
        operation.recordWithIDWasDeletedBlock = { _ in }
        XCTAssertNotNil(target.recordWithIDWasDeletedBlock)
    }

    func test__setting_completion_block() {
        operation.setFetchRecordChangesCompletionBlock { _ in
            // etc
        }
        XCTAssertNotNil(operation.configure)
    }

    func test__setting_completion_block_to_nil() {
        operation.setFetchRecordChangesCompletionBlock(.None)
        XCTAssertNil(operation.configure)
    }

    func test__success_with_completion_block() {
        var blockDidRun = false
        operation.setFetchRecordChangesCompletionBlock { token, data in
            blockDidRun = true
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(blockDidRun)
    }

    func test__error_with_completion_block() {
        target.error = NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: nil)

        operation.setFetchRecordChangesCompletionBlock { _, _ in
            // etc
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertEqual(operation.errors.count, 1)
    }
}






