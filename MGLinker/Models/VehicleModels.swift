import Foundation

// MARK: - 车辆状态响应
struct VehicleStatusResponse: Codable {
    let req_id: String?
    let data: VehicleData?
}

// MARK: - 车辆数据
struct VehicleData: Codable {
    let vehicle_position: VehiclePosition?
    let vehicle_security: String?
    let vehicle_alerts: [String]?
    let vehicle_value: VehicleValue?
    let vehicle_state: VehicleState?
    let update_time: Int64?
    var calculator: String?
}

// MARK: - 车辆位置
struct VehiclePosition: Codable {
    let satellites: Int?
    let altitude: Int?
    let gps_status: Int?
    let latitude: String?
    let longitude: String?
    let update_time: Int64?
    let gps_time: Int64?
    let hdop: Int?
}

// MARK: - 车辆数值
struct VehicleValue: Codable {
    let fuel_level_prc: Int?
    let fuel_range: Int?
    let driving_range: Int?
    let odometer: Int?
    let battery_pack_prc: Int?
    let battery_pack_range: Int?
    let interior_temperature: Double?
    let exterior_temperature: Int?
    let chrgng_rmnng_time: Int?
    let charge_status: Int?
    let speed: Int?
    let vehicle_battery: Int?
    let front_left_tyre_pressure: Int?
    let front_right_tyre_pressure: Int?
    let rear_left_tyre_pressure: Int?
    let rear_right_tyre_pressure: Int?
    let vehicle_battery_prc: Int?
    let engine_status: Int?
    let climate_on_off_status: Int?
    let steer_heat_level: Int?
}

// MARK: - 车辆状态
struct VehicleState: Codable {
    let door: Bool
    let driver_door: Bool
    let passenger_door: Bool
    let rear_left_door: Bool
    let rear_right_door: Bool
    let bonnet: Bool
    let boot: Bool
    let lock: Bool
    let window: Bool
    let driver_window: Bool
    let passenger_window: Bool
    let rear_left_window: Bool
    let rear_right_window: Bool
    let sunroof: Bool
    let engine: Bool
    let climate: Bool
    let charge: Bool
    let light: Bool
    let main_beam: Bool
    let dipped_beam: Bool
    let side_light: Bool
    let horn: Bool
    let power: Bool
    let update_time: Int64
}

// MARK: - 车辆配置
struct CarConfig: Codable {
    let brand: String
    let model: String
    let colors: [CarColor]
    let fuel: Double?
    let battery: Double?
}

struct CarColor: Codable {
    let name: String
    let imageUrl: String
}

struct RemoteConfig: Codable {
    let saic: [CarConfig]
}

// MARK: - Gitee 发布信息
struct GiteeRelease: Codable {
    let tag_name: String
    let name: String
    let body: String
    let assets: [GiteeAsset]
}

struct GiteeAsset: Codable {
    let name: String
    let browser_download_url: String
}

// MARK: - 小组件上下文数据
struct WidgetContextData {
    let carBrand: String
    let carModel: String
    let carName: String
    let plateNumber: String
    let carImageUrl: String
    let fuelCapacity: Double
    let batteryCapacity: Double
    let vehicleData: VehicleStatusResponse?
    let address: String?
}