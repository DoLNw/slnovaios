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
    var highVul = 0
    var mediumVul = 0
    var lowVul = 0
    var infoVul = 0
    
    init(isRunning: Bool, uuid: String, cpuFreq: Int, freeMemoryMB: Int, totalUsableDiskGB: Int, cpuPercent: Double, diskAllocationRatio: Double, name: String, ip: String, freeDiskGB: Double, time: String, highVul: Int=0, mediumVul: Int=0, lowVul: Int=0, infoVul: Int=0) {
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
        self.highVul = highVul
        self.mediumVul = mediumVul
        self.lowVul = lowVul
        self.infoVul = infoVul
    }
    
    func description() -> String {
        // 为了使得文本看起来空的差不多，我需要留出一些空格
        return """
                  \(self.time)
                  
                  cpu频率：         \(self.cpuFreq)GHz
                  cpu使用率：     \(String(format:"%.2f", self.cpuPercent))%
                  磁盘分配率：    \(String(format:"%.2f", self.diskAllocationRatio))
                  磁盘总量：        \(self.totalUsableDiskGB)GB
                  磁盘空闲总量：\(String(format:"%.2f", self.freeDiskGB))GB
                  空闲内存：        \(self.freeMemoryMB)MB
                  安全：                 \(self.infoVul)个
                  低风险漏洞：    \(self.lowVul)个
                  中风险漏洞：    \(self.mediumVul)个
                  高风险漏洞：    \(self.highVul)个
                  uuid：
                  \(self.uuid)
                  """
    }
}
