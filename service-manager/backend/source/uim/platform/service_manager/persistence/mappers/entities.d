/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity ↔ record mappers.
module uim.platform.service_manager.persistence.mappers.entities;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

// ── Platform ────────────────────────────────────────────────────────────────
Json platformToRecord(const Platform e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["description"] = e.description;
  d["type"] = cast(string) e.type;
  d["status"] = cast(string) e.status;
  d["region"] = e.region;
  d["subaccountId"] = e.subaccountId.value;
  d["brokerUrl"] = e.brokerUrl;
  d["credentials"] = e.credentials;
  return d;
}

Platform recordToPlatform(Json d) {
  Platform e;
  readAudit!(Platform, PlatformId)(e, d);
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.type = enumField(d, "type", PlatformType.other);
  e.status = enumField(d, "status", PlatformStatus.active);
  e.region = textField(d, "region");
  e.subaccountId = SubaccountId(textField(d, "subaccountId"));
  e.brokerUrl = textField(d, "brokerUrl");
  e.credentials = textField(d, "credentials");
  return e;
}

// ── ServiceBroker ───────────────────────────────────────────────────────────
Json brokerToRecord(const ServiceBroker e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["description"] = e.description;
  d["brokerUrl"] = e.brokerUrl;
  d["credentials"] = e.credentials;
  d["status"] = cast(string) e.status;
  d["lastCatalogFetch"] = e.lastCatalogFetch;
  d["catalogError"] = e.catalogError;
  return d;
}

ServiceBroker recordToBroker(Json d) {
  ServiceBroker e;
  readAudit!(ServiceBroker, ServiceBrokerId)(e, d);
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.brokerUrl = textField(d, "brokerUrl");
  e.credentials = textField(d, "credentials");
  e.status = enumField(d, "status", ServiceBrokerStatus.active);
  e.lastCatalogFetch = longField(d, "lastCatalogFetch");
  e.catalogError = textField(d, "catalogError");
  return e;
}

// ── ServiceOffering ─────────────────────────────────────────────────────────
Json offeringToRecord(const ServiceOffering e) {
  auto d = auditRecord(e);
  d["brokerId"] = e.brokerId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["catalogId"] = e.catalogId;
  d["catalogName"] = e.catalogName;
  d["status"] = cast(string) e.status;
  d["category"] = cast(string) e.category;
  d["bindable"] = e.bindable;
  d["instancesRetrievable"] = e.instancesRetrievable;
  d["bindingsRetrievable"] = e.bindingsRetrievable;
  d["planUpdateable"] = e.planUpdateable;
  d["metadata"] = e.metadata;
  d["tags"] = textsJson(e.tags);
  return d;
}

ServiceOffering recordToOffering(Json d) {
  ServiceOffering e;
  readAudit!(ServiceOffering, ServiceOfferingId)(e, d);
  e.brokerId = ServiceBrokerId(textField(d, "brokerId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.catalogId = textField(d, "catalogId");
  e.catalogName = textField(d, "catalogName");
  e.status = enumField(d, "status", ServiceOfferingStatus.available);
  e.category = enumField(d, "category", ServiceCategory.other);
  e.bindable = boolField(d, "bindable", true);
  e.instancesRetrievable = boolField(d, "instancesRetrievable");
  e.bindingsRetrievable = boolField(d, "bindingsRetrievable");
  e.planUpdateable = boolField(d, "planUpdateable", true);
  e.metadata = textField(d, "metadata");
  e.tags = textsField(d, "tags");
  return e;
}

// ── ServicePlan ─────────────────────────────────────────────────────────────
Json planToRecord(const ServicePlan e) {
  auto d = auditRecord(e);
  d["offeringId"] = e.offeringId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["catalogId"] = e.catalogId;
  d["catalogName"] = e.catalogName;
  d["pricing"] = cast(string) e.pricing;
  d["bindable"] = e.bindable;
  d["planUpdateable"] = e.planUpdateable;
  d["maxInstances"] = e.maxInstances;
  d["schemas"] = e.schemas;
  d["metadata"] = e.metadata;
  return d;
}

ServicePlan recordToPlan(Json d) {
  ServicePlan e;
  readAudit!(ServicePlan, ServicePlanId)(e, d);
  e.offeringId = ServiceOfferingId(textField(d, "offeringId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.catalogId = textField(d, "catalogId");
  e.catalogName = textField(d, "catalogName");
  e.pricing = enumField(d, "pricing", ServicePlanPricing.free);
  e.bindable = boolField(d, "bindable", true);
  e.planUpdateable = boolField(d, "planUpdateable", true);
  e.maxInstances = cast(int) longField(d, "maxInstances");
  e.schemas = textField(d, "schemas");
  e.metadata = textField(d, "metadata");
  return e;
}

// ── ServiceInstance ─────────────────────────────────────────────────────────
Json instanceToRecord(const ServiceInstance e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["planId"] = e.planId.value;
  d["offeringId"] = e.offeringId.value;
  d["platformId"] = e.platformId.value;
  d["status"] = cast(string) e.status;
  d["context"] = e.context;
  d["parameters"] = e.parameters;
  d["dashboardUrl"] = e.dashboardUrl;
  d["shared"] = e.shared_;
  d["usable"] = e.usable;
  d["lastOperationId"] = e.lastOperationId.value;
  return d;
}

ServiceInstance recordToInstance(Json d) {
  ServiceInstance e;
  readAudit!(ServiceInstance, ServiceInstanceId)(e, d);
  e.name = textField(d, "name");
  e.planId = ServicePlanId(textField(d, "planId"));
  e.offeringId = ServiceOfferingId(textField(d, "offeringId"));
  e.platformId = PlatformId(textField(d, "platformId"));
  e.status = enumField(d, "status", ServiceInstanceStatus.creating);
  e.context = textField(d, "context");
  e.parameters = textField(d, "parameters");
  e.dashboardUrl = textField(d, "dashboardUrl");
  e.shared_ = boolField(d, "shared");
  e.usable = boolField(d, "usable", true);
  e.lastOperationId = OperationId(textField(d, "lastOperationId"));
  return e;
}

// ── ServiceBinding ──────────────────────────────────────────────────────────
Json bindingToRecord(const ServiceBinding e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["instanceId"] = e.instanceId.value;
  d["status"] = cast(string) e.status;
  d["credentials"] = e.credentials;
  d["parameters"] = e.parameters;
  d["bindResource"] = e.bindResource;
  d["context"] = e.context;
  d["lastOperationId"] = e.lastOperationId.value;
  return d;
}

ServiceBinding recordToBinding(Json d) {
  ServiceBinding e;
  readAudit!(ServiceBinding, ServiceBindingId)(e, d);
  e.name = textField(d, "name");
  e.instanceId = ServiceInstanceId(textField(d, "instanceId"));
  e.status = enumField(d, "status", ServiceBindingStatus.creating);
  e.credentials = textField(d, "credentials");
  e.parameters = textField(d, "parameters");
  e.bindResource = textField(d, "bindResource");
  e.context = textField(d, "context");
  e.lastOperationId = OperationId(textField(d, "lastOperationId"));
  return e;
}

// ── Operation ───────────────────────────────────────────────────────────────
Json operationToRecord(const Operation e) {
  auto d = auditRecord(e);
  d["resourceType"] = cast(string) e.resourceType;
  d["resourceId"] = e.resourceId;
  d["type"] = cast(string) e.type;
  d["status"] = cast(string) e.status;
  d["description"] = e.description;
  d["errorMessage"] = e.errorMessage;
  d["rescheduleCount"] = e.rescheduleCount;
  d["startedAt"] = e.startedAt;
  d["completedAt"] = e.completedAt;
  return d;
}

Operation recordToOperation(Json d) {
  Operation e;
  readAudit!(Operation, OperationId)(e, d);
  e.resourceType = enumField(d, "resourceType", ResourceType.serviceInstance);
  e.resourceId = textField(d, "resourceId");
  e.type = enumField(d, "type", OperationType.create);
  e.status = enumField(d, "status", OperationStatus.pending);
  e.description = textField(d, "description");
  e.errorMessage = textField(d, "errorMessage");
  e.rescheduleCount = cast(int) longField(d, "rescheduleCount");
  e.startedAt = longField(d, "startedAt");
  e.completedAt = longField(d, "completedAt");
  return e;
}

// ── Label ───────────────────────────────────────────────────────────────────
Json labelToRecord(const Label e) {
  auto d = auditRecord(e);
  d["resourceType"] = cast(string) e.resourceType;
  d["resourceId"] = e.resourceId;
  d["key"] = e.key;
  d["value"] = e.value;
  return d;
}

Label recordToLabel(Json d) {
  Label e;
  readAudit!(Label, LabelId)(e, d);
  e.resourceType = enumField(d, "resourceType", ResourceType.serviceInstance);
  e.resourceId = textField(d, "resourceId");
  e.key = textField(d, "key");
  e.value = textField(d, "value");
  return e;
}

///
unittest {
  ServiceInstance i;
  i.id = ServiceInstanceId("i1");
  i.tenantId = TenantId("t");
  i.name = "db";
  i.shared_ = true;
  i.status = ServiceInstanceStatus.updating;
  i.createdAt = 123;
  auto back = recordToInstance(instanceToRecord(i));
  assert(back.id == i.id && back.name == "db" && back.shared_ && back.status == ServiceInstanceStatus.updating);
  assert(back.createdAt == 123 && back.usable);

  ServiceOffering o;
  o.tags = ["a", "b"];
  o.status = ServiceOfferingStatus.deprecated_;
  auto ob = recordToOffering(offeringToRecord(o));
  assert(ob.tags == ["a", "b"] && ob.status == ServiceOfferingStatus.deprecated_);

  // unknown enum values fall back instead of failing
  auto rec = labelToRecord(Label.init);
  rec["resourceType"] = "spaceship";
  assert(recordToLabel(rec).resourceType == ResourceType.serviceInstance);
}
