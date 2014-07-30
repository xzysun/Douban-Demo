//
//  MainViewController.swift
//  Douban-Demo
//
//  Created by xzysun on 14-7-30.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController();
    var timer:NSTimer!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.progress.progress = 0.0;
        self.loadList();
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("onUpdate"), userInfo: nil, repeats: true);
        self.timer.invalidate();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var channelListVC:ChannelListViewController = segue.destinationViewController as ChannelListViewController;
        channelListVC.changeChannel = {
            (channel:Int, name:String) -> Void in
            NSLog("获取到选择的频道列表为%d", channel);
            self.loadList();
            self.tableView.reloadData();
        };
        NSLog("准备显示频道列表");
        
    }
    
    func loadList() {
        DoubanService.getService().loadPlayList(DoubanService.getService().currentChannel, success: {
            NSLog("刷新播放列表成功");
            self.tableView.reloadData();
            }, failure: {
                (resultStr:String) -> Void in
                let alert:UIAlertView = UIAlertView(title: "错误", message: resultStr, delegate: nil, cancelButtonTitle: "确定");
                alert.show();
            });
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        var listCount:Int = DoubanService.getService().playList.count;
        if(listCount == 0) {
            return 1;
        } else {
            return listCount;
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Douban-list") as? UITableViewCell;
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Douban-list");
        }
        if(DoubanService.getService().playList.count == 0) {
            cell!.textLabel.text = "正在加载...";
        } else {
            let rowData:NSDictionary = DoubanService.getService().playList[indexPath.row] as NSDictionary;
            cell.textLabel.text = rowData["title"] as String;
            cell.detailTextLabel.text = rowData["artist"] as NSString;
            let url = rowData["picture"] as String;
            cell.imageView.image = DoubanService.getService().getImageForUrl(url, success: {
                (img:UIImage) -> Void in
                if cell? {
                    cell.imageView.image = img;
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None);
                }
                });
        }
        return cell;
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        tableView .deselectRowAtIndexPath(indexPath, animated: true);
        if(DoubanService.getService().playList.count == 0) {
            return;
        }
        //
        NSLog("选择了第%d首歌", indexPath.row);
        self.timer.invalidate();
        self.timer = nil;
        let rowData:NSDictionary = DoubanService.getService().playList[indexPath.row] as NSDictionary;
        self.audioPlayer.stop();
        let url = rowData["url"] as String;
        let pic = rowData["picture"] as String;
        self.audioPlayer.contentURL = NSURL(string:url);
        self.audioPlayer.play();
        self.progress.progress = 0.0;
        self.playTimeLabel.text = "00:00/00:00";
        self.musicImageView.image = DoubanService.getService().getImageForUrl(pic, success:{
            (img:UIImage) -> Void in
            self.musicImageView.image = img;
            });
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("onUpdate"), userInfo: nil, repeats: true);
        self.timer.fire();
    }
    
    //刷新界面
    func onUpdate() {
        let totalTime = self.audioPlayer.duration;
        let currentTime = self.audioPlayer.currentPlaybackTime;
        if(currentTime.isNaN || currentTime < 0.0 || totalTime.isNaN || totalTime <= 0.0) {
            return;
        }
        let per:CFloat = CFloat(currentTime/totalTime);
        let totalStr = self.foramtTimeStr(Int(totalTime));
        let currentStr = self.foramtTimeStr(Int(currentTime));
        NSLog("当前播放时间%f,总时间%f,播放百分比%f", currentTime, totalTime, per);
        self.progress.setProgress(per, animated: true);
        self.playTimeLabel.text = "\(currentStr)/\(totalStr)";
    }
    
    //根据传入的秒钟来计算时间格式，格式为mm:ss
    func foramtTimeStr(allSeconds:Int) -> String {
        let minutes = Int(allSeconds/60);
        let seconds = Int(allSeconds)%60;
        var time = "";
        if (minutes < 10) {
            time = "0\(minutes):";
        } else {
            time = "\(minutes):";
        }
        if(seconds < 10) {
            time += "0\(seconds)";
        } else {
            time += "\(seconds)";
        }
        return time;
    }
}
