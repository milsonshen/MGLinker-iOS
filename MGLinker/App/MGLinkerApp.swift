import SwiftUI
import ActivityKit

@main
struct MGLinkerApp: App {
    @StateObject private var vehicleManager = VehicleManager.shared
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @AppStorage("isConfigured") private var isConfigured = false
    
    init() {
        requestLiveActivityPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            if isConfigured {
                MainTabView()
                    .environmentObject(vehicleManager)
                    .environmentObject(bluetoothManager)
            } else {
                ConfigurationView()
                    .environmentObject(vehicleManager)
            }
        }
    }
    
    private func requestLiveActivityPermission() {
        // 请求 Live Activity 权限
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                try await center.requestAuthorization(options: [.alert, .sound, .badge])
                print("通知权限已授予")
            } catch {
                print("通知权限请求失败: \(error)")
            }
        }
    }
}