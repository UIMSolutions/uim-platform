module domain.entities.directory;

import uim.platform.management.domain.types;

/// A directory is a grouping entity within a global account for
/// organizing subaccounts and managing entitlements/authorizations.
struct Directory {
    DirectoryId id;
    GlobalAccountId globalAccountId;
    DirectoryId parentDirectoryId; // empty if root-level
    string displayName;
    string description;
    DirectoryStatus status = DirectoryStatus.active;
    DirectoryFeature[] features; // entitlements, authorizations
    string[] subdirectories; // child directory IDs
    string[] subaccounts; // child subaccount IDs
    bool manageEntitlements;
    bool manageAuthorizations;
    string createdBy;
    long createdAt;
    long modifiedAt;
    string[string] labels;
    string[string] customProperties;
}
