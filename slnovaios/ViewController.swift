//
//  ViewController.swift
//  slnovaios
//
//  Created by Jcwang on 2022/1/18.
//

// [iOS-Swift之用OHMySQL框架直连MySQL数据库并进行数据操作](https://blog.csdn.net/amberoot/article/details/84984860)

import UIKit
import OHMySQL

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //初始化OHMySQL协调器
        var coordinator = MySQLStoreCoordinator()
     
        //初始化上下文
        let context = MySQLQueryContext()
        let dbName = "slnova"//数据库模块名称
        let tableName = "test"//表名
        ///MySQL Server
        let SQLUserName = "root"//数据库用户名
        let SQLPassword = "971707"//数据库密码

        //数据库名称，如果是用模拟器连接电脑本地数据库，默认是localhost；若用iPhone或iPad远程连接数据库，数据库名称填写其IP地址
        let SQLServerName = "116.62.233.27"
        let SQLServerPort: UInt = 3306//数据库端口号，默认是3306
        
        ///初始化用户
        //mac本地socket为/tmp/mysql.sock，远程连接socket直接为nil即可
        let user = OHMySQLUser(user: SQLUserName, password: SQLPassword, serverName: SQLServerName, dbName: dbName, port: SQLServerPort, socket: nil)
         
        coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4//编码方式
        coordinator.connect()//连接数据库
        
        
        //判断是否成功数据库
        let sqlConnected: Bool = coordinator.isConnected
        //连接成功后保存协调器到当前的上下文，即可不用每次操作数据库都要重新连接
        context.storeCoordinator = coordinator
        //也可ping服务器查询连接状态
        switch coordinator.pingMySQL() {
        case .none:
            //数据库连接成功
            print("成功")
            break
        case .sync:
            //命令以错误的顺序执行
            break
        case .gone:
            //MySQL服务器已经丢失
            break
        case .lost:
            //与服务器的连接丢失
            break
        case .unknown:
            //未知错误
            break
        default:
            break
        }
        
        
        
        
        // SELECT - 查询
        // 查询的请求会返回的数据格式为[[String:Any]]）
        // condition不写，是查询所有，而不是写*号
        let query = MySQLQueryRequestFactory.select(tableName, condition: "")
         
//        //INSERT - 增
//        let query2 = MySQLQueryRequestFactory.insert(tableName, set: ["username": "amberoot2", "password": "33"])
//
//        //DELETE - 删
//        let query3 = MySQLQueryRequestFactory.delete(tableName, condition: "username = 'amberoot'")
//
//        //UPDATE - 改
//        let query4 = MySQLQueryRequestFactory.update(tableName, set: ["password": "10000"], condition: "username = 'amberoot2'")


        do {
            //查询
            let response = try context.executeQueryRequestAndFetchResult(query)
            print("response:\(response as Any)")
        
//            //增、删、改
//            try context.execute(query2)
//            try context.execute(query3)
//            try context.execute(query4)
                    
         }catch {
             print("MySQL_Error:\(error)")
        }



        
        coordinator.disconnect()//与数据库断开连接


    }


}

