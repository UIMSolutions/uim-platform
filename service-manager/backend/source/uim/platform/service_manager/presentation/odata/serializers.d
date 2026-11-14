/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Secrets of
/// platforms and brokers are never serialized (write-only).
module uim.platform.service_manager.presentation.odata.serializers;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// ISO 8601 (seconds precision, UTC) or null for 0.
Json isoTime(long stdTime) @trusted {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime - stdTime % 10_000_000, UTC());
  return Json(t.toISOExtString);
}

Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

private Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

Json platformRow(const Platform e, size_t instances = 0) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["type"] = cast(string) e.type;
  j["status"] = cast(string) e.status;
  j["region"] = e.region;
  j["subaccountId"] = e.subaccountId.value;
  j["brokerUrl"] = e.brokerUrl;
  j["credentials"] = Json(null);
  j["hasCredentials"] = e.credentials.length > 0;
  j["instanceCount"] = instances;
  return j;
}

Json brokerRow(const ServiceBroker e, size_t offerings = 0) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["brokerUrl"] = e.brokerUrl;
  j["credentials"] = Json(null);
  j["hasCredentials"] = e.credentials.length > 0;
  j["status"] = cast(string) e.status;
  j["lastCatalogFetch"] = isoTime(e.lastCatalogFetch);
  j["catalogError"] = e.catalogError;
  j["offeringCount"] = offerings;
  return j;
}

Json offeringRow(const ServiceOffering e, size_t plans = 0) {
  auto j = auditRow(e);
  j["brokerId"] = e.brokerId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["catalogId"] = e.catalogId;
  j["catalogName"] = e.catalogName;
  j["status"] = cast(string) e.status;
  j["category"] = cast(string) e.category;
  j["bindable"] = e.bindable;
  j["instancesRetrievable"] = e.instancesRetrievable;
  j["bindingsRetrievable"] = e.bindingsRetrievable;
  j["planUpdateable"] = e.planUpdateable;
  j["metadata"] = e.metadata;
  j["tags"] = texts(e.tags);
  j["planCount"] = plans;
  return j;
}

Json planRow(const ServicePlan e, size_t instances = 0) {
  auto j = auditRow(e);
  j["offeringId"] = e.offeringId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["catalogId"] = e.catalogId;
  j["catalogName"] = e.catalogName;
  j["pricing"] = cast(string) e.pricing;
  j["free"] = e.free;
  j["bindable"] = e.bindable;
  j["planUpdateable"] = e.planUpdateable;
  j["maxInstances"] = e.maxInstances;
  j["schemas"] = e.schemas;
  j["metadata"] = e.metadata;
  j["instanceCount"] = instances;
  return j;
}

Json instanceRow(const ServiceInstance e, size_t bindings = 0) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["planId"] = e.planId.value;
  j["offeringId"] = e.offeringId.value;
  j["platformId"] = e.platformId.value;
  j["status"] = cast(string) e.status;
  j["context"] = e.context;
  j["parameters"] = e.parameters;
  j["dashboardUrl"] = e.dashboardUrl;
  j["shared"] = e.shared_;
  j["usable"] = e.usable;
  j["lastOperationId"] = e.lastOperationId.value;
  j["bindingCount"] = bindings;
  return j;
}

Json bindingRow(const ServiceBinding e) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["instanceId"] = e.instanceId.value;
  j["status"] = cast(string) e.status;
  j["credentials"] = e.credentials;
  j["parameters"] = e.parameters;
  j["bindResource"] = e.bindResource;
  j["context"] = e.context;
  j["lastOperationId"] = e.lastOperationId.value;
  return j;
}

Json operationRow(const Operation e) {
  auto j = auditRow(e);
  j["resourceType"] = cast(string) e.resourceType;
  j["resourceId"] = e.resourceId;
  j["type"] = cast(string) e.type;
  j["status"] = cast(string) e.status;
  j["description"] = e.description;
  j["errorMessage"] = e.errorMessage;
  j["rescheduleCount"] = e.rescheduleCount;
  j["startedAt"] = isoTime(e.startedAt);
  j["completedAt"] = isoTime(e.completedAt);
  return j;
}

Json labelRow(const Label e) {
  auto j = auditRow(e);
  j["resourceType"] = cast(string) e.resourceType;
  j["resourceId"] = e.resourceId;
  j["key"] = e.key;
  j["value"] = e.value;
  return j;
}

Json statisticsRow(const ServiceManagerStatistics s) {
  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId.value;
  static foreach (name; ["platforms", "activePlatforms", "brokers", "activeBrokers", "failedBrokers", "offerings",
      "availableOfferings", "plans", "instances", "readyInstances", "pendingInstances", "failedInstances",
      "bindings", "operations", "runningOperations", "failedOperations", "labels"])
    j[name] = __traits(getMember, s, name);
  return j;
}

Json syncResultRow(const CatalogSyncResult r) {
  auto j = Json.emptyObject;
  j["brokerId"] = r.brokerId.value;
  j["brokerName"] = r.brokerName;
  j["succeeded"] = r.succeeded;
  j["error"] = r.error;
  j["offeringsCreated"] = r.offeringsCreated;
  j["offeringsUpdated"] = r.offeringsUpdated;
  j["offeringsRemoved"] = r.offeringsRemoved;
  j["plansCreated"] = r.plansCreated;
  j["plansUpdated"] = r.plansUpdated;
  j["syncedAt"] = isoTime(r.syncedAt);
  return j;
}

Json operationResultRow(const Operation op) {
  auto j = Json.emptyObject;
  j["id"] = op.id.value;
  j["status"] = cast(string) op.status;
  j["resourceType"] = cast(string) op.resourceType;
  j["resourceId"] = op.resourceId;
  j["errorMessage"] = op.errorMessage;
  return j;
}

///
unittest {
  assert(isoTime(0).type == Json.Type.null_);
  auto t = isoTime(SysTime(DateTime(2026, 11, 10, 8, 30, 15), UTC()).stdTime + 1234);
  assert(t.get!string == "2026-11-10T08:30:15Z");

  Platform p;
  p.credentials = "secret";
  auto row = platformRow(p, 3);
  assert(row["credentials"].type == Json.Type.null_ && row["hasCredentials"].get!bool);
  assert(row["instanceCount"].get!long == 3);
}
