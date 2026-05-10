/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.enumerations;

@safe:

/// Type of the transport node (deployment target environment)
enum NodeType {
    cloudFoundry,
    abap,
    neo,
    kyma,
    other
}

/// Operational status of a transport node
enum NodeStatus {
    enabled,
    disabled
}

/// Status of a transport route
enum RouteStatus {
    enabled,
    disabled
}

/// Type of content being transported
enum ContentType {
    mtaArchive,
    integrationContent,
    htmlApp,
    abapCorContent,
    other
}

/// Lifecycle status of a transport request
enum RequestStatus {
    initial,
    running,
    success,
    failed,
    warning,
    outdated,
    repeating
}

/// Status of an import queue entry
enum ImportStatus {
    initial,
    running,
    success,
    failed,
    warning,
    repeating
}

/// Type of transport action recorded in the audit trail
enum ActionType {
    export_,
    import_,
    forward,
    reset,
    delete_,
    schedule
}

/// Status of a transport action
enum ActionStatus {
    initial,
    running,
    success,
    failed,
    warning
}
