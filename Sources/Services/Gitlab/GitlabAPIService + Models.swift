//
//  GitlabApiModels.swift
//
//
//  Created by ANPILOV Roman on 09.10.2024.
//

import Foundation

/// Gitlab user
public struct GitlabUser: Decodable {
    public let id: Int
    public let name: String
}

public struct GitlabMergeRequest: Decodable {
    public let id: Int
    public let diffRefs: DiffRefs
    public let title: String
    public let sha: String
    public let targetBranch: String
    public let sourceBranch: String
    public let state: State
    
    enum CodingKeys: String, CodingKey {
        case title, sha, state
        case id = "iid" // https://docs.gitlab.com/ee/api/merge_requests.html
        case diffRefs = "diff_refs"
        case targetBranch = "target_branch"
        case sourceBranch = "source_branch"
    }
    
    public init(id: Int, diffRefs: DiffRefs, title: String, sha: String, targetBranch: String, sourceBranch: String, state: State) {
        self.id = id
        self.diffRefs = diffRefs
        self.title = title
        self.sha = sha
        self.targetBranch = targetBranch
        self.sourceBranch = sourceBranch
        self.state = state
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        diffRefs = try container.decode(DiffRefs.self, forKey: .diffRefs)
        title = try container.decode(String.self, forKey: .title)
        sha = try container.decode(String.self, forKey: .sha)
        targetBranch = try container.decode(String.self, forKey: .targetBranch)
        sourceBranch = try container.decode(String.self, forKey: .sourceBranch)
        
        let decodedState = try container.decode(String.self, forKey: .state)
        if decodedState == "merged" {
            state = .merged
        } else {
            state = .other(decodedState)
        }
    }
    
    public enum State {
        case merged
        case other(String)
    }
}



extension GitlabMergeRequest.State: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.other(lhsValue), .other(rhsValue)):
            return lhsValue == rhsValue
        case (.merged, .merged):
            return true
        case (.merged, _):
            return false
        case (.other, _):
            return false
        }
    }
}

public struct DiffRefs: Codable {
    public let baseSHA, headSHA, startSHA: String

    enum CodingKeys: String, CodingKey {
        case baseSHA = "base_sha"
        case headSHA = "head_sha"
        case startSHA = "start_sha"
    }
}

public struct MergeRequestByBranch: Decodable {
    public let id: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "iid" // https://docs.gitlab.com/ee/api/merge_requests.html
    }
}

public struct ThreadResponse: Decodable {
    public let id: String
}

public struct GitlabBranch: Decodable {
    public let name: String
    public let commit: GitlabCommit
}
    
public struct GitlabCommit: Decodable {
    public let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
    }
}

public struct GitlabCherryPick: Decodable {
    public let title: String
}

public struct CreateMergeRequestResponse: Codable {
    public let id: Int
}

public typealias MergeRequestNotes = [MergeRequestNote]

public struct MergeRequestNote: Codable {
    public let id: String
    public let notes: [Note]
}

public struct Note: Codable {
    public let id: Int
    public let body: String
    public let author: Author
    public let resolved: Bool?
    public let resolvable: Bool
}

public struct Author: Codable {
    public let id: Int
}
