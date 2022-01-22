//
//  HostState.swift
//  slnovaios
//
//  Created by Jcwang on 2022/1/19.
//

import Foundation

class HostState {
    var isRunning = true
    var uuid = ""
    var cpuFreq = 0
    var freeMemoryMB = 0
    var totalUsableDiskGB = 0
    var cpuPercent = 0.0
    var diskAllocationRatio = 0.0
    var name = "nullname"
    var ip = "0.0.0.0"
    var freeDiskGB = 0.0
    var time = "1970-00-00 00:00:00"
    
    init(isRunning: Bool, uuid: String, cpuFreq: Int, freeMemoryMB: Int, totalUsableDiskGB: Int, cpuPercent: Double, diskAllocationRatio: Double, name: String, ip: String, freeDiskGB: Double, time: String) {
        self.isRunning = isRunning
        self.uuid = uuid
        self.cpuFreq = cpuFreq
        self.freeMemoryMB = freeMemoryMB
        self.totalUsableDiskGB = totalUsableDiskGB
        self.cpuPercent = cpuPercent
        self.diskAllocationRatio = diskAllocationRatio
        self.name = name
        self.ip = ip
        self.freeDiskGB = freeDiskGB
        self.time = time
    }
    
    func description() -> String {
        return """
                  时间：\(self.time)
                  cpu频率：   \(self.cpuFreq)GHz
                  cpu使用率： \(String(format:"%.2f", self.cpuPercent))%
                  磁盘分配率： \(String(format:"%.2f", self.diskAllocationRatio))
                  磁盘总量：   \(self.totalUsableDiskGB)GB
                  磁盘空闲总量：\(String(format:"%.2f", self.freeDiskGB))GB
                  空闲内存：   \(self.freeMemoryMB)MB
                  uuid：
                  \(self.uuid)
                  """
    }
}
