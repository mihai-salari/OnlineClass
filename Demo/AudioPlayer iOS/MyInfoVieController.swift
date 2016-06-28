//
//  MyInfoVieController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/22.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs
import Kingfisher

class MyInfoVieController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    var thirdSections = [ ["me_tuijian", "我的推荐", "webViewSegue", "http://wwww.baidu.com"],
                          ["me_order", "我的订单", "webViewSegue", "http://wwww.baidu.com"],
                          ["me_team", "我的团队", "webViewSegue", "http://wwww.baidu.com"],
                          ["me_tixian", "我要提现","webViewSegue", "http://wwww.baidu.com"],
                       ]
    

    var fourthSections = [ ["me_ziliao", "我的资料", "personalInfoSegue"],
                           ["me_qrcode", "我的二维码", "codeImageSegue"],
                           ]
    
    var fifthSections = [ ["me_agent", "申请代理","webViewSegue", "http://wwww.baidu.com"],
                           ]
    
    
    var keyValueStore = KeyValueStore()
    
    var refreshControl: UIRefreshControl!
    var querying = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    
    func refresh() {
        if (querying) {
            refreshControl.endRefreshing()
            return
        }
        
        querying = true
        
        BasicService().sendRequest(ServiceConfiguration.GET_USER_STAT_DATA, request: GetUserStatDataRequest()) {
            (resp: GetUserStatDataResponse) -> Void in
            self.updateUserStatData(resp)
            self.querying = false
            self.refreshControl.endRefreshing()
        }
    }

    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

}

extension MyInfoVieController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return thirdSections.count
        case 3:
            return fourthSections.count
        case 4:
            return fifthSections.count

        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 134
        case 1:
            return 71
        case 2:
            return 48
        case 3:
            return 48
        case 4:
            return 48
        default:
            return 1
        }
    }
    
    func userImageTapped(img: AnyObject) {
        performSegueWithIdentifier("setProfilePhotoSegue", sender: nil)
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            let loginUser : LoginUserEntity = LoginUserStore().getLoginUser()!
            let cell = tableView.dequeueReusableCellWithIdentifier("myInfoMainCell") as! MyInfoMainCell
            
            
            if UserProfilePhotoStore().get() == nil {
                let profilePhotoUrl = ServiceConfiguration.GET_PROFILE_IMAGE + "?userid=" + LoginUserStore().getLoginUser()!.userName!
                cell.userImage.kf_setImageWithURL(NSURL(string: profilePhotoUrl)!,
                                                  placeholderImage: nil,
                                                  optionsInfo: nil,
                                                  progressBlock: { (receivedSize, totalSize) -> () in
                                                    print("Download Progress: \(receivedSize)/\(totalSize)")
                                                  },
                                                  completionHandler: { (image, error, cacheType, imageURL) -> () in
                                                    if image != nil {
                                                        UserProfilePhotoStore().saveOrUpdate(image!)
                                                    }
                                                  })

            } else {
                cell.userImage.image = UserProfilePhotoStore().get()
            }
            
            
            cell.userImage.becomeCircle()
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(userImageTapped))
            cell.userImage.userInteractionEnabled = true
            cell.userImage.addGestureRecognizer(tapGestureRecognizer)
            cell.levelLabel.text = loginUser.level
            cell.bossLabel.text = loginUser.boss
            if loginUser.nickName == nil || loginUser.nickName == "" {
                cell.userInfoLabel.text = "\(loginUser.name!)"
            } else {
                cell.userInfoLabel.text = "\(loginUser.name!) (\(loginUser.nickName!))"
            }

            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("myInfoSecondLineCell") as! MyInfoSecondLineCell
            cell.jifenLabel.text = keyValueStore.get(KeyValueStore.key_jifen, defaultValue: "0")
            cell.chaifuLabel.text = keyValueStore.get(KeyValueStore.key_chaifu, defaultValue: "0")
            cell.tuanduiLabel.text = keyValueStore.get(KeyValueStore.key_tuandui, defaultValue: "1人")

            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("myInfoOtherCell") as! MyInfoOtherCell
            let data = thirdSections[row]
            cell.leftImage.image = UIImage(named: data[0])
            cell.titleLabel.text = data[1]
            cell.otherInfoLabel.text  = ""
            switch row {
            case 0:
                cell.otherInfoLabel.text = keyValueStore.get(KeyValueStore.key_tuijian, defaultValue: "0人")
                break
            case 1:
                cell.otherInfoLabel.text = keyValueStore.get(KeyValueStore.key_ordercount,
                   defaultValue: "0笔")
                break
            case 2:
                cell.otherInfoLabel.text = keyValueStore.get(KeyValueStore.key_tuandui, defaultValue: "1人")
            default:
                break
            }
            //发起更新用户数据的请求
            if row == thirdSections.count - 1 {
                BasicService().sendRequest(ServiceConfiguration.GET_USER_STAT_DATA, request: GetUserStatDataRequest()) {
                    (resp: GetUserStatDataResponse) -> Void in
                    self.updateUserStatData(resp)
                }
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("myInfoOtherCell") as! MyInfoOtherCell
            let data = fourthSections[row]
            cell.leftImage.image = UIImage(named: data[0])
            cell.titleLabel.text = data[1]
            cell.otherInfoLabel.text  = ""
            return cell

        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("myInfoOtherCell") as! MyInfoOtherCell
            let data = fifthSections[row]
            cell.leftImage.image = UIImage(named: data[0])
            cell.titleLabel.text = data[1]
            cell.otherInfoLabel.text  = ""
            return cell

        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell") as! logoutCell
            cell.viewController = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        let section = indexPath.section
        let row = indexPath.row
        switch section {
            
        case 2:
            performSegueWithIdentifier(thirdSections[row][2], sender: thirdSections[row])
            break
        case 3:
            performSegueWithIdentifier(fourthSections[row][2], sender: thirdSections[row])
            break
        case 4:
            performSegueWithIdentifier(thirdSections[row][2], sender: fifthSections[row])
            break
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "webViewSegue" {
            let data  = sender as! Array<String>
            let dest = segue.destinationViewController as! WebPageViewController
            dest.url = NSURL(string: data[3])!
            dest.title = data[1]
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    private func updateUserStatData(resp : GetUserStatDataResponse) {
        if resp.status != ServerResponseStatus.Success.rawValue {
            QL1("getUserStatData return error, \(resp.errorMessage!)")
            return
        }
        
        var indexPath = NSIndexPath(forRow: 0, inSection: 1)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MyInfoSecondLineCell
        cell.jifenLabel.text = resp.jifen
        cell.chaifuLabel.text = resp.chaifu
        cell.tuanduiLabel.text = resp.teamPeople
        keyValueStore.save(KeyValueStore.key_jifen, value: resp.jifen)
        keyValueStore.save(KeyValueStore.key_chaifu, value: resp.chaifu)
        keyValueStore.save(KeyValueStore.key_tuandui, value: resp.teamPeople)
        
        indexPath = NSIndexPath(forRow: 0, inSection: 2)
        let  cell1 = tableView.cellForRowAtIndexPath(indexPath) as! MyInfoOtherCell
        cell1.otherInfoLabel.text = resp.tuijianPeople
        keyValueStore.save(KeyValueStore.key_tuijian, value: resp.tuijianPeople)
        
        indexPath = NSIndexPath(forRow: 1, inSection: 2)
        let cell2 = tableView.cellForRowAtIndexPath(indexPath) as! MyInfoOtherCell
        cell2.otherInfoLabel.text = resp.orderCount
        keyValueStore.save(KeyValueStore.key_ordercount, value: resp.orderCount)
        
        indexPath = NSIndexPath(forRow: 2, inSection: 2)
        let cell3 = tableView.cellForRowAtIndexPath(indexPath) as! MyInfoOtherCell
        cell3.otherInfoLabel.text = resp.teamPeople
    
        
    }

}
