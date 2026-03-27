import Foundation
import SwiftUI
import Combine
import ActivityKit

@MainActor
class VehicleManager: ObservableObject {
    static let shared = VehicleManager()
    
    @Published var vehicleData: VehicleStatusResponse?
    @Published var carConfigList: [CarConfig] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdateTime: Date?
    @Published var address: String?
    @Published var isLiveActivityEnabled = false
    
    // 用户配置
    @AppStorage("carBrand") var carBrand: String = "名爵"
    @AppStorage("carModel") var carModel: String = ""
    @AppStorage("carName") var carName: String = ""
    @AppStorage("vin") var vin: String = ""
    @AppStorage("color") var color: String = ""
    @AppStorage("plateNumber") var plateNumber: String = ""
    @AppStorage("accessToken") var accessToken: String = ""
    @AppStorage("isConfigured") var isConfigured: Bool = false
    @AppStorage("carImageUrl") var carImageUrl: String = ""
    @AppStorage("fuelCapacity") var fuelCapacity: Double = 0.0
    @AppStorage("batteryCapacity") var batteryCapacity: Double = 0.0
    
    private let apiService = APIService.shared
    private let liveActivityManager = LiveActivityManager.shared
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadCarConfig()
        startAutoRefresh()
    }
    
    // MARK: - 加载车辆配置
    func loadCarConfig() {
        Task {
            do {
                let configs = try await apiService.fetchCarConfig()
                carConfigList = configs
            } catch {
                print("Failed to load car config: \(error)")
            }
        }
    }
    
    // MARK: - 获取车辆数据
    func fetchVehicleData() async {
        guard !vin.isEmpty, !accessToken.isEmpty else {
            errorMessage = "请先配置车辆信息"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.fetchVehicleStatus(vin: vin, token: accessToken)
            vehicleData = response
            lastUpdateTime = Date()
            
            // 更新地址
            if let position = response?.data?.vehicle_position,
               let lat = position.latitude,
               let lon = position.longitude,
               let latitude = Double(lat),
               let longitude = Double(lon) {
                address = try? await apiService.reverseGeocode(latitude: latitude, longitude: longitude)
            }
        } catch {
            errorMessage = "获取车辆数据失败: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - 保存配置
    func saveConfig(brand: String, model: String, name: String, vin: String, 
                   color: String, plate: String, token: String) -> Bool {
        // 验证
        guard vin.count == 17 else {
            errorMessage = "请输入正确的17位车架号"
            return false
        }
        
        guard !token.isEmpty else {
            errorMessage = "请输入ACCESS_TOKEN"
            return false
        }
        
        guard token.hasSuffix("-prod_SAIC") else {
            errorMessage = "ACCESS_TOKEN格式不正确"
            return false
        }
        
        // 获取详细配置
        let brandCode = brand == "名爵" ? "MG" : "RW"
        let modelConfig = carConfigList.first { $0.brand == brandCode && $0.model == model }
        let colorConfig = modelConfig?.colors.first { $0.name == color }
        
        // 保存配置到UserDefaults
        carBrand = brand
        carModel = model
        carName = name
        self.vin = vin
        self.color = color
        plateNumber = plate
        accessToken = token
        carImageUrl = colorConfig?.imageUrl ?? ""
        fuelCapacity = modelConfig?.fuel ?? 0.0
        batteryCapacity = modelConfig?.battery ?? 0.0
        isConfigured = true
        
        // 保存到App Groups，供小组件使用
        let sharedDefaults = UserDefaults(suiteName: "group.com.mglinker.app")
        sharedDefaults?.set(brand, forKey: "carBrand")
        sharedDefaults?.set(model, forKey: "carModel")
        sharedDefaults?.set(name, forKey: "carName")
        sharedDefaults?.set(vin, forKey: "vin")
        sharedDefaults?.set(plate, forKey: "plateNumber")
        sharedDefaults?.set(token, forKey: "accessToken")
        sharedDefaults?.set(carImageUrl, forKey: "carImageUrl")
        
        // 立即获取数据
        Task {
            await fetchVehicleData()
        }
        
        return true
    }
    
    // MARK: - 自动刷新
    private func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchVehicleData()
            }
        }
    }
    
    // MARK: - 手动刷新
    func refreshData() async {
        await fetchVehicleData()
    }
    
    // MARK: - 获取车辆图片
    func getCarImage() -> URL? {
        guard !carImageUrl.isEmpty else { return nil }
        return URL(string: carImageUrl)
    }
    
    // MARK: - 获取小组件数据
    func getWidgetContextData() -> WidgetContextData {
        return WidgetContextData(
            carBrand: carBrand,
            carModel: carModel,
            carName: carName.isEmpty ? carModel : carName,
            plateNumber: plateNumber,
            carImageUrl: carImageUrl,
            fuelCapacity: fuelCapacity,
            batteryCapacity: batteryCapacity,
            vehicleData: vehicleData,
            address: address
        )
    }
    
    // MARK: - Live Activity 管理
    func startLiveActivity() {
        guard let data = vehicleData?.data else { return }
        
        let fuelRange = data.vehicle_value?.fuel_range ?? 0
        let batteryRange = data.vehicle_value?.battery_pack_range ?? 0
        let isLocked = data.vehicle_state?.lock ?? false
        let isDoorOpen = data.vehicle_state?.door ?? false
        let interiorTemperature = data.vehicle_value?.interior_temperature ?? 0.0
        
        liveActivityManager.startActivity(
            carBrand: carBrand,
            carModel: carModel,
            carName: carName.isEmpty ? carModel : carName,
            plateNumber: plateNumber,
            fuelRange: fuelRange,
            batteryRange: batteryRange,
            isLocked: isLocked,
            isDoorOpen: isDoorOpen,
            interiorTemperature: interiorTemperature
        )
        
        isLiveActivityEnabled = true
    }
    
    func updateLiveActivity() {
        guard let data = vehicleData?.data else { return }
        
        let fuelRange = data.vehicle_value?.fuel_range ?? 0
        let batteryRange = data.vehicle_value?.battery_pack_range ?? 0
        let isLocked = data.vehicle_state?.lock ?? false
        let isDoorOpen = data.vehicle_state?.door ?? false
        let interiorTemperature = data.vehicle_value?.interior_temperature ?? 0.0
        
        liveActivityManager.updateActivity(
            fuelRange: fuelRange,
            batteryRange: batteryRange,
            isLocked: isLocked,
            isDoorOpen: isDoorOpen,
            interiorTemperature: interiorTemperature
        )
    }
    
    func stopLiveActivity() {
        liveActivityManager.endActivity()
        isLiveActivityEnabled = false
    }
    
    func checkLiveActivityStatus() {
        isLiveActivityEnabled = liveActivityManager.hasActiveActivity()
    }
}