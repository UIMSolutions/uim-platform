/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.enumerations;

@safe:

enum RepositoryType {
    managed,
    external,
    googleWorkspace,
    openText,
    sharepoint,
    s4hanaDms,
    other
}

enum RepositoryStatus {
    active,
    inactive,
    maintenance,
    error_,
    provisioning
}

enum DocumentStatus {
    draft,
    active,
    obsolete,
    archived
}

enum LifecycleStatus {
    draft,
    published,
    deprecated_,
    archived_
}

enum VersioningState {
    none,
    major,
    minor,
    checkedOut
}

enum CheckoutStatus {
    available,
    checkedOut
}

enum PermissionType {
    read,
    write,
    delete_,
    full,
    readWrite
}

enum PrincipalType {
    user,
    group,
    everyone
}

enum FolderType {
    standard,
    root,
    system,
    virtual,
    archive
}

enum ContentStreamAllowed {
    notAllowed,
    allowed,
    required_
}
