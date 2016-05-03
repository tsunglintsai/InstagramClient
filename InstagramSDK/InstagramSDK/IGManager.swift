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
        guard let accessToken = accessToken else {
            runClosureAfterReauth({[weak self] () -> () in
                self?.queryTag(keyword, successClosure: successClosure, failureClosure: failureClosure)
            }, failClosure: { () -> () in
                failureClosure()
            })
            return
        }
        httpManager.GET("tags/search", parameters: ["access_token":accessToken, "q":keyword], progress: nil, success: { (dataTask, response) -> Void in
            guard let responseJson = response, dataJson = responseJson["data"] as? [AnyObject] else { failureClosure() ; return }
            let tags = dataJson.flatMap({$0["name"]}).flatMap({$0 as? String})
            successClosure(tagList: tags, keyword: keyword)
        }) { (dataTask, error) -> Void in
            failureClosure()
        }
    }
    
    public func queryMedia(tag: String , successClosure: QueryMediaSuccessCompletionClosure, failureClosure: QueryMediaFailCompletionClosure) {
        guard let accessToken = accessToken else {
            runClosureAfterReauth({[weak self] () -> () in
                self?.queryMedia(tag, successClosure: successClosure, failureClosure: failureClosure)
            }, failClosure: { () -> () in
                failureClosure()
            })
            return
        }
        httpManager.GET("tags/sun/media/recent", parameters: ["access_token":accessToken], progress: nil, success: { (dataTask, response) -> Void in
            if let responseJson = response {
                var mediaListResponse: IGMediaListResponse?
                mediaListResponse <-- responseJson
                if let mediaListResponse = mediaListResponse {
                    successClosure(response: mediaListResponse)
                }
            } else {
                failureClosure()
            }
        }) { (dataTask, error) -> Void in
            failureClosure()
        }
    }
    
    public func likeUnlikeMedia(mediaId: String , like:Bool ,successClosure: LikeMediaSuccesCompletionClosure, failureClosure: LikeMediaFailCompletionClosure) {
        guard let accessToken = accessToken else {
            return
        }
        if like {
            httpManager.POST("media/\(mediaId)/likes", parameters: ["access_token":accessToken], progress: nil, success: { (task, response) -> Void in
                successClosure()
            }) { (task, error) -> Void in
                failureClosure()
            }
        } else {
            httpManager.DELETE("media/\(mediaId)/likes", parameters: ["access_token":accessToken], success: { (task, response) -> Void in
                successClosure()
            }, failure: { (task, error) -> Void in
                print(error)
                failureClosure()
            })
        }
    }
 
    public func getMediaLikes(mediaId: String ,successClosure: GetMediaLikesSuccesCompletionClosure, failureClosure: GetMediaLikesFailCompletionClosure) {
        guard let accessToken = accessToken else {
            return
        }
        httpManager.GET("media/\(mediaId)/likes", parameters: ["access_token":accessToken], progress: nil, success: { (task, response) -> Void in
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
}
