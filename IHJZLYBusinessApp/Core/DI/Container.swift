// Core/DI/Container.swift

import Foundation

final class Container {
    static let shared = Container()
    
    private init() {}
    
    func resolve<T>(_ type: T.Type) -> T {
        // ✅ Check by attempting to cast a sample instance
        if T.self == AuthRepositoryProtocol.self {
            let client = APIClient(baseURLString: "http://31.220.56.155:5050")
            return AuthRepository(apiClient: client) as! T
        }
        
        fatalError("Unregistered type: \(T.self)")
    }
}
