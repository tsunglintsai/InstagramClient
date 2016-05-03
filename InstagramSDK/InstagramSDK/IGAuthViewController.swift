//
//  IGAuthViewController.swift
//  InstagramSDK
//
//  Created by Henry on 4/30/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit

public class IGAuthViewController: UIViewController {
    let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let authRootURL = NSURL(string:"https://www.instagram.com/oauth/authorize/")!
    let clientId: String
    let redirectURL: NSURL
    let userPermission: Set<IGAuthPermission>
    let authSucessString = "access_token="
    let authFailString = "error_reason="
    private var authURL: NSURL?
    var internalAuthSuccessClosure: ((accessToken: String)->())?
    public var authSuccessClosure: (()->())?
    public var authFailClosure: (()->())?
    public var authStateChangeClosure: ((state:IGAuthState)->())?
    public var authState: IGAuthState = .PendingStart
    public var hasReportSucessOrFaile = false
    public var hasReportUserPending = false
    
    public init?(clientId:String, redirectURL: NSURL, userPermission: Set<IGAuthPermission>) {
        self.clientId = clientId
        self.redirectURL = redirectURL
        self.userPermission = userPermission
        var hasValidAuthURL = false
        
        if let urlComponents = NSURLComponents(URL: authRootURL, resolvingAgainstBaseURL: true) {
            var params = [NSURLQueryItem]()
            params.append(NSURLQueryItem(name: "client_id", value: clientId))
            params.append(NSURLQueryItem(name: "redirect_uri", value: redirectURL.absoluteString))
            params.append(NSURLQueryItem(name: "response_type", value: "token"))
            params.append(NSURLQueryItem(name: "scope", value: userPermission.flatMap({$0.rawValue}).joinWithSeparator("+")))
            urlComponents.queryItems = params
            
            if let url = urlComponents.URL {
                self.authURL = url
                hasValidAuthURL = true
            }
        }
        super.init(nibName: "\(self.dynamicType)".componentsSeparatedByString(".").last, bundle: NSBundle(forClass: self.dynamicType))
        if !hasValidAuthURL {
            return nil
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.clientId = ""
        self.redirectURL = NSURL()
        self.authURL = NSURL()
        self.userPermission = Set([.Basic])
        super.init(coder: aDecoder)
    }
}
//MARK: Auth action
public extension IGAuthViewController {
    public func startAuth(stateChangeClosure:((state:IGAuthState)->())) {
        guard let authURL = authURL,
            let _ = view
            else { return }
        authState = .PendingStart
        hasReportSucessOrFaile = false
        hasReportUserPending = false
        authStateChangeClosure = stateChangeClosure
        let requestt = NSURLRequest(URL: authURL)
        webView.loadRequest(requestt)
    }
}


//MARK: UIWebViewDelegate
extension IGAuthViewController: UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let urlString = request.URL?.absoluteString else { return true }
        if let accessToken = parseAuthTokenFromURLString(urlString) {
            authState = .Authorized
            internalAuthSuccessClosure?(accessToken: accessToken)
            authSuccessClosure?()
        } else if urlString.containsString(authFailString) {
            authState = .Denied
            authFailClosure?()
        }
        return true
    }
    public func webViewDidFinishLoad(webView: UIWebView) {
        if authState == .PendingStart {
            authState = .PendingUserInput
        }
       
        switch authState {
            case .PendingUserInput :
                if !hasReportUserPending {
                    authStateChangeClosure?(state: authState)
                    hasReportUserPending = true
                }
            case .Authorized, .Denied:
                if !hasReportSucessOrFaile {
                    authStateChangeClosure?(state: authState)
                    hasReportSucessOrFaile = true
                }
            case .PendingStart :
                let _ = authState
        }
    }
}

//MARK: View life cycle
extension IGAuthViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
        setupWebView()
        edgesForExtendedLayout = .None
    }
}

//MARK: Component Init
private extension IGAuthViewController {
    func setupWebView() {
        webView.frame = view.bounds
        webView.delegate = self
        webView.scrollView.scrollEnabled = false
        webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(webView)
    }
}

//MARK: Convenient methods
private extension IGAuthViewController {
    func parseAuthTokenFromURLString(urlString:String) -> String?{
        guard let url = NSURL(string: urlString) ,
            let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true),
            let fragment = urlComponents.fragment,
            let range = fragment.rangeOfString(authSucessString)
            else { return nil }
        return fragment.substringFromIndex(range.endIndex)
    }
}