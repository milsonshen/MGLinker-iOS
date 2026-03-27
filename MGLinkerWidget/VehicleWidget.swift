import Foundation
import WidgetKit
import SwiftUI

// MARK: - 小组件时间线条目
struct VehicleEntry: TimelineEntry {
    let date: Date
    let vehicleData: VehicleStatusResponse?
    let carBrand: String
    let carModel: String
    let carName: String
    let plateNumber: String
    let address: String?
    let carImageUrl: String?
}

// MARK: - 小组件提供者
struct VehicleProvider: TimelineProvider {
    func placeholder(in context: Context) -> VehicleEntry {
        VehicleEntry(
            date: Date(),
            vehicleData: nil,
            carBrand: "名爵",
            carModel: "MG7",
            carName: "我的名爵",
            plateNumber: "京A12345",
            address: "北京市朝阳区",
            carImageUrl: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (VehicleEntry) -> Void) {
        let entry = VehicleEntry(
            date: Date(),
            vehicleData: nil,
            carBrand: "名爵",
            carModel: "MG7",
            carName: "我的名爵",
            plateNumber: "京A12345",
            address: "北京市朝阳区",
            carImageUrl: nil
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<VehicleEntry>) -> Void) {
        Task {
            let entry = await fetchVehicleEntry()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func fetchVehicleEntry() async -> VehicleEntry {
        // 从App Groups的UserDefaults读取配置
        let defaults = UserDefaults(suiteName: "group.com.mglinker.app")
        let carBrand = defaults?.string(forKey: "carBrand") ?? "名爵"
        let carModel = defaults?.string(forKey: "carModel") ?? ""
        let carName = defaults?.string(forKey: "carName") ?? ""
        let vin = defaults?.string(forKey: "vin") ?? ""
        let plateNumber = defaults?.string(forKey: "plateNumber") ?? ""
        let accessToken = defaults?.string(forKey: "accessToken") ?? ""
        let carImageUrl = defaults?.string(forKey: "carImageUrl")
        
        var vehicleData: VehicleStatusResponse? = nil
        var address: String? = nil
        
        // 获取车辆数据
        if !vin.isEmpty && !accessToken.isEmpty {
            do {
                let apiService = APIService.shared
                vehicleData = try await apiService.fetchVehicleStatus(vin: vin, token: accessToken)
                
                // 获取地址
                if let position = vehicleData?.data?.vehicle_position,
                   let lat = position.latitude,
                   let lon = position.longitude,
                   let latitude = Double(lat),
                   let longitude = Double(lon) {
                    address = try? await apiService.reverseGeocode(latitude: latitude, longitude: longitude)
                }
            } catch {
                print("小组件获取数据失败: \(error)")
            }
        }
        
        return VehicleEntry(
            date: Date(),
            vehicleData: vehicleData,
            carBrand: carBrand,
            carModel: carModel,
            carName: carName.isEmpty ? carModel : carName,
            plateNumber: plateNumber,
            address: address,
            carImageUrl: carImageUrl
        )
    }
}

// MARK: - 小组件视图
struct VehicleWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: VehicleEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - 小尺寸小组件
struct SmallWidgetView: View {
    var entry: VehicleEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // 品牌和车名
            HStack {
                if entry.carBrand == "荣威" {
                    Image("rw_logo")
                        .resizable()
                        .frame(width: 24, height: 24)
                } else {
                    Image("mg_logo")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                Text(entry.carName)
                    .font(.caption)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // 续航信息
            if let fuelRange = entry.vehicleData?.data?.vehicle_value?.fuel_range,
               fuelRange > 0 {
                HStack {
                    Image(systemName: "fuelpump.fill")
                        .foregroundColor(.orange)
                    Text("\(fuelRange) km")
                        .font(.headline)
                    Spacer()
                }
            }
            
            if let batteryRange = entry.vehicleData?.data?.vehicle_value?.battery_pack_range,
               batteryRange > 0 {
                HStack {
                    Image(systemName: "battery.100.bolt")
                        .foregroundColor(.green)
                    Text("\(batteryRange) km")
                        .font(.headline)
                    Spacer()
                }
            }
            
            // 车辆状态
            HStack {
                if let isLocked = entry.vehicleData?.data?.vehicle_state?.lock {
                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                        .foregroundColor(isLocked ? .green : .red)
                }
                
                if let doorOpen = entry.vehicleData?.data?.vehicle_state?.door {
                    Image(systemName: doorOpen ? "door.left.hand.open" : "door.left.hand.closed")
                        .foregroundColor(doorOpen ? .red : .green)
                }
                
                Spacer()
            }
            
            // 更新时间
            if let updateTime = entry.vehicleData?.data?.update_time {
                let date = Date(timeIntervalSince1970: TimeInterval(updateTime / 1000))
                Text("更新: \(date.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - 中尺寸小组件
struct MediumWidgetView: View {
    var entry: VehicleEntry
    
    var body: some View {
        HStack {
            // 左侧：车辆信息
            VStack(alignment: .leading, spacing: 6) {
                // 品牌和车名
                HStack {
                    if entry.carBrand == "荣威" {
                        Image("rw_logo")
                            .resizable()
                            .frame(width: 28, height: 28)
                    } else {
                        Image("mg_logo")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(entry.carName)
                            .font(.headline)
                        Text(entry.plateNumber)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // 续航信息
                HStack(spacing: 12) {
                    if let fuelRange = entry.vehicleData?.data?.vehicle_value?.fuel_range,
                       fuelRange > 0 {
                        VStack {
                            Image(systemName: "fuelpump.fill")
                                .foregroundColor(.orange)
                            Text("\(fuelRange) km")
                                .font(.caption)
                        }
                    }
                    
                    if let batteryRange = entry.vehicleData?.data?.vehicle_value?.battery_pack_range,
                       batteryRange > 0 {
                        VStack {
                            Image(systemName: "battery.100.bolt")
                                .foregroundColor(.green)
                            Text("\(batteryRange) km")
                                .font(.caption)
                        }
                    }
                }
                
                // 车辆状态
                HStack(spacing: 8) {
                    if let isLocked = entry.vehicleData?.data?.vehicle_state?.lock {
                        Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                            .foregroundColor(isLocked ? .green : .red)
                    }
                    
                    if let doorOpen = entry.vehicleData?.data?.vehicle_state?.door {
                        Image(systemName: doorOpen ? "door.left.hand.open" : "door.left.hand.closed")
                            .foregroundColor(doorOpen ? .red : .green)
                    }
                    
                    if let windowOpen = entry.vehicleData?.data?.vehicle_state?.window {
                        Image(systemName: windowOpen ? "window.vertical.open" : "window.vertical.closed")
                            .foregroundColor(windowOpen ? .red : .green)
                    }
                }
                
                Spacer()
            }
            
            Spacer()
            
            // 右侧：车辆图片
            if let imageUrl = entry.carImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "car.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                }
                .frame(width: 100, height: 60)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - 大尺寸小组件
struct LargeWidgetView: View {
    var entry: VehicleEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // 顶部：车辆信息
            HStack {
                if entry.carBrand == "荣威" {
                    Image("rw_logo")
                        .resizable()
                        .frame(width: 32, height: 32)
                } else {
                    Image("mg_logo")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                
                VStack(alignment: .leading) {
                    Text(entry.carName)
                        .font(.headline)
                    Text(entry.plateNumber)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 车辆图片
                if let imageUrl = entry.carImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "car.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 120, height: 70)
                }
            }
            
            Divider()
            
            // 中间：详细状态
            HStack(spacing: 16) {
                // 续航信息
                VStack(alignment: .leading, spacing: 8) {
                    if let fuelRange = entry.vehicleData?.data?.vehicle_value?.fuel_range,
                       fuelRange > 0 {
                        HStack {
                            Image(systemName: "fuelpump.fill")
                                .foregroundColor(.orange)
                            Text("燃油续航: \(fuelRange) km")
                                .font(.subheadline)
                        }
                    }
                    
                    if let batteryRange = entry.vehicleData?.data?.vehicle_value?.battery_pack_range,
                       batteryRange > 0 {
                        HStack {
                            Image(systemName: "battery.100.bolt")
                                .foregroundColor(.green)
                            Text("电池续航: \(batteryRange) km")
                                .font(.subheadline)
                        }
                    }
                    
                    if let odometer = entry.vehicleData?.data?.vehicle_value?.odometer {
                        HStack {
                            Image(systemName: "road.lanes")
                                .foregroundColor(.blue)
                            Text("总里程: \(odometer) km")
                                .font(.subheadline)
                        }
                    }
                }
                
                Spacer()
                
                // 状态信息
                VStack(alignment: .leading, spacing: 8) {
                    if let isLocked = entry.vehicleData?.data?.vehicle_state?.lock {
                        HStack {
                            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                                .foregroundColor(isLocked ? .green : .red)
                            Text(isLocked ? "已上锁" : "未上锁")
                                .font(.subheadline)
                        }
                    }
                    
                    if let doorOpen = entry.vehicleData?.data?.vehicle_state?.door {
                        HStack {
                            Image(systemName: doorOpen ? "door.left.hand.open" : "door.left.hand.closed")
                                .foregroundColor(doorOpen ? .red : .green)
                            Text(doorOpen ? "车门未关" : "车门已关")
                                .font(.subheadline)
                        }
                    }
                    
                    if let windowOpen = entry.vehicleData?.data?.vehicle_state?.window {
                        HStack {
                            Image(systemName: windowOpen ? "window.vertical.open" : "window.vertical.closed")
                                .foregroundColor(windowOpen ? .red : .green)
                            Text(windowOpen ? "车窗未关" : "车窗已关")
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            Divider()
            
            // 底部：温度和位置
            HStack {
                if let interiorTemp = entry.vehicleData?.data?.vehicle_value?.interior_temperature {
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(interiorTemp <= 27 ? .green : .red)
                        Text("车内: \(String(format: "%.1f°C", interiorTemp))")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                if let address = entry.address {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(address)
                            .font(.caption)
                            .lineLimit(1)
                    }
                } else if let lat = entry.vehicleData?.data?.vehicle_position?.latitude,
                          let lon = entry.vehicleData?.data?.vehicle_position?.longitude {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("坐标: \(lat), \(lon)")
                            .font(.caption)
                    }
                }
            }
            
            // 更新时间
            if let updateTime = entry.vehicleData?.data?.update_time {
                let date = Date(timeIntervalSince1970: TimeInterval(updateTime / 1000))
                Text("更新: \(date.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - 小组件定义
struct VehicleWidget: Widget {
    let kind: String = "VehicleWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VehicleProvider()) { entry in
            VehicleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MG Linker")
        .description("显示车辆状态信息")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}