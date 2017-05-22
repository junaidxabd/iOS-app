//
//  ActivityViewController.swift
//  WWDCScholars
//
//  Created by Andrew Walker on 14/04/2017.
//  Copyright © 2017 Andrew Walker. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import SafariServices
import DeckTransition

internal final class ActivityViewController: TWTRTimelineViewController {
    
    // MARK: - Lifecycle
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleUI()
        self.configureUI()
        self.configureTwitterDataSource()
        self.configureTwitterDelegate()
    }
    
    // MARK: - UI
    
    private func styleUI() {
        let composeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.openTweetComposer))
        self.navigationItem.rightBarButtonItem = composeBarButtonItem
    }
    
    private func configureUI() {
        self.title = "Activity"
        self.showTweetActions = true
    }
    
    // MARK: - Private functions
    
    private func configureTwitterDataSource() {
        let client = TWTRAPIClient()
        let query = "#WWDCScholars OR from:@tim_cook OR from:@cue OR from:@jgeleynse OR from:@pschiller OR from:@AngelaAhrendts OR from:@EEhare"
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: query, apiClient: client)
        self.dataSource = dataSource
    }
    
    private func configureTwitterDelegate() {
        self.tweetViewDelegate = self
    }
    
    // MARK: - Actions
    
    internal func openTweetComposer() {
        let composer = TWTRComposer()
        composer.setText("#WWDCScholars")
        composer.show(from: self) { _ in }
    }
}

extension ActivityViewController: TWTRTweetViewDelegate {
    internal func openSafariViewController(`for` url: URL) {
        let svc = SFSafariViewController(url: url)
        svc.preferredBarTintColor = .scholarsTranslucentPurple
        self.presentedViewController?.present(svc, animated: true, completion: nil)
    }
    
    internal func tweetView(_ tweetView: TWTRTweetView, didTap url: URL) {
        openSafariViewController(for: url)
    }
    
    internal func tweetView(_ tweetView: TWTRTweetView, didTapProfileImageFor user: TWTRUser) {
        if (UIApplication.shared.canOpenURL(URL(string:"twitter://")!)) {
            UIApplication.shared.open(URL.init(string: "twitter://user?id=\(user.userID)")!, options: [:], completionHandler: nil)
        }else if (UIApplication.shared.canOpenURL(URL(string:"tweetbot://")!)) {
            UIApplication.shared.open(URL.init(string: "tweetbot://\(user.screenName)")!, options: [:], completionHandler: nil)
        }else {
            openSafariViewController(for: user.profileURL)
        }
    }
    
    internal func tweetView(_ tweetView: TWTRTweetView, shouldDisplay controller: TWTRTweetDetailViewController) -> Bool {
        controller.delegate = self
        let transitionDelegate = DeckTransitioningDelegate()
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .custom
        present(controller, animated: true, completion: nil)
        controller.scrollView.delegate = controller
        return false
    }
}

extension ActivityViewController: TWTRTweetDetailViewControllerDelegate {
    internal func tweetDetailViewController(_ controller: TWTRTweetDetailViewController, didTap url: URL) {
        openSafariViewController(for: url)
    }
    
    internal func tweetDetailViewController(_ controller: TWTRTweetDetailViewController, didTapProfileImageFor user: TWTRUser) {
        if (UIApplication.shared.canOpenURL(URL(string:"twitter://")!)) {
            UIApplication.shared.open(URL.init(string: "twitter://user?id=\(user.userID)")!, options: [:], completionHandler: nil)
        }else if (UIApplication.shared.canOpenURL(URL(string:"tweetbot://")!)) {
            UIApplication.shared.open(URL.init(string: "tweetbot://\(user.screenName)")!, options: [:], completionHandler: nil)
        }else {
            openSafariViewController(for: user.profileURL)
        }
    }
    
    internal func tweetDetailViewController(_ controller: TWTRTweetDetailViewController, didTapHashtag hashtag: TWTRTweetHashtagEntity) {
        if hashtag.text == "WWDCScholars" {
            self.dismiss(animated: true, completion: nil)
        }else {
            if (UIApplication.shared.canOpenURL(URL(string:"twitter://")!)) {
                UIApplication.shared.open(URL.init(string: "twitter://search?query=%23\(hashtag.text)")!, options: [:], completionHandler: nil)
            }else if (UIApplication.shared.canOpenURL(URL(string:"tweetbot://")!)) {
                 UIApplication.shared.open(URL.init(string: "tweetbot://query=%23\(hashtag.text)")!, options: [:], completionHandler: nil)
            }else {
                openSafariViewController(for: URL.init(string: "https://twitter.com/search?q=%23\(hashtag.text)")!)
            }
        }
    }
    
    internal func tweetDetailViewController(_ controller: TWTRTweetDetailViewController, didTapCashtag cashtag: TWTRTweetCashtagEntity) {
        if (UIApplication.shared.canOpenURL(URL(string:"twitter://")!)) {
            UIApplication.shared.open(URL.init(string: "twitter://search?query=%24\(cashtag.text)")!, options: [:], completionHandler: nil)
        }else if (UIApplication.shared.canOpenURL(URL(string:"tweetbot://")!)) {
            UIApplication.shared.open(URL.init(string: "tweetbot://query=%24\(cashtag.text)")!, options: [:], completionHandler: nil)
        }else {
            openSafariViewController(for: URL.init(string: "https://twitter.com/search?q=%24\(cashtag.text)")!)
        }
    }
}

extension TWTRTweetDetailViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {        
        if let delegate = transitioningDelegate as? DeckTransitioningDelegate {
            if scrollView.contentOffset.y > 0 {
                // Normal behaviour if the `scrollView` isn't scrolled to the top
                scrollView.bounces = true
                delegate.isDismissEnabled = false
            } else {
                if scrollView.isDecelerating {
                    // If the `scrollView` is scrolled to the top but is decelerating
                    // that means a swipe has been performed. The view and scrollview are
                    // both translated in response to this.
                    view.transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y)
                    scrollView.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
                } else {
                    // If the user has panned to the top, the scrollview doesnʼt bounce and
                    // the dismiss gesture is enabled.
                    scrollView.bounces = false
                    delegate.isDismissEnabled = true
                }
            }
        }
    }
}
