//
//  IGManager.swift
//  InstagramSDK
//
//  Created by Henry on 4/30/16.
//  Copyright © 2016 Henry. All rights reserved.
//
import JSONHelper
import AFNetworking

public class IGManager: NSObject {
    
    public typealias QueryTagSuccessCompletionClosure = (tagList:[String],keyword:String) -> ()
    public typealias QueryTagFailCompletionClosure = () -> ()

    public typealias QueryMediaSuccessCompletionClosure = (response: IGMediaListResponse) -> ()
    public typealias QueryMediaFailCompletionClosure = () -> ()

    public typealias LikeMediaSuccesCompletionClosure = () -> ()
    public typealias LikeMediaFailCompletionClosure = () -> ()
    
    public typealias GetMediaLikesSuccesCompletionClosure = ([IGUser]) -> ()
    public typealias GetMediaLikesFailCompletionClosure = () -> ()
    
    public typealias AuthCompletionClosure = () -> ()

    public static let sharedInstance = IGManager()
    
    public private(set) static var appClientId: String?
    public private(set) static var authRedirectURLStr: String?
    public private(set) static var userPermission: Set<IGAuthPermission>?
    public private(set) var accessToken: String?
    public var authRequireUserInputClosure: ((internalAuthViewController: IGAuthViewController) -> ())?
    private let httpManager: AFHTTPSessionManager
    private let instagramKitBaseURL = "https://api.instagram.com/v1/"
    private var internalAuthViewController: IGAuthViewController?
    
    public class func configIGManager(clientId: String, redirectURL: String, permissions:Set<IGAuthPermission> = Set([.Basic])) {
        appClientId = clientId
        authRedirectURLStr = redirectURL
        userPermission = permissions
    }
    
    public override init() {
        httpManager = AFHTTPSessionManager(baseURL: NSURL(string: instagramKitBaseURL)!)
        httpManager.responseSerializer = AFJSONResponseSerializer()
        super.init()
        if let viewController = authViewController() {
            self.internalAuthViewController = viewController
            viewController.startAuth({ [weak self] (state) -> () in
                if state == .PendingUserInput {
                    self?.authRequireUserInputClosure?(internalAuthViewController: viewController)
                }
            })
        }
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
    
    public func queryTag(keyword: String , successClosure: QueryTagSuccessCompletionClosure, failureClosure: QueryTagFailCompletionClosure) {
        runGET("tags/search", parameters: ["q":keyword], progress: nil, success: { (task, response) -> Void in
            guard let responseJson = response, dataJson = responseJson["data"] as? [AnyObject] else { failureClosure() ; return }
            let tags = dataJson.flatMap({$0["name"]}).flatMap({$0 as? String})
            successClosure(tagList: tags, keyword: keyword)
        }) { (task, error) -> Void in
            failureClosure()
        }
    }
    
    public func queryMedia(tag: String , successClosure: QueryMediaSuccessCompletionClosure, failureClosure: QueryMediaFailCompletionClosure) {
        runGET("tags/sun/media/recent", parameters:nil, progress: nil, success: { (task, response) -> Void in
            var mediaListResponse: IGMediaListResponse?
            mediaListResponse <-- response
            if let mediaListResponse = mediaListResponse {
                successClosure(response: mediaListResponse)
            }
        }) { (task, error) -> Void in
            failureClosure()
        }
    }
    
    public func likeUnlikeMedia(mediaId: String , like:Bool ,successClosure: LikeMediaSuccesCompletionClosure, failureClosure: LikeMediaFailCompletionClosure) {
        if like {
            runPOST("media/\(mediaId)/likes", parameters: nil, progress: nil, success: { (task, response) -> Void in
                successClosure()
            }) { (task, error) -> Void in
                failureClosure()
            }
        } else {
            runDELETE("media/\(mediaId)/likes", parameters:nil, success: { (task, response) -> Void in
                successClosure()
            }, failure: { (task, error) -> Void in
                failureClosure()
            })
        }
    }
 
    public func getMediaLikes(mediaId: String ,successClosure: GetMediaLikesSuccesCompletionClosure, failureClosure: GetMediaLikesFailCompletionClosure) {
        runGET("media/\(mediaId)/likes", parameters: nil, progress: nil, success: { (task, response) -> Void in
            guard let responseJson = response, let userListJson = responseJson["data"]
                else {
                    failureClosure()
                    return
            }
            var userList: [IGUser]?
            userList <-- userListJson
            if let userList = userList {
                successClosure(userList)
            } else{
                failureClosure()
            }
        }) { (task, error) -> Void in
            print(error)
            failureClosure()
        }
    }
    
    private func runClosureAfterReauth(successSlosure:(()->()), failClosure:(()->())) {
        guard let internalAuthViewController = internalAuthViewController else {
            failClosure()
            return
        }
        internalAuthViewController.startAuth({ [weak self] (state) -> () in
            guard state == .Authorized else {
                if state == .PendingUserInput {
                    self?.authRequireUserInputClosure?(internalAuthViewController: internalAuthViewController)
                }
                failClosure()
                return
            }
            successSlosure()
        })
    }
    
    private func runDELETE(URLString: String, parameters: AnyObject?, success: ((NSURLSessionDataTask, AnyObject?) -> Void)?, failure: ((NSURLSessionDataTask?, NSError) -> Void)?) {
        httpManager.DELETE(URLString, parameters: paramWithAccessToken(parameters), success: success) { [weak self] (task, error) -> Void in
            if let response = task?.response as? NSHTTPURLResponse {
                if response.statusCode == 400 {
                    // need reauth
                    self?.runClosureAfterReauth({ [weak self] () -> () in
                        guard let _self = self else { failure?(task,error) ; return }
                        _self.httpManager.DELETE(URLString, parameters: _self.paramWithAccessToken(parameters), success: success, failure: failure)
                        }, failClosure: { () -> () in
                            failure?(task,error)
                    })
                } else {
                    failure?(task,error)
                }
            } else {
                failure?(task,error)
            }
        }
    }
    
    private func runPOST(URLString: String, parameters: AnyObject?, progress downloadProgress: ((NSProgress) -> Void)?, success: ((NSURLSessionDataTask, AnyObject?) -> Void)?, failure: ((NSURLSessionDataTask?, NSError) -> Void)?) {
        httpManager.POST(URLString, parameters: paramWithAccessToken(parameters), progress: downloadProgress, success: success) { [weak self] (task, error) -> Void in
            if let response = task?.response as? NSHTTPURLResponse {
                if response.statusCode == 400 {
                    // need reauth
                    self?.runClosureAfterReauth({ [weak self] () -> () in
                        guard let _self = self else { failure?(task,error) ; return }
                        _self.httpManager.POST(URLString, parameters: _self.paramWithAccessToken(parameters), progress: downloadProgress, success: success, failure: failure)
                        }, failClosure: { () -> () in
                            failure?(task,error)
                    })
                } else {
                    failure?(task,error)
                }
            } else {
                failure?(task,error)
            }
        }
    }
    
    private func runGET(URLString: String, parameters: AnyObject?, progress downloadProgress: ((NSProgress) -> Void)?, success: ((NSURLSessionDataTask, AnyObject?) -> Void)?, failure: ((NSURLSessionDataTask?, NSError) -> Void)?) {
        httpManager.GET(URLString, parameters: paramWithAccessToken(parameters), progress: downloadProgress, success: success) { [weak self] (task, error) -> Void in
            print(task)
            print("================================================")
            print(error)
            if let response = task?.response as? NSHTTPURLResponse {
                if response.statusCode == 400 {
                    // need reauth
                    self?.runClosureAfterReauth({ [weak self] () -> () in
                        guard let _self = self else { failure?(task,error) ; return }
                        _self.httpManager.GET(URLString, parameters: _self.paramWithAccessToken(parameters), progress: downloadProgress, success: success, failure: failure)
                    }, failClosure: { () -> () in
                        failure?(task,error)
                    })
                } else {
                    failure?(task,error)
                }
            } else {
                failure?(task,error)
            }
        }
    }
    
    private func paramWithAccessToken(parameters: AnyObject?) -> [String: AnyObject]{
        var paramsWithAccessToken = [String: AnyObject]()
        if let parameters = parameters as? [String: AnyObject] {
            for (k, v) in parameters {
                paramsWithAccessToken.updateValue(v, forKey: k)
            }
        }
        paramsWithAccessToken["access_token"] = accessToken ?? "0"
        return paramsWithAccessToken
    }
    
}
