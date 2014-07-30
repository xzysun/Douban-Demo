//
//  DoubanService.swift
//  Douban-Demo
//
//  Created by xzysun on 14-7-30.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

import UIKit

//定义一个失败的block 入参是String 返回是void
typealias failureBlock = (String) -> Void
//定义一个成功的block 入参是空 返回是void
typealias successBlock = () -> Void
//定义一个成功下载到图片的block 入参是Image 返回是空
typealias loadPicBlock = (UIImage) -> Void

class DoubanService: NSObject {
    let LAST_CHANNEL_STORAGE_KEY:String = "LastChannelStorageKey";
    let CHANNEL_LIST_URL:String = "http://www.douban.com/j/app/radio/channels";
    let PLAYLIST_BASE_URL:String = "http://douban.fm/j/mine/playlist?channel=";
    let REQUEST_TIMEOUT:NSTimeInterval = 10;
    
    //音乐列表
    var playList:NSArray=NSArray();
    //频道列表
    var channelList:NSArray=NSArray();
    //当前选择的频道
    var currentChannel:String = "0";
    //图片缓存
    var imageCache:NSMutableDictionary = NSMutableDictionary();
    
    class func getService() -> DoubanService {
        struct Static {
            static var singlton: DoubanService? = nil;
            static var token: dispatch_once_t = 0;
        }
        dispatch_once(&Static.token, {
            Static.singlton = DoubanService();
            Static.singlton?.initData();
        });
        return Static.singlton!;
    }
    
    func initData() {
        NSLog("准备初始化数据");
        var lastChannel: AnyObject! = NSUserDefaults.standardUserDefaults().objectForKey(LAST_CHANNEL_STORAGE_KEY);
        
    }
    
    func reloadChannelList(success:successBlock, failure:failureBlock) {
        //获取频道列表
        var nsUrl:NSURL = NSURL(string: CHANNEL_LIST_URL);
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: nsUrl);
        request.timeoutInterval = REQUEST_TIMEOUT;
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            if(error != nil) {
                NSLog("请求频道列表异常%@", error.localizedDescription);
                failure("请求频道列表异常");
                return;
            }
            NSLog("响应完成,响应长度%d",data.length);
            //解析JSON
            var err:NSError?;
            var jsonResult: NSMutableDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSMutableDictionary
            if(err == nil) {
                //这里做一个修复，把列表中得一些channel_id值为整数的对象转换成字符串
                var tempList = jsonResult!["channels"] as NSMutableArray;
                var i:Int = 0;
                for dic in tempList {
                    var d = dic as NSMutableDictionary;
                    var channel = d["channel_id"] as? Int;
                    if(channel != nil) {
                        d["channel_id"] = String(channel!);
                        tempList[i] = d;
                    }
                }
                self.channelList = tempList;
                success();
            } else {
                NSLog("JSON解析异常:%@", err!.localizedDescription);
                failure("从服务器获取的数据格式异常");
            }
            });
    }
    
    func loadPlayList(channel:String, success:successBlock, failure:failureBlock) {
        self.playList = NSArray();
        //获取播放列表
        var urlStr = PLAYLIST_BASE_URL + channel;
        NSLog("准备获取播放列表，地址为:%@", urlStr);
        var nsUrl:NSURL = NSURL(string: urlStr);
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: nsUrl);
        request.timeoutInterval = REQUEST_TIMEOUT;
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            if(error != nil) {
                NSLog("请求频道列表异常%@", error.localizedDescription);
                failure("请求频道列表异常");
                return;
            }
            NSLog("响应完成,响应长度%d",data.length);
            //解析JSON
            var err:NSError?;
            var jsonResult: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
            if (err == nil) {
                self.playList = jsonResult!["song"] as NSArray;
                success();
            } else {
                NSLog("JSON解析异常:%@", err!.localizedDescription);
                failure("从服务器获取的数据格式异常");
            }
            });
    }
    
    func getImageForUrl(url:String, success:loadPicBlock) -> UIImage? {
        let image = self.imageCache[url] as?UIImage;
        if(!image?) {
            //图片缓存不存在
            let imgURL:NSURL = NSURL(string:url);
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: imgURL);
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                if(error != nil) {
                    NSLog("请求图片%@异常:%@", url, error.localizedDescription);
                    return;
                }
                NSLog("响应完成,响应长度%d",data.length);
                var img = UIImage(data:data);
                self.imageCache[url] = img;
                success(img);
                });
            return nil;
        } else {
            //图片存在，直接返回
            return image!;
        }
    }
}
