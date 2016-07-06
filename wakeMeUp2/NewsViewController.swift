//
//  NewsViewController.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 6/27/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit
import TwitterKit

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TWTRTweetViewDelegate, APInewsProtocol, APITwitterProtocol, ConfigurationProtocol {

    @IBOutlet weak var tableView: UITableView!
    var news: [News] = [News]()
    var tweets: [TWTRTweet] = [TWTRTweet]()
    var newsApi: NewsRequest!
    var twitterApi: TwitterRequest!
    var session: String?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)) , forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableConfig()
        self.newsApi = NewsRequest()
        self.newsApi.delegate = self
        self.newsApi.getNews()
        self.twitterApi = TwitterRequest()
        self.twitterApi.delegate = self
        self.twitterApi.getTweets()
        self.session = Twitter.sharedInstance().sessionStore.session()?.userID
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table
    
    func tableConfig() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0
        self.tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "twitterCell")
        self.tableView.addSubview(self.refreshControl)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.news.count
        } else {
            return self.tweets.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath) as! NewsCell
            let new = news[indexPath.row]
            cell.titleLabel.text = new.title
            cell.bodyLabel.text = new.content
            cell.dateLabel.text = new.date
            if let imageData = new.image {
                let image = UIImage(data: imageData)
                cell.newsImage.image = image
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("twitterCell", forIndexPath: indexPath) as! TWTRTweetTableViewCell
            let tweet = self.tweets[indexPath.row]
            cell.configureWithTweet(tweet)
            cell.tweetView.delegate = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRectMake(10, 15, tableView.frame.size.width, 30))
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 0.98)
        let twitterText = (self.session != nil) ? "Twitter" : "Para ver tu Timeline inicia sesion"
        label.text = section == 0 ? "Noticias" : twitterText
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 60))
        view.addSubview(label)
        view.backgroundColor = UIColor.init(red: 236/255, green: 240/255, blue: 241/255, alpha: 0.98)
        return view
    }
    
    func reloadedTwitterSession(logIn: Bool) {
        if logIn {
            self.twitterApi.getTweets()
            self.session = Twitter.sharedInstance().sessionStore.session()?.userID
        } else {
            self.tableView.reloadData()
        }
    }
    
    func didRecieveAPIResults(news: [News]) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.news.appendContentsOf(news)
            let index = NSIndexSet(index: 0)
            self.tableView.reloadSections(index, withRowAnimation: .Fade)
            if self.refreshControl.refreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func didRecieveAPIResults(tweets: [TWTRTweet]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.tweets.appendContentsOf(tweets)
            self.tableView.reloadData()
            let index = NSIndexSet(index: 1)
            self.tableView.reloadSections(index, withRowAnimation: .Fade)
            
            if self.refreshControl.refreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tweets.removeAll(keepCapacity: true)
        self.news.removeAll(keepCapacity: true)
        self.newsApi.getNews()
        self.twitterApi.getTweets()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "configSegue" {
            let view = segue.destinationViewController.childViewControllers.first as! ConfigurationViewController
            view.delegate = self
        }
    }
}
