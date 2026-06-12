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
EventCategory toEventCategory(string category) {
    const map = [
        "notification": EventCategory.notification,
        "alert": EventCategory.alert,
        "exception": EventCategory.exception_
    ];
    return map.get(category.toLower, EventCategory.notification);
}

/// Severity of an alert event
enum EventSeverity : string {
    info    = "INFO",
    warning = "WARNING",
    error_  = "ERROR",
    fatal   = "FATAL"
}
EventSeverity toEventSeverity(string severity) {
    const map = [
        "info": EventSeverity.info,
        "warning": EventSeverity.warning,
        "error": EventSeverity.error_,
        "fatal": EventSeverity.fatal
    ];
    return map.get(severity.toLower, EventSeverity.info);
}   

/// Lifecycle status of an alert event
enum EventStatus : string {
    sent        = "SENT",
    buffered    = "BUFFERED",
    undelivered = "UNDELIVERED",
    matched     = "MATCHED"
}
EventStatus toEventStatus(string status) {
    const map = [
        "sent": EventStatus.sent,
        "buffered": EventStatus.buffered,
        "undelivered": EventStatus.undelivered,
        "matched": EventStatus.matched
    ];
    return map.get(status.toLower, EventStatus.sent);
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
PropertyKey toPropertyKey(string key) {
    const map = [
        "eventtype": PropertyKey.eventType,
        "eventcategory": PropertyKey.eventCategory,
        "eventseverity": PropertyKey.eventSeverity,
        "resourcename": PropertyKey.resourceName,
        "resourcetype": PropertyKey.resourceType,
        "resourceinstance": PropertyKey.resourceInstance,
        "tags": PropertyKey.tags
    ];
    return map.get(key.toLower, PropertyKey.eventType);
}

/// Comparison operator used in condition evaluation
enum Predicate : string {
    equals      = "EQUALS",
    contains    = "CONTAINS",
    notEquals   = "NOT_EQUALS",
    notContains = "NOT_CONTAINS",
    any_        = "ANY"
}
Predicate toPredicate(string predicate) {
    const map = [
        "equals": Predicate.equals,
        "contains": Predicate.contains,
        "not_equals": Predicate.notEquals,
        "notcontains": Predicate.notContains,
        "any": Predicate.any_
    ];
    return map.get(predicate.toLower, Predicate.equals);
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
ActionType toActionType(string type) {
    const map = [
        "email": ActionType.email,
        "slack": ActionType.slack,
        "webhook": ActionType.webHook,
        "store": ActionType.store,
        "pagerduty": ActionType.pagerDuty,
        "jira": ActionType.jira,
        "servicenow": ActionType.serviceNow,
        "siem": ActionType.siem
    ];
    return map.get(type.toLower, ActionType.email);
}

/// Operational state of an action or subscription
enum ResourceState : string {
    enabled  = "ENABLED",
    disabled = "DISABLED"
}
ResourceState toResourceState(string state) {
    const map = [
        "enabled": ResourceState.enabled,
        "disabled": ResourceState.disabled
    ];
    return map.get(state.toLower, ResourceState.enabled);
}
