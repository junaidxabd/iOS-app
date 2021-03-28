//
//  YearsCloudKitRepository.swift
//  WWDCScholars
//
//  Created by Moritz Sternemann on 23.03.21.
//

import CloudKit
import Combine

protocol YearsCloudKitRepository: CloudKitRepository {
    func loadAllYears() -> AnyPublisher<[WWDCYear], Error>
}

struct YearsCloudKitRepositoryImpl: YearsCloudKitRepository {
    let database: CKDatabase
    let queue: DispatchQueue

    func loadAllYears()  -> AnyPublisher<[WWDCYear], Error> {
        let sortYear = NSSortDescriptor(key: "year", ascending: true)
        let yearsQuery = CKQuery(recordType: WWDCYear.recordType, predicate: NSPredicate(value: true))
        yearsQuery.sortDescriptors = [sortYear]

        return query(yearsQuery)
    }
}