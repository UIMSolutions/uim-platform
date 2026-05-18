/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.types;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Domain ID value types
// ---------------------------------------------------------------------------

struct SaasApplicationId {
    mixin DomainId;
}

struct AppSubscriptionId {
    mixin DomainId;
}

struct SubscriptionJobId {
    mixin DomainId;
}

// ---------------------------------------------------------------------------
// Domain enumerations
// ---------------------------------------------------------------------------

/// Registration status of a multitenant application in the registry.
enum AppRegistrationStatus : string {
    registered   = "REGISTERED",
    unregistered = "UNREGISTERED",
    updating     = "UPDATING",
    failed       = "FAILED"
}

/// Lifecycle state of a consumer tenant's subscription to a SaaS application.
enum SubscriptionState : string {
    subscribed    = "SUBSCRIBED",
    subscribing   = "SUBSCRIBING",
    unsubscribed  = "UNSUBSCRIBED",
    unsubscribing = "UNSUBSCRIBING",
    updatePending = "UPDATE_PENDING",
    updating      = "UPDATING",
    failed        = "FAILED"
}

/// Type of an asynchronous subscription job.
enum JobType : string {
    subscribe   = "SUBSCRIBE",
    unsubscribe = "UNSUBSCRIBE",
    update      = "UPDATE"
}

/// Processing status of a subscription job.
enum JobStatus : string {
    queued    = "QUEUED",
    running   = "RUNNING",
    succeeded = "SUCCEEDED",
    failed    = "FAILED"
}

/// Commercial plan offered by the multitenant application in the marketplace.
enum AppPlan : string {
    application  = "application",
    lite         = "lite",
    standard     = "standard",
    professional = "professional",
    enterprise   = "enterprise"
}
