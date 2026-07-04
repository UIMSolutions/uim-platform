/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.services.event_dispatcher;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

/// Outcome of a single action dispatch attempt.
struct DispatchResult {
    bool   success;
    string message;
    string actionName;
    string subscriptionName;
}

/// Domain service — decides how to route a matched event to an action.
/// Actual transport (HTTP call, email) is handled in the infrastructure layer.
/// Here we only record what *should* happen and produce a DispatchResult.
class EventDispatcher {
    /// Dispatch event to the given action.
    /// For STORE actions the caller is responsible for persisting the MatchedEvent.
    /// Returns a DispatchResult that indicates success or failure intent.
    DispatchResult dispatch(AlertEvent event, Action action, string subscriptionName) @safe {
        if (action is null || action.isNull())
            return DispatchResult(false, "Action not found", "", subscriptionName);

        if (!action.isEnabled())
            return DispatchResult(false, "Action is disabled", action.name, subscriptionName);

        // For STORE actions there is nothing to send externally.
        if (action.type_ == ActionType.store)
            return DispatchResult(true, "Event stored", action.name, subscriptionName);

        // For all other action types return success intent.
        // Real HTTP/email delivery would be implemented in infrastructure adapters.
        return DispatchResult(true, "Dispatched via " ~ action.type_, action.name, subscriptionName);
    }
}
