import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    
    @Published var isConnected = false
    @Published var connectedDevice: CBPeripheral?
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var autoUnlockEnabled = false
    @Published var autoLockEnabled = false
    
    private var centralManager: CBCentralManager!
    private var peripherals: [CBPeripheral] = []
    private var cancellables = Set<AnyCancellable>()
    
    // 蓝牙服务和特征UUID（示例，需要根据实际车辆蓝牙协议调整）
    private let serviceUUID = CBUUID(string: "FFF0")
    private let characteristicUUID = CBUUID(string: "FFF1")
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // 监听自动解锁/落锁设置
        $autoUnlockEnabled
            .sink { [weak self] enabled in
                if enabled {
                    self?.startMonitoringForAutoUnlock()
                } else {
                    self?.stopMonitoringForAutoUnlock()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 扫描设备
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("蓝牙未开启")
            return
        }
        
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        print("开始扫描蓝牙设备...")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        print("停止扫描")
    }
    
    // MARK: - 连接设备
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        if let device = connectedDevice {
            centralManager.cancelPeripheralConnection(device)
        }
    }
    
    // MARK: - 发送命令
    func sendCommand(_ command: Data) {
        guard let device = connectedDevice,
              let characteristic = device.services?.first(where: { $0.uuid == serviceUUID })?
            .characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            print("未找到特征")
            return
        }
        
        device.writeValue(command, for: characteristic, type: .withResponse)
    }
    
    // MARK: - 车辆控制命令
    func lockVehicle() {
        let command = Data([0x01, 0x01]) // 示例命令
        sendCommand(command)
        print("发送锁车命令")
    }
    
    func unlockVehicle() {
        let command = Data([0x01, 0x00]) // 示例命令
        sendCommand(command)
        print("发送解锁命令")
    }
    
    func openTrunk() {
        let command = Data([0x02, 0x01]) // 示例命令
        sendCommand(command)
        print("发送开启后备箱命令")
    }
    
    func findVehicle() {
        let command = Data([0x03, 0x01]) // 示例命令
        sendCommand(command)
        print("发送寻车命令")
    }
    
    // MARK: - 自动解锁/落锁监控
    private func startMonitoringForAutoUnlock() {
        // 实现基于蓝牙信号强度的自动解锁逻辑
        // 当检测到车辆蓝牙信号强度达到阈值时自动解锁
        print("开始监控自动解锁")
    }
    
    private func stopMonitoringForAutoUnlock() {
        print("停止监控自动解锁")
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("蓝牙已开启")
            startScanning()
        case .poweredOff:
            print("蓝牙已关闭")
            isConnected = false
            connectedDevice = nil
        case .resetting:
            print("蓝牙重置中")
        case .unauthorized:
            print("蓝牙未授权")
        case .unsupported:
            print("设备不支持蓝牙")
        case .unknown:
            print("蓝牙状态未知")
        @unknown default:
            print("未知蓝牙状态")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("发现设备: \(peripheral.name ?? "未知"), RSSI: \(RSSI)")
        
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
        
        // 自动解锁逻辑：如果信号强度足够强且已启用自动解锁
        if autoUnlockEnabled && RSSI.intValue > -50 {
            print("检测到车辆信号，尝试自动解锁")
            connect(to: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("已连接设备: \(peripheral.name ?? "未知")")
        isConnected = true
        connectedDevice = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败: \(error?.localizedDescription ?? "未知错误")")
        isConnected = false
        connectedDevice = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("设备断开连接: \(peripheral.name ?? "未知")")
        isConnected = false
        connectedDevice = nil
        
        // 自动落锁逻辑
        if autoLockEnabled {
            print("设备断开，执行自动落锁")
            // 这里应该调用远程锁车API
        }
        
        // 重新开始扫描
        startScanning()
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("发现服务失败: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("发现服务: \(service.uuid)")
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("发现特征失败: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("发现特征: \(characteristic.uuid)")
            if characteristic.uuid == self.characteristicUUID {
                // 订阅特征通知
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("读取特征值失败: \(error.localizedDescription)")
            return
        }
        
        guard let value = characteristic.value else { return }
        
        print("收到数据: \(value.map { String(format: "%02x", $0) }.joined())")
        
        // 解析车辆状态数据
        parseVehicleData(value)
    }
    
    private func parseVehicleData(_ data: Data) {
        // 根据实际车辆蓝牙协议解析数据
        // 这里只是示例
        guard data.count >= 2 else { return }
        
        let command = data[0]
        let status = data[1]
        
        switch command {
        case 0x01: // 锁车状态
            print("锁车状态: \(status == 0x01 ? "已锁定" : "未锁定")")
        case 0x02: // 后备箱状态
            print("后备箱状态: \(status == 0x01 ? "已开启" : "已关闭")")
        default:
            break
        }
    }
}