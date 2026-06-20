module uim.platform.saas_provisioning.domain.enumerations;

import uim.platform.saas_provisioning;

// mixin(ShowModule!());

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

AppRegistrationStatus toAppRegistrationStatus(string s) {
  switch(s.lower) {
    case "registered": return AppRegistrationStatus.registered;
    case "unregistered": return AppRegistrationStatus.unregistered;
    case "updating": return AppRegistrationStatus.updating;
    case "failed": return AppRegistrationStatus.failed;
    default: return AppRegistrationStatus.registered;
  }
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

SubscriptionState toSubscriptionState(string s) {
  switch(s.lower) {
    case "subscribed": return SubscriptionState.subscribed;
    case "subscribing": return SubscriptionState.subscribing;
    case "unsubscribed": return SubscriptionState.unsubscribed;
    case "unsubscribing": return SubscriptionState.unsubscribing;
    case "update_pending": return SubscriptionState.updatePending;
    case "updating": return SubscriptionState.updating;
    case "failed": return SubscriptionState.failed;
    default: return SubscriptionState.subscribed;
  }
}

/// Type of an asynchronous subscription job.
enum JobType : string {
    subscribe   = "SUBSCRIBE",
    unsubscribe = "UNSUBSCRIBE",
    update      = "UPDATE"
}

JobType toJobType(string s) {
  switch(s.lower) {
    case "subscribe": return JobType.subscribe;
    case "unsubscribe": return JobType.unsubscribe;
    case "update": return JobType.update;
    default: return JobType.subscribe;
  }
}

/// Processing status of a subscription job.
enum JobStatus : string {
    queued    = "QUEUED",
    running   = "RUNNING",
    succeeded = "SUCCEEDED",
    failed    = "FAILED"
}
JobStatus toJobStatus(string s) {
  switch(s.lower) {
    case "queued": return JobStatus.queued;
    case "running": return JobStatus.running;
    case "succeeded": return JobStatus.succeeded;
    case "failed": return JobStatus.failed;
    default: return JobStatus.queued;
  }
}

/// Commercial plan offered by the multitenant application in the marketplace.
enum AppPlan : string {
    application  = "application",
    lite         = "lite",
    standard     = "standard",
    professional = "professional",
    enterprise   = "enterprise"
}
AppPlan toAppPlan(string s) {
  mixin(toEnumSwitch("AppPlan", "AppPlan.application"));
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