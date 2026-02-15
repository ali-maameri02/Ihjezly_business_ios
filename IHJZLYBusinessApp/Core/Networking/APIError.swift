import Foundation

enum APIError: Error {
    case invalidResponse
    case decodingFailed(Error)
    case networkError(Error)
    case unauthorized
    case badRequest(String)
    case unknown(String)
}

extension APIError {
    init(_ error: Error) {
        if let urlError = error as? URLError {
            self = .networkError(urlError)
        } else {
            let nsError = error as NSError
            switch nsError.code {
            case 401:
                self = .unauthorized
            case 400:
                self = .badRequest("Bad request")
            default:
                self = .unknown(error.localizedDescription)
            }
        }
    }
}
