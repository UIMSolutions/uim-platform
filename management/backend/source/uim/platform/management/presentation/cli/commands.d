/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Talks to the application exclusively via the
/// driving ports (ManagementPorts) — exactly like the HTTP/OData/GUI adapters.
module uim.platform.management.presentation.cli.commands;

import uim.platform.management;
import uim.platform.management.presentation.cli.args;
import uim.platform.management.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-management-cli — SAP BTP style Cloud Management administration

Usage: uim-management-cli <resource> [command] [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     use volatile storage (testing)
  --json               machine readable JSON output

General:
  overview [--global-account=ID]          dashboard figures (tenant or one global account)
  config                                  effective service configuration
  seed [--force]                          create a demo landscape in the tenant
  help

Resources (default command: list):
  global-accounts  list [--status=S] | get ID | delete ID | suspend ID | reactivate ID
                   create --name=N --region=R [--license=enterprise|trial|partner|internal]
                          [--company=C] [--email=E] [--contract=NO] [--cost-center=CC]
                          [--max-subaccounts=N] [--max-directories=N]
                   update ID [--name=N] [--description=D] [--company=C] [--email=E]
                          [--cost-center=CC] [--max-subaccounts=N] [--max-directories=N]
  directories      list [--global-account=ID] [--parent=ID] | get ID | delete ID
                   create --global-account=ID --name=N [--parent=ID] [--description=D]
                          [--features=entitlements,authorizations]
                   update ID [--name=N] [--description=D]
  subaccounts      list [--global-account=ID [--region=R]] [--directory=ID] | get ID | delete ID
                   create --global-account=ID --name=N --subdomain=S --region=R
                          [--usage=development|test|staging|production|demo] [--directory=ID] [--beta]
                   update ID [--name=N] [--description=D] [--usage=U]
                   move ID [--directory=ID]   (no --directory = global account root)
                   suspend ID | reactivate ID
  entitlements     list [--global-account=ID|--subaccount=ID|--directory=ID] | get ID | delete ID
                   assign --plan=PLAN_ID (--subaccount=ID|--directory=ID|--global-account=ID)
                          [--quota=N] [--unlimited] [--auto-assign]
                   quota ID --quota=N [--unlimited]
                   revoke ID
  environments     list [--subaccount=ID [--type=T]] | get ID
                   create --subaccount=ID --name=N [--type=cloudFoundry|kyma|abap] [--plan=standard]
                          [--landscape=L] [--memory=MB] [--routes=N] [--services=N]
                   update ID [--description=D] [--memory=MB] [--routes=N] [--services=N]
                   deprovision ID
  subscriptions    list [--subaccount=ID] | get ID
                   create --subaccount=ID --app=APP [--plan=P]
                   plan ID --plan=P
                   unsubscribe ID
  plans            list [--service=S|--category=C|--region=R] | get ID | delete ID
                   create --service=S --plan=P [--display-name=N] [--category=service|application|environment]
                          [--pricing=free|subscription|consumption|byol] [--max-quota=N] [--unit=U]
                          [--regions=eu10,us10] [--description=D] [--beta]
  labels           list [--resource-type=T --resource-id=ID | --resource-type=T --key=K] | get ID | delete ID
                   create --resource-type=subaccount|globalAccount|directory|environment|subscription
                          --resource-id=ID --key=K --values=v1,v2
                   update ID --values=v1,v2
  events           list [--global-account=ID] [--subaccount=ID] [--category=C] [--severity=MIN]
                        [--since=DATE] [--limit=N] | get ID
                   prune --days=N

Aliases: ga, dirs, subs, ents, envs, saas, plans, labels, events
DATE: 2026-11-09 or 2026-11-09T10:00:00Z
`;

/// The command line adapter.
class ManagementCli {
  protected ManagementPorts ports;
  protected ManagementConfig config;
  protected void delegate(string) @safe output;
  protected TenantId tenant;
  protected bool json;

  this(ManagementPorts ports, ManagementConfig config, void delegate(string) @safe output) {
    this.ports = ports;
    this.config = config;
    this.output = output;
  }

  /// Run one command. Returns the process exit code (0 ok, 1 failure, 2 usage).
  int run(const string[] argv) {
    auto a = CliArgs.parse(argv);
    tenant = TenantId(a.opt("tenant", config.defaultTenant));
    json = a.flag("json");

    try {
      if (a.positional.length == 0 || a.flag("help") || a.arg(0) == "help") {
        output(cliUsage);
        return a.positional.length == 0 && !a.flag("help") ? 2 : 0;
      }
      switch (a.arg(0)) {
      case "overview", "stats":
        return overview(a);
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      case "seed":
        return emitResult(ports.demoData.seed(tenant, a.flag("force")));
      case "global-accounts", "global-account", "ga":
        return globalAccounts(a);
      case "directories", "directory", "dirs":
        return directories(a);
      case "subaccounts", "subaccount", "subs":
        return subaccounts(a);
      case "entitlements", "entitlement", "ents":
        return entitlements(a);
      case "environments", "environment", "envs":
        return environments(a);
      case "subscriptions", "subscription", "saas":
        return subscriptions(a);
      case "plans", "service-plans", "plan":
        return plans(a);
      case "labels", "label":
        return labels(a);
      case "events", "event":
        return events(a);
      default:
        throw new CliUsageError("unknown resource '" ~ a.arg(0) ~ "'");
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-management-cli help' for usage.\n");
      return 2;
    } catch (Exception e) {
      output("error: " ~ e.msg ~ "\n");
      return 1;
    }
  }

  // ── output helpers ─────────────────────────────────────────────────────

  protected int emit(Json data, lazy string text) {
    output(json ? data.toPrettyString ~ "\n" : text);
    return 0;
  }

  protected int emitTable(T)(const T[] items, Table table) {
    auto arr = Json.emptyArray;
    foreach (i; items)
      arr ~= i.toJson;
    return emit(arr, table.render ~ "%d record(s)\n".format(table.length));
  }

  protected int emitOne(T)(const T item, string what, string id) {
    if (item.isNull)
      throw new Exception(what ~ " '" ~ id ~ "' not found in tenant '" ~ tenant.value ~ "'");
    return emit(item.toJson, item.toJson.toPrettyString ~ "\n");
  }

  protected int emitResult(UsecaseResult r) {
    if (json)
      output(r.toJson.toPrettyString ~ "\n");
    else if (r.isSuccess)
      output((r.message.length ? r.message : "OK") ~ (r.id.length ? " (" ~ r.id ~ ")" : "") ~ "\n");
    else
      output("failed: " ~ r.message ~ "\n");
    return r.isSuccess ? 0 : 1;
  }

  protected noreturn unknown(const CliArgs a) {
    throw new CliUsageError("unknown '" ~ a.arg(0) ~ "' command '" ~ a.arg(1) ~ "'");
  }

  // ── general ────────────────────────────────────────────────────────────

  protected int overview(const CliArgs a) {
    if (a.has("global-account")) {
      auto o = ports.overview.getOverview(tenant, GlobalAccountId(a.opt("global-account")));
      Table t;
      t.headers = ["Figure", "Value"];
      foreach (k, v; o.toJson.get!(Json[string]))
        t.rows ~= [k, v.toString];
      t.rows.sort();
      return emit(o.toJson, t.render);
    }
    auto o = ports.overview.getTenantOverview(tenant);
    return emit(o.toJson, overviewTable(o).render);
  }

  // ── resources ──────────────────────────────────────────────────────────

  protected int globalAccounts(const CliArgs a) {
    auto p = ports.globalAccounts;
    switch (a.arg(1)) {
    case "list", "": {
      auto items = a.has("status") ? p.listAccounts(tenant, a.opt("status")) : p.listAccounts(tenant);
      return emitTable(items, globalAccountTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "global account id");
      return emitOne(p.getAccount(tenant, GlobalAccountId(id)), "Global account", id);
      }
    case "create": {
      CreateGlobalAccountRequest r;
      r.tenantId = tenant;
      r.displayName = a.requireOpt("name");
      r.region = a.requireOpt("region");
      r.description = a.opt("description");
      r.licenseType = a.opt("license");
      r.companyName = a.opt("company");
      r.contactEmail = a.opt("email");
      r.contractNumber = a.opt("contract");
      r.costCenter = a.opt("cost-center");
      r.maxSubaccounts = a.intOpt("max-subaccounts", 0);
      r.maxDirectories = a.intOpt("max-directories", 0);
      r.createdBy = UserId(a.opt("user", "cli"));
      return emitResult(p.createAccount(r));
      }
    case "update": {
      UpdateGlobalAccountRequest r;
      r.tenantId = tenant;
      r.accountId = GlobalAccountId(a.requireArg(2, "global account id"));
      r.displayName = a.opt("name");
      r.description = a.opt("description");
      r.companyName = a.opt("company");
      r.contactEmail = a.opt("email");
      r.costCenter = a.opt("cost-center");
      r.maxSubaccounts = a.intOpt("max-subaccounts", 0);
      r.maxDirectories = a.intOpt("max-directories", 0);
      r.updatedBy = UserId(a.opt("user", "cli"));
      return emitResult(p.updateAccount(r));
      }
    case "suspend": {
      return emitResult(p.suspendAccount(tenant, GlobalAccountId(a.requireArg(2, "global account id"))));
      }
    case "reactivate": {
      return emitResult(p.reactivateAccount(tenant, GlobalAccountId(a.requireArg(2, "global account id"))));
      }
    case "delete": {
      return emitResult(p.deleteAccount(tenant, GlobalAccountId(a.requireArg(2, "global account id"))));
      }
    default:
      unknown(a);
    }
  }

  protected int directories(const CliArgs a) {
    auto p = ports.directories;
    switch (a.arg(1)) {
    case "list", "": {
      AccountDirectory[] items;
      if (a.has("parent"))
        items = p.listDirectories(tenant, DirectoryId(a.opt("parent")));
      else if (a.has("global-account"))
        items = p.listDirectories(tenant, GlobalAccountId(a.opt("global-account")));
      else
        items = p.listDirectories(tenant);
      return emitTable(items, directoryTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "directory id");
      return emitOne(p.getDirectory(tenant, DirectoryId(id)), "Directory", id);
      }
    case "create": {
      CreateDirectoryRequest r;
      r.tenantId = tenant;
      r.accountId = GlobalAccountId(a.requireOpt("global-account"));
      r.parentDirectoryId = DirectoryId(a.opt("parent"));
      r.displayName = a.requireOpt("name");
      r.description = a.opt("description");
      r.features = a.listOpt("features");
      r.createdBy = UserId(a.opt("user", "cli"));
      return emitResult(p.createDirectory(r));
      }
    case "update": {
      UpdateDirectoryRequest r;
      r.tenantId = tenant;
      r.directoryId = DirectoryId(a.requireArg(2, "directory id"));
      r.displayName = a.opt("name");
      r.description = a.opt("description");
      return emitResult(p.updateDirectory(r));
      }
    case "delete": {
      return emitResult(p.deleteDirectory(tenant, DirectoryId(a.requireArg(2, "directory id"))));
      }
    default:
      unknown(a);
    }
  }

  protected int subaccounts(const CliArgs a) {
    auto p = ports.subaccounts;
    switch (a.arg(1)) {
    case "list", "": {
      Subaccount[] items;
      if (a.has("directory"))
        items = p.listSubaccounts(tenant, DirectoryId(a.opt("directory")));
      else if (a.has("global-account") && a.has("region"))
        items = p.listSubaccounts(tenant, GlobalAccountId(a.opt("global-account")), a.opt("region"));
      else if (a.has("global-account"))
        items = p.listSubaccounts(tenant, GlobalAccountId(a.opt("global-account")));
      else
        items = p.listSubaccounts(tenant);
      return emitTable(items, subaccountTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "subaccount id");
      return emitOne(p.getSubaccount(tenant, SubaccountId(id)), "Subaccount", id);
      }
    case "create": {
      CreateSubaccountRequest r;
      r.tenantId = tenant;
      r.globalAccountId = GlobalAccountId(a.requireOpt("global-account"));
      r.parentDirectoryId = DirectoryId(a.opt("directory"));
      r.displayName = a.requireOpt("name");
      r.subdomain = a.requireOpt("subdomain");
      r.region = a.requireOpt("region");
      r.description = a.opt("description");
      r.usage = a.opt("usage");
      r.betaEnabled = a.flag("beta");
      r.usedForProduction = a.flag("production");
      r.createdBy = UserId(a.opt("user", "cli"));
      return emitResult(p.createSubaccount(r));
      }
    case "update": {
      auto id = SubaccountId(a.requireArg(2, "subaccount id"));
      auto current = p.getSubaccount(tenant, id);
      if (current.isNull)
        throw new Exception("Subaccount '" ~ id.value ~ "' not found");
      UpdateSubaccountRequest r;
      r.tenantId = tenant;
      r.subaccountId = id;
      r.displayName = a.opt("name");
      r.description = a.opt("description");
      r.usage = a.opt("usage");
      r.betaEnabled = a.has("beta") ? a.flag("beta") : current.betaEnabled;
      r.usedForProduction = a.has("production") ? a.flag("production") : current.usedForProduction;
      return emitResult(p.updateSubaccount(r));
      }
    case "move": {
      auto id = SubaccountId(a.requireArg(2, "subaccount id"));
      MoveSubaccountRequest r;
      r.tenantId = tenant;
      r.subaccountId = id;
      r.targetDirectoryId = DirectoryId(a.opt("directory"));
      r.movedBy = UserId(a.opt("user", "cli"));
      return emitResult(p.moveSubaccount(tenant, id, r));
      }
    case "suspend": {
      return emitResult(p.suspendSubaccount(tenant, SubaccountId(a.requireArg(2, "subaccount id"))));
      }
    case "reactivate": {
      return emitResult(p.reactivateSubaccount(tenant, SubaccountId(a.requireArg(2, "subaccount id"))));
      }
    case "delete": {
      return emitResult(p.deleteSubaccount(tenant, SubaccountId(a.requireArg(2, "subaccount id"))));
      }
    default:
      unknown(a);
    }
  }

  protected int entitlements(const CliArgs a) {
    auto p = ports.entitlements;
    switch (a.arg(1)) {
    case "list", "": {
      Entitlement[] items;
      if (a.has("subaccount"))
        items = p.listEntitlements(tenant, SubaccountId(a.opt("subaccount")));
      else if (a.has("directory"))
        items = p.listEntitlements(tenant, DirectoryId(a.opt("directory")));
      else if (a.has("global-account"))
        items = p.listEntitlements(tenant, GlobalAccountId(a.opt("global-account")));
      else
        items = p.listEntitlements(tenant);
      return emitTable(items, entitlementTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "entitlement id");
      return emitOne(p.getEntitlement(tenant, EntitlementId(id)), "Entitlement", id);
      }
    case "assign": {
      AssignEntitlementRequest r;
      r.tenantId = tenant;
      r.servicePlanId = ServicePlanId(a.requireOpt("plan"));
      r.globalAccountId = GlobalAccountId(a.opt("global-account"));
      r.subaccountId = SubaccountId(a.opt("subaccount"));
      r.directoryId = DirectoryId(a.opt("directory"));
      r.unlimited = a.flag("unlimited");
      r.quotaAssigned = a.intOpt("quota", r.unlimited ? 0 : 1);
      r.autoAssign = a.flag("auto-assign");
      r.assignedBy = UserId(a.opt("user", "cli"));
      return emitResult(p.assignEntitlement(r));
      }
    case "quota": {
      UpdateEntitlementQuotaRequest r;
      r.tenantId = tenant;
      r.entitlementId = EntitlementId(a.requireArg(2, "entitlement id"));
      r.unlimited = a.flag("unlimited");
      r.quotaAssigned = r.unlimited ? 0 : a.intOpt("quota", -1);
      if (!r.unlimited && r.quotaAssigned < 0)
        throw new CliUsageError("missing option: --quota (or --unlimited)");
      return emitResult(p.updateEntitlementQuota(r));
      }
    case "revoke": {
      return emitResult(p.revokeEntitlement(tenant, EntitlementId(a.requireArg(2, "entitlement id"))));
      }
    case "delete": {
      return emitResult(p.deleteEntitlement(tenant, EntitlementId(a.requireArg(2, "entitlement id"))));
      }
    default:
      unknown(a);
    }
  }

  protected int environments(const CliArgs a) {
    auto p = ports.environments;
    switch (a.arg(1)) {
    case "list", "": {
      Environment[] items;
      if (a.has("subaccount") && a.has("type"))
        items = p.listEnvironments(tenant, SubaccountId(a.opt("subaccount")), a.opt("type"));
      else if (a.has("subaccount"))
        items = p.listEnvironments(tenant, SubaccountId(a.opt("subaccount")));
      else
        items = p.listEnvironments(tenant);
      return emitTable(items, environmentTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "environment id");
      return emitOne(p.getEnvironment(tenant, EnvironmentId(id)), "Environment", id);
      }
    case "create": {
      CreateEnvironmentRequest r;
      r.tenantId = tenant;
      r.subaccountId = SubaccountId(a.requireOpt("subaccount"));
      r.name = a.requireOpt("name");
      r.description = a.opt("description");
      r.environmentType = a.opt("type", "cloudFoundry");
      r.planName = a.opt("plan", "standard");
      r.landscapeLabel = a.opt("landscape");
      r.memoryQuotaMb = a.intOpt("memory", 0);
      r.routeQuota = a.intOpt("routes", 0);
      r.serviceQuota = a.intOpt("services", 0);
      r.createdBy = UserId(a.opt("user", "cli"));
      return emitResult(p.createEnvironment(r));
      }
    case "update": {
      UpdateEnvironmentRequest r;
      r.tenantId = tenant;
      r.instanceId = EnvironmentId(a.requireArg(2, "environment id"));
      r.description = a.opt("description");
      r.memoryQuotaMb = a.intOpt("memory", 0);
      r.routeQuota = a.intOpt("routes", 0);
      r.serviceQuota = a.intOpt("services", 0);
      return emitResult(p.updateEnvironment(r));
      }
    case "deprovision", "delete": {
      return emitResult(p.deprovisionEnvironment(tenant, EnvironmentId(a.requireArg(2, "environment id"))));
      }
    default:
      unknown(a);
    }
  }

  protected int subscriptions(const CliArgs a) {
    auto p = ports.subscriptions;
    switch (a.arg(1)) {
    case "list", "": {
      auto items = a.has("subaccount")
        ? p.listSubscriptions(tenant, SubaccountId(a.opt("subaccount"))) : p.listSubscriptions(tenant);
      return emitTable(items, subscriptionTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "subscription id");
      return emitOne(p.getSubscription(tenant, SubscriptionId(id)), "Subscription", id);
      }
    case "create", "subscribe": {
      CreateSubscriptionRequest r;
      r.tenantId = tenant;
      r.subaccountId = SubaccountId(a.requireOpt("subaccount"));
      r.appName = a.requireOpt("app");
      r.planName = a.opt("plan");
      r.subscribedBy = UserId(a.opt("user", "cli"));
      return emitResult(p.createSubscription(r));
      }
    case "plan": {
      UpdateSubscriptionRequest r;
      r.tenantId = tenant;
      r.subscriptionId = SubscriptionId(a.requireArg(2, "subscription id"));
      r.planName = a.requireOpt("plan");
      return emitResult(p.updateSubscriptionPlan(r));
      }
    case "unsubscribe", "delete": {
      return emitResult(p.unsubscribeSubscription(tenant, SubscriptionId(a.requireArg(2, "subscription id"))));
      }
    default:
      unknown(a);
    }
  }

  protected int plans(const CliArgs a) {
    auto p = ports.servicePlans;
    switch (a.arg(1)) {
    case "list", "": {
      ServicePlan[] items;
      if (a.has("service"))
        items = p.listPlansByService(tenant, a.opt("service"));
      else if (a.has("category"))
        items = p.listPlansByCategory(tenant, a.opt("category"));
      else if (a.has("region"))
        items = p.listPlansByRegion(tenant, a.opt("region"));
      else
        items = p.listPlans(tenant);
      return emitTable(items, servicePlanTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "service plan id");
      return emitOne(p.getPlan(tenant, ServicePlanId(id)), "Service plan", id);
      }
    case "create": {
      CreateServicePlanRequest r;
      r.tenantId = tenant;
      r.serviceName = a.requireOpt("service");
      r.planName = a.requireOpt("plan");
      r.serviceDisplayName = a.opt("display-name");
      r.description = a.opt("description");
      r.category = a.opt("category");
      r.pricingModel = a.opt("pricing");
      r.maxQuota = a.intOpt("max-quota", 0);
      r.unit = a.opt("unit");
      r.availableRegions = a.listOpt("regions");
      r.isBeta = a.flag("beta");
      r.createdBy = UserId(a.opt("user", "cli"));
      return emitResult(p.createPlan(r));
      }
    case "delete": {
      return emitResult(p.deletePlan(tenant, ServicePlanId(a.requireArg(2, "service plan id"))));
      }
    default:
      unknown(a);
    }
  }

  protected int labels(const CliArgs a) {
    auto p = ports.labels;
    switch (a.arg(1)) {
    case "list", "": {
      Label[] items;
      if (a.has("resource-type") && a.has("resource-id"))
        items = p.listLabels(tenant, a.opt("resource-type"), a.opt("resource-id"));
      else if (a.has("resource-type") && a.has("key"))
        items = p.listLabelsByKey(tenant, a.opt("resource-type"), a.opt("key"));
      else
        items = p.listLabels(tenant);
      return emitTable(items, labelTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "label id");
      return emitOne(p.getLabel(tenant, LabelId(id)), "Label", id);
      }
    case "create": {
      CreateLabelRequest r;
      r.tenantId = tenant;
      r.resourceType = a.requireOpt("resource-type");
      r.resourceId = a.requireOpt("resource-id");
      r.key = a.requireOpt("key");
      r.values = a.listOpt("values");
      r.createdBy = UserId(a.opt("user", "cli"));
      return emitResult(p.createLabel(r));
      }
    case "update": {
      auto id = LabelId(a.requireArg(2, "label id"));
      UpdateLabelRequest r;
      r.tenantId = tenant;
      r.labelId = id;
      r.values = a.listOpt("values");
      r.updatedBy = UserId(a.opt("user", "cli"));
      return emitResult(p.updateLabel(tenant, id, r));
      }
    case "delete": {
      return emitResult(p.deleteLabel(tenant, LabelId(a.requireArg(2, "label id"))));
      }
    default:
      unknown(a);
    }
  }

  protected int events(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "": {
      QueryEventsRequest q;
      q.tenantId = tenant;
      q.globalAccountId = GlobalAccountId(a.opt("global-account"));
      q.subaccountId = SubaccountId(a.opt("subaccount"));
      q.category = a.opt("category");
      q.severity = a.opt("severity");
      q.sinceTimestamp = parseCliTime(a.opt("since"));
      q.limit = a.intOpt("limit", 50);
      auto items = ports.events.queryEvents(q);
      return emitTable(items, eventTable(items));
      }
    case "get": {
      auto id = a.requireArg(2, "event id");
      return emitOne(ports.events.getEvent(tenant, EnvironmentEventId(id)), "Event", id);
      }
    case "prune": {
      return emitResult(ports.pruneEvents.pruneEvents(tenant, a.intOpt("days", config.eventRetentionDays)));
      }
    default:
      unknown(a);
    }
  }
}

///
unittest {
  mixin(ShowTest!("ManagementCli"));

  ManagementConfig cfg;
  cfg.storage = "memory";
  auto ports = buildContainer(cfg).ports;
  string captured;
  auto cli = new ManagementCli(ports, cfg, (string s) { captured ~= s; });

  assert(cli.run([]) == 2);
  assert(cli.run(["help"]) == 0 && captured.canFind("Usage:"));
  assert(cli.run(["seed"]) == 0);

  captured = "";
  assert(cli.run(["subaccounts", "list"]) == 0);
  assert(captured.canFind("acme-sales-dev") && captured.canFind("4 record(s)"));

  captured = "";
  assert(cli.run(["ga", "--json"]) == 0);
  auto gas = parseJsonString(captured);
  assert(gas.length == 1);
  auto gaId = gas[0]["id"].get!string;

  captured = "";
  assert(cli.run(["subaccounts", "create", "--global-account=" ~ gaId, "--name=QA",
      "--subdomain=acme-qa", "--region=eu10", "--usage=test"]) == 0);
  assert(captured.canFind("Subaccount created"));
  assert(cli.run(["subaccounts", "create", "--global-account=" ~ gaId, "--name=QA2",
      "--subdomain=acme-qa", "--region=eu10"]) == 1); // subdomain taken
  assert(cli.run(["subaccounts", "create", "--name=x"]) == 2); // missing option
  assert(cli.run(["nonsense"]) == 2);
  assert(cli.run(["subaccounts", "get", "missing"]) == 1);

  captured = "";
  assert(cli.run(["overview"]) == 0 && captured.canFind("Subaccounts"));
  captured = "";
  assert(cli.run(["events", "--limit=3"]) == 0 && captured.canFind("3 record(s)"));
}
