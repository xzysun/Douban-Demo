//
//  ChannelListViewController.swift
//  Douban-Demo
//
//  Created by xzysun on 14-7-30.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

import UIKit
//定义一个切换频道的block,传入一个Int代表频道号，一个String代表频道名称
typealias ChangeChannelBlock = (Int, String) -> Void

class ChannelListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var changeChannel:ChangeChannelBlock?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var failure:failureBlock = {
            (resultStr:String) -> Void in
            let alert:UIAlertView = UIAlertView(title: "错误", message: resultStr, delegate: nil, cancelButtonTitle: "确定");
            alert.show();
        };
        var success:successBlock = {
            self.tableView.reloadData();
        };
        DoubanService.getService().reloadChannelList(success, failure:failure);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        NSLog("取消频道列表");
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    //datasource
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        var listCount = DoubanService.getService().channelList.count;
        if(listCount == 0) {
            return 1;
        } else {
            return listCount;
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Douban-channel") as? UITableViewCell;
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Douban-channel");
        }
        //填充数据
        var listCount = DoubanService.getService().channelList.count;
        if(listCount == 0) {
            cell.textLabel.text = "正在加载...";
        } else {
            let rowData:NSDictionary=DoubanService.getService().channelList[indexPath.row] as NSDictionary
            cell.textLabel.text = rowData["name"] as String;
            if(rowData["channel_id"].isEqual(DoubanService.getService().currentChannel)) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None;
            }
        }
        return cell;
    }
    
    //delegate
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        if(DoubanService.getService().channelList.count == 0) {
            //点击的是正在加载...
            return;
        }
        NSLog("选择了%d", indexPath.row);
        let rowData:NSDictionary=DoubanService.getService().channelList[indexPath.row] as NSDictionary;
        var channel = rowData["channel_id"]as String;
        DoubanService.getService().currentChannel = channel;
        if let existedBlock = self.changeChannel {
            self.changeChannel!(indexPath.row,"");
        }
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
