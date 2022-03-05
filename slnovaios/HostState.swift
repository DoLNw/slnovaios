//
//  HostState.swift
//  slnovaios
//
//  Created by Jcwang on 2022/1/19.
//

import Foundation

class HostState {
    // 不变
    var uuid = ""
    var diskAllocationRatio = 0.0
    var name = "nullname"
    var ip = "0.0.0.0"
    
    var totalDiskGB = 0.0
    var totalMemoryGB = 0.0
    var gpuTotalMemoryGB = 0.0
    var cpu_max_freq = 0.0
    
    
    // 变
    var time = "1970-00-00 00:00:00"
    var cpuPercent = 0.0
    
    var usedDiskGB = 0.0
    var usedMemoryGB = 0.0
    var gpuUsedMemoryGB = 0.0
    var cpuCurrentFreq = 0.0
    
    var highVul = 0
    var mediumVul = 0
    var lowVul = 0
    var infoVul = 0
    
    var modelSizeMB = 0.0
    var loss = 0.0
    var accuracy = 0.0
    // 显示的时候从0开始，存储的时候，也是从0开始存储的，因为训练的时候26，101这样，为了每5次存储时首位都存储
    var epoch = (-1)
    var isAggregating = false
    var isTraining = false
    
    init(uuid: String,
         diskAllocationRatio: Double,
         name: String,
         ip: String,
         totalDiskGB: Double,
         totalMemoryGB: Double,
         gpuTotalMemoryGB: Double,
         cpu_max_freq: Double,
         time: String,
         cpuPercent: Double,
         usedDiskGB: Double,
         usedMemoryGB: Double,
         gpuUsedMemoryGB: Double,
         cpuCurrentFreq: Double,
         highVul: Int=0,
         mediumVul: Int=0,
         lowVul: Int=0,
         infoVul: Int=0,
         modelSizeMB: Double,
         loss: Double,
         accuracy: Double,
         epoch: Int=0,
         isAggregating: Bool=false,
         isTraining: Bool=false) {
        
        // 不变
        self.uuid = uuid
        self.diskAllocationRatio = diskAllocationRatio
        self.name = name
        self.ip = ip
        
        self.totalDiskGB = totalDiskGB
        self.totalMemoryGB = totalMemoryGB
        self.gpuTotalMemoryGB = gpuTotalMemoryGB
        self.cpu_max_freq = cpu_max_freq
        
        
        // 变
        self.time = time
        self.cpuPercent = cpuPercent
        
        self.usedDiskGB = usedDiskGB
        self.usedMemoryGB = usedMemoryGB
        self.gpuUsedMemoryGB = gpuUsedMemoryGB
        self.cpuCurrentFreq = cpuCurrentFreq
        
        self.highVul = highVul
        self.mediumVul = mediumVul
        self.lowVul = lowVul
        self.infoVul = infoVul
        
        self.modelSizeMB = modelSizeMB
        self.loss = loss
        self.accuracy = accuracy
        self.epoch = epoch
        self.isAggregating = isAggregating
        self.isTraining = isTraining
    }
    
    func description() -> String {
        // 为了使得文本看起来空的差不多，我需要留出一些空格
        return """
                  \(self.time)
                  
                  cpu使用率：     \(String(format:"%.2f", self.cpuPercent))%
                  cpu频率： \(String(format:"%.2f", self.cpuCurrentFreq))GHz(\(String(format:"%.2f", self.cpu_max_freq))GHz)
                  磁盘：    \(String(format:"%.2f", self.usedDiskGB))GB(\(String(format:"%.2f", self.totalDiskGB))GB)
                  内存：    \(String(format:"%.2f", self.usedMemoryGB))GB(\(String(format:"%.2f", self.totalMemoryGB))GB)
                  显存：    \(String(format:"%.2f", self.gpuUsedMemoryGB))GB(\(String(format:"%.2f", self.gpuTotalMemoryGB))GB)
                  安全：                 \(self.infoVul)个
                  低风险漏洞：    \(self.lowVul)个
                  中风险漏洞：    \(self.mediumVul)个
                  高风险漏洞：    \(self.highVul)个
                  模型大小：      \(String(format:"%.2f", self.modelSizeMB))
                  损失值：          \(String(format:"%.4f", self.loss))
                  准确率：          \(String(format:"%.4f", self.accuracy))
                  训练轮数：      第\(epoch)轮
                  正在聚合：      \(isAggregating)
                  正在训练：      \(isTraining)
                  uuid：
                  \(self.uuid)
                  """
    }
}
