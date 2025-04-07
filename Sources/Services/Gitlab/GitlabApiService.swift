//
//  GitlabApiService.swift
//
//
//  Created by ANPILOV Roman on 09.10.2024.
//

import Foundation

// TODO: Split into separate services, close protocols based on the necessary functions
// For example, when using si in coderunners, no requests are needed except fetchUserInfo
// And in the codestyler, the fetchUserInfo request is not needed

public actor GitlabAPIService: Sendable {
    let gitlabTokenAccessor: () async ->  String
    let baseUrlPath: String
    let projectID: Int
    private let decoder: JSONDecoder =  {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Decoding error - \(dateString)"
            )
        }
        return decoder
    }()

    
    public init(baseUrlPath: String, projectID: Int, gitlabTokenAccessor: @escaping () async -> String) {
        self.baseUrlPath = baseUrlPath + "/api/v4"
        self.projectID = projectID
        self.gitlabTokenAccessor = gitlabTokenAccessor
    }
    
    /// Getting user data
    /// - Parameter username: User login
    /// - Returns: Loaded user data or nil if user not found
    public func fetchUserInfo(byUsername username: String) async throws -> (name: String, gitlabID: Int)? {
        let users: [GitlabUser] = try await makeRequest(
            endpoint: "/users?username=\(username)"
        )
        guard let user = users.first else {
            return nil
        }
        return (name: user.name, gitlabID: user.id)
    }
    
    @discardableResult
    public func getMergeRequest(
        by branch: String
    ) async throws -> GitlabMergeRequest {
        let decoded: [MergeRequestByBranch] = try await makeRequest(
            endpoint: "/projects/\(projectID)/merge_requests?source_branch=\(branch)"
        )
        guard let mergeRequest = decoded.first else { throw GitlabApiError.notFindMrByBranch }
        return try await getMergeRequest(by: mergeRequest.id)
    }
    
    @discardableResult
    public func getMergeRequest(
        by id: Int
    ) async throws -> GitlabMergeRequest {
        let decoded: GitlabMergeRequest = try await makeRequest(
            endpoint: "/projects/\(projectID)/merge_requests/\(id)"
        )
        return decoded
    }
    
    @discardableResult
    public func getReleaseBranches() async throws -> [GitlabBranch] {
        let decoded: [GitlabBranch] = try await makeRequest(
            endpoint: "/projects/\(projectID)/repository/branches?regex=^release.*&per_page=100"
        )
        return decoded
    }
    
    @discardableResult
    public func createNewBranch(
        newBranch: String,
        fromBranch: String
    ) async throws -> GitlabBranch {
        let parameters = [
            "branch": newBranch,
            "ref": fromBranch
        ]
        let data = try JSONSerialization.data(withJSONObject: parameters)
        return try await makeRequest(
            endpoint: "/projects/\(projectID)/repository/branches",
            body: data,
            httpMethod: .POST
        )
    }
    
    @discardableResult
    public func cherryPickCommitToBranch(
        commitSHA: String,
        branch: String
    ) async throws -> GitlabCherryPick {
        let parameters = [
            "branch": branch
        ]
        let data = try JSONSerialization.data(withJSONObject: parameters)
        return try await makeRequest(
            endpoint: "/projects/\(projectID)/repository/commits/\(commitSHA)/cherry_pick",
            body: data,
            httpMethod: .POST
        )
    }
    
    @discardableResult
    public func createMergeRequest(
        targetBranch: String,
        sourceBranch: String,
        title: String
    ) async throws -> GitlabMergeRequest {
        let parameters = [
            "source_branch": sourceBranch,
            "target_branch": targetBranch,
            "title": title
        ]
        let data = try JSONSerialization.data(withJSONObject: parameters)
        return try await makeRequest(
            endpoint: "/projects/\(projectID)/merge_requests",
            body: data,
            httpMethod: .POST
        )
    }
    
    public func createOverviewThread(
        body: String,
        mergeRequestID: Int
    ) async throws -> ThreadResponse {
        return try await makeRequest(
            endpoint: "/projects/\(projectID)/merge_requests/\(mergeRequestID)/discussions?body=\(body)",
            httpMethod: .POST
        )
    }
    
    // TODO: Remove CodeStyleErrorMessage
//    func createInCodeThread(
//        messageInCode: CodeStyleErrorMessage,
//        mergeRequest: MergeRequestInfo
//    ) async throws {
//        let requestBody = [
//            "body": messageInCode.message,
//            "position[base_sha]": mergeRequest.diffRefs.baseSHA,
//            "position[start_sha]": mergeRequest.diffRefs.startSHA,
//            "position[head_sha]": mergeRequest.diffRefs.headSHA,
//            "position[position_type]": "text",
//            "position[\(messageInCode.typeOfChange == .added ? "new_line" : "old_line")]": messageInCode.line,
//            "position[new_path]": messageInCode.filePath
//        ]
//        let bodyString = requestBody.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
//        let _: ThreadResponse = try await makeRequest(
//            endpoint: "/projects/\(projectID)/merge_requests/\(mergeRequest.id)/discussions",
//            body: bodyString.data(using: .utf8),
//            contentType: .urlencoded,
//            httpMethod: .POST
//        )
//    }
    
    func getThreads(
        for mergeRequest: GitlabMergeRequest
    ) async throws -> MergeRequestNotes {
        let endpoint: (Int) -> (String) = { page in
            "/projects/\(self.projectID)/merge_requests/\(mergeRequest.id)/discussions?per_page=100&page=\(page)"
        }

        let (initialData, response) = try await makeRequest(
            endpoint: endpoint(1)
        )

        guard let value = response.value(forHTTPHeaderField: "X-Total-Pages"),
              let totalPages = Int(value)
        else { throw GitlabApiError.responseNotValid }

        var allNotes: [MergeRequestNote] = []

        let initialNotes = try decoder.decode(MergeRequestNotes.self, from: initialData)
        allNotes.append(contentsOf: initialNotes)

        if totalPages > 1 {
            try await withThrowingTaskGroup(of: MergeRequestNotes.self) { group in
                (2...totalPages).forEach { page in
                    group.addTask {
                        let (data, _) = try await self.makeRequest(endpoint: endpoint(page))
                        return try self.decoder.decode(MergeRequestNotes.self, from: data)
                    }
                }
                for try await notes in group {
                    allNotes.append(contentsOf: notes)
                }
            }
        }

        return allNotes
    }
    
    public func resolveThread(
        for mergeRequest: GitlabMergeRequest,
        threadID: String
    ) async throws -> MergeRequestNotes {
        return try await makeRequest(
            endpoint: "/projects/\(projectID)/merge_requests/\(mergeRequest.id)/discussions/\(threadID)?resolved=true",
            httpMethod: .PUT
        )
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        endpoint: String,
        body: Data? = nil,
        contentType: ContentType = .json,
        httpMethod: HTTPMethod = .GET
    ) async throws -> (Data, HTTPURLResponse) {
        let gitlabApiToken = await gitlabTokenAccessor()
        guard let url = URL(string: "\(baseUrlPath)\(endpoint)") else {
            throw GitlabApiError.urlNotValid
        }
        /// Debounce requests to gitlab api (Otherwise returns error-code)
        try await Task.sleep(for: .seconds(1))
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = body
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = [
            "Content-Type": contentType.header,
            "PRIVATE-TOKEN": gitlabApiToken
        ]
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else { throw GitlabApiError.statusCodeError }
        return (data, httpResponse)
    }
    
    private func makeRequest<T: Decodable>(
        endpoint: String,
        body: Data? = nil,
        contentType: ContentType = .json,
        httpMethod: HTTPMethod = .GET
    ) async throws -> T {
        let (data, _) = try await makeRequest(
            endpoint: endpoint,
            body: body,
            contentType: contentType,
            httpMethod: httpMethod
        )
        return try decoder.decode(
            T.self, from: data
        )
    }
}

extension GitlabAPIService {
    enum ContentType {
        case json
        case urlencoded
        
        var header: String {
            switch self {
            case .json:
                "application/json"
            case .urlencoded:
                "application/x-www-form-urlencoded"
            }
        }
    }
    
    enum HTTPMethod: String {
        case POST
        case GET
        case PUT
    }
    
    enum GitlabApiError: Error {
        case statusCodeError
        case notFindMrByBranch
        case urlNotValid
        case notFindAccessToken
        case responseNotValid
    }
}
