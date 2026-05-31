/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.application.usecases.produce.events;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

/// Receives an incoming alert event, evaluates all enabled subscriptions against
/// it, and dispatches matching actions (or records undelivered events on failure).
class ProduceEventsUseCase {
    private SubscriptionRepository   subscriptions;
    private ConditionRepository      conditions;
    private ActionRepository         actions;
    private MatchedEventRepository   matchedEvents;
    private UndeliveredEventRepository undeliveredEvents;
    private EventMatcher             matcher;
    private EventDispatcher          dispatcher;

    this(
        SubscriptionRepository   subscriptions,
        ConditionRepository      conditions,
        ActionRepository         actions,
        MatchedEventRepository   matchedEvents,
        UndeliveredEventRepository undeliveredEvents,
        EventMatcher             matcher,
        EventDispatcher          dispatcher
    ) {
        this.subscriptions    = subscriptions;
        this.conditions       = conditions;
        this.actions          = actions;
        this.matchedEvents    = matchedEvents;
        this.undeliveredEvents = undeliveredEvents;
        this.matcher          = matcher;
        this.dispatcher       = dispatcher;
    }

    CommandResult postEvent(TenantId tenantId, PostAlertEventRequest req) {
        import std.conv  : to;
        import std.datetime.systime : Clock;

        auto event       = new AlertEvent(tenantId);
        event.eventType  = req.eventType;
        event.category   = req.category.to!EventCategory;
        event.severity   = req.severity.to!EventSeverity;
        event.subject    = req.subject;
        event.body       = req.body;
        event.region     = req.region;
        event.tags       = req.tags.dup;
        event.status     = EventStatus.buffered;
        event.timestamp  = Clock.currTime().toUnixTime();

        auto res         = req.affectedResource;
        event.affectedResource = AffectedResource(res.name, res.type_, res.instance_, res.tags.dup);

        // Walk all enabled subscriptions and dispatch matching ones
        auto enabledSubs = subscriptions.findEnabled(tenantId);
        auto allConds    = conditions.findByTenant(tenantId);

        foreach (sub; enabledSubs) {
            if (!matcher.subscriptionMatches(event, sub, allConds)) continue;

            foreach (actionName; sub.actions) {
                auto action = actions.findByName(tenantId, actionName);
                auto result = dispatcher.dispatch(event, action, sub.name);

                if (result.success && action !is null && action.type_ == ActionType.store) {
                    auto me         = new MatchedEvent(tenantId);
                    me.eventId      = event.id.toString();
                    me.eventType    = event.eventType;
                    me.category     = event.category;
                    me.severity     = event.severity;
                    me.subject      = event.subject;
                    me.body         = event.body;
                    me.region       = event.region;
                    me.tags         = event.tags.dup;
                    me.affectedResource = event.affectedResource;
                    me.subscriptionName = sub.name;
                    me.actionName   = actionName;
                    me.storedAt     = event.timestamp;
                    me.retentionPeriod = 604_800;
                    matchedEvents.save(me);
                } else if (!result.success) {
                    auto ue              = new UndeliveredEvent(tenantId);
                    ue.eventId           = event.id.toString();
                    ue.eventType         = event.eventType;
                    ue.category          = event.category;
                    ue.severity          = event.severity;
                    ue.subject           = event.subject;
                    ue.body              = event.body;
                    ue.region            = event.region;
                    ue.tags              = event.tags.dup;
                    ue.affectedResource  = event.affectedResource;
                    ue.subscriptionName  = sub.name;
                    ue.actionName        = actionName;
                    ue.failureReason     = result.message;
                    ue.failedAt          = event.timestamp;
                    ue.deliveryAttempts  = 1;
                    undeliveredEvents.save(ue);
                }
            }
        }

        event.status = EventStatus.sent;
        return CommandResult(true, event.id.toString(), event.toJson().toString());
    }
}
