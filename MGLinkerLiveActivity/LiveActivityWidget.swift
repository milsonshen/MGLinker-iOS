import WidgetKit
import SwiftUI

@main
struct MGLinkerLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        VehicleLiveActivityWidget()
    }
}

struct VehicleLiveActivityWidget: Widget {
    let kind: String = "VehicleLiveActivityWidget"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VehicleActivityAttributes.self) { context in
            // 锁屏界面
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.blue)
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
                            Image(systemName: "thermometer")
                                .foregroundColor(context.state.interiorTemperature <= 27 ? .green : .red)
                            Text("\(String(format: "%.1f°C", context.state.interiorTemperature))")
                                .font(.caption)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
            } compactTrailing: {
                if context.state.fuelRange > 0 {
                    Text("\(context.state.fuelRange)km")
                        .font(.caption2)
                } else if context.state.batteryRange > 0 {
                    Text("\(context.state.batteryRange)km")
                        .font(.caption2)
                }
            } minimal: {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<VehicleActivityAttributes>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundColor(.blue)
                    Text(context.attributes.carName)
                        .font(.headline)
                }
                Text(context.attributes.plateNumber)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
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