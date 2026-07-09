module uim.platform.saas_provisioning.domain.enumerations;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:
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

AppRegistrationStatus toAppRegistrationStatus(string value) {
  mixin(EnumSwitch("AppRegistrationStatus", "registered"));
}
///
unittest {
    assert(toAppRegistrationStatus("registered") == AppRegistrationStatus.registered);
    assert(toAppRegistrationStatus("UNREGISTERED") == AppRegistrationStatus.unregistered);
    assert(toAppRegistrationStatus("Updating") == AppRegistrationStatus.updating);
    assert(toAppRegistrationStatus("failed") == AppRegistrationStatus.failed);
    assert(toAppRegistrationStatus("unknown") == AppRegistrationStatus.registered);
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

SubscriptionState toSubscriptionState(string value) {
  mixin(EnumSwitch("SubscriptionState", "subscribed"));
}
///
unittest {
    assert(toSubscriptionState("subscribed") == SubscriptionState.subscribed);
    assert(toSubscriptionState("UNSUBSCRIBED") == SubscriptionState.unsubscribed);
    assert(toSubscriptionState("Updating") == SubscriptionState.updating);
    assert(toSubscriptionState("failed") == SubscriptionState.failed);
    assert(toSubscriptionState("unknown") == SubscriptionState.subscribed);
}

/// Type of an asynchronous subscription job.
enum JobType : string {
    subscribe   = "SUBSCRIBE",
    unsubscribe = "UNSUBSCRIBE",
    update      = "UPDATE"
}

JobType toJobType(string value) {
  mixin(EnumSwitch("JobType", "subscribe"));
}
/// 
unittest {
    assert(toJobType("subscribe") == JobType.subscribe);
    assert(toJobType("UNSUBSCRIBE") == JobType.unsubscribe);
    assert(toJobType("Update") == JobType.update);
    assert(toJobType("unknown") == JobType.subscribe);
}

/// Processing status of a subscription job.
enum JobStatus : string {
    queued    = "QUEUED",
    running   = "RUNNING",
    succeeded = "SUCCEEDED",
    failed    = "FAILED"
}
JobStatus toJobStatus(string value) {
  mixin(EnumSwitch("JobStatus", "queued"));
}
///
unittest {
    assert(toJobStatus("queued") == JobStatus.queued);
    assert(toJobStatus("RUNNING") == JobStatus.running);
    assert(toJobStatus("Succeeded") == JobStatus.succeeded);
    assert(toJobStatus("failed") == JobStatus.failed);
    assert(toJobStatus("unknown") == JobStatus.queued);
}

/// Commercial plan offered by the multitenant application in the marketplace.
enum AppPlan : string {
    application  = "application",
    lite         = "lite",
    standard     = "standard",
    professional = "professional",
    enterprise   = "enterprise"
}
AppPlan toAppPlan(string value) {
  mixin(EnumSwitch("AppPlan", "application"));
}
///
unittest {
    assert(toAppPlan("application") == AppPlan.application);
    assert(toAppPlan("lite") == AppPlan.lite);
    assert(toAppPlan("LITE") == AppPlan.lite);
    assert(toAppPlan("Standard") == AppPlan.standard);
    assert(toAppPlan("Professional") == AppPlan.professional);
    assert(toAppPlan("enterPRISE") == AppPlan.enterprise);
    assert(toAppPlan("ENTERPRISE") == AppPlan.enterprise);
    assert(toAppPlan("unknown") == AppPlan.application);
}