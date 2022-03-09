//
//  CollectionViewController.swift
//  slnovaios
//
//  Created by Jcwang on 2022/1/19.
//

import UIKit
import OHMySQL
import RMQClient

/*
 模式一：fanout
 这种模式下，传递到 exchange 的消息将会转发到所有与其绑定的 queue 上。
 不需要指定 routing_key ，即使指定了也是无效。
 需要提前将 exchange 和 queue 绑定，一个 exchange 可以绑定多个 queue，一个queue可以绑定多个exchange。
 需要先启动 订阅者，此模式下的队列是 consumer 随机生成的，发布者 仅仅发布消息到 exchange，由 exchange 转发消息至 queue。
 */

private let reuseIdentifier = "HostState"

let keys = ["uuid", "cpufreq", "free_memory_mb", "total_usable_disk_gb", "cpu_percent", "disk_allocation_ratio", "name", "ip","free_disk_gb" ]

var hostStates = [HostState]()
var trainingHost = [String]()
var epochIndex = [Int: Int]()   // 指示每一个epoch，有多少个主机已经训练好了
var schedulerIndex = 0

class CollectionViewController: UICollectionViewController {
    // 初始化OHMySQL协调器
    var coordinator = MySQLStoreCoordinator()
    // 初始化上下文
    let context = MySQLQueryContext()
    
    var timer: Timer!
    
    var conn: RMQConnection!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "HostStates"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startTrain))
        

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
        
        
        let delegate = RMQConnectionDelegateLogger() // implement RMQConnectionDelegate yourself to react to errors
        conn = RMQConnection(uri: self.getRabbitMQUrl(), delegate: delegate)
        
        conn.start()
        let ch = conn.createChannel()

        let x = ch.fanout("ml_fanout_exchange") // “无路由交换机”，使用这个交换机不需要routingkey绑定，fanout交换机直接绑定了队列

        let q = ch.queue("", options: .durable)
        q.bind(x)

        q.subscribe({[self] (_ message: RMQMessage) -> Void in
            let str = String(data: message.body, encoding: .utf8) ?? "no data"
            if let message = str.stringValueDic() {
                print(message)
                
                let epoch = message["epoch"] as! Int
                let uuid = message["uuid"] as! String
                let isStart = message["start"] as! Int == 1 ? true : false
                let finished = message["finished"] as! Int == 1 ? true : false
                let scheduler = message["scheduler"] as! Int == 1 ? true : false
                
                // 发送消息的时候保证都正确，下面的if就只会执行一个
                if (isStart && !trainingHost.contains(uuid)) {
                    trainingHost.append(uuid)
                }
                if (finished) {
                    trainingHost.removeAll(keepingCapacity: true)
                    schedulerIndex = 0
                }
                if (scheduler) {
                    schedulerIndex += 1
                    if (schedulerIndex == trainingHost.count) {
                        self.sendFanoutMessage(message: "start scheduler")
                        schedulerIndex = 0
                    }
                }
                if (epoch != -1) {
                    if let _ = epochIndex[epoch] {
                        epochIndex[epoch]! += 1;
                    } else {
                        epochIndex[epoch] = 1;
                    }
                    if (epochIndex[epoch] == trainingHost.count) {
                        self.sendFanoutMessage(message: "next epoch")
                        epochIndex[epoch] = 0
                    }
                }
                
            }
        })
        
        print("hhh")
//        conn.close()
        print("iii")
    }
    
    func getRabbitMQUrl() -> String{
        var components = URLComponents()
        components.scheme = "amqp"
        components.host = "116.62.233.27"
        components.user = "rabbit"
        components.password = "password"
        components.port = 5672
        components.path = "/vhost"
        let url = components.url?.absoluteString ?? "-"
        print("RabbitMQ URL \(url)")
        return url
    }
    
    func sendFanoutMessage(message: String) {
        print("aaa")
        let delegate = RMQConnectionDelegateLogger() // implement RMQConnectionDelegate yourself to react to errors
        // "amqp://username:password@hostName:port/virtualHost"
        // https://juejin.cn/post/6948322270989254664
        print("bbb")
        let conn = RMQConnection(uri: self.getRabbitMQUrl(), delegate: delegate)
        
        print("ccc")
        conn.start()
        print("ddd")
        let ch = conn.createChannel()
        print("eee")
        
        
//        let q = ch.queue("ml_queue")
//        let exchange = ch.direct("ml_exchange") // 这个返回exchange
//        q.bind(exchange, routingKey: "ml_routing_key")
//
////        q.subscribe({ m in
////           print("Received: \(String(data: m.body, encoding: String.Encoding.utf8))")
////        })
//        q.publish("start train".data(using: String.Encoding.utf8)!)
        
        print("fff")
        let x = ch.fanout("ml_fanout_exchange") // “无路由交换机”，使用这个交换机不需要routingkey绑定，fanout交换机直接绑定了队列
        print("ggg")
        x.publish(message.data(using: String.Encoding.utf8)!)
        

//        let q = ch.queue("ml_quene", options: .durable)
//        q.bind(x)
//        print("Waiting for logs.")
//        q.subscribe({(_ message: RMQMessage) -> Void in
//            print("Received \(String(describing: String(data: message.body, encoding: .utf8)))")
//        })
        
        print("hhh")
        conn.close()
        print("iii")
    }
    
    @objc func startTrain() {
        let ac = UIAlertController(title: "Start train?", message: "It will make all hosts start to train", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default) { [self] _ in
            sendFanoutMessage(message: "start train")
        }
        ac.addAction(okBtn)
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelBtn)
        self.present(ac, animated: true, completion: nil)
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
        // 因为数据库存进去，读取出来，都需要时间，所以显示的时间都会比实际时间晚的。
        if (hostStates[indexPath.item].time.count == 19) {
            let localTime = Helper.getAllSeconds(time: Helper.getCurrentTime())
            let mysqlTime = Helper.getAllSeconds(time: hostStates[indexPath.item].time)
            
            // 训练用红色，聚合用橙色，运行蓝色，不活跃状态背景色
            if (mysqlTime - 3 < localTime && localTime <= mysqlTime + 4) {
                cell.contentView.backgroundColor = .systemBlue.withAlphaComponent(0.6)
                
                if hostStates[indexPath.item].isTraining {
                    cell.contentView.backgroundColor = .red.withAlphaComponent(0.5)
                }
                // 聚合为true的时候，training肯定是true的
                if hostStates[indexPath.item].isAggregating {
                    cell.contentView.backgroundColor = .orange.withAlphaComponent(0.5)
                }
                
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
    // 注意，mysql中text类型的字符串数据，获取方法是String(data: info["uuid"] as! Data, encoding: String.Encoding.utf8) ?? "nulluuid"
    // 而如果使用VARCHAR的话，只要转换成String就好了
    func getHostStates(infos: [[String: Any]]) {
        for info in infos {
            let hostate = HostState(
                uuid: info["uuid"] as! String,
                diskAllocationRatio: (info["disk_allocation_ratio"] as! Double),
                name: info["name"] as! String,
                ip: info["ip"] as! String,
                totalDiskGB: (info["total_disk_gb"] as! Double),
                totalMemoryGB: (info["total_memory_gb"] as! Double),
                gpuTotalMemoryGB: (info["gpu_total_memory_gb"] as! Double),
                cpu_max_freq: (info["cpu_max_freq"] as! Double),
                time: info["time"] as! String,
                cpuPercent: (info["cpu_percent"] as! Double),
                usedDiskGB: (info["used_disk_gb"] as! Double),
                usedMemoryGB: (info["used_memory_gb"] as! Double),
                gpuUsedMemoryGB: (info["gpu_used_memory_gb"] as! Double),
                cpuCurrentFreq: (info["cpu_current_freq"] as! Double),
                highVul: (info["high_vul"] as! Int),
                mediumVul: (info["medium_vul"] as! Int),
                lowVul: (info["low_vul"] as! Int),
                infoVul: (info["info_vul"] as! Int),
                modelSizeMB: (info["model_size_mb"] as! Double),
                loss: (info["loss"] as! Double),
                accuracy: (info["accuracy"] as! Double),
                epoch: (info["epoch"] as! Int),
                isAggregating: (info["is_aggregating"] as! Bool),
                isTraining: (info["is_training"] as! Bool)
            )
            
            hostStates.append(hostate)
        }
    }
    
 
}
