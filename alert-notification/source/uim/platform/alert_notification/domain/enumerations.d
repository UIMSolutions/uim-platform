module uim.platform.alert_notification.domain.enumerations;

import uim.platform.alert_notification;

mixin(ShowModule!());

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
EventCategory toEventCategory(string value) {
    switch (value.toLower) {
        case "notification": return EventCategory.notification;
        case "alert": return EventCategory.alert;
        case "exception": return EventCategory.exception_;
        default: return EventCategory.notification; // default
    }
}
EventCategory[] toEventCategory(string[] categories) {
    return categories.map!(toEventCategory).array;
}
string toString(EventCategory category) {
    return cast(string)category;
}
string[] toString(EventCategory[] categories) {
    return categories.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("EventCategory"));

    assert("notification".toEventCategory == EventCategory.notification);
    assert("alert".toEventCategory == EventCategory.alert);
    assert("exception".toEventCategory == EventCategory.exception_);

    assert("unknown".toEventCategory == EventCategory.notification);
    assert("".toEventCategory == EventCategory.notification);

    assert(EventCategory.notification.toString == "notification");
    assert(EventCategory.alert.toString == "alert");
    assert(EventCategory.exception_.toString == "exception");

    assert(toString([EventCategory.notification, EventCategory.alert]) == ["notification", "alert"]);
    assert(toEventCategory(["notification", "alert"]) == [EventCategory.notification, EventCategory.alert]);
}

/// Severity of an alert event
enum EventSeverity : string {
    /// Informational event, no action required
    info    = "INFO",
    /// Something unusual that needs attention
    warning = "WARNING",
    /// Error that requires immediate action
    error_  = "ERROR",
    /// Critical error that requires immediate action
    fatal   = "FATAL"
}
EventSeverity toEventSeverity(string value) {
    switch (value.toLower) {
        case "info": return EventSeverity.info;
        case "warning": return EventSeverity.warning;
        case "error": return EventSeverity.error_;
        case "fatal": return EventSeverity.fatal;
        default: return EventSeverity.info; // default
    }
}   
EventSeverity[] toEventSeverity(string[] severities) {
    return severities.map!(toEventSeverity).array;
}
string toString(EventSeverity severity) {
    return cast(string)severity;
}
string[] toString(EventSeverity[] severities) {
    return severities.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("EventSeverity"));

    assert("info".toEventSeverity == EventSeverity.info);
    assert("warning".toEventSeverity == EventSeverity.warning);
    assert("error".toEventSeverity == EventSeverity.error_);
    assert("fatal".toEventSeverity == EventSeverity.fatal);

    assert("unknown".toEventSeverity == EventSeverity.info);
    assert("".toEventSeverity == EventSeverity.info);

    assert(EventSeverity.info.toString == "info");
    assert(EventSeverity.warning.toString == "warning");
    assert(EventSeverity.error_.toString == "error");
    assert(EventSeverity.fatal.toString == "fatal");

    assert(toString([EventSeverity.info, EventSeverity.warning]) == ["info", "warning"]);
    assert(toEventSeverity(["info", "warning"]) == [EventSeverity.info, EventSeverity.warning]);
}

/// Lifecycle status of an alert event
enum EventStatus : string {
    sent        = "SENT",
    buffered    = "BUFFERED",
    undelivered = "UNDELIVERED",
    matched     = "MATCHED"
}
EventStatus toEventStatus(string value) {
    mixin(EnumSwitch!("EventStatus", "sent"));
}
EventStatus[] toEventStatus(string[] values) {
    return values.map!(toEventStatus).array;
}
string toString(EventStatus status) {
    return status.to!string;
}
string[] toString(EventStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("EventStatus"));

    assert("sent".toEventStatus == EventStatus.sent);
    assert("buffered".toEventStatus == EventStatus.buffered);
    assert("undelivered".toEventStatus == EventStatus.undelivered);
    assert("matched".toEventStatus == EventStatus.matched);

    assert("unknown".toEventStatus == EventStatus.sent);
    assert("".toEventStatus == EventStatus.sent);

    assert(EventStatus.sent.toString == "sent");
    assert(EventStatus.buffered.toString == "buffered");
    assert(EventStatus.undelivered.toString == "undelivered");
    assert(EventStatus.matched.toString == "matched");

    assert(toString([EventStatus.sent, EventStatus.buffered]) == ["sent", "buffered"]);
    assert(toEventStatus(["sent", "buffered"]) == [EventStatus.sent, EventStatus.buffered]);
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
PropertyKey toPropertyKey(string value) {
    mixin(EnumSwitch!("PropertyKey", "eventType"));
}
PropertyKey[] toPropertyKey(string[] values) {
    return values.map!(toPropertyKey).array;
}
string toString(PropertyKey key) {
    return key.to!string;
}
string[] toString(PropertyKey[] keys) {
    return keys.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("PropertyKey"));

    assert("eventType".toPropertyKey == PropertyKey.eventType);
    assert("eventCategory".toPropertyKey == PropertyKey.eventCategory);
    assert("eventSeverity".toPropertyKey == PropertyKey.eventSeverity);
    assert("resourceName".toPropertyKey == PropertyKey.resourceName);
    assert("resourceType".toPropertyKey == PropertyKey.resourceType);
    assert("resourceInstance".toPropertyKey == PropertyKey.resourceInstance);
    assert("tags".toPropertyKey == PropertyKey.tags);

    assert("unknown".toPropertyKey == PropertyKey.eventType);
    assert("".toPropertyKey == PropertyKey.eventType);

    assert(PropertyKey.eventType.toString == "eventType");
    assert(PropertyKey.eventCategory.toString == "eventCategory");
    assert(PropertyKey.eventSeverity.toString == "eventSeverity");
    assert(PropertyKey.resourceName.toString == "resourceName");
    assert(PropertyKey.resourceType.toString == "resourceType");
    assert(PropertyKey.resourceInstance.toString == "resourceInstance");
    assert(PropertyKey.tags.toString == "tags");

    assert(toString([PropertyKey.eventType, PropertyKey.tags]) == ["eventType", "tags"]);
    assert(toPropertyKey(["eventType", "tags"]) == [PropertyKey.eventType, PropertyKey.tags]);
}

/// Comparison operator used in condition evaluation
enum Predicate : string {
    any_        = "ANY",
    equals      = "EQUALS",
    contains    = "CONTAINS",
    notEquals   = "NOT_EQUALS",
    notContains = "NOT_CONTAINS",
}
Predicate toPredicate(string value) {
    switch (value.toLower) {
        case "equals": return Predicate.equals;
        case "contains": return Predicate.contains;
        case "not_equals": return Predicate.notEquals;
        case "not_contains": return Predicate.notContains;
        case "any": return Predicate.any_;
        default: return Predicate.any_; // default
    }
}
Predicate[] toPredicate(string[] values) {
    return values.map!(toPredicate).array;
}
string toString(Predicate predicate) {
    return cast(string)predicate;
}
string[] toString(Predicate[] predicates) {
    return predicates.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("Predicate"));

    assert("any".toPredicate == Predicate.any_);
    assert("equals".toPredicate == Predicate.equals);
    assert("contains".toPredicate == Predicate.contains);
    assert("not_equals".toPredicate == Predicate.notEquals);
    assert("not_contains".toPredicate == Predicate.notContains);

    assert("unknown".toPredicate == Predicate.any_);
    assert("".toPredicate == Predicate.any_);

    assert(Predicate.any_.toString == "any");
    assert(Predicate.equals.toString == "equals");
    assert(Predicate.contains.toString == "contains");
    assert(Predicate.notEquals.toString == "notEquals");
    assert(Predicate.notContains.toString == "notContains");

    assert(toString([Predicate.any_, Predicate.equals]) == ["any", "equals"]);
    assert(toPredicate(["any", "equals"]) == [Predicate.any_, Predicate.equals]);
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
ActionType toActionType(string value) {
    mixin(EnumSwitch!("ActionType", "email"));
}
ActionType[] toActionType(string[] values) {
    return values.map!(toActionType).array;
}
string toString(ActionType type) {
    return type.to!string;
}
string[] toString(ActionType[] types) {
    return types.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ActionType"));

    assert("email".toActionType == ActionType.email);
    assert("slack".toActionType == ActionType.slack);
    assert("web_hook".toActionType == ActionType.webHook);
    assert("store".toActionType == ActionType.store);
    assert("pager_duty".toActionType == ActionType.pagerDuty);
    assert("jira".toActionType == ActionType.jira);
    assert("service_now".toActionType == ActionType.serviceNow);
    assert("siem".toActionType == ActionType.siem);

    assert("unknown".toActionType == ActionType.email);
    assert("".toActionType == ActionType.email);

    assert(ActionType.email.toString == "email");
    assert(ActionType.slack.toString == "slack");
    assert(ActionType.webHook.toString == "webHook");
    assert(ActionType.store.toString == "store");
    assert(ActionType.pagerDuty.toString == "pagerDuty");
    assert(ActionType.jira.toString == "jira");
    assert(ActionType.serviceNow.toString == "serviceNow");
    assert(ActionType.siem.toString == "siem");

    assert(toString([ActionType.email, ActionType.slack]) == ["email", "slack"]);
    assert(toActionType(["email", "slack"]) == [ActionType.email, ActionType.slack]);
}

/// Operational state of an action or subscription
enum ResourceState : string {
    enabled  = "ENABLED",
    disabled = "DISABLED"
}
ResourceState toResourceState(string value) {
    mixin(EnumSwitch!("ResourceState", "enabled"));
}
ResourceState[] toResourceState(string[] values) {
    return values.map!(toResourceState).array;
}
string toString(ResourceState state) {
    return state.to!string;
}
string[] toString(ResourceState[] states) {
    return states.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ResourceState"));

    assert("enabled".toResourceState == ResourceState.enabled);
    assert("disabled".toResourceState == ResourceState.disabled);

    assert("unknown".toResourceState == ResourceState.enabled);
    assert("".toResourceState == ResourceState.enabled);

    assert(ResourceState.enabled.toString == "enabled");
    assert(ResourceState.disabled.toString == "disabled");

    assert(toString([ResourceState.enabled, ResourceState.disabled]) == ["enabled", "disabled"]);
    assert(toResourceState(["enabled", "disabled"]) == [ResourceState.enabled, ResourceState.disabled]);
}
