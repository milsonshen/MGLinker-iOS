import Foundation
import ActivityKit
import SwiftUI

// MARK: - Live Activity 数据模型
struct VehicleActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 动态状态
        let fuelRange: Int
        let batteryRange: Int
        let isLocked: Bool
        let isDoorOpen: Bool
        let interiorTemperature: Double
        let updateTime: Date
    }
    
    // 静态属性
    let carBrand: String
    let carModel: String
    let carName: String
    let plateNumber: String
}

// MARK: - Live Activity 管理器
class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<VehicleActivityAttributes>?
    
    private init() {}
    
    // 启动 Live Activity
    func startActivity(
        carBrand: String,
        carModel: String,
        carName: String,
        plateNumber: String,
        fuelRange: Int,
        batteryRange: Int,
        isLocked: Bool,
        isDoorOpen: Bool,
        interiorTemperature: Double
    ) {
        // 检查是否支持 Live Activity
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activity 不可用")
            return
        }
        
        let attributes = VehicleActivityAttributes(
            carBrand: carBrand,
            carModel: carModel,
            carName: carName,
            plateNumber: plateNumber
        )
        
        let contentState = VehicleActivityAttributes.ContentState(
            fuelRange: fuelRange,
            batteryRange: batteryRange,
            isLocked: isLocked,
            isDoorOpen: isDoorOpen,
            interiorTemperature: interiorTemperature,
            updateTime: Date()
        )
        
        do {
            let activity = try Activity<VehicleActivityAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
            print("Live Activity 已启动: \(activity.id)")
        } catch {
            print("启动 Live Activity 失败: \(error)")
        }
    }
    
    // 更新 Live Activity
    func updateActivity(
        fuelRange: Int,
        batteryRange: Int,
        isLocked: Bool,
        isDoorOpen: Bool,
        interiorTemperature: Double
    ) {
        guard let activity = currentActivity else { return }
        
        let contentState = VehicleActivityAttributes.ContentState(
            fuelRange: fuelRange,
            batteryRange: batteryRange,
            isLocked: isLocked,
            isDoorOpen: isDoorOpen,
            interiorTemperature: interiorTemperature,
            updateTime: Date()
        )
        
        Task {
            await activity.update(using: contentState)
            print("Live Activity 已更新")
        }
    }
    
    // 结束 Live Activity
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
            print("Live Activity 已结束")
        }
    }
    
    // 检查是否有活动中的 Live Activity
    func hasActiveActivity() -> Bool {
        return currentActivity != nil
    }
}

// MARK: - Live Activity 视图
struct VehicleLiveActivityView: View {
    let context: ActivityViewContext<VehicleActivityAttributes>
    
    var body: some View {
        VStack {
            // 锁屏界面
            LockScreenLiveActivityView(context: context)
        }
    }
}

// MARK: - 锁屏界面视图
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<VehicleActivityAttributes>
    
    var body: some View {
        HStack {
            // 左侧：车辆信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if context.attributes.carBrand == "荣威" {
                        Image("rw_logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                    } else {
                        Image("mg_logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    
                    Text(context.attributes.carName)
                        .font(.headline)
                }
                
                Text(context.attributes.plateNumber)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 中间：续航信息
            VStack(spacing: 4) {
                if context.state.fuelRange > 0 {
                    HStack {
                        Image(systemName: "fuelpump.fill")
                            .foregroundColor(.orange)
                        Text("\(context.state.fuelRange) km")
                            .font(.caption)
                    }
                }
                
                if context.state.batteryRange > 0 {
                    HStack {
                        Image(systemName: "battery.100.bolt")
                            .foregroundColor(.green)
                        Text("\(context.state.batteryRange) km")
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            // 右侧：状态信息
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: context.state.isLocked ? "lock.fill" : "lock.open.fill")
                        .foregroundColor(context.state.isLocked ? .green : .red)
                    Text(context.state.isLocked ? "已上锁" : "未上锁")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "thermometer")
                        .foregroundColor(context.state.interiorTemperature <= 27 ? .green : .red)
                    Text("\(String(format: "%.1f°C", context.state.interiorTemperature))")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Dynamic Island 视图
struct VehicleDynamicIslandView: View {
    let context: ActivityViewContext<VehicleActivityAttributes>
    
    var body: some View {
        // 紧凑视图
        DynamicIsland {
            // 展开视图
            DynamicIslandExpandedRegion(.leading) {
                HStack {
                    if context.attributes.carBrand == "荣威" {
                        Image("rw_logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                    } else {
                        Image("mg_logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(context.attributes.carName)
                            .font(.headline)
                        Text(context.attributes.plateNumber)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            DynamicIslandExpandedRegion(.trailing) {
                VStack(alignment: .trailing, spacing: 4) {
                    if context.state.fuelRange > 0 {
                        HStack {
                            Image(systemName: "fuelpump.fill")
                                .foregroundColor(.orange)
                            Text("\(context.state.fuelRange) km")
                                .font(.caption)
                        }
                    }
                    
                    if context.state.batteryRange > 0 {
                        HStack {
                            Image(systemName: "battery.100.bolt")
                                .foregroundColor(.green)
                            Text("\(context.state.batteryRange) km")
                                .font(.caption)
                        }
                    }
                }
            }
            
            DynamicIslandExpandedRegion(.bottom) {
                HStack {
                    HStack {
                        Image(systemName: context.state.isLocked ? "lock.fill" : "lock.open.fill")
                            .foregroundColor(context.state.isLocked ? .green : .red)
                        Text(context.state.isLocked ? "已上锁" : "未上锁")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: context.state.isDoorOpen ? "door.left.hand.open" : "door.left.hand.closed")
                            .foregroundColor(context.state.isDoorOpen ? .red : .green)
                        Text(context.state.isDoorOpen ? "车门未关" : "车门已关")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(context.state.interiorTemperature <= 27 ? .green : .red)
                        Text("\(String(format: "%.1f°C", context.state.interiorTemperature))")
                            .font(.caption)
                    }
                }
            }
        } compactLeading: {
            // 紧凑左侧
            if context.attributes.carBrand == "荣威" {
                Image("rw_logo")
                    .resizable()
                    .frame(width: 20, height: 20)
            } else {
                Image("mg_logo")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        } compactTrailing: {
            // 紧凑右侧
            HStack(spacing: 4) {
                if context.state.fuelRange > 0 {
                    Text("\(context.state.fuelRange)km")
                        .font(.caption2)
                } else if context.state.batteryRange > 0 {
                    Text("\(context.state.batteryRange)km")
                        .font(.caption2)
                }
            }
        } minimal: {
            // 最小视图
            if context.attributes.carBrand == "荣威" {
                Image("rw_logo")
                    .resizable()
                    .frame(width: 16, height: 16)
            } else {
                Image("mg_logo")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
        }
    }
}