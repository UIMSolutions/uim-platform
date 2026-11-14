/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Conversion between domain entities / DTOs and OData v4 JSON payloads.
///
/// PATCH payloads only contain the changed properties; the update requests are
/// therefore always built from the current entity, overlaid with the payload.
module uim.platform.management.presentation.odata.serializers;

import core.time : Duration;
import std.datetime.systime : SysTime;
import std.datetime.timezone : UTC;
import uim.platform.management;

mixin(ShowModule!());

@safe:

/// stdTime (hnsecs) → Edm.DateTimeOffset ("2026-11-09T10:00:00Z"); 0 → null.
Json odataTime(long stdTime) {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime, UTC());
  t.fracSecs = Duration.zero;
  return Json(t.toISOExtString);
}

/// Edm.DateTimeOffset → stdTime; "" / null → 0. Throws on invalid values.
long parseODataTime(Json value) {
  if (value.type != Json.Type.string || value.get!string.length == 0)
    return 0;
  return SysTime.fromISOExtString(value.get!string).stdTime;
}

private void base(T)(ref Json j, const ref T e) {
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdBy"] = e.createdBy.value;
  j["createdAt"] = odataTime(e.createdAt);
  j["updatedBy"] = e.updatedBy.value;
  j["updatedAt"] = odataTime(e.updatedAt);
}

// ─────────────────────────────────────────────────────────────────────────────
// Entities → OData
// ─────────────────────────────────────────────────────────────────────────────

Json toOData(const GlobalAccount e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["displayName"] = e.displayName;
  j["description"] = e.description;
  j["contractNumber"] = e.contractNumber;
  j["licenseType"] = enumName(e.licenseType);
  j["status"] = enumName(e.status);
  j["region"] = e.region;
  j["costCenter"] = e.costCenter;
  j["companyName"] = e.companyName;
  j["contactEmail"] = e.contactEmail;
  j["maxSubaccounts"] = e.maxSubaccounts;
  j["currentSubaccounts"] = e.currentSubaccounts;
  j["maxDirectories"] = e.maxDirectories;
  j["currentDirectories"] = e.currentDirectories;
  j["enabledServices"] = listToJson(e.enabledServices);
  j["renewalDate"] = odataTime(e.renewalDate);
  return j;
}

Json toOData(const AccountDirectory e, size_t subaccountCount = 0) {
  auto j = Json.emptyObject;
  base(j, e);
  j["globalAccountId"] = e.globalAccountId.value;
  j["parentDirectoryId"] = e.parentDirectoryId.value;
  j["displayName"] = e.displayName;
  j["description"] = e.description;
  j["status"] = enumName(e.status);
  auto features = Json.emptyArray;
  foreach (f; e.features)
    features ~= Json(enumName(f));
  j["features"] = features;
  j["manageEntitlements"] = e.manageEntitlements;
  j["manageAuthorizations"] = e.manageAuthorizations;
  j["subaccountCount"] = cast(int) subaccountCount;
  return j;
}

Json toOData(const Subaccount e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["globalAccountId"] = e.globalAccountId.value;
  j["parentDirectoryId"] = e.parentDirectoryId.value;
  j["displayName"] = e.displayName;
  j["description"] = e.description;
  j["subdomain"] = e.subdomain;
  j["region"] = e.region;
  j["status"] = enumName(e.status);
  j["usage"] = enumName(e.usage);
  j["betaEnabled"] = e.betaEnabled;
  j["usedForProduction"] = e.usedForProduction;
  j["technicalName"] = e.technicalName;
  return j;
}

Json toOData(const Entitlement e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["globalAccountId"] = e.globalAccountId.value;
  j["directoryId"] = e.directoryId.value;
  j["subaccountId"] = e.subaccountId.value;
  j["servicePlanId"] = e.servicePlanId.value;
  j["serviceName"] = e.serviceName;
  j["planName"] = e.planName;
  j["planDisplayName"] = e.planDisplayName;
  j["category"] = enumName(e.category);
  j["status"] = enumName(e.status);
  j["quotaAssigned"] = e.quotaAssigned;
  j["quotaUsed"] = e.quotaUsed;
  j["quotaRemaining"] = e.quotaRemaining;
  j["unlimited"] = e.unlimited;
  j["autoAssign"] = e.autoAssign;
  j["assignedAt"] = odataTime(e.assignedAt);
  j["assignedBy"] = e.assignedBy.value;
  return j;
}

Json toOData(const Environment e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["globalAccountId"] = e.globalAccountId.value;
  j["subaccountId"] = e.subaccountId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["environmentType"] = enumName(e.environmentType);
  j["status"] = enumName(e.status);
  j["planName"] = e.planName;
  j["landscapeLabel"] = e.landscapeLabel;
  j["technicalKey"] = e.technicalKey;
  j["dashboardUrl"] = e.dashboardUrl;
  j["platformRegion"] = e.platformRegion;
  j["memoryQuotaMb"] = e.memoryQuotaMb;
  j["routeQuota"] = e.routeQuota;
  j["serviceQuota"] = e.serviceQuota;
  return j;
}

Json toOData(const Subscription e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["globalAccountId"] = e.globalAccountId.value;
  j["subaccountId"] = e.subaccountId.value;
  j["appName"] = e.appName;
  j["appDisplayName"] = e.appDisplayName;
  j["appDescription"] = e.appDescription;
  j["planName"] = e.planName;
  j["status"] = enumName(e.status);
  j["appUrl"] = e.appUrl;
  j["isSubscriptionDone"] = e.isSubscriptionDone;
  j["errorDescription"] = e.errorDescription;
  j["subscribedAt"] = odataTime(e.subscribedAt);
  j["subscribedBy"] = e.subscribedBy.value;
  return j;
}

Json toOData(const ServicePlan e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["serviceName"] = e.serviceName;
  j["serviceDisplayName"] = e.serviceDisplayName;
  j["planName"] = e.planName;
  j["planDisplayName"] = e.planDisplayName;
  j["description"] = e.description;
  j["category"] = enumName(e.category);
  j["status"] = enumName(e.status);
  j["pricingModel"] = enumName(e.pricingModel);
  j["isFree"] = e.isFree;
  j["isBeta"] = e.isBeta;
  j["availableRegions"] = listToJson(e.availableRegions);
  j["maxQuota"] = e.maxQuota;
  j["unit"] = e.unit;
  j["supportedPlatforms"] = listToJson(e.supportedPlatforms);
  j["providerDisplayName"] = e.providerDisplayName;
  j["provisionable"] = e.provisionable;
  return j;
}

Json toOData(const Label e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["resourceType"] = enumName(e.resourceType);
  j["resourceId"] = e.resourceId;
  j["key"] = e.key;
  j["values"] = listToJson(e.values);
  return j;
}

Json toOData(const EnvironmentEvent e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["globalAccountId"] = e.globalAccountId.value;
  j["subaccountId"] = e.subaccountId.value;
  j["directoryId"] = e.directoryId.value;
  j["category"] = enumName(e.category);
  j["severity"] = enumName(e.severity);
  j["eventType"] = e.eventType;
  j["description"] = e.description;
  j["resourceId"] = e.resourceId;
  j["resourceType"] = e.resourceType;
  j["initiatedBy"] = e.initiatedBy.value;
  j["sourceService"] = e.sourceService;
  j["timestamp"] = odataTime(e.timestamp);
  return j;
}

Json toOData(const TenantOverview o) {
  auto j = Json.emptyObject;
  j["tenantId"] = o.tenantId.value;
  j["globalAccounts"] = cast(int) o.globalAccounts;
  j["activeGlobalAccounts"] = cast(int) o.activeGlobalAccounts;
  j["suspendedGlobalAccounts"] = cast(int) o.suspendedGlobalAccounts;
  j["directories"] = cast(int) o.directories;
  j["subaccounts"] = cast(int) o.subaccounts;
  j["activeSubaccounts"] = cast(int) o.activeSubaccounts;
  j["suspendedSubaccounts"] = cast(int) o.suspendedSubaccounts;
  j["entitlements"] = cast(int) o.entitlements;
  j["revokedEntitlements"] = cast(int) o.revokedEntitlements;
  j["overQuotaEntitlements"] = cast(int) o.overQuotaEntitlements;
  j["quotaAssigned"] = cast(int) o.quotaAssigned;
  j["quotaUsed"] = cast(int) o.quotaUsed;
  j["environments"] = cast(int) o.environments;
  j["subscriptions"] = cast(int) o.subscriptions;
  j["servicePlans"] = cast(int) o.servicePlans;
  j["labels"] = cast(int) o.labels;
  j["events"] = cast(int) o.events;
  j["warningEvents"] = cast(int) o.warningEvents;
  j["lastEventAt"] = odataTime(o.lastEventAt);
  return j;
}

// ─────────────────────────────────────────────────────────────────────────────
// OData payloads → requests
// ─────────────────────────────────────────────────────────────────────────────

private bool has(Json body, string key) {
  return body.type == Json.Type.object && (key in body) !is null && body[key].type != Json.Type.null_;
}

private string str(Json body, string key, string current) {
  return has(body, key) ? fieldString(body, key, current) : current;
}

private int num(Json body, string key, int current) {
  return has(body, key) ? fieldInt(body, key, current) : current;
}

private bool flag(Json body, string key, bool current) {
  return has(body, key) ? fieldBool(body, key, current) : current;
}

CreateGlobalAccountRequest toCreateGlobalAccountRequest(Json b, TenantId tenant, UserId user) {
  CreateGlobalAccountRequest r;
  r.tenantId = tenant;
  r.displayName = fieldString(b, "displayName");
  r.description = fieldString(b, "description");
  r.contractNumber = fieldString(b, "contractNumber");
  r.licenseType = fieldString(b, "licenseType");
  r.region = fieldString(b, "region");
  r.costCenter = fieldString(b, "costCenter");
  r.companyName = fieldString(b, "companyName");
  r.contactEmail = fieldString(b, "contactEmail");
  r.maxSubaccounts = fieldInt(b, "maxSubaccounts");
  r.maxDirectories = fieldInt(b, "maxDirectories");
  r.createdBy = user;
  return r;
}

UpdateGlobalAccountRequest toUpdateGlobalAccountRequest(Json b, const GlobalAccount current, UserId user) {
  UpdateGlobalAccountRequest r;
  r.tenantId = current.tenantId;
  r.accountId = current.id;
  r.displayName = str(b, "displayName", "");
  r.description = str(b, "description", "");
  r.costCenter = str(b, "costCenter", "");
  r.contactEmail = str(b, "contactEmail", "");
  r.companyName = str(b, "companyName", "");
  r.maxSubaccounts = num(b, "maxSubaccounts", 0);
  r.maxDirectories = num(b, "maxDirectories", 0);
  r.updatedBy = user;
  return r;
}

CreateDirectoryRequest toCreateDirectoryRequest(Json b, TenantId tenant, UserId user) {
  CreateDirectoryRequest r;
  r.tenantId = tenant;
  r.accountId = GlobalAccountId(fieldString(b, "globalAccountId"));
  r.parentDirectoryId = DirectoryId(fieldString(b, "parentDirectoryId"));
  r.displayName = fieldString(b, "displayName");
  r.description = fieldString(b, "description");
  r.features = fieldStrings(b, "features");
  r.manageEntitlements = fieldBool(b, "manageEntitlements");
  r.manageAuthorizations = fieldBool(b, "manageAuthorizations");
  r.createdBy = user;
  return r;
}

UpdateDirectoryRequest toUpdateDirectoryRequest(Json b, const AccountDirectory current) {
  UpdateDirectoryRequest r;
  r.tenantId = current.tenantId;
  r.directoryId = current.id;
  r.displayName = str(b, "displayName", "");
  r.description = str(b, "description", "");
  return r;
}

CreateSubaccountRequest toCreateSubaccountRequest(Json b, TenantId tenant, UserId user) {
  CreateSubaccountRequest r;
  r.tenantId = tenant;
  r.globalAccountId = GlobalAccountId(fieldString(b, "globalAccountId"));
  r.parentDirectoryId = DirectoryId(fieldString(b, "parentDirectoryId"));
  r.displayName = fieldString(b, "displayName");
  r.description = fieldString(b, "description");
  r.subdomain = fieldString(b, "subdomain");
  r.region = fieldString(b, "region");
  r.usage = fieldString(b, "usage");
  r.betaEnabled = fieldBool(b, "betaEnabled");
  r.usedForProduction = fieldBool(b, "usedForProduction");
  r.createdBy = user;
  return r;
}

UpdateSubaccountRequest toUpdateSubaccountRequest(Json b, const Subaccount current) {
  UpdateSubaccountRequest r;
  r.tenantId = current.tenantId;
  r.globalAccountId = current.globalAccountId;
  r.subaccountId = current.id;
  r.displayName = str(b, "displayName", "");
  r.description = str(b, "description", "");
  r.usage = str(b, "usage", "");
  r.betaEnabled = flag(b, "betaEnabled", current.betaEnabled);
  r.usedForProduction = flag(b, "usedForProduction", current.usedForProduction);
  return r;
}

AssignEntitlementRequest toAssignEntitlementRequest(Json b, TenantId tenant, UserId user) {
  AssignEntitlementRequest r;
  r.tenantId = tenant;
  r.globalAccountId = GlobalAccountId(fieldString(b, "globalAccountId"));
  r.directoryId = DirectoryId(fieldString(b, "directoryId"));
  r.subaccountId = SubaccountId(fieldString(b, "subaccountId"));
  r.servicePlanId = ServicePlanId(fieldString(b, "servicePlanId"));
  r.quotaAssigned = fieldInt(b, "quotaAssigned");
  r.unlimited = fieldBool(b, "unlimited");
  r.autoAssign = fieldBool(b, "autoAssign");
  r.assignedBy = user;
  return r;
}

UpdateEntitlementQuotaRequest toUpdateEntitlementQuotaRequest(Json b, const Entitlement current) {
  UpdateEntitlementQuotaRequest r;
  r.tenantId = current.tenantId;
  r.entitlementId = current.id;
  r.quotaAssigned = num(b, "quotaAssigned", current.quotaAssigned);
  r.unlimited = flag(b, "unlimited", current.unlimited);
  return r;
}

CreateEnvironmentRequest toCreateEnvironmentRequest(Json b, TenantId tenant, UserId user) {
  CreateEnvironmentRequest r;
  r.tenantId = tenant;
  r.subaccountId = SubaccountId(fieldString(b, "subaccountId"));
  r.globalAccountId = GlobalAccountId(fieldString(b, "globalAccountId"));
  r.name = fieldString(b, "name");
  r.description = fieldString(b, "description");
  r.environmentType = fieldString(b, "environmentType");
  r.planName = fieldString(b, "planName");
  r.landscapeLabel = fieldString(b, "landscapeLabel");
  r.memoryQuotaMb = fieldInt(b, "memoryQuotaMb");
  r.routeQuota = fieldInt(b, "routeQuota");
  r.serviceQuota = fieldInt(b, "serviceQuota");
  r.createdBy = user;
  return r;
}

UpdateEnvironmentRequest toUpdateEnvironmentRequest(Json b, const Environment current) {
  UpdateEnvironmentRequest r;
  r.tenantId = current.tenantId;
  r.instanceId = current.id;
  r.description = str(b, "description", "");
  r.memoryQuotaMb = num(b, "memoryQuotaMb", 0);
  r.routeQuota = num(b, "routeQuota", 0);
  r.serviceQuota = num(b, "serviceQuota", 0);
  return r;
}

CreateSubscriptionRequest toCreateSubscriptionRequest(Json b, TenantId tenant, UserId user) {
  CreateSubscriptionRequest r;
  r.tenantId = tenant;
  r.subaccountId = SubaccountId(fieldString(b, "subaccountId"));
  r.globalAccountId = GlobalAccountId(fieldString(b, "globalAccountId"));
  r.appName = fieldString(b, "appName");
  r.planName = fieldString(b, "planName");
  r.subscribedBy = user;
  return r;
}

UpdateSubscriptionRequest toUpdateSubscriptionRequest(Json b, const Subscription current) {
  UpdateSubscriptionRequest r;
  r.tenantId = current.tenantId;
  r.subscriptionId = current.id;
  r.planName = str(b, "planName", "");
  return r;
}

CreateServicePlanRequest toCreateServicePlanRequest(Json b, TenantId tenant, UserId user) {
  CreateServicePlanRequest r;
  r.tenantId = tenant;
  r.serviceName = fieldString(b, "serviceName");
  r.serviceDisplayName = fieldString(b, "serviceDisplayName");
  r.planName = fieldString(b, "planName");
  r.planDisplayName = fieldString(b, "planDisplayName");
  r.description = fieldString(b, "description");
  r.category = fieldString(b, "category");
  r.pricingModel = fieldString(b, "pricingModel");
  r.isFree = fieldBool(b, "isFree");
  r.isBeta = fieldBool(b, "isBeta");
  r.availableRegions = fieldStrings(b, "availableRegions");
  r.maxQuota = fieldInt(b, "maxQuota");
  r.unit = fieldString(b, "unit");
  r.supportedPlatforms = fieldStrings(b, "supportedPlatforms");
  r.providerDisplayName = fieldString(b, "providerDisplayName");
  r.provisionable = fieldBool(b, "provisionable", true);
  r.createdBy = user;
  return r;
}

UpdateServicePlanRequest toUpdateServicePlanRequest(Json b, const ServicePlan current, UserId user) {
  UpdateServicePlanRequest r;
  r.tenantId = current.tenantId;
  r.planId = current.id;
  r.planDisplayName = str(b, "planDisplayName", "");
  r.description = str(b, "description", "");
  r.availableRegions = has(b, "availableRegions") ? fieldStrings(b, "availableRegions") : null;
  r.maxQuota = num(b, "maxQuota", 0);
  r.isBeta = flag(b, "isBeta", current.isBeta);
  r.provisionable = flag(b, "provisionable", current.provisionable);
  r.updatedBy = user;
  return r;
}

CreateLabelRequest toCreateLabelRequest(Json b, TenantId tenant, UserId user) {
  CreateLabelRequest r;
  r.tenantId = tenant;
  r.resourceType = fieldString(b, "resourceType");
  r.resourceId = fieldString(b, "resourceId");
  r.key = fieldString(b, "key");
  r.values = fieldStrings(b, "values");
  r.createdBy = user;
  return r;
}

UpdateLabelRequest toUpdateLabelRequest(Json b, const Label current, UserId user) {
  UpdateLabelRequest r;
  r.tenantId = current.tenantId;
  r.labelId = current.id;
  r.values = has(b, "values") ? fieldStrings(b, "values") : current.values.dup;
  r.updatedBy = user;
  return r;
}

///
unittest {
  mixin(ShowTest!("OData serializers"));

  assert(odataTime(0).type == Json.Type.null_);
  auto t = odataTime(Clock.currStdTime);
  assert(t.get!string.endsWith("Z"));
  assert(parseODataTime(t) > 0);

  auto s = Subaccount(TenantId("t"));
  s.betaEnabled = true;
  s.status = SubaccountStatus.moveInProgress;
  assert(toOData(s)["status"].get!string == "moveInProgress");

  // PATCH keeps fields that are not in the payload
  auto u = toUpdateSubaccountRequest(parseJsonString(`{"displayName": "New"}`), s);
  assert(u.displayName == "New" && u.betaEnabled);
  u = toUpdateSubaccountRequest(parseJsonString(`{"betaEnabled": false}`), s);
  assert(!u.betaEnabled && u.displayName == "");
}
