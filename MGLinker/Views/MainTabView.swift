import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VehicleStatusView()
                .tabItem {
                    Label("车辆状态", systemImage: "car.fill")
                }
                .tag(0)
            
            RemoteControlView()
                .tabItem {
                    Label("远程控制", systemImage: "gear")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

struct VehicleStatusView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 车辆信息卡片
                    VehicleInfoCard()
                    
                    // 车辆状态卡片
                    VehicleStatusCard()
                    
                    // 轮胎压力卡片
                    TirePressureCard()
                    
                    // 位置信息卡片
                    LocationCard()
                    
                    // 更新时间
                    if let updateTime = vehicleManager.lastUpdateTime {
                        Text("更新于: \(updateTime.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .navigationTitle("MG Linker")
            .refreshable {
                isRefreshing = true
                await vehicleManager.refreshData()
                isRefreshing = false
            }
            .overlay {
                if vehicleManager.isLoading {
                    ProgressView("加载中...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
            .alert("错误", isPresented: .constant(vehicleManager.errorMessage != nil)) {
                Button("确定") {
                    vehicleManager.errorMessage = nil
                }
            } message: {
                Text(vehicleManager.errorMessage ?? "")
            }
        }
    }
}

struct VehicleInfoCard: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // 品牌Logo
                if vehicleManager.carBrand == "荣威" {
                    Image("rw_logo")
                        .resizable()
                        .frame(width: 40, height: 40)
                } else {
                    Image("mg_logo")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading) {
                    Text(vehicleManager.carName.isEmpty ? vehicleManager.carModel : vehicleManager.carName)
                        .font(.headline)
                    Text(vehicleManager.plateNumber)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 车辆图片
                if let imageURL = vehicleManager.getCarImage() {
                    AsyncImage(url: imageURL) { image in
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
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct VehicleStatusCard: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(spacing: 15) {
            // 续航信息
            HStack(spacing: 20) {
                // 燃油续航
                if let fuelRange = vehicleManager.vehicleData?.data?.vehicle_value?.fuel_range,
                   fuelRange > 0 {
                    StatusItem(
                        title: "燃油续航",
                        value: "\(fuelRange) km",
                        icon: "fuelpump.fill",
                        color: .orange
                    )
                }
                
                // 电池续航
                if let batteryRange = vehicleManager.vehicleData?.data?.vehicle_value?.battery_pack_range,
                   batteryRange > 0 {
                    StatusItem(
                        title: "电池续航",
                        value: "\(batteryRange) km",
                        icon: "battery.100.bolt",
                        color: .green
                    )
                }
            }
            
            Divider()
            
            // 车辆状态
            HStack(spacing: 20) {
                // 车门状态
                if let doorState = vehicleManager.vehicleData?.data?.vehicle_state?.door {
                    StatusItem(
                        title: "车门",
                        value: doorState ? "未关闭" : "已关闭",
                        icon: doorState ? "door.left.hand.open" : "door.left.hand.closed",
                        color: doorState ? .red : .green
                    )
                }
                
                // 锁车状态
                if let lockState = vehicleManager.vehicleData?.data?.vehicle_state?.lock {
                    StatusItem(
                        title: "门锁",
                        value: lockState ? "已上锁" : "未上锁",
                        icon: lockState ? "lock.fill" : "lock.open.fill",
                        color: lockState ? .green : .red
                    )
                }
                
                // 车窗状态
                if let windowState = vehicleManager.vehicleData?.data?.vehicle_state?.window {
                    StatusItem(
                        title: "车窗",
                        value: windowState ? "未关闭" : "已关闭",
                        icon: windowState ? "window.vertical.open" : "window.vertical.closed",
                        color: windowState ? .red : .green
                    )
                }
            }
            
            Divider()
            
            // 温度信息
            HStack(spacing: 20) {
                if let interiorTemp = vehicleManager.vehicleData?.data?.vehicle_value?.interior_temperature {
                    StatusItem(
                        title: "车内温度",
                        value: String(format: "%.1f°C", interiorTemp),
                        icon: "thermometer",
                        color: interiorTemp <= 27 ? .green : .red
                    )
                }
                
                if let exteriorTemp = vehicleManager.vehicleData?.data?.vehicle_value?.exterior_temperature {
                    StatusItem(
                        title: "车外温度",
                        value: "\(exteriorTemp)°C",
                        icon: "cloud.sun.fill",
                        color: .blue
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatusItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TirePressureCard: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("轮胎压力")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                TirePressureItem(
                    position: "左前轮",
                    pressure: vehicleManager.vehicleData?.data?.vehicle_value?.front_left_tyre_pressure
                )
                TirePressureItem(
                    position: "右前轮",
                    pressure: vehicleManager.vehicleData?.data?.vehicle_value?.front_right_tyre_pressure
                )
                TirePressureItem(
                    position: "左后轮",
                    pressure: vehicleManager.vehicleData?.data?.vehicle_value?.rear_left_tyre_pressure
                )
                TirePressureItem(
                    position: "右后轮",
                    pressure: vehicleManager.vehicleData?.data?.vehicle_value?.rear_right_tyre_pressure
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TirePressureItem: View {
    let position: String
    let pressure: Int?
    
    var body: some View {
        VStack {
            Text(position)
                .font(.caption)
                .foregroundColor(.gray)
            
            if let pressure = pressure {
                let pressureValue = Double(pressure) / 100.0
                let pressureString = String(format: "%.1f Bar", pressureValue)
                let isNormal = pressureValue >= 2.0 && pressureValue <= 3.8
                
                Text(pressureString)
                    .font(.headline)
                    .foregroundColor(isNormal ? .green : .red)
            } else {
                Text("- Bar")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct LocationCard: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("车辆位置")
                .font(.headline)
            
            if let address = vehicleManager.address {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text(address)
                        .font(.subheadline)
                }
            } else if let lat = vehicleManager.vehicleData?.data?.vehicle_position?.latitude,
                      let lon = vehicleManager.vehicleData?.data?.vehicle_position?.longitude {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text("坐标: \(lat), \(lon)")
                        .font(.subheadline)
                }
            } else {
                HStack {
                    Image(systemName: "location.slash.fill")
                        .foregroundColor(.gray)
                    Text("位置信息不可用")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RemoteControlView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("车辆控制")) {
                    ControlButton(title: "锁车", icon: "lock.fill", color: .blue)
                    ControlButton(title: "解锁", icon: "lock.open.fill", color: .green)
                    ControlButton(title: "开启后备箱", icon: "car.side.rear.open", color: .orange)
                    ControlButton(title: "寻车", icon: "horn.fill", color: .purple)
                }
                
                Section(header: Text("空调控制")) {
                    ControlButton(title: "开启空调", icon: "snowflake", color: .cyan)
                    ControlButton(title: "关闭空调", icon: "snowflake", color: .gray)
                    ControlButton(title: "座椅加热", icon: "heater.fill", color: .red)
                }
                
                Section(header: Text("车窗控制")) {
                    ControlButton(title: "开启车窗", icon: "window.vertical.open", color: .blue)
                    ControlButton(title: "关闭车窗", icon: "window.vertical.closed", color: .blue)
                }
                
                Section(header: Text("蓝牙钥匙")) {
                    NavigationLink(destination: BluetoothControlView()) {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                            Text("蓝牙钥匙设置")
                        }
                    }
                }
            }
            .navigationTitle("远程控制")
        }
    }
}

struct ControlButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // 远程控制操作
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct BluetoothControlView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        List {
            Section(header: Text("蓝牙状态")) {
                HStack {
                    Text("连接状态")
                    Spacer()
                    Text(bluetoothManager.isConnected ? "已连接" : "未连接")
                        .foregroundColor(bluetoothManager.isConnected ? .green : .red)
                }
                
                HStack {
                    Text("自动解锁")
                    Spacer()
                    Toggle("", isOn: $bluetoothManager.autoUnlockEnabled)
                }
                
                HStack {
                    Text("自动落锁")
                    Spacer()
                    Toggle("", isOn: $bluetoothManager.autoLockEnabled)
                }
            }
            
            Section(header: Text("设备管理")) {
                if bluetoothManager.discoveredDevices.isEmpty {
                    Text("未发现设备")
                        .foregroundColor(.gray)
                } else {
                    ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                        Button(action: {
                            bluetoothManager.connect(to: device)
                        }) {
                            HStack {
                                Text(device.name ?? "未知设备")
                                Spacer()
                                if bluetoothManager.connectedDevice?.identifier == device.identifier {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    bluetoothManager.startScanning()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("扫描设备")
                    }
                }
            }
        }
        .navigationTitle("蓝牙钥匙")
        .onAppear {
            bluetoothManager.startScanning()
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @State private var showingConfig = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("车辆信息")) {
                    HStack {
                        Text("品牌")
                        Spacer()
                        Text(vehicleManager.carBrand)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("车型")
                        Spacer()
                        Text(vehicleManager.carModel)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("车架号")
                        Spacer()
                        Text(vehicleManager.vin)
                            .foregroundColor(.gray)
                    }
                    
                    Button("修改配置") {
                        showingConfig = true
                    }
                }
                
                Section(header: Text("应用设置")) {
                    NavigationLink(destination: Text("通知设置")) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                            Text("通知设置")
                        }
                    }
                    
                    NavigationLink(destination: Text("主题设置")) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.purple)
                            Text("主题设置")
                        }
                    }
                    
                    NavigationLink(destination: Text("关于")) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                            Text("关于")
                        }
                    }
                }
                

                
                Section {
                    Button("检查更新") {
                        Task {
                            // 检查更新
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showingConfig) {
                ConfigurationView()
            }
        }
    }
}

struct ConfigurationView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) var dismiss
    
    @State private var brand = "名爵"
    @State private var model = ""
    @State private var name = ""
    @State private var vin = ""
    @State private var color = ""
    @State private var plate = ""
    @State private var token = ""
    @State private var availableModels: [String] = []
    @State private var availableColors: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("车辆品牌")) {
                    Picker("品牌", selection: $brand) {
                        Text("名爵").tag("名爵")
                        Text("荣威").tag("荣威")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: brand) { _ in
                        updateAvailableModels()
                    }
                }
                
                Section(header: Text("车辆信息")) {
                    Picker("车型", selection: $model) {
                        ForEach(availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    
                    TextField("车辆名称（可选）", text: $name)
                    
                    TextField("17位车架号", text: $vin)
                        .keyboardType(.asciiCapable)
                    
                    Picker("颜色", selection: $color) {
                        ForEach(availableColors, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }
                    
                    TextField("车牌号", text: $plate)
                }
                
                Section(header: Text("认证信息")) {
                    SecureField("ACCESS_TOKEN", text: $token)
                    
                    Text("Token格式：xxx-prod_SAIC")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section {
                    Button("保存配置") {
                        if vehicleManager.saveConfig(
                            brand: brand,
                            model: model,
                            name: name,
                            vin: vin,
                            color: color,
                            plate: plate,
                            token: token
                        ) {
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("车辆配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                updateAvailableModels()
            }
        }
    }
    
    private func updateAvailableModels() {
        let brandCode = brand == "名爵" ? "MG" : "RW"
        availableModels = vehicleManager.carConfigList
            .filter { $0.brand == brandCode }
            .map { $0.model }
        
        if !availableModels.contains(model) {
            model = availableModels.first ?? ""
        }
        
        updateAvailableColors()
    }
    
    private func updateAvailableColors() {
        let brandCode = brand == "名爵" ? "MG" : "RW"
        if let modelConfig = vehicleManager.carConfigList.first(where: { $0.brand == brandCode && $0.model == model }) {
            availableColors = modelConfig.colors.map { $0.name }
        } else {
            availableColors = []
        }
        
        if !availableColors.contains(color) {
            color = availableColors.first ?? ""
        }
    }
}