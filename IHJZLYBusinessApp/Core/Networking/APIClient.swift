// Core/Networking/APIClient.swift
import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

// Core/Networking/APIClient.swift

final class APIClient {
    private let baseURL: URL
    var defaultHeaders: [String: String] = [:] // ✅ ADD THIS
    
    init(baseURLString: String) {
        guard let url = URL(string: baseURLString) else {
            fatalError("Invalid base URL: \(baseURLString)")
        }
        self.baseURL = url
    }
    
    private func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = endpoint
        guard let url = urlComponents.url else { throw APIError.invalidResponse }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // ✅ MERGE defaultHeaders + custom headers
        let allHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
            .merging(defaultHeaders) { $1 }
            .merging(headers) { $1 }
        request.allHTTPHeaderFields = allHeaders
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let message = try? JSONDecoder().decode([String: String].self, from: data),
               let msg = message["message"] {
                throw APIError.badRequest(msg)
            } else {
                throw APIError.badRequest("Unknown error")
            }
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func post<T: Codable>(to endpoint: String, body: some Codable) async throws -> T {
        let data = try JSONEncoder().encode(body)
        return try await request(endpoint, method: .post, body: data)
    }
    // Core/Networking/APIClient.swift

    func postMultipartRaw(
        to endpoint: String,
        formData: [String: Any]
    ) async throws -> (Data, URLResponse) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        for (key, value) in formData {
            switch value {
            case let data as Data:
                // Single image file
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(data)
                body.append("\r\n".data(using: .utf8)!)
                
            case let array as [Data]:
                // Multiple image files with same field name
                for (idx, data) in array.enumerated() {
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"image_\(idx).jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(data)
                    body.append("\r\n".data(using: .utf8)!)
                }
                
            case let array as [String]:
                // String array - send as multiple fields with same name
                for item in array {
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                    body.append("\(item)\r\n".data(using: .utf8)!)
                }
                
            default:
                // Single string value
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = endpoint
        guard let url = urlComponents.url else { throw APIError.invalidResponse }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Merge headers
        let allHeaders = defaultHeaders.merging(["accept": "*/*"]) { $1 }
        request.allHTTPHeaderFields = allHeaders
        request.httpBody = body
        
        print("📤 Sending multipart request to: \(url)")
        print("📦 Boundary: \(boundary)")
        print("📋 Form fields: \(formData.keys)")
        
        return try await URLSession.shared.data(for: request)
    }
    func get<T: Decodable>(to endpoint: String) async throws -> T {
        return try await request(endpoint, method: .get)
    }
}
