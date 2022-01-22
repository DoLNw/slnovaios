//
//  CollectionViewController.swift
//  slnovaios
//
//  Created by Jcwang on 2022/1/19.
//

import UIKit
import OHMySQL

private let reuseIdentifier = "HostState"

let keys = ["isrunning", "uuid", "cpufreq", "free_memory_mb", "total_usable_disk_gb", "cpu_percent", "disk_allocation_ratio", "name", "ip","free_disk_gb" ]

var hostStates = [HostState]()

class CollectionViewController: UICollectionViewController {
    // 初始化OHMySQL协调器
    var coordinator = MySQLStoreCoordinator()
    // 初始化上下文
    let context = MySQLQueryContext()
    
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "HostStates"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // 为什么不需要注册这一句话？
//        self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        // 注意数据库与timer的先后顺序，创建：数据库线，timer后。销毁：timer先，数据库后。
        let _ = connectMySQL()
        scheGetHostStates() // 一开始先来一遍
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(scheGetHostStates), userInfo: nil, repeats: true)
    }
    
    @objc func scheGetHostStates() {
        hostStates.removeAll(keepingCapacity: true)
        getHostStates(infos: queryMySQL())
        self.collectionView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        if let timer = self.timer {
            timer.invalidate()
        }
        
        disconMySQL()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
//        return hostStates.count
        
        return hostStates.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        // Configure the cell
        // 为啥我把这个UI配置放在cell的init函数中没有用呢？
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.borderWidth = 2.5
        cell.contentView.layer.borderColor = UIColor.systemTeal.cgColor
        cell.contentView.layer.masksToBounds = true
        
        // 检查如果是时间格式
        if (hostStates[indexPath.item].time.count == 19) {
            let localTime = Helper.getAllSeconds(time: Helper.getCurrentTime())
            let mysqlTime = Helper.getAllSeconds(time: hostStates[indexPath.item].time)
            if (mysqlTime - 3 < localTime && localTime < mysqlTime + 3) {
                cell.contentView.backgroundColor = .systemBlue
            } else {
                cell.contentView.backgroundColor = .systemBackground
            }
        } else {
            cell.contentView.backgroundColor = .systemBackground
        }
        
        
        cell.infoLabel.contentMode = .top
        
        cell.nameLabel.text = hostStates[indexPath.item].name
        cell.ipLabel.text = hostStates[indexPath.item].ip
        cell.infoLabel.text = hostStates[indexPath.item].description()
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}


extension CollectionViewController {
    
    func connectMySQL() -> Bool {

        let dbName = "slnova"//数据库模块名称
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
        // 连接成功后保存协调器到当前的上下文，即可不用每次操作数据库都要重新连接
        if (sqlConnected) {
            print("连接成功")
            context.storeCoordinator = coordinator
            
            return true
        }
        
//        //也可ping服务器查询连接状态
//        switch coordinator.pingMySQL() {
//        case .none:
//            //数据库连接成功
//            print("成功")
//            break
//        case .sync:
//            //命令以错误的顺序执行
//            break
//        case .gone:
//            //MySQL服务器已经丢失
//            break
//        case .lost:
//            //与服务器的连接丢失
//            break
//        case .unknown:
//            //未知错误
//            break
//        default:
//            break
//        }
        
        return false
    }
    
    func disconMySQL() {
        // 与数据库断开连接
        coordinator.disconnect()
    }
    
    func queryMySQL() -> [[String: Any]] {
        
        // 表名
        let tableName = "test"

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
//            print("query successfully")
//            print("response:\(response as Any)")
            
            return response
        
    //            //增、删、改
    //            try context.execute(query2)
    //            try context.execute(query3)
    //            try context.execute(query4)
                    
         }catch {
             print("MySQL_Error:\(error)")
        }
        
        return [[String: Any]]()
        
    }
    // 注意：MySQL数据库拿下来的TEXT数据显示出来是带有ASCII字符串十六进制表示的ANY对象，需要先转成Data然后转成String
    func getHostStates(infos: [[String: Any]]) {
        for info in infos {
            let hostate = HostState(isRunning: (info["isrunning"] as! Int) != 0, uuid: String(data: info["uuid"] as! Data, encoding: String.Encoding.utf8) ?? "nulluuid", cpuFreq: (info["cpufreq"] as! Int), freeMemoryMB: (info["free_memory_mb"] as! Int), totalUsableDiskGB: (info["total_usable_disk_gb"] as! Int), cpuPercent: (info["cpu_percent"] as! Double), diskAllocationRatio: (info["disk_allocation_ratio"] as! Double), name: String(data: info["name"] as! Data, encoding: String.Encoding.utf8) ?? "nullname", ip: String(data: info["ip"] as! Data, encoding: String.Encoding.utf8) ?? "0.0.0.0", freeDiskGB: (info["free_disk_gb"] as! Double), time: String(data: info["time"] as! Data, encoding: String.Encoding.utf8) ?? "1970-00-00s 00:00:00")
            
            
            hostStates.append(hostate)
        }
    }
    
 
}
