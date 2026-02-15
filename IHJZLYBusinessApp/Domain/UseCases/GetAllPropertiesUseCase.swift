// Domain/UseCases/GetAllPropertiesUseCase.swift

import Foundation

final class GetAllPropertiesUseCase {
    func execute() async throws -> [Property] {
        // For now, return mock data
        return [
            Property(
                id: "1",
                title: "شقة فاخرة",
                description: "وصف الشقة",
                price: 1000,
                currency: "LYD",
                type: "Residence",
                rawSubtype: "Apartment",
                images: [ImageItem(url: "")],
                status: "Accepted",
                businessOwnerFullName: "أحمد الفرجاني"
            )
        ]
    }
}
