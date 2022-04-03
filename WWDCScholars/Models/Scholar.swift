//
//  Scholar.swift
//  WWDCScholars
//
//  Created by Moritz Sternemann on 21.03.21.
//

import CloudKit
import UIKit

struct Scholar {
    let recordName: String

    let givenName: String
    let familyName: String
    let gender: Gender
    let birthday: Date
    let location: CLLocation
    let biography: String
    let profilePicture: UIImage?
    let gdprConsentAt: Date

    let scholarPrivate: CKRecord.Reference?
    let socialMedia: CKRecord.Reference
    let wwdcYearInfos: [CKRecord.Reference]
    let wwdcYears: [CKRecord.Reference]
    let wwdcYearsApproved: [CKRecord.Reference]
}

extension Scholar: Identifiable {
    var id: String { recordName }
}

extension Scholar: Equatable {}

extension Scholar: Comparable {
    static func < (lhs: Scholar, rhs: Scholar) -> Bool {
        return lhs.givenName < rhs.givenName
    }
}

extension Scholar: CKRecordConvertible {
    init?(record: CKRecord) {
        guard let givenName = record["givenName"] as? String,
              let familyName = record["familyName"] as? String,
              let gender = (record["gender"] as? String).flatMap(Gender.init(rawValue:)),
              let birthday = record["birthday"] as? Date,
              let location = record["location"] as? CLLocation,
              let biography = record["biography"] as? String,
              let gdprConsentAt = record["gdprConsentAt"] as? Date,
              let socialMedia = record["socialMedia"] as? CKRecord.Reference,
              let wwdcYearInfos = record["wwdcYearInfos"] as? [CKRecord.Reference],
              let wwdcYears = record["wwdcYears"] as? [CKRecord.Reference],
              let wwdcYearsApproved = record["wwdcYearsApproved"] as? [CKRecord.Reference]
        else { return nil }

        recordName = record.recordID.recordName

        self.givenName = givenName
        self.familyName = familyName
        self.gender = gender
        self.birthday = birthday // TODO: Interpret as UTC
        self.location = location
        self.biography = biography
        profilePicture = (record["profilePicture"] as? CKAsset)?.image
        self.gdprConsentAt = gdprConsentAt

        scholarPrivate = record["scholarPrivate"] as? CKRecord.Reference
        self.socialMedia = socialMedia
        self.wwdcYearInfos = wwdcYearInfos
        self.wwdcYears = wwdcYears
        self.wwdcYearsApproved = wwdcYearsApproved
    }
}

// MARK: - Partial Fetching

extension Scholar {
    enum DesiredKeys {
        static let `default`: [CKRecord.FieldKey] = [
            "givenName",
            "familyName",
            "gender",
            "birthday",
            "location",
            "biography",
            "gdprConsentAt",
            "scholarPrivate",
            "socialMedia",
            "wwdcYearInfos",
            "wwdcYears",
            "wwdcYearsApproved"
        ]

        static let onlyProfilePicture: [CKRecord.FieldKey] = ["profilePicture"]
    }
}

// MARK: - Subtypes

extension Scholar {
    enum Gender: String {
        case female
        case male
        case other

        var grammaticalGender: Morphology.GrammaticalGender {
            switch self {
            case .female: return .feminine
            case .male: return .masculine
            case .other: return .neuter
            }
        }
    }
}

// MARK: - Convenience

extension Scholar {
    var fullName: String {
        "\(givenName) \(familyName)"
    }

    var age: UInt {
        let ageComponents = Calendar.current.dateComponents([.year], from: birthday, to: Date())
        guard let age = ageComponents.year else { return 0 }
        return UInt(age)
    }

    var lastApprovedYearReference: CKRecord.Reference? {
        wwdcYearsApproved
            .sorted(by: \.recordID.recordName)
            .last
    }
}
