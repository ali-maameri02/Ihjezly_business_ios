// Core/Services/ValidationManager.swift

import Foundation

class ValidationManager {
    static let shared = ValidationManager()
    
    private init() {}
    
    // MARK: - Step 1 Validation (Property Info)
    func validateStep1(form: HotelRoomForm) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if form.title.isEmpty {
            errors.append(ValidationError(message: "يرجى إدخال اسم العقار"))
        }
        
        if form.location.state.isEmpty {
            errors.append(ValidationError(message: "يرجى اختيار المدينة"))
        }
        
        if form.location.city.isEmpty {
            errors.append(ValidationError(message: "يرجى اختيار الحي"))
        }
        
        if form.description.count < 10 {
            errors.append(ValidationError(message: "وصف العقار يجب أن يحتوي على 10 أحرف على الأقل"))
        }
        
        return errors
    }
    
    // MARK: - Step 3 Validation (Guests)
    func validateStep3(adults: Int, children: Int) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if adults < 1 {
            errors.append(ValidationError(message: "يجب أن يكون عدد البالغين على الأقل 1"))
        }
        
        if adults + children > 20 {
            errors.append(ValidationError(message: "الحد الأقصى للضيوف هو 20 شخص"))
        }
        
        return errors
    }
    
    // MARK: - Step 4 Validation (Classification)
    func validateStep4(classification: Classification) -> [ValidationError] {
        // Classification is optional per API, so no validation needed
        return []
    }
    
    // ValidationManager.swift
    func validateStep5(images: [String], videoUrl: String?) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if images.isEmpty {
            errors.append(ValidationError(message: "يجب إضافة صورة واحدة على الأقل"))
        }
        
        if let url = videoUrl, !url.isEmpty {
            if !isValidURL(url) {
                errors.append(ValidationError(message: "رابط الفيديو غير صالح"))
            }
        }
        
        return errors
    }
    
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme == "https" || url.scheme == "http"
    }
    
    
    
    func validateStep6(facilities: [Facility]) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if facilities.isEmpty {
            errors.append(ValidationError(message: "يرجى اختيار ميزة واحدة على الأقل"))
        }
        
        return errors
    }
}
