// Data/Repositories/HotelRoomRepository.swift

import Foundation

final class HotelRoomRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func createHotelRoom(_ request: HotelRoomCreateRequest) async throws -> String {
        var formData: [String: Any] = [:]
        
        // Basic fields
        formData["Title"] = request.title
        formData["Description"] = request.description
        formData["Price"] = request.price
        formData["Currency"] = request.currency
        formData["Type"] = request.type.rawValue
        formData["IsAd"] = request.isAd
        
        // Location (flattened)
        formData["Location.City"] = request.location.city
        formData["Location.State"] = request.location.state
        formData["Location.Country"] = request.location.country
        formData["Location.Latitude"] = request.location.latitude
        formData["Location.Longitude"] = request.location.longitude
        
        // Details (flattened)
        formData["Details.NumberOfAdults"] = request.details.numberOfAdults
        formData["Details.NumberOfChildren"] = request.details.numberOfChildren
        formData["Details.hotelRoomType"] = request.details.hotelRoomType.rawValue
        formData["Details.clasification"] = request.details.classification.rawValue
        
        // Discount (optional)
        if let discount = request.discount {
            formData["Discount.Value"] = discount.value
        }
        
        // Facilities (array of strings)
        if !request.facilities.isEmpty {
            formData["Facilities"] = request.facilities.map { $0.rawValue }
        }
        
        // Business Owner
        formData["BusinessOwnerId"] = request.businessOwnerId
        
        // Video URL - FIXED field name to match what backend expects from curl
        if let videoUrl = request.videoUrl, !videoUrl.isEmpty {
            formData["ViedeoUrl.Url"] = videoUrl  // Note: "ViedeoUrl" is misspelled in backend
        }
        
        // Unavailable dates (array)
        if !request.unavailables.isEmpty {
            formData["Unavailables"] = request.unavailables
        }
        
        // IMAGES FIX: Convert base64 strings back to image data
        var imageFiles: [Data] = []
        var imageObjects: [String] = []
        
        for (index, image) in request.images.enumerated() {
            // Extract raw base64 and convert back to image data
            if let imageData = convertBase64ToImageData(image.url) {
                imageFiles.append(imageData)
                
                // Create the image object JSON for the Images field
                let escapedUrl = image.url.replacingOccurrences(of: "\"", with: "\\\"")
                let imageObject = "{\"url\":\"\(escapedUrl)\",\"isMain\":\(image.isMain)}"
                imageObjects.append(imageObject)
            }
        }
        
        // Add image files to formData (for the 'images' field as in curl)
        if !imageFiles.isEmpty {
            formData["images"] = imageFiles
        }
        
        // Add image objects as strings (for the 'Images' field as in curl)
        if !imageObjects.isEmpty {
            formData["Images"] = imageObjects
        }
        
        // Send multipart
        let (data, response) = try await apiClient.postMultipartRaw(
            to: "/api/v1/HotelRoom",
            formData: formData
        )
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Server error: \(errorString)")
                throw APIError.badRequest("HTTP \(httpResponse.statusCode): \(errorString)")
            }
            throw APIError.badRequest("HTTP \(httpResponse.statusCode)")
        }
        
        if let id = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !id.isEmpty {
            print("✅ Room created with ID: \(id)")
            return id
        } else {
            throw APIError.invalidResponse
        }
    }
    
    // Helper function to convert base64 string back to image data
    private func convertBase64ToImageData(_ base64String: String) -> Data? {
        // Extract the base64 part after the comma if it's a data URL
        if let range = base64String.range(of: ",") {
            let rawBase64 = String(base64String[range.upperBound...])
            return Data(base64Encoded: rawBase64)
        }
        // Try as raw base64
        return Data(base64Encoded: base64String)
    }
}
