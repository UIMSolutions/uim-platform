module uim.platform.events.domain.enumerations;

import uim.platform.events;
// mixin(ShowModule!());
@safe:

enum MessagingServiceStatus {
    creating,
    active,
    inactive,
    updating,
    deleting,
    failed
}
MessagingServiceStatus toMessagingServiceStatus(string value) {
    mixin(toEnumSwitch("MessagingServiceStatus", "MessagingServiceStatus.creating"));
}
MessagingServiceStatus[] toMessagingServiceStatus(string[] values) {
    return values.map!(v => v.toMessagingServiceStatus).array;
}
string toString(MessagingServiceStatus value) {
    return value.to!string();
}
string[] toString(MessagingServiceStatus[] values) {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("MessagingServiceStatus"));

    assert("creating".toMessagingServiceStatus == MessagingServiceStatus.creating);
    assert("active".toMessagingServiceStatus == MessagingServiceStatus.active);
    assert("inactive".toMessagingServiceStatus == MessagingServiceStatus.inactive);
    assert("updating".toMessagingServiceStatus == MessagingServiceStatus.updating);
    assert("deleting".toMessagingServiceStatus == MessagingServiceStatus.deleting);
    assert("failed".toMessagingServiceStatus == MessagingServiceStatus.failed);

    assert(MessagingServiceStatus.creating.toString == "creating");
    assert(MessagingServiceStatus.active.toString == "active");
    assert(MessagingServiceStatus.inactive.toString == "inactive");
    assert(MessagingServiceStatus.updating.toString == "updating");
    assert(MessagingServiceStatus.deleting.toString == "deleting");
    assert(MessagingServiceStatus.failed.toString == "failed");

    assert(["creating", "active"].toMessagingServiceStatus == [MessagingServiceStatus.creating, MessagingServiceStatus.active]);
    assert([MessagingServiceStatus.creating, MessagingServiceStatus.active].toString == ["creating", "active"]);
}

enum MessagingServicePlan {
    dev,
    standard,
    premium
}
MessagingServicePlan toMessagingServicePlan(string value) {
    mixin(toEnumSwitch("MessagingServicePlan", "MessagingServicePlan.dev"));
}
MessagingServicePlan[] toMessagingServicePlan(string[] values) {
    return values.map!(v => v.toMessagingServicePlan).array;
}
string toString(MessagingServicePlan value) {
    return value.to!string();
}
string[] toString(MessagingServicePlan[] values) {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("MessagingServicePlan"));

    assert("dev".toMessagingServicePlan == MessagingServicePlan.dev);
    assert("standard".toMessagingServicePlan == MessagingServicePlan.standard);
    assert("premium".toMessagingServicePlan == MessagingServicePlan.premium);
    assert("unknown".toMessagingServicePlan == MessagingServicePlan.dev); // default

    assert(MessagingServicePlan.dev.toString == "dev");
    assert(MessagingServicePlan.standard.toString == "standard");
    assert(MessagingServicePlan.premium.toString == "premium");

    assert(["dev", "standard"].toMessagingServicePlan == [MessagingServicePlan.dev, MessagingServicePlan.standard]);
    assert([MessagingServicePlan.dev, MessagingServicePlan.standard].toString == ["dev", "standard"]);
}

enum MessageClientStatus {
    active,
    inactive,
    suspended
}
MessageClientStatus toMessageClientStatus(string value) {
    mixin(toEnumSwitch("MessageClientStatus", "MessageClientStatus.active"));
}
MessageClientStatus[] toMessageClientStatus(string[] values) {
    return values.map!(v => v.toMessageClientStatus).array;
}
string toString(MessageClientStatus value) {
    return value.to!string();
}
string[] toString(MessageClientStatus[] values) {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("MessageClientStatus"));

    assert("active".toMessageClientStatus == MessageClientStatus.active);
    assert("inactive".toMessageClientStatus == MessageClientStatus.inactive);
    assert("suspended".toMessageClientStatus == MessageClientStatus.suspended);
    assert("unknown".toMessageClientStatus == MessageClientStatus.active); // default

    assert(MessageClientStatus.active.toString == "active");
    assert(MessageClientStatus.inactive.toString == "inactive");
    assert(MessageClientStatus.suspended.toString == "suspended");  

    assert(["active", "inactive"].toMessageClientStatus == [MessageClientStatus.active, MessageClientStatus.inactive]);
    assert([MessageClientStatus.active, MessageClientStatus.inactive].toString == ["active", "inactive"]);
}

enum MessageClientProtocol {
    amqp10,
    mqtt311,
    mqtt500,
    httprest
}
MessageClientProtocol toMessageClientProtocol(string value) {
    mixin(toEnumSwitch("MessageClientProtocol", "MessageClientProtocol.amqp10"));
}
MessageClientProtocol[] toMessageClientProtocol(string[] values) {
    return values.map!(v => v.toMessageClientProtocol).array;
}
string toString(MessageClientProtocol value) {
    return value.to!string();
}
string[] toString(MessageClientProtocol[] values) {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("MessageClientProtocol"));

    assert("amqp10".toMessageClientProtocol == MessageClientProtocol.amqp10);
    assert("mqtt311".toMessageClientProtocol == MessageClientProtocol.mqtt311);
    assert("mqtt500".toMessageClientProtocol == MessageClientProtocol.mqtt500);
    assert("httprest".toMessageClientProtocol == MessageClientProtocol.httprest);
    assert("unknown".toMessageClientProtocol == MessageClientProtocol.amqp10); // default

    assert(MessageClientProtocol.amqp10.toString == "amqp10");
    assert(MessageClientProtocol.mqtt311.toString == "mqtt311");
    assert(MessageClientProtocol.mqtt500.toString == "mqtt500");
    assert(MessageClientProtocol.httprest.toString == "httprest");

    assert(["amqp10", "mqtt311"].toMessageClientProtocol == [MessageClientProtocol.amqp10, MessageClientProtocol.mqtt311]);
    assert([MessageClientProtocol.amqp10, MessageClientProtocol.mqtt311].toString == ["amqp10", "mqtt311"]);
}

enum QueueStatus {
    active,
    inactive,
    pendingDelete
}
QueueStatus toQueueStatus(string value) {
    mixin(toEnumSwitch("QueueStatus", "QueueStatus.active"));
}
QueueStatus[] toQueueStatus(string[] values) {
    return values.map!(v => v.toQueueStatus).array;
}
string toString(QueueStatus value) {
    return value.to!string();
}
string[] toString(QueueStatus[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("QueueStatus"));

    assert("active".toQueueStatus == QueueStatus.active);
    assert("inactive".toQueueStatus == QueueStatus.inactive);
    assert("pendingDelete".toQueueStatus == QueueStatus.pendingDelete);
    assert("unknown".toQueueStatus == QueueStatus.active); // default   

    assert(QueueStatus.active.toString == "active");
    assert(QueueStatus.inactive.toString == "inactive");
    assert(QueueStatus.pendingDelete.toString == "pendingDelete");

    assert(["active", "inactive"].toQueueStatus == [QueueStatus.active, QueueStatus.inactive]);
    assert([QueueStatus.active, QueueStatus.inactive].toString == ["active", "inactive"]);
}

enum QueueAccessType {
    exclusive,
    nonExclusive
}
QueueAccessType toQueueAccessType(string value) {
    mixin(toEnumSwitch("QueueAccessType", "QueueAccessType.exclusive"));
}
QueueAccessType[] toQueueAccessType(string[] values) {
    return values.map!(v => v.toQueueAccessType).array;
}
string toString(QueueAccessType value) {
    return value.to!string();
}
string[] toString(QueueAccessType[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("QueueAccessType"));

    assert("exclusive".toQueueAccessType == QueueAccessType.exclusive);
    assert("nonExclusive".toQueueAccessType == QueueAccessType.nonExclusive);
    assert("unknown".toQueueAccessType == QueueAccessType.exclusive); // default    

    assert(QueueAccessType.exclusive.toString == "exclusive");
    assert(QueueAccessType.nonExclusive.toString == "nonExclusive");    

    assert(["exclusive", "nonExclusive"].toQueueAccessType == [QueueAccessType.exclusive, QueueAccessType.nonExclusive]);
    assert([QueueAccessType.exclusive, QueueAccessType.nonExclusive].toString == ["exclusive", "nonExclusive"]);
}

enum QueueSubscriptionStatus {
    active,
    inactive,
    pendingDelete
}
QueueSubscriptionStatus toQueueSubscriptionStatus(string value) {
    mixin(toEnumSwitch("QueueSubscriptionStatus", "QueueSubscriptionStatus.active"));
}
QueueSubscriptionStatus[] toQueueSubscriptionStatus(string[] values) {
    return values.map!(v => v.toQueueSubscriptionStatus).array;
}
string toString(QueueSubscriptionStatus value) {
    return value.to!string();
}
string[] toString(QueueSubscriptionStatus[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("QueueSubscriptionStatus"));

    assert("active".toQueueSubscriptionStatus == QueueSubscriptionStatus.active);
    assert("inactive".toQueueSubscriptionStatus == QueueSubscriptionStatus.inactive);
    assert("pendingDelete".toQueueSubscriptionStatus == QueueSubscriptionStatus.pendingDelete);
    assert("unknown".toQueueSubscriptionStatus == QueueSubscriptionStatus.active); // default

    assert(QueueSubscriptionStatus.active.toString == "active");
    assert(QueueSubscriptionStatus.inactive.toString == "inactive");
    assert(QueueSubscriptionStatus.pendingDelete.toString == "pendingDelete");

    assert(["active", "inactive"].toQueueSubscriptionStatus == [QueueSubscriptionStatus.active, QueueSubscriptionStatus.inactive]);
    assert([QueueSubscriptionStatus.active, QueueSubscriptionStatus.inactive].toString == ["active", "inactive"]);
}

enum WebhookStatus {
    active,
    paused,
    inactive,
    failed
}
WebhookStatus toWebhookStatus(string value) {
    mixin(toEnumSwitch("WebhookStatus", "WebhookStatus.active"));
}
WebhookStatus[] toWebhookStatus(string[] values) {
    return values.map!(v => v.toWebhookStatus).array;
}
string toString(WebhookStatus value) {
    return value.to!string();
}
string[] toString(WebhookStatus[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("WebhookStatus"));

    assert("active".toWebhookStatus == WebhookStatus.active);
    assert("paused".toWebhookStatus == WebhookStatus.paused);
    assert("inactive".toWebhookStatus == WebhookStatus.inactive);
    assert("failed".toWebhookStatus == WebhookStatus.failed);
    assert("unknown".toWebhookStatus == WebhookStatus.active); // default

    assert(WebhookStatus.active.toString == "active");
    assert(WebhookStatus.paused.toString == "paused");
    assert(WebhookStatus.inactive.toString == "inactive");
    assert(WebhookStatus.failed.toString == "failed");

    assert(["active", "paused"].toWebhookStatus == [WebhookStatus.active, WebhookStatus.paused]);
    assert([WebhookStatus.active, WebhookStatus.paused].toString == ["active", "paused"]);  
}

enum WebhookAuthType {
    none_,
    oauth2,
    basic,
    apiKey
}
WebhookAuthType toWebhookAuthType(string value) {
    mixin(toEnumSwitch("WebhookAuthType", "WebhookAuthType.none_"));
}
WebhookAuthType[] toWebhookAuthType(string[] values) {
    return values.map!(v => v.toWebhookAuthType).array;
}
string toString(WebhookAuthType value) {
    return value.to!string();
}
string[] toString(WebhookAuthType[] values) {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("WebhookAuthType"));

    assert("none".toWebhookAuthType == WebhookAuthType.none_);
    assert("oauth2".toWebhookAuthType == WebhookAuthType.oauth2);
    assert("basic".toWebhookAuthType == WebhookAuthType.basic);
    assert("apiKey".toWebhookAuthType == WebhookAuthType.apiKey);
    assert("unknown".toWebhookAuthType == WebhookAuthType.none_); // default

    assert(WebhookAuthType.none_.toString == "none");
    assert(WebhookAuthType.oauth2.toString == "oauth2");
    assert(WebhookAuthType.basic.toString == "basic");
    assert(WebhookAuthType.apiKey.toString == "apiKey");

    assert(["none", "oauth2"].toWebhookAuthType == [WebhookAuthType.none_, WebhookAuthType.oauth2]);
    assert([WebhookAuthType.none_, WebhookAuthType.oauth2].toString == ["none", "oauth2"]);  
}

enum WebhookDeliveryMode {
    atLeastOnce,
    atMostOnce
}
WebhookDeliveryMode toWebhookDeliveryMode(string value) {
    mixin(toEnumSwitch("WebhookDeliveryMode", "WebhookDeliveryMode.atLeastOnce"));
}
WebhookDeliveryMode[] toWebhookDeliveryMode(string[] values) {
    return values.map!(v => v.toWebhookDeliveryMode).array;
}
string toString(WebhookDeliveryMode value) {
    return value.to!string();
}
string[] toString(WebhookDeliveryMode[] values) {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("WebhookDeliveryMode"));

    assert("atLeastOnce".toWebhookDeliveryMode == WebhookDeliveryMode.atLeastOnce);
    assert("atMostOnce".toWebhookDeliveryMode == WebhookDeliveryMode.atMostOnce);
    assert("unknown".toWebhookDeliveryMode == WebhookDeliveryMode.atLeastOnce); // default

    assert(WebhookDeliveryMode.atLeastOnce.toString == "atLeastOnce");
    assert(WebhookDeliveryMode.atMostOnce.toString == "atMostOnce");    

    assert(["atLeastOnce", "atMostOnce"].toWebhookDeliveryMode == [WebhookDeliveryMode.atLeastOnce, WebhookDeliveryMode.atMostOnce]);
    assert([WebhookDeliveryMode.atLeastOnce, WebhookDeliveryMode.atMostOnce].toString == ["atLeastOnce", "atMostOnce"]);  
}

enum EventChannelStatus {
    active,
    inactive,
    deprecated_
}
EventChannelStatus toEventChannelStatus(string value) {
    mixin(toEnumSwitch("EventChannelStatus", "EventChannelStatus.active"));
}
EventChannelStatus[] toEventChannelStatus(string[] values) {
    return values.map!(v => v.toEventChannelStatus).array;
}
string toString(EventChannelStatus value) {
    return value.to!string();
}
string[] toString(EventChannelStatus[] values) {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("EventChannelStatus"));

    assert("active".toEventChannelStatus == EventChannelStatus.active);
    assert("inactive".toEventChannelStatus == EventChannelStatus.inactive);
    assert("deprecated".toEventChannelStatus == EventChannelStatus.deprecated_);
    assert("unknown".toEventChannelStatus == EventChannelStatus.active); // default

    assert(EventChannelStatus.active.toString == "active");
    assert(EventChannelStatus.inactive.toString == "inactive");
    assert(EventChannelStatus.deprecated_.toString == "deprecated");        

    assert(["active", "inactive"].toEventChannelStatus == [EventChannelStatus.active, EventChannelStatus.inactive]);
    assert([EventChannelStatus.active, EventChannelStatus.inactive].toString == ["active", "inactive"]);
}

enum EventChannelType {
    queue,
    topic,
    eventChannel
}
EventChannelType toEventChannelType(string value) {
    mixin(toEnumSwitch("EventChannelType", "EventChannelType.queue"));
}
EventChannelType[] toEventChannelType(string[] values) {
    return values.map!(v => v.toEventChannelType).array;
}
string toString(EventChannelType value) {
    return value.to!string();
}
string[] toString(EventChannelType[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("EventChannelType"));

    assert("queue".toEventChannelType == EventChannelType.queue);
    assert("topic".toEventChannelType == EventChannelType.topic);
    assert("eventChannel".toEventChannelType == EventChannelType.eventChannel);
    assert("unknown".toEventChannelType == EventChannelType.queue); // default

    assert(EventChannelType.queue.toString == "queue");
    assert(EventChannelType.topic.toString == "topic");
    assert(EventChannelType.eventChannel.toString == "eventChannel");   

    assert(["queue", "topic", "eventChannel"].toEventChannelType == [EventChannelType.queue, EventChannelType.topic, EventChannelType.eventChannel]);
    assert([EventChannelType.queue, EventChannelType.topic, EventChannelType.eventChannel].toString == ["queue", "topic", "eventChannel"]);
}

enum MessageBindingStatus {
    active,
    inactive
}
MessageBindingStatus toMessageBindingStatus(string value) {
    mixin(toEnumSwitch("MessageBindingStatus", "MessageBindingStatus.active"));
}
MessageBindingStatus[] toMessageBindingStatus(string[] values) {
    return values.map!(v => v.toMessageBindingStatus).array;
}
string toString(MessageBindingStatus value) {
    return value.to!string();
}
string[] toString(MessageBindingStatus[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("MessageBindingStatus"));

    assert("active".toMessageBindingStatus == MessageBindingStatus.active);
    assert("inactive".toMessageBindingStatus == MessageBindingStatus.inactive);
    assert("unknown".toMessageBindingStatus == MessageBindingStatus.active); // default

    assert(MessageBindingStatus.active.toString == "active");
    assert(MessageBindingStatus.inactive.toString == "inactive");

    assert(["active", "inactive"].toMessageBindingStatus == [MessageBindingStatus.active, MessageBindingStatus.inactive]);
    assert([MessageBindingStatus.active, MessageBindingStatus.inactive].toString == ["active", "inactive"]);
}

enum MessageBindingPermission {
    publish,
    subscribe,
    manage,
    publishSubscribe
}
MessageBindingPermission toMessageBindingPermission(string value) {
    mixin(toEnumSwitch("MessageBindingPermission", "MessageBindingPermission.publish"));
}
MessageBindingPermission[] toMessageBindingPermission(string[] values) {
    return values.map!(v => v.toMessageBindingPermission).array;
}
string toString(MessageBindingPermission value) {
    return value.to!string();
}
string[] toString(MessageBindingPermission[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("MessageBindingPermission"));

    assert("publish".toMessageBindingPermission == MessageBindingPermission.publish);
    assert("subscribe".toMessageBindingPermission == MessageBindingPermission.subscribe);
    assert("manage".toMessageBindingPermission == MessageBindingPermission.manage);
    assert("publishSubscribe".toMessageBindingPermission == MessageBindingPermission.publishSubscribe);
    assert("unknown".toMessageBindingPermission == MessageBindingPermission.publish); // default

    assert(MessageBindingPermission.publish.toString == "publish");
    assert(MessageBindingPermission.subscribe.toString == "subscribe");
    assert(MessageBindingPermission.manage.toString == "manage");
    assert(MessageBindingPermission.publishSubscribe.toString == "publishSubscribe");   

    assert(["publish", "subscribe"].toMessageBindingPermission == [MessageBindingPermission.publish, MessageBindingPermission.subscribe]);
    assert([MessageBindingPermission.publish, MessageBindingPermission.subscribe].toString == ["publish", "subscribe"]);
}
