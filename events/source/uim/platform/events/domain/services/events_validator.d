/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.services.events_validator;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

struct EventsValidator {

    static bool isValidMessagingService(const MessagingService s) {
        return s.name.length > 0 && s.namespace.length > 0;
    }

    static bool isValidMessageClient(const MessageClient c) {
        return c.name.length > 0 && !c.serviceId.isNull;
    }

    static bool isValidQueue(const Queue q) {
        return q.name.length > 0 && !q.serviceId.isNull;
    }

    static bool isValidQueueSubscription(const QueueSubscription qs) {
        return qs.topicPattern.length > 0 && !qs.queueId.isNull;
    }

    static bool isValidWebhook(const Webhook wh) {
        return wh.url.length > 0 && !wh.serviceId.isNull;
    }

    static bool isValidEventChannel(const EventChannel ec) {
        return ec.name.length > 0 && ec.namespace.length > 0 && !ec.serviceId.isNull;
    }

    static bool isValidMessageBinding(const MessageBinding mb) {
        return !mb.clientId.isNull && !mb.serviceId.isNull;
    }
}
