//
//  IGManager.swift
//  InstagramSDK
//
//  Created by Henry on 4/30/16.
//  Copyright © 2016 Henry. All rights reserved.
//

public class IGManager: NSObject {

    public static let sharedInstance = IGManager()
    
    public private(set) static var appClientId: String?
    public private(set) static var authRedirectURLStr: String?
    public private(set) static var userPermission: Set<IGAuthPermission>?
    public private(set) var accessToken: String?
    
    public class func configIGManager(clientId: String, redirectURL: String, permissions:Set<IGAuthPermission> = Set([.Basic])) {
        appClientId = clientId
        authRedirectURLStr = redirectURL
        userPermission = permissions
    }
    
    public func authViewController()-> IGAuthViewController? {
        guard let appClientId = IGManager.appClientId,
            let authRedirectURLStr = IGManager.authRedirectURLStr,
            let authRedirectURL = NSURL(string: authRedirectURLStr),
            let userPermission = IGManager.userPermission,
            let viewController = IGAuthViewController(clientId: appClientId, redirectURL:authRedirectURL, userPermission: userPermission)
            else { return nil }
        viewController.internalAuthSuccessClosure = { [weak self] (accessToken)->() in
            self?.accessToken = accessToken
        }
        return viewController
    }
    
    public func queryMedia(tag:String) {
        let filePath = NSBundle.mainBundle().pathForResource("tagResuls", ofType: "txt")
        if let data = NSData.dataWithContentsOfMappedFile(filePath!) as? NSData {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(json)
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
    }
}
