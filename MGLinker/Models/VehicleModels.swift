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
    
    // 更多字段...
    let local_sec_row_r_seat_vent_lvl: Int?
    let climate_on_off_status: Int?
    let steer_heat_level: Int?
    let pwr_lftgt_pos: Int?
    let inst_fuel_consumption: Int?
    let rear_right_tyre_pressure_alt: Int?
    let tbox_internal_battery: Int?
    let battery_pack_fault_status: Int?
    let charge_door_position_status: Int?
    let veh_elec_rng_dsp_cmd: Int?
    let local_sec_row_l_seat_vent_lvl: Int?
    let veh_bms_pack_soc_dsp_v: Int?
    let battery_lattice_number: Int?
    let battery_pack_range_alt: Int?
    let power_mode: Int?
    let engine_status: Int?
    let exterior_temperature_alt: Int?
    let rmt_rr_seat_heat_flr_rsn: Int?
    let fuel_level_prc_alt: Int?
    let localfront_left_seat_heat_level: Int?
    let interior_pm25: Int?
    let odometer_alt: Int?
    let local_sec_row_l_seat_heat_lvl: Int?
    let rmt_fr_seat_heat_flr_rsn: Int?
    let rmt_seat_vent_flr_rsn: Int?
    let inspect_status: Int?
    let remote_steer_heat_level: Int?
    let last_key_seen: Int?
    let wheel_tyre_monitor_status: Int?
    let rmt_a_c_abot_rsn: Int?
    let vehicle_battery_alt: Int?
    let chrgng_rmnng_time_alt: Int?
    let exterior_pm25: Int?
    let front_left_tyre_pressure_alt: Int?
    let charge_status_alt: Int?
    let localfront_right_seat_vent_level: Int?
    let speed_alt: Int?
    let vehicle_battery_dev: Int?
    let front_right_tyre_pressure_alt: Int?
    let battery_pack_prc_alt: Int?
    let interior_temperature_v: Int?
    let steer_heat_failure_reason: Int?
    let local_sec_row_r_seat_heat_lvl: Int?
    let clstr_elec_rng_to_eptv: Int?
    let fuel_range_alt: Int?
    let current_journey_id: Int?
    let pwr_lftgt_pos_v: Int?
    let interior_temperature_alt: Double?
    let localfront_right_seat_heat_level: Int?
    let heading: Int?
    let battery_alarm_value: [Int]?
    let update_time_alt: Int64?
    let remote_climate_status: Int?
    let fota_status: Int?
    let current_journey_distance: Int?
    let bms_charge_status: Int?
    let vehicle_alarm_status: Int?
    let veh_intlgnt_scene_md: Int?
    let rear_left_tyre_pressure_alt: Int?
    let vehicle_battery_prc: Int?
    let battery_type: Int?
    let fuel_level_disp: Int?
    let monitor_status: Int?
    let localfront_left_seat_vent_level: Int?
}

// MARK: - 车辆状态
struct VehicleState: Codable {
    let door: Bool
    let gnss_ant_connected: Bool
    let second_row_left_seat_heat: Bool
    let rear_right_door: Bool
    let second_row_right_seat_vent: Bool
    let dipped_beam: Bool
    let driver_window: Bool
    let clstr_range: Bool
    let vehicle_battery_connected: Bool
    let seat_heat: Bool
    let driver_door: Bool
    let lock: Bool
    let right_seat_heat: Bool
    let feed: Bool
    let horn: Bool
    let air_clean: Bool
    let light: Bool
    let bonnet: Bool
    let bat_low: Bool?
    let inspect: Bool?
    let steer_heat: Bool
    let side_light: Bool
    let gsm_ant_connected: Bool
    let second_row_left_seat_vent: Bool
    let battery_pack: Bool
    let combination_control: Bool
    let engine: Bool
    let seat_vent: Bool
    let left_seat_vent: Bool
    let second_row_right_seat_heat: Bool
    let power: Bool
    let boot: Bool
    let power_protection: Bool
    let charge: Bool
    let passenger_door: Bool
    let can_bus: Bool
    let update_time: Int64
    let monitor: Bool?
    let climate: Bool
    let right_seat_vent: Bool
    let left_seat_heat: Bool
    let rear_right_window: Bool
    let sunroof: Bool
    let rear_left_door: Bool
    let passenger_window: Bool
    let window: Bool
    let rear_left_window: Bool
    let main_beam: Bool
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

// MARK: - 应用状态
struct MainUIState {
    var carBrand: String = "名爵"
    var carModel: String = ""
    var carName: String = ""
    var vin: String = ""
    var color: String = ""
    var plateNumber: String = ""
    var accessToken: String = ""
    var isConfigured: Bool = false
    var isLoadingConfig: Bool = true
    var carConfigList: [CarConfig] = []
    var isUpdateAvailable: Bool = false
    var releaseInfo: GiteeRelease?
    var isDownloading: Bool = false
    var downloadProgress: Float = 0.0
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