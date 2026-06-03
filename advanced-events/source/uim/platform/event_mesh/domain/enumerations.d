module uim.platform.event_mesh.domain.enumerations;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

enum BrokerServiceStatus {
    provisioning,
    running,
    stopped,
    updating,
    degraded,
    failed,
    decommissioned
}

BrokerServiceStatus toBrokerServiceStatus(string status) {
    const map = [
        "provisioning": BrokerServiceStatus.provisioning,
        "running": BrokerServiceStatus.running,
        "stopped": BrokerServiceStatus.stopped,
        "updating": BrokerServiceStatus.updating,
        "degraded": BrokerServiceStatus.degraded,
        "failed": BrokerServiceStatus.failed,
        "decommissioned": BrokerServiceStatus.decommissioned
    ];
    return map.get(status.toLower, BrokerServiceStatus.failed); // default to failed if unknown
}

enum BrokerServiceType {
    enterprise,
    developer,
    standard,
    premium
}

BrokerServiceType toBrokerServiceType(string type) {
    const map = [
        "enterprise": BrokerServiceType.enterprise,
        "developer": BrokerServiceType.developer,
        "standard": BrokerServiceType.standard,
        "premium": BrokerServiceType.premium
    ];
    return map.get(type.toLower, BrokerServiceType.standard); // default to standard if unknown
}

enum BrokerServiceClass {
    enterpriseKilo,
    enterpriseMega,
    enterpriseGiga,
    developerKilo,
    standardKilo,
    standardMega
}

BrokerServiceClass toBrokerServiceClass(string name) {
    const map = [
        "enterprisekilo": BrokerServiceClass.enterpriseKilo,
        "enterprisemega": BrokerServiceClass.enterpriseMega,
        "enterprisegiga": BrokerServiceClass.enterpriseGiga,
        "developerkilo": BrokerServiceClass.developerKilo,
        "standardkilo": BrokerServiceClass.standardKilo,
        "standardmega": BrokerServiceClass.standardMega
    ];
    return map.get(name.toLower, BrokerServiceClass.standardKilo); // default to standardkilo if unknown
}

enum CloudProvider {
    aws,
    azure,
    gcp,
    sap,
    onPremise
}

CloudProvider toCloudProvider(string provider) {
    const map = [
        "aws": CloudProvider.aws,
        "azure": CloudProvider.azure,
        "gcp": CloudProvider.gcp,
        "sap": CloudProvider.sap,
        "onpremise": CloudProvider.onPremise
    ];
    return map.get(provider.toLower, CloudProvider.onPremise); // default to onPremise if unknown
}

enum QueueAccessType {
    exclusive,
    nonExclusive
}

QueueAccessType toQueueAccessType(string accessType) {
    const map = [
        "exclusive": QueueAccessType.exclusive,
        "nonexclusive": QueueAccessType.nonExclusive
    ];
    return map.get(accessType.toLower, QueueAccessType.nonExclusive); // default to nonExclusive if unknown
}

enum QueueStatus {
    active,
    inactive,
    shuttingDown,
    pendingDelete
}

QueueStatus toQueueStatus(string status) {
    const map = [
        "active": QueueStatus.active,
        "inactive": QueueStatus.inactive,
        "shuttingdown": QueueStatus.shuttingDown,
        "pendingdelete": QueueStatus.pendingDelete
    ];
    return map.get(status.toLower, QueueStatus.inactive); // default to inactive if unknown
}

enum QueueType {
    durable,
    nonDurable,
    temporary
}

QueueType toQueueType(string type) {
    const map = [
        "durable": QueueType.durable,
        "nondurable": QueueType.nonDurable,
        "temporary": QueueType.temporary
    ];
    return map.get(type.toLower, QueueType.durable); // default to durable if unknown
}

enum TopicStatus {
    active,
    inactive,
    pendingDelete
}

TopicStatus toTopicStatus(string status) {
    const map = [
        "active": TopicStatus.active,
        "inactive": TopicStatus.inactive,
        "pendingdelete": TopicStatus.pendingDelete
    ];
    return map.get(status.toLower, TopicStatus.inactive); // default to inactive if unknown
}

enum SubscriptionStatus {
    active,
    suspended,
    pendingDelete
}

SubscriptionStatus toSubscriptionStatus(string status) {
    const map = [
        "active": SubscriptionStatus.active,
        "suspended": SubscriptionStatus.suspended,
        "pendingdelete": SubscriptionStatus.pendingDelete
    ];
    return map.get(status.toLower, SubscriptionStatus.active); // default to inactive if unknown
}

enum SubscriptionType {
    direct,
    queueBased,
    topicEndpoint
}

SubscriptionType toSubscriptionType(string type) {
    const map = [
        "direct": SubscriptionType.direct,
        "queuebased": SubscriptionType.queueBased,
        "topicendpoint": SubscriptionType.topicEndpoint
    ];
    return map.get(type.toLower, SubscriptionType.direct); // default to direct if unknown
}

enum DeliveryMode {
    direct,
    persistent,
    nonPersistent
}

DeliveryMode toDeliveryMode(string mode) {
    const map = [
        "direct": DeliveryMode.direct,
        "persistent": DeliveryMode.persistent,
        "nonpersistent": DeliveryMode.nonPersistent
    ];
    return map.get(mode.toLower, DeliveryMode.direct); // default to direct if unknown
}

enum MessageStatus {
    pending,
    delivered,
    acknowledged,
    rejected,
    expired,
    deadLettered
}

MessageStatus toMessageStatus(string status) {
    const map = [
        "pending": MessageStatus.pending,
        "delivered": MessageStatus.delivered,
        "acknowledged": MessageStatus.acknowledged,
        "rejected": MessageStatus.rejected,
        "expired": MessageStatus.expired,
        "deadlettered": MessageStatus.deadLettered
    ];
    return map.get(status.toLower, MessageStatus.pending); // default to pending if unknown
}

enum MessagePriority {
    low,
    normal,
    high,
    urgent
}

MessagePriority toMessagePriority(string priority) {
    const map = [
        "low": MessagePriority.low,
        "normal": MessagePriority.normal,
        "high": MessagePriority.high,
        "urgent": MessagePriority.urgent
    ];
    return map.get(priority.toLower, MessagePriority.normal); // default to normal if unknown
}

enum SchemaFormat {
    json,
    avro,
    protobuf,
    xml,
    asyncapi
}

SchemaFormat toSchemaFormat(string format) {
    const map = [
        "json": SchemaFormat.json,
        "avro": SchemaFormat.avro,
        "protobuf": SchemaFormat.protobuf,
        "xml": SchemaFormat.xml,
        "asyncapi": SchemaFormat.asyncapi
    ];
    return map.get(format.toLower, SchemaFormat.json); // default to json if unknown
}

enum SchemaStatus {
    draft,
    active,
    deprecated_,
    retired
}

SchemaStatus toSchemaStatus(string status) {
    const map = [
        "draft": SchemaStatus.draft,
        "active": SchemaStatus.active,
        "deprecated": SchemaStatus.deprecated_,
        "retired": SchemaStatus.retired
    ];
    return map.get(status.toLower, SchemaStatus.draft); // default to draft if unknown
}

enum EventApplicationStatus {
    registered,
    active,
    suspended,
    deregistered
}

EventApplicationStatus toEventApplicationStatus(string status) {
    const map = [
        "registered": EventApplicationStatus.registered,
        "active": EventApplicationStatus.active,
        "suspended": EventApplicationStatus.suspended,
        "deregistered": EventApplicationStatus.deregistered
    ];
    return map.get(status.toLower, EventApplicationStatus.registered); // default to registered if unknown
}

enum EventApplicationType {
    publisher,
    subscriber,
    both
}

EventApplicationType toEventApplicationType(string type) {
    const map = [
        "publisher": EventApplicationType.publisher,
        "subscriber": EventApplicationType.subscriber,
        "both": EventApplicationType.both
    ];
    return map.get(type.toLower, EventApplicationType.both); // default to both if unknown
}

enum BridgeStatus {
    provisioning,
    active,
    inactive,
    degraded,
    failed
}

BridgeStatus toBridgeStatus(string status) {
    const map = [
        "provisioning": BridgeStatus.provisioning,
        "active": BridgeStatus.active,
        "inactive": BridgeStatus.inactive,
        "degraded": BridgeStatus.degraded,
        "failed": BridgeStatus.failed
    ];
    return map.get(status.toLower, BridgeStatus.failed); // default to failed if unknown
}

enum BridgeType {
    mesh,
    vpn,
    rest,
    kafka,
    jms_
}

BridgeType toBridgeType(string type) {
    const map = [
        "mesh": BridgeType.mesh,
        "vpn": BridgeType.vpn,
        "rest": BridgeType.rest,
        "kafka": BridgeType.kafka,
        "jms": BridgeType.jms_
    ];
    return map.get(type.toLower, BridgeType.mesh); // default to mesh if unknown
}

enum ProtocolType {
    smf,
    mqtt,
    amqp,
    rest,
    jms_,
    websocket
}

ProtocolType toProtocolType(string type) {
    const map = [
        "smf": ProtocolType.smf,
        "mqtt": ProtocolType.mqtt,
        "amqp": ProtocolType.amqp,
        "rest": ProtocolType.rest,
        "jms": ProtocolType.jms_,
        "websocket": ProtocolType.websocket
    ];
    return map.get(type.toLower, ProtocolType.smf); // default to smf if unknown
}
