/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations;

@safe:

/// Mobile application target platform
enum AppPlatform {
    ios,
    android,
    windows,
    web,
    cross
}

/// Lifecycle status of a registered mobile application
enum AppStatus {
    draft,
    active,
    deprecated_,
    archived
}

/// Lifecycle status of an app metadata definition
enum DefinitionStatus {
    draft,
    published,
    archived
}

/// Published release status of an app version
enum AppVersionStatus {
    pending,
    published,
    deprecated_,
    withdrawn
}

/// Enrollment and activity status of a mobile device
enum DeviceStatus {
    enrolled,
    active,
    suspended,
    removed
}

/// Status of a data synchronization session
enum SyncStatus {
    pending,
    inProgress,
    completed,
    failed,
    cancelled
}

/// Synchronization direction
enum SyncDirection {
    upload,
    download,
    bidirectional
}

/// SAP backend system type for backend connections
enum BackendType {
    s4hana,
    ecc,
    btp,
    crm,
    custom
}

/// Connectivity status of a backend connection
enum ConnectionStatus {
    active,
    inactive,
    error,
    testing
}

/// Deployment lifecycle status
enum DeploymentStatus {
    pending,
    deploying,
    deployed,
    failed,
    rolledBack
}

/// Target scope of a deployment
enum DeploymentScope {
    device,
    group,
    tenant
}
