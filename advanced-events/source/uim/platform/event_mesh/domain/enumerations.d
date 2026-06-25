module uim.platform.event_mesh.domain.enumerations;

import uim.platform.event_mesh;

// mixin(ShowModule!());

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

BrokerServiceStatus toBrokerServiceStatus(string value) {
    mixin(toEnumSwitch("BrokerServiceStatus", "failed"));
}
BrokerServiceStatus[] toBrokerServiceStatus(string[] values) {
    return values.map!(v => toBrokerServiceStatus(v)).array;
}
string toString(BrokerServiceStatus status) {
    mixin(toEnumToString!("BrokerServiceStatus"));
}
string[] toString(BrokerServiceStatus[] statuses) {
    return statuses.map!(s => toString(s)).array;
}
/// 
unittest {
    mixin(ShowTest!("BrokerServiceStatus Enum Conversion"));

    assert(toBrokerServiceStatus("provisioning") == BrokerServiceStatus.provisioning);
    assert(toBrokerServiceStatus("running") == BrokerServiceStatus.running);
    assert(toBrokerServiceStatus("stopped") == BrokerServiceStatus.stopped);
    assert(toBrokerServiceStatus("updating") == BrokerServiceStatus.updating);
    assert(toBrokerServiceStatus("degraded") == BrokerServiceStatus.degraded);
    assert(toBrokerServiceStatus("failed") == BrokerServiceStatus.failed);
    assert(toBrokerServiceStatus("decommissioned") == BrokerServiceStatus.decommissioned);
    assert(toBrokerServiceStatus("unknown") == BrokerServiceStatus.failed); // default case

    assert(toString(BrokerServiceStatus.provisioning) == "provisioning");
    assert(toString(BrokerServiceStatus.running) == "running");
    assert(toString(BrokerServiceStatus.stopped) == "stopped");
    assert(toString(BrokerServiceStatus.updating) == "updating");
    assert(toString(BrokerServiceStatus.degraded) == "degraded");
    assert(toString(BrokerServiceStatus.failed) == "failed");
    assert(toString(BrokerServiceStatus.decommissioned) == "decommissioned");

    assert(toBrokerServiceStatus(["running", "unknown", "provisioning"]) == [BrokerServiceStatus.running, BrokerServiceStatus.failed, BrokerServiceStatus.provisioning]);
    assert(toString([BrokerServiceStatus.stopped, BrokerServiceStatus.degraded]) == ["stopped", "degraded"]);
}

enum BrokerServiceType {
    enterprise,
    developer,
    standard,
    premium
}
BrokerServiceType toBrokerServiceType(string value) {
    mixin(toEnumSwitch("BrokerServiceType", "standard"));
}
BrokerServiceType[] toBrokerServiceType(string[] values) {
    return values.map!(v => toBrokerServiceType(v)).array;
}
string toString(BrokerServiceType type) {
    mixin(toEnumToString!("BrokerServiceType"));
}
string[] toString(BrokerServiceType[] types) {
    return types.map!(t => toString(t)).array;
}
///
unittest {
    mixin(ShowTest!("BrokerServiceType Enum Conversion"));

    assert(toBrokerServiceType("enterprise") == BrokerServiceType.enterprise);
    assert(toBrokerServiceType("developer") == BrokerServiceType.developer);
    assert(toBrokerServiceType("standard") == BrokerServiceType.standard);
    assert(toBrokerServiceType("premium") == BrokerServiceType.premium);
    assert(toBrokerServiceType("unknown") == BrokerServiceType.standard); // default case

    assert(toString(BrokerServiceType.enterprise) == "enterprise");
    assert(toString(BrokerServiceType.developer) == "developer");
    assert(toString(BrokerServiceType.standard) == "standard");
    assert(toString(BrokerServiceType.premium) == "premium");

    assert(toBrokerServiceType(["developer", "unknown", "premium"]) == [BrokerServiceType.developer, BrokerServiceType.standard, BrokerServiceType.premium]);
    assert(toString([BrokerServiceType.enterprise, BrokerServiceType.standard]) == ["enterprise", "standard"]);
}

enum BrokerServiceClass {
    enterpriseKilo,
    enterpriseMega,
    enterpriseGiga,
    developerKilo,
    standardKilo,
    standardMega
}
BrokerServiceClass toBrokerServiceClass(string value) {
    mixin(toEnumSwitch("BrokerServiceClass", "standardKilo"));
}
BrokerServiceClass[] toBrokerServiceClass(string[] values) {
    return values.map!(v => toBrokerServiceClass(v)).array;
}
string toString(BrokerServiceClass serviceClass) {
    return serviceClass.to!string;
}
string[] toString(BrokerServiceClass[] serviceClasses) {
    return serviceClasses.map!(sc => toString(sc)).array;
}
///
unittest {
    mixin(ShowTest!("BrokerServiceClass Enum Conversion"));

    assert(toBrokerServiceClass("enterprisekilo") == BrokerServiceClass.enterpriseKilo);
    assert(toBrokerServiceClass("enterprisemega") == BrokerServiceClass.enterpriseMega);
    assert(toBrokerServiceClass("enterprisegiga") == BrokerServiceClass.enterpriseGiga);
    assert(toBrokerServiceClass("developerkilo") == BrokerServiceClass.developerKilo);
    assert(toBrokerServiceClass("standardkilo") == BrokerServiceClass.standardKilo);
    assert(toBrokerServiceClass("standardmega") == BrokerServiceClass.standardMega);
    assert(toBrokerServiceClass("unknown") == BrokerServiceClass.standardKilo); // default

    assert(toString(BrokerServiceClass.enterpriseKilo) == "enterpriseKilo");
    assert(toString(BrokerServiceClass.enterpriseMega) == "enterpriseMega");
    assert(toString(BrokerServiceClass.enterpriseGiga) == "enterpriseGiga");
    assert(toString(BrokerServiceClass.developerKilo) == "developerKilo");
    assert(toString(BrokerServiceClass.standardKilo) == "standardKilo");
    assert(toString(BrokerServiceClass.standardMega) == "standardMega");

    assert(toBrokerServiceClass(["enterprisekilo", "unknown", "standardmega"]) == [BrokerServiceClass.enterpriseKilo, BrokerServiceClass.standardKilo, BrokerServiceClass.standardMega]);
    assert(toString([BrokerServiceClass.developerKilo, BrokerServiceClass.enterpriseGiga]) == ["developerKilo", "enterpriseGiga"]);
}

enum CloudProvider {
    aws,
    azure,
    gcp,
    sap,
    onPremise
}
CloudProvider toCloudProvider(string provider) {
    mixin(toEnumSwitch("CloudProvider", "sap"));
}
CloudProvider[] toCloudProvider(string[] providers) {
    return providers.map!(p => toCloudProvider(p)).array;
}
string toString(CloudProvider provider) {
    return provider.to!string;
}
string[] toString(CloudProvider[] providers) {
    return providers.map!(p => toString(p)).array;
}
///
unittest {
    mixin(ShowTest!("CloudProvider Enum Conversion"));

    assert(toCloudProvider("aws") == CloudProvider.aws);
    assert(toCloudProvider("azure") == CloudProvider.azure);
    assert(toCloudProvider("gcp") == CloudProvider.gcp);
    assert(toCloudProvider("sap") == CloudProvider.sap);
    assert(toCloudProvider("onpremise") == CloudProvider.onPremise);
    assert(toCloudProvider("unknown") == CloudProvider.sap); // default case

    assert(toString(CloudProvider.aws) == "aws");
    assert(toString(CloudProvider.azure) == "azure");
    assert(toString(CloudProvider.gcp) == "gcp");
    assert(toString(CloudProvider.sap) == "sap");
    assert(toString(CloudProvider.onPremise) == "onPremise");

    assert(toCloudProvider(["aws", "unknown", "gcp"]) == [CloudProvider.aws, CloudProvider.sap, CloudProvider.gcp]);
    assert(toString([CloudProvider.azure, CloudProvider.onPremise]) == ["azure", "onPremise"]);
}

enum QueueAccessType {
    exclusive,
    nonExclusive
}
QueueAccessType toQueueAccessType(string value) {
    mixin(toEnumSwitch("QueueAccessType", "exclusive"));
}
QueueAccessType[] toQueueAccessType(string[] values) {
    return values.map!(v => toQueueAccessType(v)).array;
}
string toString(QueueAccessType accessType) {
    return accessType.to!string;
}
string[] toString(QueueAccessType[] accessTypes) {
    return accessTypes.map!(at => toString(at)).array;
}
///
unittest {
    mixin(ShowTest!("QueueAccessType Enum Conversion"));

    assert(toQueueAccessType("exclusive") == QueueAccessType.exclusive);
    assert(toQueueAccessType("nonexclusive") == QueueAccessType.nonExclusive);
    assert(toQueueAccessType("unknown") == QueueAccessType.exclusive); // default case  

    assert(toString(QueueAccessType.exclusive) == "exclusive");
    assert(toString(QueueAccessType.nonExclusive) == "nonExclusive");

    assert(toQueueAccessType(["exclusive", "unknown", "nonexclusive"]) == [QueueAccessType.exclusive, QueueAccessType.exclusive, QueueAccessType.nonExclusive]);
    assert(toString([QueueAccessType.exclusive, QueueAccessType.nonExclusive]) == ["exclusive", "nonExclusive"]);
}

enum QueueStatus {
    active,
    inactive,
    shuttingDown,
    pendingDelete
}
QueueStatus toQueueStatus(string status) {
    mixin(toEnumSwitch("QueueStatus", "inactive"));
}
QueueStatus[] toQueueStatus(string[] statuses) {
    return statuses.map!(s => toQueueStatus(s)).array;
}
string toString(QueueStatus status) {
    return status.to!string;
}
string[] toString(QueueStatus[] statuses) {
    return statuses.map!(s => toString(s)).array;
}
///
unittest {
    mixin(ShowTest!("QueueStatus Enum Conversion"));

    assert(toQueueStatus("active") == QueueStatus.active);
    assert(toQueueStatus("inactive") == QueueStatus.inactive);
    assert(toQueueStatus("shuttingdown") == QueueStatus.shuttingDown);
    assert(toQueueStatus("pendingdelete") == QueueStatus.pendingDelete);
    assert(toQueueStatus("unknown") == QueueStatus.inactive); // default case

    assert(toString(QueueStatus.active) == "active");
    assert(toString(QueueStatus.inactive) == "inactive");
    assert(toString(QueueStatus.shuttingDown) == "shuttingDown");
    assert(toString(QueueStatus.pendingDelete) == "pendingDelete"); 

    assert(toQueueStatus(["active", "unknown", "shuttingdown"]) == [QueueStatus.active, QueueStatus.inactive, QueueStatus.shuttingDown]);
    assert(toString([QueueStatus.inactive, QueueStatus.pendingDelete]) == ["inactive", "pendingDelete"]);
}

enum QueueType {
    durable,
    nonDurable,
    temporary
}
QueueType toQueueType(string type) {
    mixin(toEnumSwitch("QueueType", "durable"));
}
QueueType[] toQueueType(string[] types) {
    return types.map!(t => toQueueType(t)).array;
}
string toString(QueueType type) {
    return type.to!string;
}
string[] toString(QueueType[] types) {
    return types.map!(t => toString(t)).array;
}
///
unittest {
    mixin(ShowTest!("QueueType Enum Conversion"));

    assert(toQueueType("durable") == QueueType.durable);
    assert(toQueueType("nondurable") == QueueType.nonDurable);
    assert(toQueueType("temporary") == QueueType.temporary);
    assert(toQueueType("unknown") == QueueType.durable); // default case

    assert(toString(QueueType.durable) == "durable");
    assert(toString(QueueType.nonDurable) == "nonDurable");
    assert(toString(QueueType.temporary) == "temporary");

    assert(toQueueType(["durable", "unknown", "temporary"]) == [QueueType.durable, QueueType.durable, QueueType.temporary]);
    assert(toString([QueueType.nonDurable, QueueType.temporary]) == ["nonDurable", "temporary"]);
}

enum TopicStatus {
    active,
    inactive,
    pendingDelete
}
TopicStatus toTopicStatus(string status) {
    mixin(toEnumSwitch("TopicStatus", "inactive"));
}
TopicStatus[] toTopicStatus(string[] statuses) {
    return statuses.map!(s => toTopicStatus(s)).array;
}
string toString(TopicStatus status) {
    return status.to!string;
}
string[] toString(TopicStatus[] statuses) {
    return statuses.map!(s => toString(s)).array;
}
///
unittest {
    mixin(ShowTest!("TopicStatus Enum Conversion"));

    assert(toTopicStatus("active") == TopicStatus.active);
    assert(toTopicStatus("inactive") == TopicStatus.inactive);
    assert(toTopicStatus("pendingdelete") == TopicStatus.pendingDelete);
    assert(toTopicStatus("unknown") == TopicStatus.inactive); // default case

    assert(toString(TopicStatus.active) == "active");
    assert(toString(TopicStatus.inactive) == "inactive");
    assert(toString(TopicStatus.pendingDelete) == "pendingDelete");

    assert(toTopicStatus(["active", "unknown", "pendingdelete"]) == [TopicStatus.active, TopicStatus.inactive, TopicStatus.pendingDelete]);
    assert(toString([TopicStatus.inactive, TopicStatus.pendingDelete]) == ["inactive", "pendingDelete"]);
}

enum SubscriptionStatus {
    active,
    suspended,
    pendingDelete
}
SubscriptionStatus toSubscriptionStatus(string status) {
    mixin(toEnumSwitch("SubscriptionStatus", "suspended"));
}
SubscriptionStatus[] toSubscriptionStatus(string[] statuses) {
    return statuses.map!(s => toSubscriptionStatus(s)).array;
}
string toString(SubscriptionStatus status) {
    return status.to!string;
}
string[] toString(SubscriptionStatus[] statuses) {
    return statuses.map!(s => toString(s)).array;
}
///
unittest {
    mixin(ShowTest!("SubscriptionStatus Enum Conversion")); 

    assert(toSubscriptionStatus("active") == SubscriptionStatus.active);
    assert(toSubscriptionStatus("suspended") == SubscriptionStatus.suspended);
    assert(toSubscriptionStatus("pendingdelete") == SubscriptionStatus.pendingDelete);
    assert(toSubscriptionStatus("unknown") == SubscriptionStatus.suspended); // default case    

    assert(toString(SubscriptionStatus.active) == "active");
    assert(toString(SubscriptionStatus.suspended) == "suspended");
    assert(toString(SubscriptionStatus.pendingDelete) == "pendingDelete");

    assert(toSubscriptionStatus(["active", "unknown", "pendingdelete"]) == [SubscriptionStatus.active, SubscriptionStatus.suspended, SubscriptionStatus.pendingDelete]);
    assert(toString([SubscriptionStatus.suspended, SubscriptionStatus.pendingDelete]) == ["suspended", "pendingDelete"]);
}

enum SubscriptionType {
    direct,
    queueBased,
    topicEndpoint
}

SubscriptionType toSubscriptionType(string value) {
    mixin(toEnumSwitch("SubscriptionType", "direct"));
}
SubscriptionType[] toSubscriptionType(string[] values) {
    return values.map!(v => toSubscriptionType(v)).array;
}
string toString(SubscriptionType type) {
    return type.to!string;
}
string[] toString(SubscriptionType[] types) {
    return types.map!(t => toString(t)).array;
}
///
unittest {
    mixin(ShowTest!("SubscriptionType Enum Conversion"));

    assert(toSubscriptionType("direct") == SubscriptionType.direct);
    assert(toSubscriptionType("queuebased") == SubscriptionType.queueBased);
    assert(toSubscriptionType("topicendpoint") == SubscriptionType.topicEndpoint);
    assert(toSubscriptionType("unknown") == SubscriptionType.direct); // default case

    assert(toString(SubscriptionType.direct) == "direct");
    assert(toString(SubscriptionType.queueBased) == "queueBased");
    assert(toString(SubscriptionType.topicEndpoint) == "topicEndpoint");

    assert(toSubscriptionType(["direct", "unknown", "queuebased"]) == [SubscriptionType.direct, SubscriptionType.direct, SubscriptionType.queueBased]);
    assert(toString([SubscriptionType.queueBased, SubscriptionType.topicEndpoint]) == ["queueBased", "topicEndpoint"]);
}

enum DeliveryMode {
    direct,
    persistent,
    nonPersistent
}

DeliveryMode toDeliveryMode(string value) {
    mixin(toEnumSwitch("DeliveryMode", "direct"));
}
DeliveryMode[] toDeliveryMode(string[] values) {
    return values.map!(v => toDeliveryMode(v)).array;
}
string toString(DeliveryMode mode) {
    return mode.to!string;
}
string[] toString(DeliveryMode[] modes) {
    return modes.map!(m => toString(m)).array;
}
///
unittest {
    mixin(ShowTest!("DeliveryMode Enum Conversion"));

    assert(toDeliveryMode("direct") == DeliveryMode.direct);
    assert(toDeliveryMode("persistent") == DeliveryMode.persistent);
    assert(toDeliveryMode("nonpersistent") == DeliveryMode.nonPersistent);
    assert(toDeliveryMode("unknown") == DeliveryMode.direct); // default case

    assert(toString(DeliveryMode.direct) == "direct");
    assert(toString(DeliveryMode.persistent) == "persistent");
    assert(toString(DeliveryMode.nonPersistent) == "nonPersistent");

    assert(toDeliveryMode(["direct", "unknown", "persistent"]) == [DeliveryMode.direct, DeliveryMode.direct, DeliveryMode.persistent]);
    assert(toString([DeliveryMode.persistent, DeliveryMode.nonPersistent]) == ["persistent", "nonPersistent"]);
}

enum MessageStatus {
    pending,
    delivered,
    acknowledged,
    rejected,
    expired,
    deadLettered
}

MessageStatus toMessageStatus(string value) {
    mixin(toEnumSwitch("MessageStatus", "pending"));
}
MessageStatus[] toMessageStatus(string[] values) {
    return values.map!(v => toMessageStatus(v)).array;
}
string toString(MessageStatus status) {
    return status.to!string;
}
string[] toString(MessageStatus[] statuses) {
    return statuses.map!(s => toString(s)).array;
}
///
unittest {
    mixin(ShowTest!("MessageStatus Enum Conversion"));

    assert(toMessageStatus("pending") == MessageStatus.pending);
    assert(toMessageStatus("delivered") == MessageStatus.delivered);
    assert(toMessageStatus("acknowledged") == MessageStatus.acknowledged);
    assert(toMessageStatus("rejected") == MessageStatus.rejected);
    assert(toMessageStatus("expired") == MessageStatus.expired);
    assert(toMessageStatus("deadlettered") == MessageStatus.deadLettered);
    assert(toMessageStatus("unknown") == MessageStatus.pending); // default case

    assert(toString(MessageStatus.pending) == "pending");
    assert(toString(MessageStatus.delivered) == "delivered");
    assert(toString(MessageStatus.acknowledged) == "acknowledged");
    assert(toString(MessageStatus.rejected) == "rejected");
    assert(toString(MessageStatus.expired) == "expired");
    assert(toString(MessageStatus.deadLettered) == "deadLettered");

    assert(toMessageStatus(["pending", "unknown", "delivered"]) == [MessageStatus.pending, MessageStatus.pending, MessageStatus.delivered]);
    assert(toString([MessageStatus.acknowledged, MessageStatus.rejected]) == ["acknowledged", "rejected"]);
}

enum MessagePriority {
    low,
    normal,
    high,
    urgent
}

MessagePriority toMessagePriority(string value) {
    mixin(toEnumSwitch("MessagePriority", "normal"));
}
MessagePriority[] toMessagePriority(string[] values) {
    return values.map!(v => toMessagePriority(v)).array;
}
string toString(MessagePriority priority) {
    return priority.to!string;
}
string[] toString(MessagePriority[] priorities) {
    return priorities.map!(p => toString(p)).array;
}
///
unittest {
    mixin(ShowTest!("MessagePriority Enum Conversion"));

    assert(toMessagePriority("low") == MessagePriority.low);
    assert(toMessagePriority("normal") == MessagePriority.normal);
    assert(toMessagePriority("high") == MessagePriority.high);  
    assert(toMessagePriority("urgent") == MessagePriority.urgent);
    assert(toMessagePriority("unknown") == MessagePriority.normal); // default case

    assert(toString(MessagePriority.low) == "low");
    assert(toString(MessagePriority.normal) == "normal");
    assert(toString(MessagePriority.high) == "high");   
    assert(toString(MessagePriority.urgent) == "urgent");

    assert(toMessagePriority(["low", "unknown", "high"]) == [MessagePriority.low, MessagePriority.normal, MessagePriority.high]);
    assert(toString([MessagePriority.normal, MessagePriority.urgent]) == ["normal", "urgent"]);
}

enum SchemaFormat {
    json,
    avro,
    protobuf,
    xml,
    asyncapi
}

SchemaFormat toSchemaFormat(string format) {
    mixin(toEnumSwitch("SchemaFormat", "json"));
}
SchemaFormat[] toSchemaFormat(string[] formats) {
    return formats.map!(f => toSchemaFormat(f)).array;
}
string toString(SchemaFormat format) {
    return format.to!string;
}
string[] toString(SchemaFormat[] formats) {
    return formats.map!(f => toString(f)).array;
}
///
unittest {
    mixin(ShowTest!("SchemaFormat Enum Conversion"));

    assert(toSchemaFormat("json") == SchemaFormat.json);
    assert(toSchemaFormat("avro") == SchemaFormat.avro);
    assert(toSchemaFormat("protobuf") == SchemaFormat.protobuf);
    assert(toSchemaFormat("xml") == SchemaFormat.xml);
    assert(toSchemaFormat("asyncapi") == SchemaFormat.asyncapi);
    assert(toSchemaFormat("unknown") == SchemaFormat.json); // default case

    assert(toString(SchemaFormat.json) == "json");
    assert(toString(SchemaFormat.avro) == "avro");
    assert(toString(SchemaFormat.protobuf) == "protobuf");
    assert(toString(SchemaFormat.xml) == "xml");
    assert(toString(SchemaFormat.asyncapi) == "asyncapi");

    assert(toSchemaFormat(["json", "unknown", "xml"]) == [SchemaFormat.json, SchemaFormat.json, SchemaFormat.xml]);
    assert(toString([SchemaFormat.avro, SchemaFormat.protobuf]) == ["avro", "protobuf"]);
}

enum SchemaStatus : string {
    draft = "draft",
    active = "active",
    deprecated_ = "deprecated",
    retired = "retired"
}

SchemaStatus toSchemaStatus(string value) {
   switch(value.toLower) {
        case "draft": return SchemaStatus.draft;
        case "active": return SchemaStatus.active;
        case "deprecated": return SchemaStatus.deprecated_;
        case "retired": return SchemaStatus.retired;
        default: return SchemaStatus.draft; // default to draft if unknown
    }
}
SchemaStatus[] toSchemaStatus(string[] values) {
    return values.map!(v => toSchemaStatus(v)).array;
}
string toString(SchemaStatus status) {
    return cast(string)status;
}
string[] toString(SchemaStatus[] statuses) {
    return statuses.map!(s => toString(s)).array;
}
///
unittest {
    mixin(ShowTest!("SchemaStatus Enum Conversion"));

    assert(toSchemaStatus("draft") == SchemaStatus.draft);
    assert(toSchemaStatus("active") == SchemaStatus.active);
    assert(toSchemaStatus("deprecated") == SchemaStatus.deprecated_);
    assert(toSchemaStatus("retired") == SchemaStatus.retired);
    assert(toSchemaStatus("unknown") == SchemaStatus.draft); // default case

    assert(toString(SchemaStatus.draft) == "draft");
    assert(toString(SchemaStatus.active) == "active");  
    assert(toString(SchemaStatus.deprecated_) == "deprecated");
    assert(toString(SchemaStatus.retired) == "retired");

    assert(toSchemaStatus(["draft", "unknown", "active"]) == [SchemaStatus.draft, SchemaStatus.draft, SchemaStatus.active]);
    assert(toString([SchemaStatus.deprecated_, SchemaStatus.retired]) == ["deprecated", "retired"]);
}

enum EventApplicationStatus {
    registered,
    active,
    suspended,
    deregistered
}

EventApplicationStatus toEventApplicationStatus(string value) {
    mixin(toEnumSwitch("EventApplicationStatus", "registered"));
}
EventApplicationStatus[] toEventApplicationStatus(string[] values) {
    return values.map!(v => toEventApplicationStatus(v)).array;
}
string toString(EventApplicationStatus status) {
    return status.to!string;
}
string[] toString(EventApplicationStatus[] statuses) {
    return statuses.map!(s => toString(s)).array;
}
///
unittest {
    mixin(ShowTest!("EventApplicationStatus Enum Conversion"));

    assert(toEventApplicationStatus("registered") == EventApplicationStatus.registered);
    assert(toEventApplicationStatus("active") == EventApplicationStatus.active);
    assert(toEventApplicationStatus("suspended") == EventApplicationStatus.suspended);
    assert(toEventApplicationStatus("deregistered") == EventApplicationStatus.deregistered);    
    assert(toEventApplicationStatus("unknown") == EventApplicationStatus.registered); // default case

    assert(toString(EventApplicationStatus.registered) == "registered");
    assert(toString(EventApplicationStatus.active) == "active");
    assert(toString(EventApplicationStatus.suspended) == "suspended");
    assert(toString(EventApplicationStatus.deregistered) == "deregistered");

    assert(toEventApplicationStatus(["active", "unknown", "suspended"]) == [EventApplicationStatus.active, EventApplicationStatus.registered, EventApplicationStatus.suspended]);
    assert(toString([EventApplicationStatus.active, EventApplicationStatus.deregistered]) == ["active", "deregistered"]);
}

enum EventApplicationType {
    publisher,
    subscriber,
    both
}

EventApplicationType toEventApplicationType(string value) {
    mixin(toEnumSwitch("EventApplicationType", "both"));
}
EventApplicationType[] toEventApplicationType(string[] values) {
    return values.map!(v => toEventApplicationType(v)).array;
}
string toString(EventApplicationType type) {
    return type.to!string;
}
string[] toString(EventApplicationType[] types) {
    return types.map!(t => toString(t)).array;
}
///
unittest {
    mixin(ShowTest!("EventApplicationType Enum Conversion"));
    
    assert(toEventApplicationType("publisher") == EventApplicationType.publisher);
    assert(toEventApplicationType("subscriber") == EventApplicationType.subscriber);
    assert(toEventApplicationType("both") == EventApplicationType.both);
    assert(toEventApplicationType("unknown") == EventApplicationType.both); // default case

    assert(toString(EventApplicationType.publisher) == "publisher");
    assert(toString(EventApplicationType.subscriber) == "subscriber");
    assert(toString(EventApplicationType.both) == "both");

    assert(toEventApplicationType(["publisher", "unknown", "subscriber"]) == [EventApplicationType.publisher, EventApplicationType.both, EventApplicationType.subscriber]);
    assert(toString([EventApplicationType.subscriber, EventApplicationType.both]) == ["subscriber", "both"]);
}

enum BridgeStatus {
    provisioning,
    active,
    inactive,
    degraded,
    failed
}

BridgeStatus toBridgeStatus(string value) {
    mixin(toEnumSwitch("BridgeStatus", "failed"));
}
BridgeStatus[] toBridgeStatus(string[] values) {
    return values.map!(v => toBridgeStatus(v)).array;
}
string toString(BridgeStatus status) {    return status.to!string;
}
string[] toString(BridgeStatus[] statuses) {    return statuses.map!(s => toString(s)).array;
}
///
unittest {
    mixin(ShowTest!("BridgeStatus Enum Conversion"));

    assert(toBridgeStatus("provisioning") == BridgeStatus.provisioning);
    assert(toBridgeStatus("active") == BridgeStatus.active);
    assert(toBridgeStatus("inactive") == BridgeStatus.inactive);    
    assert(toBridgeStatus("degraded") == BridgeStatus.degraded);
    assert(toBridgeStatus("failed") == BridgeStatus.failed);

    assert(toBridgeStatus("unknown") == BridgeStatus.failed); // default case

    assert(toString(BridgeStatus.provisioning) == "provisioning");
    assert(toString(BridgeStatus.active) == "active");
    assert(toString(BridgeStatus.inactive) == "inactive");
    assert(toString(BridgeStatus.degraded) == "degraded");  
    assert(toString(BridgeStatus.failed) == "failed");

    assert(toBridgeStatus(["active", "unknown", "degraded"]) == [BridgeStatus.active, BridgeStatus.failed, BridgeStatus.degraded]);
    assert(toString([BridgeStatus.inactive, BridgeStatus.failed]) == ["inactive", "failed"]);
}

enum BridgeType {
    mesh,
    vpn,
    rest,
    kafka,
    jms
}

BridgeType toBridgeType(string value) {
    mixin(toEnumSwitch("BridgeType", "mesh"));
}
BridgeType[] toBridgeType(string[] values) {
    return values.map!(v => toBridgeType(v)).array;
}
string toString(BridgeType type) {
    return type.to!string;
}
string[] toString(BridgeType[] types) {
    return types.map!(t => toString(t)).array;
}
///
unittest {
    mixin(ShowTest!("BridgeType Enum Conversion"));

    assert(toBridgeType("mesh") == BridgeType.mesh);
    assert(toBridgeType("vpn") == BridgeType.vpn);
    assert(toBridgeType("rest") == BridgeType.rest);
    assert(toBridgeType("kafka") == BridgeType.kafka);
    assert(toBridgeType("jms") == BridgeType.jms);
    assert(toBridgeType("unknown") == BridgeType.mesh); // default case

    assert(toString(BridgeType.mesh) == "mesh");
    assert(toString(BridgeType.vpn) == "vpn");
    assert(toString(BridgeType.rest) == "rest");
    assert(toString(BridgeType.kafka) == "kafka");
    assert(toString(BridgeType.jms) == "jms");

    assert(toBridgeType(["vpn", "unknown", "rest"]) == [BridgeType.vpn, BridgeType.mesh, BridgeType.rest]);
    assert(toString([BridgeType.kafka, BridgeType.jms]) == ["kafka", "jms"]);
}

enum ProtocolType {
    smf,
    mqtt,
    amqp,
    rest,
    jms,
    websocket
}

ProtocolType toProtocolType(string value) {
    mixin(toEnumSwitch("ProtocolType", "mqtt"));
}
ProtocolType[] toProtocolType(string[] values) {
    return values.map!(v => toProtocolType(v)).array;
}
string toString(ProtocolType type) {
    return type.to!string;
}
string[] toString(ProtocolType[] types) {
    return types.map!(t => toString(t)).array;
}
///
unittest {
    mixin(ShowTest!("ProtocolType Enum Conversion"));

    assert(toProtocolType("smf") == ProtocolType.smf);
    assert(toProtocolType("mqtt") == ProtocolType.mqtt);
    assert(toProtocolType("amqp") == ProtocolType.amqp);
    assert(toProtocolType("rest") == ProtocolType.rest);
    assert(toProtocolType("jms") == ProtocolType.jms);      
    assert(toProtocolType("websocket") == ProtocolType.websocket);
    assert(toProtocolType("unknown") == ProtocolType.mqtt); // default case

    assert(toString(ProtocolType.smf) == "smf");
    assert(toString(ProtocolType.mqtt) == "mqtt");  
    assert(toString(ProtocolType.amqp) == "amqp");
    assert(toString(ProtocolType.rest) == "rest");
    assert(toString(ProtocolType.jms) == "jms");
    assert(toString(ProtocolType.websocket) == "websocket");

    assert(toProtocolType(["mqtt", "unknown", "rest"]) == [ProtocolType.mqtt, ProtocolType.mqtt, ProtocolType.rest]);
    assert(toString([ProtocolType.amqp, ProtocolType.websocket]) == ["amqp", "websocket"]);
}
