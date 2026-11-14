/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST
/// adapter, the CLI and the GtkD GUI.
///
/// Scopes: Read (all reads), Write (instances, bindings, labels),
///         Admin (platforms, brokers, catalog, operations, actions).
module uim.platform.service_manager.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.servicemanager";

ODataServiceModel serviceManagerModel() {
  auto m = new ODataServiceModel(odataNamespace, "ServiceManagerService", "Service Manager");

  m.entitySet("Platforms", "Platform")
    .tenantAware()
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("type", Edm.string_, "Type")
    .property("status", Edm.string_, "Status")
    .property("region", Edm.string_, "Region")
    .property("subaccountId", Edm.string_, "Subaccount")
    .property("brokerUrl", Edm.string_, "Broker URL")
    .property("credentials", Edm.string_, "Credentials")
    .property("hasCredentials", Edm.boolean, "Has Credentials")
    .property("instanceCount", Edm.int32, "Instances")
    .computed("hasCredentials", "instanceCount")
    .writable()
    .titled("Platform", "Platforms", "name", "description")
    .columns("name", "type", "status", "region", "instanceCount")
    .filters("name", "type", "status", "region")
    .scopes("Read", "Admin");

  m.entitySet("ServiceBrokers", "ServiceBroker")
    .tenantAware()
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("brokerUrl", Edm.string_, "Broker URL", false)
    .property("credentials", Edm.string_, "Credentials (user:password)")
    .property("hasCredentials", Edm.boolean, "Has Credentials")
    .property("status", Edm.string_, "Status")
    .property("lastCatalogFetch", Edm.dateTimeOffset, "Last Catalog Fetch")
    .property("catalogError", Edm.string_, "Catalog Error")
    .property("offeringCount", Edm.int32, "Offerings")
    .computed("hasCredentials", "lastCatalogFetch", "catalogError", "offeringCount")
    .writable()
    .titled("Service Broker", "Service Brokers", "name", "brokerUrl")
    .columns("name", "brokerUrl", "status", "offeringCount", "lastCatalogFetch")
    .filters("name", "status")
    .scopes("Read", "Admin");

  m.entitySet("ServiceOfferings", "ServiceOffering")
    .tenantAware()
    .property("brokerId", Edm.string_, "Broker", false)
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("catalogId", Edm.string_, "Catalog ID")
    .property("catalogName", Edm.string_, "Catalog Name")
    .property("status", Edm.string_, "Status")
    .property("category", Edm.string_, "Category")
    .property("bindable", Edm.boolean, "Bindable")
    .property("instancesRetrievable", Edm.boolean, "Instances Retrievable")
    .property("bindingsRetrievable", Edm.boolean, "Bindings Retrievable")
    .property("planUpdateable", Edm.boolean, "Plan Updateable")
    .property("metadata", Edm.string_, "Metadata (JSON)")
    .collection("tags", Edm.string_, "Tags")
    .property("planCount", Edm.int32, "Plans")
    .computed("planCount")
    .immutableProps("brokerId", "catalogId")
    .writable()
    .titled("Service Offering", "Service Offerings", "name", "description")
    .columns("name", "category", "status", "bindable", "planCount")
    .filters("name", "category", "status", "brokerId")
    .scopes("Read", "Admin");

  m.entitySet("ServicePlans", "ServicePlan")
    .tenantAware()
    .property("offeringId", Edm.string_, "Offering", false)
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("catalogId", Edm.string_, "Catalog ID")
    .property("catalogName", Edm.string_, "Catalog Name")
    .property("pricing", Edm.string_, "Pricing")
    .property("free", Edm.boolean, "Free")
    .property("bindable", Edm.boolean, "Bindable")
    .property("planUpdateable", Edm.boolean, "Plan Updateable")
    .property("maxInstances", Edm.int32, "Max. Instances")
    .property("schemas", Edm.string_, "Schemas (JSON)")
    .property("metadata", Edm.string_, "Metadata (JSON)")
    .property("instanceCount", Edm.int32, "Instances")
    .computed("free", "instanceCount")
    .immutableProps("offeringId", "catalogId")
    .writable()
    .titled("Service Plan", "Service Plans", "name", "description")
    .columns("name", "offeringId", "pricing", "maxInstances", "instanceCount")
    .filters("name", "offeringId", "pricing")
    .scopes("Read", "Admin");

  m.entitySet("ServiceInstances", "ServiceInstance")
    .tenantAware()
    .property("name", Edm.string_, "Name", false)
    .property("planId", Edm.string_, "Plan", false)
    .property("offeringId", Edm.string_, "Offering")
    .property("platformId", Edm.string_, "Platform")
    .property("status", Edm.string_, "Status")
    .property("context", Edm.string_, "Context (JSON)")
    .property("parameters", Edm.string_, "Parameters (JSON)")
    .property("dashboardUrl", Edm.string_, "Dashboard")
    .property("shared", Edm.boolean, "Shared")
    .property("usable", Edm.boolean, "Usable")
    .property("lastOperationId", Edm.string_, "Last Operation")
    .property("bindingCount", Edm.int32, "Bindings")
    .computed("offeringId", "status", "dashboardUrl", "lastOperationId", "bindingCount")
    .immutableProps("platformId")
    .writable()
    .titled("Service Instance", "Service Instances", "name", "status")
    .columns("name", "planId", "platformId", "status", "bindingCount", "shared")
    .filters("name", "status", "planId", "platformId")
    .scopes("Read", "Write");

  m.entitySet("ServiceBindings", "ServiceBinding")
    .tenantAware()
    .property("name", Edm.string_, "Name", false)
    .property("instanceId", Edm.string_, "Instance", false)
    .property("status", Edm.string_, "Status")
    .property("credentials", Edm.string_, "Credentials (JSON)")
    .property("parameters", Edm.string_, "Parameters (JSON)")
    .property("bindResource", Edm.string_, "Bind Resource (JSON)")
    .property("context", Edm.string_, "Context (JSON)")
    .property("lastOperationId", Edm.string_, "Last Operation")
    .computed("status", "lastOperationId")
    .writable(true, false, true)
    .titled("Service Binding", "Service Bindings", "name", "status")
    .columns("name", "instanceId", "status", "createdAt")
    .filters("name", "instanceId", "status")
    .scopes("Read", "Write");

  m.entitySet("Operations", "Operation")
    .tenantAware()
    .property("resourceType", Edm.string_, "Resource Type")
    .property("resourceId", Edm.string_, "Resource")
    .property("type", Edm.string_, "Type")
    .property("status", Edm.string_, "Status")
    .property("description", Edm.string_, "Description")
    .property("errorMessage", Edm.string_, "Error")
    .property("rescheduleCount", Edm.int32, "Reschedules")
    .property("startedAt", Edm.dateTimeOffset, "Started At")
    .property("completedAt", Edm.dateTimeOffset, "Completed At")
    .writable(false, false, true)
    .titled("Operation", "Operations", "description", "status")
    .columns("type", "resourceType", "description", "status", "startedAt", "completedAt")
    .filters("type", "status", "resourceType", "resourceId")
    .scopes("Read", "Admin");

  m.entitySet("Labels", "Label")
    .tenantAware()
    .property("resourceType", Edm.string_, "Resource Type", false)
    .property("resourceId", Edm.string_, "Resource", false)
    .property("key", Edm.string_, "Key", false)
    .property("value", Edm.string_, "Value")
    .immutableProps("resourceType", "resourceId", "key")
    .writable()
    .titled("Label", "Labels", "key", "value")
    .columns("resourceType", "resourceId", "key", "value")
    .filters("resourceType", "resourceId", "key")
    .scopes("Read", "Write");

  m.singletonSet("Statistics", "Statistic")
    .keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false)
    .property("platforms", Edm.int32, "Platforms")
    .property("activePlatforms", Edm.int32, "Active Platforms")
    .property("brokers", Edm.int32, "Brokers")
    .property("activeBrokers", Edm.int32, "Active Brokers")
    .property("failedBrokers", Edm.int32, "Failed Brokers")
    .property("offerings", Edm.int32, "Offerings")
    .property("availableOfferings", Edm.int32, "Available Offerings")
    .property("plans", Edm.int32, "Plans")
    .property("instances", Edm.int32, "Instances")
    .property("readyInstances", Edm.int32, "Ready Instances")
    .property("pendingInstances", Edm.int32, "Pending Instances")
    .property("failedInstances", Edm.int32, "Failed Instances")
    .property("bindings", Edm.int32, "Bindings")
    .property("operations", Edm.int32, "Operations")
    .property("runningOperations", Edm.int32, "Running Operations")
    .property("failedOperations", Edm.int32, "Failed Operations")
    .property("labels", Edm.int32, "Labels")
    .titled("Statistic", "Statistics", "tenantId")
    .scopes("Read", "");

  m.complexType("CatalogSyncResult")
    .property("brokerId", Edm.string_, "Broker")
    .property("brokerName", Edm.string_, "Broker Name")
    .property("succeeded", Edm.boolean, "Succeeded")
    .property("error", Edm.string_, "Error")
    .property("offeringsCreated", Edm.int32, "Offerings Created")
    .property("offeringsUpdated", Edm.int32, "Offerings Updated")
    .property("offeringsRemoved", Edm.int32, "Offerings Removed")
    .property("plansCreated", Edm.int32, "Plans Created")
    .property("plansUpdated", Edm.int32, "Plans Updated")
    .property("syncedAt", Edm.dateTimeOffset, "Synced At");
  m.action("SyncBrokerCatalog", "CatalogSyncResult")
    .parameter("brokerId", Edm.string_, false)
    .labelled("Fetch the broker catalog (OSB GET /v2/catalog) and reconcile offerings and plans")
    .requires("Admin");

  m.complexType("OperationResult")
    .property("id", Edm.string_, "Operation")
    .property("status", Edm.string_, "Status")
    .property("resourceType", Edm.string_, "Resource Type")
    .property("resourceId", Edm.string_, "Resource")
    .property("errorMessage", Edm.string_, "Error");
  m.action("CompleteOperation", "OperationResult")
    .parameter("operationId", Edm.string_, false)
    .parameter("succeeded", Edm.boolean, false)
    .parameter("errorMessage", Edm.string_)
    .labelled("Finish an in-progress operation (broker callback)")
    .requires("Admin");
  return m;
}

///
unittest {
  auto m = serviceManagerModel();
  m.validate();
  assert(m.find("ServiceInstances") !is null && m.find("Statistics").singleton);
  assert(m.findAction("SyncBrokerCatalog") !is null);
  assert(!m.find("ServiceBindings").updatable);
}
