/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.odata.model;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Primitive EDM types used by the service.
enum Edm : string {
  string_ = "Edm.String",
  int32 = "Edm.Int32",
  int64 = "Edm.Int64",
  boolean = "Edm.Boolean",
  dateTimeOffset = "Edm.DateTimeOffset",
}

/// A structural property of an entity or complex type.
struct ODataPropertyDef {
  string name;
  string type; /// Edm.* or a qualified complex type name
  bool nullable = true;
  bool collection;
  string label; /// Common.Label for Fiori

  string edmType() const {
    return collection ? "Collection(" ~ type ~ ")" : type;
  }
}

/// A complex type (no key).
struct ODataComplexTypeDef {
  string name;
  ODataPropertyDef[] properties;
}

/// Entity type + entity set (1:1 in this service).
struct ODataEntitySetDef {
  string name; /// entity set name, e.g. "AuditLogs"
  string entityType; /// entity type name, e.g. "AuditLog"
  string key = "id";
  ODataPropertyDef[] properties;
  bool insertable;
  bool updatable;
  bool deletable;
  bool singleton; /// exposed as <Singleton> instead of <EntitySet>

  bool hasProperty(string propertyName) const {
    return properties.any!(p => p.name == propertyName);
  }
}

/// An unbound action.
struct ODataActionDef {
  string name;
  ODataPropertyDef[] parameters;
  string returnType;
}

/// The whole EDM model of a service.
class ODataServiceModel {
  string namespace_;
  string containerName;
  ODataEntitySetDef[] entitySets;
  ODataComplexTypeDef[] complexTypes;
  ODataActionDef[] actions;

  this(string namespace_, string containerName) {
    this.namespace_ = namespace_;
    this.containerName = containerName;
  }

  /// True if an entity set or singleton with this name exists.
  bool has(string name) const {
    return entitySets.any!(s => s.name == name);
  }

  /// The entity set or singleton with this name (ODataEntitySetDef.init if unknown).
  const(ODataEntitySetDef) find(string name) const {
    foreach (s; entitySets)
      if (s.name == name)
        return s;
    return ODataEntitySetDef.init;
  }

  string qualified(string typeName) const {
    return namespace_ ~ "." ~ typeName;
  }
}

private ODataPropertyDef p(string name, Edm type, string label, bool nullable = true) {
  return ODataPropertyDef(name, cast(string) type, nullable, false, label);
}

private ODataPropertyDef strings(string name, string label) {
  return ODataPropertyDef(name, cast(string) Edm.string_, true, true, label);
}

private ODataPropertyDef[] tenantEntityProperties() {
  return [
    p("id", Edm.string_, "ID", false),
    p("tenantId", Edm.string_, "Tenant"),
    p("createdBy", Edm.string_, "Created By"),
    p("createdAt", Edm.dateTimeOffset, "Created At"),
    p("updatedBy", Edm.string_, "Changed By"),
    p("updatedAt", Edm.dateTimeOffset, "Changed At"),
  ];
}

/// The EDM model of the cloud management OData service.
ODataServiceModel managementODataModel() {
  enum ns = "uim.management";
  auto m = new ODataServiceModel(ns, "ManagementService");

  m.complexTypes ~= ODataComplexTypeDef("ActionResult", [
      p("id", Edm.string_, "ID"),
      p("success", Edm.boolean, "Success"),
      p("message", Edm.string_, "Message"),
    ]);

  ODataEntitySetDef globalAccounts = {
    name: "GlobalAccounts", entityType: "GlobalAccount", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("displayName", Edm.string_, "Display Name"),
      p("description", Edm.string_, "Description"),
      p("contractNumber", Edm.string_, "Contract"),
      p("licenseType", Edm.string_, "License Type"),
      p("status", Edm.string_, "Status"),
      p("region", Edm.string_, "Region"),
      p("costCenter", Edm.string_, "Cost Center"),
      p("companyName", Edm.string_, "Company"),
      p("contactEmail", Edm.string_, "Contact E-Mail"),
      p("maxSubaccounts", Edm.int32, "Max. Subaccounts"),
      p("currentSubaccounts", Edm.int32, "Subaccounts"),
      p("maxDirectories", Edm.int32, "Max. Directories"),
      p("currentDirectories", Edm.int32, "Directories"),
      strings("enabledServices", "Enabled Services"),
      p("renewalDate", Edm.dateTimeOffset, "Renewal Date"),
    ]
  };
  m.entitySets ~= globalAccounts;

  ODataEntitySetDef directories = {
    name: "Directories", entityType: "Directory", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("globalAccountId", Edm.string_, "Global Account"),
      p("parentDirectoryId", Edm.string_, "Parent Directory"),
      p("displayName", Edm.string_, "Display Name"),
      p("description", Edm.string_, "Description"),
      p("status", Edm.string_, "Status"),
      strings("features", "Features"),
      p("manageEntitlements", Edm.boolean, "Manage Entitlements"),
      p("manageAuthorizations", Edm.boolean, "Manage Authorizations"),
      p("subaccountCount", Edm.int32, "Subaccounts"),
    ]
  };
  m.entitySets ~= directories;

  ODataEntitySetDef subaccounts = {
    name: "Subaccounts", entityType: "Subaccount", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("globalAccountId", Edm.string_, "Global Account"),
      p("parentDirectoryId", Edm.string_, "Directory"),
      p("displayName", Edm.string_, "Display Name"),
      p("description", Edm.string_, "Description"),
      p("subdomain", Edm.string_, "Subdomain"),
      p("region", Edm.string_, "Region"),
      p("status", Edm.string_, "Status"),
      p("usage", Edm.string_, "Usage"),
      p("betaEnabled", Edm.boolean, "Beta Features"),
      p("usedForProduction", Edm.boolean, "Used for Production"),
      p("technicalName", Edm.string_, "Technical Name"),
    ]
  };
  m.entitySets ~= subaccounts;

  ODataEntitySetDef entitlements = {
    name: "Entitlements", entityType: "Entitlement", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("globalAccountId", Edm.string_, "Global Account"),
      p("directoryId", Edm.string_, "Directory"),
      p("subaccountId", Edm.string_, "Subaccount"),
      p("servicePlanId", Edm.string_, "Service Plan"),
      p("serviceName", Edm.string_, "Service"),
      p("planName", Edm.string_, "Plan"),
      p("planDisplayName", Edm.string_, "Plan Name"),
      p("category", Edm.string_, "Category"),
      p("status", Edm.string_, "Status"),
      p("quotaAssigned", Edm.int32, "Assigned Quota"),
      p("quotaUsed", Edm.int32, "Used Quota"),
      p("quotaRemaining", Edm.int32, "Remaining Quota"),
      p("unlimited", Edm.boolean, "Unlimited"),
      p("autoAssign", Edm.boolean, "Auto-Assign"),
      p("assignedAt", Edm.dateTimeOffset, "Assigned At"),
      p("assignedBy", Edm.string_, "Assigned By"),
    ]
  };
  m.entitySets ~= entitlements;

  ODataEntitySetDef environments = {
    name: "Environments", entityType: "Environment", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("globalAccountId", Edm.string_, "Global Account"),
      p("subaccountId", Edm.string_, "Subaccount"),
      p("name", Edm.string_, "Name"),
      p("description", Edm.string_, "Description"),
      p("environmentType", Edm.string_, "Environment Type"),
      p("status", Edm.string_, "Status"),
      p("planName", Edm.string_, "Plan"),
      p("landscapeLabel", Edm.string_, "Landscape"),
      p("technicalKey", Edm.string_, "Technical Key"),
      p("dashboardUrl", Edm.string_, "Dashboard"),
      p("platformRegion", Edm.string_, "Region"),
      p("memoryQuotaMb", Edm.int32, "Memory (MB)"),
      p("routeQuota", Edm.int32, "Routes"),
      p("serviceQuota", Edm.int32, "Service Instances"),
    ]
  };
  m.entitySets ~= environments;

  ODataEntitySetDef subscriptions = {
    name: "Subscriptions", entityType: "Subscription", insertable: true, updatable: true,
    properties: tenantEntityProperties() ~ [
      p("globalAccountId", Edm.string_, "Global Account"),
      p("subaccountId", Edm.string_, "Subaccount"),
      p("appName", Edm.string_, "Application"),
      p("appDisplayName", Edm.string_, "Application Name"),
      p("appDescription", Edm.string_, "Description"),
      p("planName", Edm.string_, "Plan"),
      p("status", Edm.string_, "Status"),
      p("appUrl", Edm.string_, "URL"),
      p("isSubscriptionDone", Edm.boolean, "Ready"),
      p("errorDescription", Edm.string_, "Error"),
      p("subscribedAt", Edm.dateTimeOffset, "Subscribed At"),
      p("subscribedBy", Edm.string_, "Subscribed By"),
    ]
  };
  m.entitySets ~= subscriptions;

  ODataEntitySetDef servicePlans = {
    name: "ServicePlans", entityType: "ServicePlan", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("serviceName", Edm.string_, "Service"),
      p("serviceDisplayName", Edm.string_, "Service Name"),
      p("planName", Edm.string_, "Plan"),
      p("planDisplayName", Edm.string_, "Plan Name"),
      p("description", Edm.string_, "Description"),
      p("category", Edm.string_, "Category"),
      p("status", Edm.string_, "Status"),
      p("pricingModel", Edm.string_, "Pricing Model"),
      p("isFree", Edm.boolean, "Free"),
      p("isBeta", Edm.boolean, "Beta"),
      strings("availableRegions", "Regions"),
      p("maxQuota", Edm.int32, "Max. Quota"),
      p("unit", Edm.string_, "Unit"),
      strings("supportedPlatforms", "Platforms"),
      p("providerDisplayName", Edm.string_, "Provider"),
      p("provisionable", Edm.boolean, "Provisionable"),
    ]
  };
  m.entitySets ~= servicePlans;

  ODataEntitySetDef labels = {
    name: "Labels", entityType: "Label", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("resourceType", Edm.string_, "Resource Type"),
      p("resourceId", Edm.string_, "Resource"),
      p("key", Edm.string_, "Key"),
      strings("values", "Values"),
    ]
  };
  m.entitySets ~= labels;

  ODataEntitySetDef events = {
    name: "Events", entityType: "Event",
    properties: tenantEntityProperties() ~ [
      p("globalAccountId", Edm.string_, "Global Account"),
      p("subaccountId", Edm.string_, "Subaccount"),
      p("directoryId", Edm.string_, "Directory"),
      p("category", Edm.string_, "Category"),
      p("severity", Edm.string_, "Severity"),
      p("eventType", Edm.string_, "Event"),
      p("description", Edm.string_, "Description"),
      p("resourceId", Edm.string_, "Resource"),
      p("resourceType", Edm.string_, "Resource Type"),
      p("initiatedBy", Edm.string_, "Initiated By"),
      p("sourceService", Edm.string_, "Source"),
      p("timestamp", Edm.dateTimeOffset, "Time"),
    ]
  };
  m.entitySets ~= events;

  ODataEntitySetDef overview = {
    name: "Overview", entityType: "TenantOverview", key: "tenantId", singleton: true,
    properties: [
      p("tenantId", Edm.string_, "Tenant", false),
      p("globalAccounts", Edm.int32, "Global Accounts"),
      p("activeGlobalAccounts", Edm.int32, "Active Global Accounts"),
      p("suspendedGlobalAccounts", Edm.int32, "Suspended Global Accounts"),
      p("directories", Edm.int32, "Directories"),
      p("subaccounts", Edm.int32, "Subaccounts"),
      p("activeSubaccounts", Edm.int32, "Active Subaccounts"),
      p("suspendedSubaccounts", Edm.int32, "Suspended Subaccounts"),
      p("entitlements", Edm.int32, "Entitlements"),
      p("revokedEntitlements", Edm.int32, "Revoked Entitlements"),
      p("overQuotaEntitlements", Edm.int32, "Over Quota"),
      p("quotaAssigned", Edm.int32, "Assigned Quota"),
      p("quotaUsed", Edm.int32, "Used Quota"),
      p("environments", Edm.int32, "Environments"),
      p("subscriptions", Edm.int32, "Subscriptions"),
      p("servicePlans", Edm.int32, "Service Plans"),
      p("labels", Edm.int32, "Labels"),
      p("events", Edm.int32, "Events"),
      p("warningEvents", Edm.int32, "Warnings"),
      p("lastEventAt", Edm.dateTimeOffset, "Last Event"),
    ]
  };
  m.entitySets ~= overview;

  auto result = ns ~ ".ActionResult";
  auto id = [p("id", Edm.string_, "ID", false)];
  m.actions ~= ODataActionDef("SuspendGlobalAccount", id, result);
  m.actions ~= ODataActionDef("ReactivateGlobalAccount", id, result);
  m.actions ~= ODataActionDef("SuspendSubaccount", id, result);
  m.actions ~= ODataActionDef("ReactivateSubaccount", id, result);
  m.actions ~= ODataActionDef("MoveSubaccount", id ~ [p("targetDirectoryId", Edm.string_, "Target Directory")], result);
  m.actions ~= ODataActionDef("RevokeEntitlement", id, result);
  m.actions ~= ODataActionDef("Unsubscribe", id, result);
  m.actions ~= ODataActionDef("SeedDemoData", null, result);

  return m;
}

///
unittest {
  mixin(ShowTest!("managementODataModel"));

  auto m = managementODataModel();
  assert(m.has("Subaccounts"));
  assert(m.find("Subaccounts").hasProperty("subdomain"));
  assert(m.find("Overview").singleton);
  assert(!m.find("Events").insertable);
  assert(!m.has("Unknown"));
  assert(m.actions.length == 8);
}
