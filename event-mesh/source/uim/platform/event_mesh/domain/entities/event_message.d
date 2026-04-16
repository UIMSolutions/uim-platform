/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.entities.event_message;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct EventMessage {
    EventMessageId id;
    TenantId tenantId;
    BrokerServiceId brokerServiceId;
    TopicId topicId;
    QueueId queueId;
    EventApplicationId publisherId;
    string correlationId;
    string contentType;
    string payload;
    DeliveryMode deliveryMode = DeliveryMode.persistent;
    MessageStatus status = MessageStatus.pending;
    MessagePriority priority = MessagePriority.normal;
    string topicString;
    string replyTo;
    string timeToLive;
    string expiration;
    string sequenceNumber;
    string redeliveryCount;
    string dmqEligible;
    string publishTime;
    string deliveredTime;
    string acknowledgedTime;
    string createdBy;
    string createdAt;

    Json eventMessageToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("brokerServiceId", brokerServiceId)
            .set("topicId", topicId)
            .set("queueId", queueId)
            .set("publisherId", publisherId)
            .set("correlationId", correlationId)
            .set("contentType", contentType)
            .set("payload", payload)
            .set("deliveryMode", deliveryMode.to!string)
            .set("status", status.to!string)
            .set("priority", priority.to!string)
            .set("topicString", topicString)
            .set("replyTo", replyTo)
            .set("timeToLive", timeToLive)
            .set("expiration", expiration)
            .set("sequenceNumber", sequenceNumber)
            .set("redeliveryCount", redeliveryCount)
            .set("dmqEligible", dmqEligible)
            .set("publishTime", publishTime)
            .set("deliveredTime", deliveredTime)
            .set("acknowledgedTime", acknowledgedTime)
            .set("createdBy", createdBy)
            .set("createdAt", createdAt);
    }
}
