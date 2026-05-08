//
//  openkoudiosTests.swift
//  openkoudiosTests
//
//  Created by Mauro ™ on 06.05.26.
//

import Foundation
import Testing
@testable import openkoudios

struct openkoudiosTests {

    @Test func classifiesFoodIdeas() async throws {
        let result = IdeaClassifier.classify("Brunch en una cafeteria nueva el domingo")

        #expect(result.category == .food)
        #expect(result.idealConditions.contains(.day))
        #expect(result.idealConditions.contains(.weekend))
    }

    @Test func repeatableIdeasWaitFifteenDaysBeforeSuggestion() async throws {
        let recent = Idea(
            id: "recent",
            rawText: "Picnic",
            title: "Picnic",
            link: nil,
            category: .plans,
            status: .repeatable,
            discardedReason: nil,
            dateType: .none,
            dateStart: nil,
            dateEnd: nil,
            flexibleNote: nil,
            locationName: nil,
            latitude: nil,
            longitude: nil,
            address: nil,
            idealConditions: [],
            notes: nil,
            createdByUserId: nil,
            ownerUserId: nil,
            groupId: nil,
            createdAt: Date(),
            updatedAt: Date(),
            completedAt: Date(),
            lastSuggestedAt: nil,
            lastRepeatedAt: Date()
        )

        #expect(IdeaScoring.suggestions(from: [recent]).isEmpty)
    }

}
