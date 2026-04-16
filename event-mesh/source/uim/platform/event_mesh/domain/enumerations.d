module uim.platform.event_mesh.domain.enumerations;

// --- Enumerations ---

enum BrokerServiceStatus {
    provisioning,
    running,
    stopped,
    updating,
    degraded,
    failed,
    decommissioned
}

enum BrokerServiceType {
    enterprise,
    developer,
    standard,
    premium
}

enum BrokerServiceClass {
    enterpriseKilo,
    enterpriseMega,
    enterpriseGiga,
    developerKilo,
    standardKilo,
    standardMega
}

enum CloudProvider {
    aws,
    azure,
    gcp,
    sap,
    onPremise
}

enum QueueAccessType {
    exclusive,
    nonExclusive
}

enum QueueStatus {
    active,
    inactive,
    shuttingDown,
    pendingDelete
}

enum QueueType {
    durable,
    nonDurable,
    temporary
}

enum TopicStatus {
    active,
    inactive,
    pendingDelete
}

enum SubscriptionStatus {
    active,
    suspended,
    pendingDelete
}

enum SubscriptionType {
    direct,
    queueBased,
    topicEndpoint
}

enum DeliveryMode {
    direct,
    persistent,
    nonPersistent
}

enum MessageStatus {
    pending,
    delivered,
    acknowledged,
    rejected,
    expired,
    deadLettered
}

enum MessagePriority {
    low,
    normal,
    high,
    urgent
}

enum SchemaFormat {
    json,
    avro,
    protobuf,
    xml,
    asyncapi
}

enum SchemaStatus {
    draft,
    active,
    deprecated_,
    retired
}

enum EventApplicationStatus {
    registered,
    active,
    suspended,
    deregistered
}

enum EventApplicationType {
    publisher,
    subscriber,
    both
}

enum BridgeStatus {
    provisioning,
    active,
    inactive,
    degraded,
    failed
}

enum BridgeType {
    mesh,
    vpn,
    rest,
    kafka,
    jms_
}

enum ProtocolType {
    smf,
    mqtt,
    amqp,
    rest,
    jms_,
    websocket
}
