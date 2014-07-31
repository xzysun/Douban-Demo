//
//  TestThread.swift
//  Douban-Demo
//
//  Created by xzysun on 14-7-31.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

import UIKit
import XCTest

class TestThread: XCTestCase {
    let condition = NSCondition()
    let mainCondition = NSCondition()
    let singletons: NSMutableArray = NSMutableArray()
    let threadNumbers = 500
    var count = 0

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//        
//    }
    
    //测试方法，只要以test开头即可
    func testThread() {
        //生产线程
        for index in 0 ... threadNumbers {
            NSThread.detachNewThreadSelector("startNewThread", toTarget: self, withObject: nil)
        }
        condition.broadcast()
        mainCondition.lock()
        mainCondition.wait()
        mainCondition.unlock()
        //检查结果
        let one = singletons[0] as DoubanService
        for temp:AnyObject in singletons {
            let newTemp = temp as DoubanService
            if newTemp !== one {
                XCTFail("检测到多个singlton对象")
                break
            }
//            XCTAssertNotEqual(newTemp, one, "检测到多个singlton对象")
        }
    }
    
    func startNewThread() {
        condition.lock()
        condition.wait()
        condition.unlock()
        let temp = DoubanService.getService()
        count++
        singletons.addObject(temp)
        if count >= threadNumbers {
            mainCondition.signal()
        }
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
