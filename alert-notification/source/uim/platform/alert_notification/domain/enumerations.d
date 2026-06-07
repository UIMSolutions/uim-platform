module uim.platform.alert_notification.domain.enumerations;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Domain enumerations
// ---------------------------------------------------------------------------

/// Category of an alert event
enum EventCategory : string {
    notification = "NOTIFICATION",  /// Informational event, no action required
    alert        = "ALERT",         /// Something unusual that needs attention
    exception_   = "EXCEPTION"      /// Error that requires immediate action
}

/// Severity of an alert event
enum EventSeverity : string {
    info    = "INFO",
    warning = "WARNING",
    error_  = "ERROR",
    fatal   = "FATAL"
}

/// Lifecycle status of an alert event
enum EventStatus : string {
    sent        = "SENT",
    buffered    = "BUFFERED",
    undelivered = "UNDELIVERED",
    matched     = "MATCHED"
}

/// The event property that a condition evaluates
enum PropertyKey : string {
    eventType         = "eventType",
    eventCategory     = "eventCategory",
    eventSeverity     = "eventSeverity",
    resourceName      = "resourceName",
    resourceType      = "resourceType",
    resourceInstance  = "resourceInstance",
    tags              = "tags"
}

/// Comparison operator used in condition evaluation
enum Predicate : string {
    equals      = "EQUALS",
    contains    = "CONTAINS",
    notEquals   = "NOT_EQUALS",
    notContains = "NOT_CONTAINS",
    any_        = "ANY"
}

/// Delivery channel / action type
enum ActionType : string {
    email      = "EMAIL",
    slack      = "SLACK",
    webHook    = "WEB_HOOK",
    store      = "STORE",
    pagerDuty  = "PAGER_DUTY",
    jira       = "JIRA",
    serviceNow = "SERVICE_NOW",
    siem       = "SIEM"
}

/// Operational state of an action or subscription
enum ResourceState : string {
    enabled  = "ENABLED",
    disabled = "DISABLED"
}
