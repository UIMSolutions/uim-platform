/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.services.event_matcher;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

/// Pure domain service — evaluates whether an event satisfies a condition.
class EventMatcher {
    /// Returns true when every mandatory condition matches and at least one
    /// optional condition matches (or there are no optional conditions).
    bool subscriptionMatches(AlertEvent event, Subscription sub, Condition[] allConditions) {
        if (!sub.isEnabled()) return false;

        bool mandatoryFailed = false;
        bool anyOptionalMatched = false;
        bool hasOptional = false;

        foreach (condName; sub.conditions) {
            Condition cond = findCondition(allConditions, condName);
            if (cond is null || cond.isNull()) continue;
            bool matched = cond.matches(event);
            if (cond.mandatory) {
                if (!matched) { mandatoryFailed = true; break; }
            } else {
                hasOptional = true;
                if (matched) anyOptionalMatched = true;
            }
        }

        if (mandatoryFailed) return false;
        if (hasOptional && !anyOptionalMatched) return false;
        return true;
    }

    private Condition findCondition(Condition[] list, string name) {
        foreach (c; list)
            if (c.name == name) return c;
        return null;
    }
}
