//
//  PluginManagerTests.swift
//  ZappApple-Unit-UnitTests
//
//  Created by Alex Zchut on 14/03/2021.
//

import XCTest
@testable import ZappApple
import ZappCore

class PluginManagerTests: XCTestCase {
    struct Constants {
        static let pluginConfigurationJson = "https://assets-secure.applicaster.com/zapp/accounts/5a364b49e03b2f000d51a0de/apps/com.featureappqbmobile/apple_store/0.4.0.0/plugin_configurations/plugin_configurations.json"
        static let timeout = 10.0
    }

    struct ErrorMessages {
        static let pluginsListEmpty = "[PluginManager] - Loaded plugins list is empty"
        static let pluginsListUnableToLoad = "[PluginManager] - Unable to load plugins configuration"
        static let analyticsPluginsListEmpty = "[PluginManager] - Analytics plugins not exists"
        static let generalPluginsListEmpty = "[PluginManager] - General plugins not exists"
        static let playerPluginsListEmpty = "[PluginManager] - Player plugins not exists"
    }

    var pluginModels: [ZPPluginModel]?

    override func setUpWithError() throws {
        SessionStorage.sharedInstance.set(key: ZappStorageKeys.pluginConfigurationUrl,
                                          value: Constants.pluginConfigurationJson,
                                          namespace: nil)

        pluginInitialization()
    }

    func testAnalyticsPlugins() {
        let pluginsManager = AnalyticsManager()
        guard let models = plugins(for: pluginsManager.pluginType) else {
            XCTAssert(false, ErrorMessages.analyticsPluginsListEmpty)
            return
        }

        XCTAssertTrue(models.count > 0, ErrorMessages.analyticsPluginsListEmpty)
    }

    func testGeneralPlugins() {
        let pluginsManager = GeneralPluginsManager()
        guard let models = plugins(for: pluginsManager.pluginType) else {
            XCTAssert(false, ErrorMessages.generalPluginsListEmpty)
            return
        }

        XCTAssertTrue(models.count > 0, ErrorMessages.generalPluginsListEmpty)
    }

    func testPlayerPlugins() {
        let pluginsManager = PlayerPluginsManager()
        guard let models = plugins(for: pluginsManager.pluginType) else {
            XCTAssert(false, ErrorMessages.playerPluginsListEmpty)
            return
        }

        XCTAssertTrue(models.count > 0, ErrorMessages.playerPluginsListEmpty)
    }
}

extension PluginManagerTests {
    func pluginInitialization() {
        let pluginManager = PluginsManager()

        let expectation = XCTestExpectation(description: "Download plugins configuration")

        pluginManager.loadPluginsGroup {
            self.pluginModels = PluginsManager.parseLatestPluginsJson()
            XCTAssertEqual(self.pluginModels?.count ?? 0, 0, ErrorMessages.pluginsListEmpty)
            expectation.fulfill()
        } _: {
            XCTAssert(true, ErrorMessages.pluginsListUnableToLoad)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Constants.timeout)
    }

    func plugins(for pluginType: ZPPluginType) -> [ZPPluginModel]? {
        return pluginModels?.filter({ $0.pluginType == pluginType })
    }
}
