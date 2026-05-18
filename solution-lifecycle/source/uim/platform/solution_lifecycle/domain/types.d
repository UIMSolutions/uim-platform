/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.domain.types;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Domain ID value types
// ---------------------------------------------------------------------------

struct MtaArchiveId {
    mixin DomainId;
}

struct MtaId {
    mixin DomainId;
}

struct MtaOperationId {
    mixin DomainId;
}

struct MtaSubscriptionId {
    mixin DomainId;
}

// ---------------------------------------------------------------------------
// Domain enumerations
// ---------------------------------------------------------------------------

/// Solution type determines deployment and subscription semantics
enum SolutionType : string {
    standard   = "standard",    /// Deployed only in current subaccount
    provided_  = "provided",    /// Deployed and exposed for subscription
    subscribed = "subscribed"   /// Subscribed from another provider subaccount
}

/// Overall lifecycle status of a deployed MTA solution
enum MtaStatus : string {
    deploying   = "deploying",
    deployed    = "deployed",
    updating    = "updating",
    deleting    = "deleting",
    failed      = "failed",
    deleted     = "deleted"
}

/// Type of an async MTA operation
enum OperationType : string {
    deploy      = "deploy",
    update      = "update",
    subscribe   = "subscribe",
    unsubscribe = "unsubscribe",
    delete_     = "delete",
    abort       = "abort"
}

/// Status of an async MTA operation
enum OperationStatus : string {
    queued     = "queued",
    running    = "running",
    finished   = "finished",
    failed     = "failed",
    aborted    = "aborted"
}

/// Lifecycle state of an individual MTA module (application/service)
enum ModuleState : string {
    started  = "started",
    stopped  = "stopped",
    starting = "starting",
    stopping = "stopping",
    failed   = "failed",
    unknown  = "unknown"
}

/// Subscription status
enum SubscriptionStatus : string {
    available    = "available",
    subscribing  = "subscribing",
    subscribed   = "subscribed",
    unsubscribing = "unsubscribing",
    failed       = "failed"
}

/// MTA module type
enum ModuleType : string {
    javaMain        = "java.main",
    javaTomcat      = "java.tomcat",
    javaEe          = "java.javaee",
    html5           = "html5.application",
    nodeJs          = "nodejs",
    fioriLaunchpad  = "portal.site",
    jobScheduler    = "jobscheduler",
    contentFtp      = "com.sap.application.content",
    other_          = "other"
}
