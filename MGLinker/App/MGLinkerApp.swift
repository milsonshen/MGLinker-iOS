import SwiftUI

@main
struct MGLinkerApp: App {
    @StateObject private var vehicleManager = VehicleManager.shared
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @AppStorage("isConfigured") private var isConfigured = false
    
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
}