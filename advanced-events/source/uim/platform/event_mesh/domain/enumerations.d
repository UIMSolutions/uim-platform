/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.enumerations;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

enum BrokerServiceStatus {
  ///  The service is being provisioned and is not yet available for use.
  provisioning,
  ///  The service is currently running and available for use.
  running,
  ///  The service is currently stopped and not available for use.
  stopped,
  ///  The service is being updated and may not be fully available.
  updating,
  ///  The service is degraded and may have limited functionality.
  degraded,
  ///  The service has failed and is not operational.
  failed,
  ///  The service is being decommissioned and will no longer be available.
  decommissioned
}

BrokerServiceStatus toBrokerServiceStatus(string value) {
  mixin(EnumSwitch("BrokerServiceStatus", "failed"));
}

BrokerServiceStatus[] toBrokerServiceStatuses(string[] values)
  => values.map!toBrokerServiceStatus.array;

string toString(BrokerServiceStatus status)
  => status.to!string;

string[] toStrings(BrokerServiceStatus[] statuses)
  => statuses.map!toString.array;
/// 
unittest {
  mixin(ShowTest!("BrokerServiceStatus Enum Conversion"));

  assert("provisioning".toBrokerServiceStatus == BrokerServiceStatus.provisioning);
  assert("running".toBrokerServiceStatus == BrokerServiceStatus.running);
  assert("stopped".toBrokerServiceStatus == BrokerServiceStatus.stopped);
  assert("updating".toBrokerServiceStatus == BrokerServiceStatus.updating);
  assert("degraded".toBrokerServiceStatus == BrokerServiceStatus.degraded);
  assert("failed".toBrokerServiceStatus == BrokerServiceStatus.failed);
  assert("decommissioned".toBrokerServiceStatus == BrokerServiceStatus.decommissioned);
  assert("unknown".toBrokerServiceStatus == BrokerServiceStatus.failed); // default case

  assert(BrokerServiceStatus.provisioning.toString == "provisioning");
  assert(BrokerServiceStatus.running.toString == "running");
  assert(BrokerServiceStatus.stopped.toString == "stopped");
  assert(BrokerServiceStatus.updating.toString == "updating");
  assert(BrokerServiceStatus.degraded.toString == "degraded");
  assert(BrokerServiceStatus.failed.toString == "failed");
  assert(BrokerServiceStatus.decommissioned.toString == "decommissioned");

  assert(["running", "unknown", "provisioning"].toBrokerServiceStatuses == [
      BrokerServiceStatus.running, BrokerServiceStatus.failed,
      BrokerServiceStatus.provisioning
    ]);
  assert([BrokerServiceStatus.stopped, BrokerServiceStatus.degraded].toStrings == [
      "stopped", "degraded"
    ]);
}

enum BrokerServiceType {
  enterprise,
  developer,
  standard,
  premium
}

BrokerServiceType toBrokerServiceType(string value) {
  mixin(EnumSwitch("BrokerServiceType", "standard"));
}

BrokerServiceType[] toBrokerServiceTypes(string[] values)
  => values.map!toBrokerServiceType.array;

string toString(BrokerServiceType type)
  => type.to!string;

string[] toStrings(BrokerServiceType[] types)
  => types.map!toString.array;
///
unittest {
  mixin(ShowTest!("BrokerServiceType Enum Conversion"));

  assert("enterprise".toBrokerServiceType == BrokerServiceType.enterprise);
  assert("developer".toBrokerServiceType == BrokerServiceType.developer);
  assert("standard".toBrokerServiceType == BrokerServiceType.standard);
  assert("premium".toBrokerServiceType == BrokerServiceType.premium);
  assert("unknown".toBrokerServiceType == BrokerServiceType.standard); // default case

  assert(BrokerServiceType.enterprise.toString == "enterprise");
  assert(BrokerServiceType.developer.toString == "developer");
  assert(BrokerServiceType.standard.toString == "standard");
  assert(BrokerServiceType.premium.toString == "premium");

  assert(["developer", "unknown", "premium"].toBrokerServiceTypes == [
      BrokerServiceType.developer, BrokerServiceType.standard,
      BrokerServiceType.premium
    ]);
  assert([BrokerServiceType.enterprise, BrokerServiceType.standard].toStrings == [
      "enterprise", "standard"
    ]);
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
  mixin(EnumSwitch("BrokerServiceClass", "standardKilo"));
}

BrokerServiceClass[] toBrokerServiceClasses(string[] values)
  => values.map!toBrokerServiceClass.array;

string toString(BrokerServiceClass serviceClass)
  => serviceClass.to!string;

string[] toStrings(BrokerServiceClass[] serviceClasses)
  => serviceClasses.map!toString.array;
///
unittest {
  mixin(ShowTest!("BrokerServiceClass Enum Conversion"));

  assert("enterprisekilo".toBrokerServiceClass == BrokerServiceClass.enterpriseKilo);
  assert("enterprisemega".toBrokerServiceClass == BrokerServiceClass.enterpriseMega);
  assert("enterprisegiga".toBrokerServiceClass == BrokerServiceClass.enterpriseGiga);
  assert("developerkilo".toBrokerServiceClass == BrokerServiceClass.developerKilo);
  assert("standardkilo".toBrokerServiceClass == BrokerServiceClass.standardKilo);
  assert("standardmega".toBrokerServiceClass == BrokerServiceClass.standardMega);

  assert("".toBrokerServiceClass == BrokerServiceClass.standardKilo); // default
  assert("unknown".toBrokerServiceClass == BrokerServiceClass.standardKilo); // default

  assert(BrokerServiceClass.enterpriseKilo.toString == "enterpriseKilo");
  assert(BrokerServiceClass.enterpriseMega.toString == "enterpriseMega");
  assert(BrokerServiceClass.enterpriseGiga.toString == "enterpriseGiga");
  assert(BrokerServiceClass.developerKilo.toString == "developerKilo");
  assert(BrokerServiceClass.standardKilo.toString == "standardKilo");
  assert(BrokerServiceClass.standardMega.toString == "standardMega");

  assert(["enterprisekilo", "unknown", "standardmega"].toBrokerServiceClasses == [
      BrokerServiceClass.enterpriseKilo, BrokerServiceClass.standardKilo,
      BrokerServiceClass.standardMega
    ]);
  assert([
      BrokerServiceClass.developerKilo, BrokerServiceClass.enterpriseGiga
    ].toStrings == ["developerKilo", "enterpriseGiga"]);
}

enum CloudProvider {
  aws,
  azure,
  gcp,
  sap,
  onPremise
}

CloudProvider toCloudProvider(string value) {
  mixin(EnumSwitch("CloudProvider", "sap"));
}

CloudProvider[] toCloudProviders(string[] providers)
  => providers.map!toCloudProvider.array;

string toString(CloudProvider provider)
  => provider.to!string;

string[] toStrings(CloudProvider[] providers)
  => providers.map!toString.array;
///
unittest {
  mixin(ShowTest!("CloudProvider Enum Conversion"));

  assert("aws".toCloudProvider == CloudProvider.aws);
  assert("azure".toCloudProvider == CloudProvider.azure);
  assert("gcp".toCloudProvider == CloudProvider.gcp);
  assert("sap".toCloudProvider == CloudProvider.sap);
  assert("onpremise".toCloudProvider == CloudProvider.onPremise);

  assert("".toCloudProvider == CloudProvider.sap); // default case
  assert("unknown".toCloudProvider == CloudProvider.sap); // default case

  assert(CloudProvider.aws.toString == "aws");
  assert(CloudProvider.azure.toString == "azure");
  assert(CloudProvider.gcp.toString == "gcp");
  assert(CloudProvider.sap.toString == "sap");
  assert(CloudProvider.onPremise.toString == "onPremise");

  assert(["aws", "unknown", "gcp"].toCloudProviders == [
      CloudProvider.aws, CloudProvider.sap, CloudProvider.gcp
    ]);
  assert([CloudProvider.azure, CloudProvider.onPremise].toStrings == [
      "azure", "onPremise"
    ]);
}

enum QueueAccessType {
  exclusive,
  nonExclusive
}

QueueAccessType toQueueAccessType(string value) {
  mixin(EnumSwitch("QueueAccessType", "exclusive"));
}

QueueAccessType[] toQueueAccessTypes(string[] values)
  => values.map!toQueueAccessType.array;

string toString(QueueAccessType accessType)
  => accessType.to!string;

string[] toStrings(QueueAccessType[] accessTypes)
  => accessTypes.map!toString.array;
///
unittest {
  mixin(ShowTest!("QueueAccessType Enum Conversion"));

  assert("exclusive".toQueueAccessType == QueueAccessType.exclusive);
  assert("nonexclusive".toQueueAccessType == QueueAccessType.nonExclusive);

  assert("".toQueueAccessType == QueueAccessType.exclusive); // default case
  assert("unknown".toQueueAccessType == QueueAccessType.exclusive); // default case

  assert(["exclusive", "unknown", "nonexclusive"].toQueueAccessTypes == [
      QueueAccessType.exclusive, QueueAccessType.exclusive,
      QueueAccessType.nonExclusive
    ]);

  assert(QueueAccessType.exclusive.toString == "exclusive");
  assert(QueueAccessType.nonExclusive.toString == "nonExclusive");

  assert(["exclusive", "unknown", "nonexclusive"].toQueueAccessTypes == [
      QueueAccessType.exclusive, QueueAccessType.exclusive,
      QueueAccessType.nonExclusive
    ]);
  assert([QueueAccessType.exclusive, QueueAccessType.nonExclusive].toStrings == [
      "exclusive", "nonExclusive"
    ]);
}

enum QueueStatus {
  active,
  inactive,
  shuttingDown,
  pendingDelete
}

QueueStatus toQueueStatus(string value) {
  mixin(EnumSwitch("QueueStatus", "inactive"));
}

QueueStatus[] toQueueStatuses(string[] values)
  => values.map!toQueueStatus.array;

string toString(QueueStatus status)
  => status.to!string;

string[] toStrings(QueueStatus[] statuses)
  => statuses.map!toString.array;
///
unittest {
  mixin(ShowTest!("QueueStatus Enum Conversion"));

  assert("active".toQueueStatus == QueueStatus.active);
  assert("inactive".toQueueStatus == QueueStatus.inactive);
  assert("shuttingdown".toQueueStatus == QueueStatus.shuttingDown);
  assert("pendingdelete".toQueueStatus == QueueStatus.pendingDelete);
  assert("unknown".toQueueStatus == QueueStatus.inactive); // default case

  assert(QueueStatus.active.toString == "active");
  assert(QueueStatus.inactive.toString == "inactive");
  assert(QueueStatus.shuttingDown.toString == "shuttingDown");
  assert(QueueStatus.pendingDelete.toString == "pendingDelete");

  assert(["active", "unknown", "shuttingdown"].toQueueStatuses == [
      QueueStatus.active, QueueStatus.inactive, QueueStatus.shuttingDown
    ]);
  assert([QueueStatus.inactive, QueueStatus.pendingDelete].toStrings == [
      "inactive", "pendingDelete"
    ]);
}

enum QueueType {
  durable,
  nonDurable,
  temporary
}

QueueType toQueueType(string value) {
  mixin(EnumSwitch("QueueType", "durable"));
}

QueueType[] toQueueTypes(string[] values)
  => values.map!toQueueType.array;

string toString(QueueType type)
  => type.to!string;

string[] toStrings(QueueType[] types)
  => types.map!toString.array;
///
unittest {
  mixin(ShowTest!("QueueType Enum Conversion"));

  assert("durable".toQueueType == QueueType.durable);
  assert("nondurable".toQueueType == QueueType.nonDurable);
  assert("temporary".toQueueType == QueueType.temporary);
  assert("unknown".toQueueType == QueueType.durable); // default case

  assert(QueueType.durable.toString == "durable");
  assert(QueueType.nonDurable.toString == "nonDurable");
  assert(QueueType.temporary.toString == "temporary");

  assert(["durable", "unknown", "temporary"].toQueueTypes == [
      QueueType.durable, QueueType.durable, QueueType.temporary
    ]);
  assert([QueueType.nonDurable, QueueType.temporary].toStrings == [
      "nonDurable", "temporary"
    ]);
}

enum TopicStatus {
  active,
  inactive,
  pendingDelete
}

TopicStatus toTopicStatus(string value) {
  mixin(EnumSwitch("TopicStatus", "inactive"));
}

TopicStatus[] toTopicStatuses(string[] values)

  => values.map!toTopicStatus.array;

string toString(TopicStatus status)
  => status.to!string;

string[] toStrings(TopicStatus[] statuses)
  => statuses.map!toString.array;
///
unittest {
  mixin(ShowTest!("TopicStatus Enum Conversion"));

  assert("active".toTopicStatus == TopicStatus.active);
  assert("inactive".toTopicStatus == TopicStatus.inactive);
  assert("pendingdelete".toTopicStatus == TopicStatus.pendingDelete);
  assert("unknown".toTopicStatus == TopicStatus.inactive); // default case

  assert(TopicStatus.active.toString == "active");
  assert(TopicStatus.inactive.toString == "inactive");
  assert(TopicStatus.pendingDelete.toString == "pendingDelete");

  assert(["active", "unknown", "pendingdelete"].toTopicStatuses == [
      TopicStatus.active, TopicStatus.inactive,
      TopicStatus.pendingDelete
    ]);
  assert([TopicStatus.inactive, TopicStatus.pendingDelete].toStrings == [
      "inactive", "pendingDelete"
    ]);
}

enum SubscriptionStatus {
  active,
  suspended,
  pendingDelete
}

SubscriptionStatus toSubscriptionStatus(string value) {
  mixin(EnumSwitch("SubscriptionStatus", "suspended"));
}

SubscriptionStatus[] toSubscriptionStatuses(string[] values)

  => values.map!toSubscriptionStatus.array;

string toString(SubscriptionStatus status)
  => status.to!string;

string[] toStrings(SubscriptionStatus[] statuses)
  => statuses.map!toString.array;
///
unittest {
  mixin(ShowTest!("SubscriptionStatus Enum Conversion"));

  assert("active".toSubscriptionStatus == SubscriptionStatus.active);
  assert("suspended".toSubscriptionStatus == SubscriptionStatus.suspended);
  assert("pendingdelete".toSubscriptionStatus == SubscriptionStatus.pendingDelete);
  assert("unknown".toSubscriptionStatus == SubscriptionStatus.suspended); // default case    

  assert(SubscriptionStatus.active.toString == "active");
  assert(SubscriptionStatus.suspended.toString == "suspended");
  assert(SubscriptionStatus.pendingDelete.toString == "pendingDelete");

  assert(["active", "unknown", "pendingdelete"].toSubscriptionStatuses == [
      SubscriptionStatus.active, SubscriptionStatus.suspended,
      SubscriptionStatus.pendingDelete
    ]);
  assert([
      SubscriptionStatus.suspended, SubscriptionStatus.pendingDelete
    ].toStrings == ["suspended", "pendingDelete"]);
}

enum SubscriptionType {
  direct,
  queueBased,
  topicEndpoint
}

SubscriptionType toSubscriptionType(string value) {
  mixin(EnumSwitch("SubscriptionType", "direct"));
}

SubscriptionType[] toSubscriptionTypes(string[] values)
  => values.map!toSubscriptionType.array;

string toString(SubscriptionType type)
  => type.to!string;

string[] toStrings(SubscriptionType[] types)
  => types.map!toString.array;
///
unittest {
  mixin(ShowTest!("SubscriptionType Enum Conversion"));

  assert("direct".toSubscriptionType == SubscriptionType.direct);
  assert("queuebased".toSubscriptionType == SubscriptionType.queueBased);
  assert("topicendpoint".toSubscriptionType == SubscriptionType.topicEndpoint);
  assert("unknown".toSubscriptionType == SubscriptionType.direct); // default case

  assert(SubscriptionType.direct.toString == "direct");
  assert(SubscriptionType.queueBased.toString == "queueBased");
  assert(SubscriptionType.topicEndpoint.toString == "topicEndpoint");

  assert(["direct", "unknown", "queuebased"].toSubscriptionTypes == [
      SubscriptionType.direct, SubscriptionType.direct,
      SubscriptionType.queueBased
    ]);
  assert([
      SubscriptionType.queueBased, SubscriptionType.topicEndpoint
    ].toStrings == ["queueBased", "topicEndpoint"]);
}

enum DeliveryMode {
  direct,
  persistent,
  nonPersistent
}

DeliveryMode toDeliveryMode(string value) {
  mixin(EnumSwitch("DeliveryMode", "direct"));
}

DeliveryMode[] toDeliveryModes(string[] values)
  => values.map!toDeliveryMode.array;

string toString(DeliveryMode mode)
  => mode.to!string;

string[] toStrings(DeliveryMode[] modes)
  => modes.map!toString.array;
///
unittest {
  mixin(ShowTest!("DeliveryMode Enum Conversion"));

  assert("direct".toDeliveryMode == DeliveryMode.direct);
  assert("persistent".toDeliveryMode == DeliveryMode.persistent);
  assert("nonPersistent".toDeliveryMode == DeliveryMode.nonPersistent);
  assert("unknown".toDeliveryMode == DeliveryMode.direct); // default case

  assert(DeliveryMode.direct.toString == "direct");
  assert(DeliveryMode.persistent.toString == "persistent");
  assert(DeliveryMode.nonPersistent.toString == "nonPersistent");

  assert(["direct", "unknown", "persistent"].toDeliveryModes == [
      DeliveryMode.direct, DeliveryMode.direct,
      DeliveryMode.persistent
    ]);
  assert([DeliveryMode.persistent, DeliveryMode.nonPersistent].toStrings == [
      "persistent", "nonPersistent"
    ]);
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
  mixin(EnumSwitch("MessageStatus", "pending"));
}

MessageStatus[] toMessageStatuses(string[] values)
  => values.map!toMessageStatus.array;

string toString(MessageStatus status)
  => status.to!string;

string[] toStrings(MessageStatus[] statuses)
  => statuses.map!toString.array;
///
unittest {
  mixin(ShowTest!("MessageStatus Enum Conversion"));

  assert("pending".toMessageStatus == MessageStatus.pending);
  assert("delivered".toMessageStatus == MessageStatus.delivered);
  assert("acknowledged".toMessageStatus == MessageStatus.acknowledged);
  assert("rejected".toMessageStatus == MessageStatus.rejected);
  assert("expired".toMessageStatus == MessageStatus.expired);
  assert("deadlettered".toMessageStatus == MessageStatus.deadLettered);
  assert("unknown".toMessageStatus == MessageStatus.pending); // default case

  assert(MessageStatus.pending.toString == "pending");
  assert(MessageStatus.delivered.toString == "delivered");
  assert(MessageStatus.acknowledged.toString == "acknowledged");
  assert(MessageStatus.rejected.toString == "rejected");
  assert(MessageStatus.expired.toString == "expired");
  assert(MessageStatus.deadLettered.toString == "deadLettered");

  assert(["pending", "unknown", "delivered"].toMessageStatuses == [
      MessageStatus.pending, MessageStatus.pending,
      MessageStatus.delivered
    ]);
  assert([MessageStatus.acknowledged, MessageStatus.rejected].toStrings == [
      "acknowledged", "rejected"
    ]);
}

enum MessagePriority {
  low,
  normal,
  high,
  urgent
}

MessagePriority toMessagePriority(string value) {
  mixin(EnumSwitch("MessagePriority", "normal"));
}

MessagePriority[] toMessagePriorities(string[] values)
  => values.map!toMessagePriority.array;

string toString(MessagePriority priority)
  => priority.to!string;

string[] toStrings(MessagePriority[] priorities)
  => priorities.map!toString.array;

///
unittest {
  mixin(ShowTest!("MessagePriority Enum Conversion"));

  assert("low".toMessagePriority == MessagePriority.low);
  assert("normal".toMessagePriority == MessagePriority.normal);
  assert("high".toMessagePriority == MessagePriority.high);
  assert("urgent".toMessagePriority == MessagePriority.urgent);
  assert("unknown".toMessagePriority == MessagePriority.normal); // default case

  assert(MessagePriority.low.toString == "low");
  assert(MessagePriority.normal.toString == "normal");
  assert(MessagePriority.high.toString == "high");
  assert(MessagePriority.urgent.toString == "urgent");

  assert(["low", "unknown", "high"].toMessagePriorities == [
      MessagePriority.low, MessagePriority.normal,
      MessagePriority.high
    ]);
  assert([MessagePriority.normal, MessagePriority.urgent].toStrings == [
      "normal", "urgent"
    ]);
}

enum SchemaFormat {
  json,
  avro,
  protobuf,
  xml,
  asyncapi
}

SchemaFormat toSchemaFormat(string value) {
  mixin(EnumSwitch("SchemaFormat", "json"));
}

SchemaFormat[] toSchemaFormats(string[] formats) {
  return formats.map!toSchemaFormat.array;
}

string toString(SchemaFormat format) {
  return format.to!string;
}

string[] toStrings(SchemaFormat[] formats) {
  return formats.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("SchemaFormat Enum Conversion"));

  assert("json".toSchemaFormat == SchemaFormat.json);
  assert("avro".toSchemaFormat == SchemaFormat.avro);
  assert("protobuf".toSchemaFormat == SchemaFormat.protobuf);
  assert("xml".toSchemaFormat == SchemaFormat.xml);
  assert("asyncapi".toSchemaFormat == SchemaFormat.asyncapi);
  assert("unknown".toSchemaFormat == SchemaFormat.json); // default case

  assert(SchemaFormat.json.toString == "json");
  assert(SchemaFormat.avro.toString == "avro");
  assert(SchemaFormat.protobuf.toString == "protobuf");
  assert(SchemaFormat.xml.toString == "xml");
  assert(SchemaFormat.asyncapi.toString == "asyncapi");

  assert(["json", "unknown", "xml"].toSchemaFormats == [
      SchemaFormat.json, SchemaFormat.json, SchemaFormat.xml
    ]);
  assert([SchemaFormat.avro, SchemaFormat.protobuf].toStrings == [
      "avro", "protobuf"
    ]);
}

enum SchemaStatus : string {
  draft = "draft",
  active = "active",
  deprecated_ = "deprecated",
  retired = "retired"
}

SchemaStatus toSchemaStatus(string value) {
  switch (value.toLower) {
  case "draft":
    return SchemaStatus.draft;
  case "active":
    return SchemaStatus.active;
  case "deprecated":
    return SchemaStatus.deprecated_;
  case "retired":
    return SchemaStatus.retired;
  default:
    return SchemaStatus.draft; // default to draft if unknown
  }
}

SchemaStatus[] toSchemaStatuses(string[] values) {
  return values.map!toSchemaStatus.array;
}

string toString(SchemaStatus status) {
  return cast(string)status;
}

string[] toStrings(SchemaStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("SchemaStatus Enum Conversion"));

  assert("draft".toSchemaStatus == SchemaStatus.draft);
  assert("active".toSchemaStatus == SchemaStatus.active);
  assert("deprecated".toSchemaStatus == SchemaStatus.deprecated_);
  assert("retired".toSchemaStatus == SchemaStatus.retired);

  assert("unknown".toSchemaStatus == SchemaStatus.draft); // default case
  assert("".toSchemaStatus == SchemaStatus.draft); // default case

  assert(SchemaStatus.draft.toString == "draft");
  assert(SchemaStatus.active.toString == "active");
  assert(SchemaStatus.deprecated_.toString == "deprecated");
  assert(SchemaStatus.retired.toString == "retired");

  assert(["draft", "unknown", "active"].toSchemaStatuses == [
      SchemaStatus.draft, SchemaStatus.draft, SchemaStatus.active
    ]);
  assert([SchemaStatus.deprecated_, SchemaStatus.retired].toStrings == [
      "deprecated", "retired"
    ]);
}

enum EventApplicationStatus {
  registered,
  active,
  suspended,
  deregistered
}

EventApplicationStatus toEventApplicationStatus(string value) {
  mixin(EnumSwitch("EventApplicationStatus", "registered"));
}

EventApplicationStatus[] toEventApplicationStatuses(string[] values) {
  return values.map!(v => toEventApplicationStatus(v)).array;
}

string toString(EventApplicationStatus status) {
  return status.to!string;
}

string[] toStrings(EventApplicationStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("EventApplicationStatus Enum Conversion"));

  assert("registered".toEventApplicationStatus == EventApplicationStatus.registered);
  assert("active".toEventApplicationStatus == EventApplicationStatus.active);
  assert("suspended".toEventApplicationStatus == EventApplicationStatus.suspended);
  assert(
    "deregistered".toEventApplicationStatus == EventApplicationStatus.deregistered);
  assert("unknown".toEventApplicationStatus == EventApplicationStatus.registered); // default case

  assert(EventApplicationStatus.registered.toString == "registered");
  assert(EventApplicationStatus.active.toString == "active");
  assert(EventApplicationStatus.suspended.toString == "suspended");
  assert(EventApplicationStatus.deregistered.toString == "deregistered");

  assert(["active", "unknown", "suspended"].toEventApplicationStatuses == [
      EventApplicationStatus.active,
      EventApplicationStatus.registered,
      EventApplicationStatus.suspended
    ]);
  assert([
      EventApplicationStatus.active,
      EventApplicationStatus.deregistered
    ].toStrings == ["active", "deregistered"]);
}

enum EventApplicationType {
  publisher,
  subscriber,
  both
}

EventApplicationType toEventApplicationType(string value) {
  mixin(EnumSwitch("EventApplicationType", "both"));
}

EventApplicationType[] toEventApplicationTypes(string[] values) {
  return values.map!toEventApplicationType.array;
}

string toString(EventApplicationType type) {
  return type.to!string;
}

string[] toStrings(EventApplicationType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("EventApplicationType Enum Conversion"));

  assert("publisher".toEventApplicationType == EventApplicationType.publisher);
  assert("subscriber".toEventApplicationType == EventApplicationType.subscriber);
  assert("both".toEventApplicationType == EventApplicationType.both);

  assert("".toEventApplicationType == EventApplicationType.both); // default case
  assert("unknown".toEventApplicationType == EventApplicationType.both); // default case

  assert(EventApplicationType.publisher.toString == "publisher");
  assert(EventApplicationType.subscriber.toString == "subscriber");
  assert(EventApplicationType.both.toString == "both");

  assert(["publisher", "unknown", "subscriber"].toEventApplicationTypes == [
      EventApplicationType.publisher, EventApplicationType.both,
      EventApplicationType.subscriber
    ]);
  assert([
      EventApplicationType.subscriber, EventApplicationType.both
    ].toStrings == [
      "subscriber", "both"
    ]);
}

enum BridgeStatus {
  provisioning,
  active,
  inactive,
  degraded,
  failed
}

BridgeStatus toBridgeStatus(string value) {
  mixin(EnumSwitch("BridgeStatus", "failed"));
}

BridgeStatus[] toBridgeStatuses(string[] values) {
  return values.map!toBridgeStatus.array;
}

string toString(BridgeStatus status) {
  return status.to!string;
}

string[] toStrings(BridgeStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("BridgeStatus Enum Conversion"));

  assert("provisioning".toBridgeStatus == BridgeStatus.provisioning);
  assert("active".toBridgeStatus == BridgeStatus.active);
  assert("inactive".toBridgeStatus == BridgeStatus.inactive);
  assert("degraded".toBridgeStatus == BridgeStatus.degraded);
  assert("failed".toBridgeStatus == BridgeStatus.failed);

  assert("".toBridgeStatus == BridgeStatus.failed); // default case
  assert("unknown".toBridgeStatus == BridgeStatus.failed); // default case

  assert(BridgeStatus.provisioning.toString == "provisioning");
  assert(BridgeStatus.active.toString == "active");
  assert(BridgeStatus.inactive.toString == "inactive");
  assert(BridgeStatus.degraded.toString == "degraded");
  assert(BridgeStatus.failed.toString == "failed");

  assert(["active", "unknown", "degraded"].toBridgeStatuses == [
      BridgeStatus.active, BridgeStatus.failed,
      BridgeStatus.degraded
    ]);
  assert([BridgeStatus.inactive, BridgeStatus.failed].toStrings == [
      "inactive", "failed"
    ]);
}

enum BridgeType {
  mesh,
  vpn,
  rest,
  kafka,
  jms
}

BridgeType toBridgeType(string value) {
  mixin(EnumSwitch("BridgeType", "mesh"));
}

BridgeType[] toBridgeTypes(string[] values) {
  return values.map!toBridgeType.array;
}

string toString(BridgeType type) {
  return type.to!string;
}

string[] toStrings(BridgeType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("BridgeType Enum Conversion"));

  assert("mesh".toBridgeType == BridgeType.mesh);
  assert("vpn".toBridgeType == BridgeType.vpn);
  assert("rest".toBridgeType == BridgeType.rest);
  assert("kafka".toBridgeType == BridgeType.kafka);
  assert("jms".toBridgeType == BridgeType.jms);
  assert("unknown".toBridgeType == BridgeType.mesh); // default case

  assert(BridgeType.mesh.toString == "mesh");
  assert(BridgeType.vpn.toString == "vpn");
  assert(BridgeType.rest.toString == "rest");
  assert(BridgeType.kafka.toString == "kafka");
  assert(BridgeType.jms.toString == "jms");

  assert(["vpn", "unknown", "rest"].toBridgeTypes == [
      BridgeType.vpn, BridgeType.mesh, BridgeType.rest
    ]);
  assert([BridgeType.kafka, BridgeType.jms].toStrings == [
      "kafka", "jms"
    ]);
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
  mixin(EnumSwitch("ProtocolType", "mqtt"));
}

ProtocolType[] toProtocolTypes(string[] values) {
  return values.map!toProtocolType.array;
}

string toString(ProtocolType type) {
  return type.to!string;
}

string[] toStrings(ProtocolType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ProtocolType Enum Conversion"));

  assert("smf".toProtocolType == ProtocolType.smf);
  assert("mqtt".toProtocolType == ProtocolType.mqtt);
  assert("amqp".toProtocolType == ProtocolType.amqp);
  assert("rest".toProtocolType == ProtocolType.rest);
  assert("jms".toProtocolType == ProtocolType.jms);
  assert("websocket".toProtocolType == ProtocolType.websocket);

  assert("unknown".toProtocolType == ProtocolType.mqtt); // default case
  assert("".toProtocolType == ProtocolType.mqtt); // default case

  assert(ProtocolType.smf.toString == "smf");
  assert(ProtocolType.mqtt.toString == "mqtt");
  assert(ProtocolType.amqp.toString == "amqp");
  assert(ProtocolType.rest.toString == "rest");
  assert(ProtocolType.jms.toString == "jms");
  assert(ProtocolType.websocket.toString == "websocket");

  assert(["mqtt", "unknown", "rest"].toProtocolTypes == [
      ProtocolType.mqtt, ProtocolType.mqtt, ProtocolType.rest
    ]);
  assert([ProtocolType.amqp, ProtocolType.websocket].toStrings == [
      "amqp", "websocket"
    ]);
}
