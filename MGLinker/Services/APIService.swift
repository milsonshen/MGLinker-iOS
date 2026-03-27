import Foundation

class APIService {
    static let shared = APIService()
    private let session = URLSession.shared
    private let baseURL = "https://mp.ebanma.com/app-mp/vp/1.1/"
    
    private init() {}
    
    // MARK: - 获取车辆状态
    func fetchVehicleStatus(vin: String, token: String) async throws -> VehicleStatusResponse? {
        let timestamp = Int(Date().timeIntervalSince1970)
        let urlString = "\(baseURL)getVehicleStatus?timestamp=\(timestamp)&token=\(token)&vin=\(vin)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(VehicleStatusResponse.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
    
    // MARK: - 获取车辆配置
    func fetchCarConfig() async throws -> [CarConfig] {
        let urlString = "https://gitee.com/yangyachao-X/mg-linker/raw/master/other/config.json"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        do {
            let decoder = JSONDecoder()
            let remoteConfig = try decoder.decode(RemoteConfig.self, from: data)
            return remoteConfig.saic
        } catch {
            throw APIError.decodingFailed
        }
    }
    
    // MARK: - 检查更新
    func checkUpdate() async throws -> GiteeRelease? {
        let urlString = "https://gitee.com/api/v5/repos/yangyachao-X/mg-linker/releases/latest"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(GiteeRelease.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
    
    // MARK: - 逆地理编码（GPS坐标转地址）
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> String? {
        // 使用Apple的CLGeocoder
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                var address = ""
                if let name = placemark.name {
                    address += name
                }
                if let locality = placemark.locality {
                    address += ", \(locality)"
                }
                if let administrativeArea = placemark.administrativeArea {
                    address += ", \(administrativeArea)"
                }
                return address
            }
        } catch {
            print("Geocoding failed: \(error)")
        }
        return nil
    }
}

// MARK: - API错误类型
enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .requestFailed:
            return "请求失败"
        case .decodingFailed:
            return "数据解析失败"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}