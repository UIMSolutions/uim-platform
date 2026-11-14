/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Seeds a tenant with a sample landscape. Everything is created through the
/// regular use case ports, so all business rules apply to the demo data too.
module uim.platform.management.application.services.demo_data;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class DemoDataService : IDemoDataService {
  protected IManageGlobalAccountsUseCase globalAccounts;
  protected IManageDirectoriesUseCase directories;
  protected IManageSubaccountsUseCase subaccounts;
  protected IManageEntitlementsUseCase entitlements;
  protected IManageEnvironmentsUseCase environments;
  protected IManageSubscriptionsUseCase subscriptions;
  protected IManageServicePlansUseCase servicePlans;
  protected IManageLabelsUseCase labels;

  this(IManageGlobalAccountsUseCase globalAccounts, IManageDirectoriesUseCase directories,
      IManageSubaccountsUseCase subaccounts, IManageEntitlementsUseCase entitlements,
      IManageEnvironmentsUseCase environments, IManageSubscriptionsUseCase subscriptions,
      IManageServicePlansUseCase servicePlans, IManageLabelsUseCase labels) {
    this.globalAccounts = globalAccounts;
    this.directories = directories;
    this.subaccounts = subaccounts;
    this.entitlements = entitlements;
    this.environments = environments;
    this.subscriptions = subscriptions;
    this.servicePlans = servicePlans;
    this.labels = labels;
  }

  bool isEmpty(TenantId tenantId) {
    return globalAccounts.listAccounts(tenantId).length == 0 && servicePlans.listPlans(tenantId).length == 0;
  }

  UsecaseResult seed(TenantId tenantId, bool force = false) {
    if (!force && !isEmpty(tenantId))
      return ok(tenantId.value, "Tenant '" ~ tenantId.value ~ "' already contains data — nothing seeded");

    auto by = UserId("demo-seed");
    string[] failures;
    string check(UsecaseResult r, string what) {
      if (!r.isSuccess)
        failures ~= what ~ ": " ~ r.message;
      return r.id;
    }

    // ── Service catalog ──────────────────────────────────────────────────
    string plan(string service, string display, string planName, string category, string pricing,
        int maxQuota, string unit, string description) {
      CreateServicePlanRequest r;
      r.tenantId = tenantId;
      r.serviceName = service;
      r.serviceDisplayName = display;
      r.planName = planName;
      r.description = description;
      r.category = category;
      r.pricingModel = pricing;
      r.maxQuota = maxQuota;
      r.unit = unit;
      r.availableRegions = ["eu10", "us10", "ap21"];
      r.providerDisplayName = "UIM";
      r.createdBy = by;
      return check(servicePlans.createPlan(r), "plan " ~ service ~ "/" ~ planName);
    }

    auto planCf = plan("cloudfoundry", "Cloud Foundry Runtime", "standard", "environment", "consumption", 0, "GB",
      "Memory for Cloud Foundry applications");
    auto planKyma = plan("kyma", "Kyma Runtime", "azure", "environment", "consumption", 4, "clusters",
      "Managed Kubernetes runtime");
    auto planHana = plan("hana-cloud", "SAP HANA Cloud", "hana", "service", "consumption", 10, "instances",
      "In-memory database");
    auto planXsuaa = plan("xsuaa", "Authorization & Trust Management", "application", "service", "free", 0, "instances",
      "OAuth 2.0 authorization server");
    plan("destination", "Destination Service", "lite", "service", "free", 0, "instances",
      "Connection targets for applications");
    auto planWorkzone = plan("workzone", "Build Work Zone", "standard", "application", "subscription", 5, "users",
      "Central launchpad for business apps");
    plan("auditlog-viewer", "Audit Log Viewer", "default", "application", "free", 0, "subscriptions",
      "Browse audit logs of the subaccount");

    // ── Global account & hierarchy ───────────────────────────────────────
    CreateGlobalAccountRequest ga;
    ga.tenantId = tenantId;
    ga.displayName = "ACME Corporation";
    ga.description = "Production contract of ACME";
    ga.contractNumber = "C-2026-0042";
    ga.licenseType = "enterprise";
    ga.region = "eu10";
    ga.companyName = "ACME Corp.";
    ga.contactEmail = "cloud-admin@acme.example";
    ga.costCenter = "CC-4711";
    ga.maxSubaccounts = 25;
    ga.maxDirectories = 10;
    ga.createdBy = by;
    auto gaId = GlobalAccountId(check(globalAccounts.createAccount(ga), "global account"));
    if (gaId.isEmpty)
      return violation("Seeding failed: " ~ failures.join("; "));

    string dir(string name, string parent, string description) {
      CreateDirectoryRequest r;
      r.tenantId = tenantId;
      r.accountId = gaId;
      r.parentDirectoryId = DirectoryId(parent);
      r.displayName = name;
      r.description = description;
      r.features = ["entitlements"];
      r.createdBy = by;
      return check(directories.createDirectory(r), "directory " ~ name);
    }

    auto dirSales = dir("Sales", "", "Sales & CRM applications");
    auto dirFinance = dir("Finance", "", "Finance applications");
    auto dirEmea = dir("EMEA", dirSales, "Sales EMEA");

    string sub(string name, string subdomain, string region, string usage, string directory) {
      CreateSubaccountRequest r;
      r.tenantId = tenantId;
      r.globalAccountId = gaId;
      r.parentDirectoryId = DirectoryId(directory);
      r.displayName = name;
      r.subdomain = subdomain;
      r.region = region;
      r.usage = usage;
      r.createdBy = by;
      return check(subaccounts.createSubaccount(r), "subaccount " ~ name);
    }

    auto subDev = sub("Sales Development", "acme-sales-dev", "eu10", "development", dirEmea);
    auto subProd = sub("Sales Production", "acme-sales-prod", "eu10", "production", dirEmea);
    auto subFin = sub("Finance Production", "acme-finance", "us10", "production", dirFinance);
    sub("Sandbox", "acme-sandbox", "ap21", "test", "");

    // ── Entitlements ─────────────────────────────────────────────────────
    void entitle(string planId, string subaccountId, int quota, bool unlimited = false) {
      if (planId.length == 0 || subaccountId.length == 0)
        return;
      AssignEntitlementRequest r;
      r.tenantId = tenantId;
      r.subaccountId = SubaccountId(subaccountId);
      r.servicePlanId = ServicePlanId(planId);
      r.quotaAssigned = quota;
      r.unlimited = unlimited;
      r.assignedBy = by;
      check(entitlements.assignEntitlement(r), "entitlement");
    }

    entitle(planCf, subDev, 4);
    entitle(planCf, subProd, 16);
    entitle(planHana, subProd, 2);
    entitle(planHana, subFin, 3);
    entitle(planKyma, subFin, 1);
    entitle(planXsuaa, subDev, 0, true);
    entitle(planWorkzone, subProd, 5);

    // ── Environments & subscriptions ─────────────────────────────────────
    void env(string subaccountId, string name, string type, string planName, int memory) {
      if (subaccountId.length == 0)
        return;
      CreateEnvironmentRequest r;
      r.tenantId = tenantId;
      r.subaccountId = SubaccountId(subaccountId);
      r.name = name;
      r.environmentType = type;
      r.planName = planName;
      r.memoryQuotaMb = memory;
      r.routeQuota = 20;
      r.serviceQuota = 20;
      r.createdBy = by;
      check(environments.createEnvironment(r), "environment " ~ name);
    }

    env(subDev, "acme-sales-dev", "cloudFoundry", "standard", 4096);
    env(subProd, "acme-sales-prod", "cloudFoundry", "standard", 16_384);
    env(subFin, "acme-finance-kyma", "kyma", "azure", 0);

    void subscribe(string subaccountId, string app, string planName) {
      if (subaccountId.length == 0)
        return;
      CreateSubscriptionRequest r;
      r.tenantId = tenantId;
      r.subaccountId = SubaccountId(subaccountId);
      r.appName = app;
      r.planName = planName;
      r.subscribedBy = by;
      check(subscriptions.createSubscription(r), "subscription " ~ app);
    }

    subscribe(subProd, "workzone", "standard");
    subscribe(subFin, "auditlog-viewer", "default");

    // ── Labels ───────────────────────────────────────────────────────────
    void label(string type, string resourceId, string key, string[] values) {
      if (resourceId.length == 0)
        return;
      CreateLabelRequest r;
      r.tenantId = tenantId;
      r.resourceType = type;
      r.resourceId = resourceId;
      r.key = key;
      r.values = values;
      r.createdBy = by;
      check(labels.createLabel(r), "label " ~ key);
    }

    label("subaccount", subProd, "costCenter", ["CC-4711"]);
    label("subaccount", subProd, "criticality", ["high"]);
    label("subaccount", subDev, "costCenter", ["CC-4711"]);
    label("globalAccount", gaId.value, "contract", ["enterprise-2026"]);

    if (failures.length > 0)
      return UsecaseResult(false, gaId.value, "Seeded with errors: " ~ failures.join("; "), ResultCode.ruleViolation);
    return created(gaId.value, "Demo landscape seeded into tenant '" ~ tenantId.value ~ "'");
  }
}
