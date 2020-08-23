//
//  AppDelegate.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit
import Apollo
import GRDB

let apollo: ApolloClient = {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(authToken1 + authToken2 + authToken3)"]
    guard let url = URL(string: k.API.endpoint) else {
        // TODO: Handle this better
        fatalError()
    }
    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, session: URLSession(configuration: configuration)))
}()

var dbQueue: DatabaseQueue?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try setupDatabase(application)
        } catch VideoGameDatabaseError.appSupportDirURL {
            debugPrint("ERROR: Unable to get app suppport directory URL")
        } catch VideoGameDatabaseError.dbNotInAppBundle {
            debugPrint("ERROR: videoGame.sqlite not in app bundle")
        } catch {
            debugPrint("ERROR: Unable to setup database: \(error.localizedDescription)")
        }
        
        // Load the array of all video games
        do {
            videoGames = try VideoGameDatabase.getVideoGames()
        } catch {
            print(error)
        }
        return true
    }
    
    private func setupDatabase(_ application: UIApplication) throws {
        guard let appSupportDirURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw VideoGameDatabaseError.appSupportDirURL
        }
        let finalDatabasePath = appSupportDirURL.appendingPathComponent("videoGame.sqlite").path
        
        // Check if the database file already exists in the app support directory
        if !FileManager.default.fileExists(atPath: finalDatabasePath) {
            print("DB does not exist in app support directory yet; copying now")
            // Create app support directory if it doesn't exist already
            if !FileManager.default.fileExists(atPath: appSupportDirURL.path) {
                print("App support directory does not exist yet; creating now")
                try FileManager.default.createDirectory(at: appSupportDirURL, withIntermediateDirectories: true)
            }
            // Copy the database file from the app bundle to the app support directory
            if let bundleDatabasePath = Bundle.main.path(forResource: "videoGame", ofType: "sqlite") {
                try FileManager.default.copyItem(atPath: bundleDatabasePath, toPath: finalDatabasePath)
            } else {
                throw VideoGameDatabaseError.dbNotInAppBundle
            }
        } else {
            print("DB already exists at path: \(finalDatabasePath)")
        }
        dbQueue = try VideoGameDatabase.openDatabase(atPath: finalDatabasePath)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
