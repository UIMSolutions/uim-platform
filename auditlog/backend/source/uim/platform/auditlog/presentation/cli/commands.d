/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Talks to the application exclusively via the
/// driving ports (AuditLogPorts) — exactly like the HTTP/OData/GUI adapters.
module uim.platform.auditlog.presentation.cli.commands;

import uim.platform.auditlog;
import uim.platform.auditlog.presentation.cli.args;
import uim.platform.auditlog.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-auditlog-cli — SAP BTP style Audit Log administration

Usage: uim-auditlog-cli <command> [subcommand] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     use volatile storage (testing)
  --json               machine readable JSON output

Commands:
  stats                                   aggregated figures of the tenant
  config                                  effective service configuration
  logs list   [--category=c1,c2] [--from=DATE] [--to=DATE] [--limit=N] [--offset=N]
  logs get    <id>
  logs write  --message=TEXT [--category=configuration] [--severity=info]
              [--action=create] [--outcome=success] [--user=ID] [--service=ID]
              [--object-type=T] [--object-id=ID] [--correlation-id=ID]
  security list | get <id>
  security write  --event-type=login --user=ID [--outcome=success] [--ip=ADDR]
                  [--auth-method=password] [--risk=low] [--failure-reason=TEXT]
  data-access list | get <id>
  data-access write --user=ID --subject=NAME --object-type=T --object-id=ID
                    [--fields=f1,f2] [--purpose=TEXT] [--channel=api]
  config-changes list | get <id>
  config-changes write --user=ID --config-type=T --object-id=ID
                       [--name=ATTR --old=V --new=V] [--reason=TEXT]
  retention list | get <id> | delete <id> | enforce
  retention create --name=NAME --days=N [--categories=c1,c2] [--description=TEXT] [--default]
  retention update <id> [--name=..] [--days=N] [--categories=..] [--status=active|inactive|expired]
  audit-config show
  audit-config set [--name=..] [--status=enabled|disabled] [--data-access=on|off]
                   [--data-modification=on|off] [--security-events=on|off]
                   [--config-changes=on|off] [--masking=on|off] [--masked-fields=a,b]
                   [--min-severity=info] [--rate-limit=N]
  exports list | get <id> | delete <id>
  exports create [--format=json|csv] [--categories=..] [--from=DATE] [--to=DATE] [--user=ID]
  exports download <id> [--out=FILE]
  help

Categories: securityEvents, configuration, dataAccess, dataModification
DATE: 2026-11-09 or 2026-11-09T10:00:00Z
`;

/// The command line adapter.
class AuditLogCli {
  protected AuditLogPorts ports;
  protected AuditLogConfig config;
  protected void delegate(string) @safe output;
  protected TenantId tenant;
  protected bool json;

  this(AuditLogPorts ports, AuditLogConfig config, void delegate(string) @safe output) {
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
      case "stats":
        return stats();
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString);
      case "logs":
        return logs(a);
      case "security":
        return security(a);
      case "data-access":
        return dataAccess(a);
      case "config-changes":
        return configChanges(a);
      case "retention":
        return retention(a);
      case "audit-config":
        return auditConfig(a);
      case "exports":
        return exports(a);
      default:
        throw new CliUsageError("unknown command '" ~ a.arg(0) ~ "'");
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-auditlog-cli help' for usage.\n");
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

  protected int emitOne(T)(const T item) {
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

  protected void notFound(string what, string id) {
    throw new Exception(what ~ " '" ~ id ~ "' not found in tenant '" ~ tenant.value ~ "'");
  }

  // ── commands ───────────────────────────────────────────────────────────

  protected int stats() {
    auto s = ports.statistics.statistics(tenant);
    return emit(s.toJson, statisticsTable(s).render);
  }

  protected int logs(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "":
      AuditLogQueryRequest q;
      q.tenantId = tenant;
      q.categories = a.listOpt("category").toAuditCategory;
      q.timeFrom = parseCliTime(a.opt("from"));
      q.timeTo = parseCliTime(a.opt("to"));
      q.limit = a.intOpt("limit", 50);
      q.offset = a.intOpt("offset", 0);
      auto entries = ports.retrieveAuditLogs.queryAuditLogs(q);
      return emitTable(entries, auditLogTable(entries));

    case "get":
      auto id = AuditLogId(a.requireArg(2, "audit log id"));
      if (!ports.retrieveAuditLogs.hasAuditLog(tenant, id))
        notFound("Audit log", id.value);
      return emitOne(ports.retrieveAuditLogs.getAuditLog(tenant, id));

    case "write":
      WriteAuditLogRequest r;
      r.tenantId = tenant;
      r.message = a.requireOpt("message");
      r.category = a.opt("category", "configuration").toAuditCategory;
      r.severity = a.opt("severity", "info").toAuditSeverity;
      r.action = a.opt("action", "create").toAuditAction;
      r.outcome = a.opt("outcome", "success").toAuditOutcome;
      r.userId = UserId(a.opt("user", "cli"));
      r.userName = a.opt("user-name");
      r.serviceId = ServiceId(a.opt("service", "auditlog-cli"));
      r.serviceName = a.opt("service-name");
      r.objectType = a.opt("object-type");
      r.objectId = a.opt("object-id");
      r.correlationId = a.opt("correlation-id");
      r.originApp = "uim-auditlog-cli";
      return emitResult(ports.writeAuditLog.writeAuditLog(r));

    default:
      throw new CliUsageError("unknown 'logs' subcommand '" ~ a.arg(1) ~ "'");
    }
  }

  protected int security(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "":
      auto events = ports.browseRecords.listSecurityEvents(tenant);
      return emitTable(events, securityEventTable(events));
    case "get":
      auto e = ports.browseRecords.getSecurityEvent(tenant, SecurityEventId(a.requireArg(2, "id")));
      if (e.id.isEmpty)
        notFound("Security event", a.arg(2));
      return emitOne(e);
    case "write":
      WriteSecurityEventRequest r;
      r.tenantId = tenant;
      r.eventType = a.requireOpt("event-type");
      r.userId = UserId(a.requireOpt("user"));
      r.userName = a.opt("user-name");
      r.outcome = a.opt("outcome", "success").toAuditOutcome;
      r.ipAddress = a.opt("ip");
      r.authMethod = a.opt("auth-method");
      r.identityProvider = a.opt("idp");
      r.clientId = a.opt("client-id");
      r.riskLevel = a.opt("risk");
      r.failureReason = a.opt("failure-reason");
      r.correlationId = a.opt("correlation-id");
      return emitResult(ports.writeSecurityEvent.writeEvent(r));
    default:
      throw new CliUsageError("unknown 'security' subcommand '" ~ a.arg(1) ~ "'");
    }
  }

  protected int dataAccess(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "":
      auto logs = ports.browseRecords.listDataAccessLogs(tenant);
      return emitTable(logs, dataAccessTable(logs));
    case "get":
      auto e = ports.browseRecords.getDataAccessLog(tenant, DataAccessLogId(a.requireArg(2, "id")));
      if (e.id.isEmpty)
        notFound("Data access log", a.arg(2));
      return emitOne(e);
    case "write":
      WriteDataAccessLogRequest r;
      r.tenantId = tenant;
      r.accessedBy = UserId(a.requireOpt("user"));
      r.dataSubject = a.requireOpt("subject");
      r.dataObjectType = a.requireOpt("object-type");
      r.dataObjectId = a.requireOpt("object-id");
      r.accessedFields = a.listOpt("fields");
      r.purpose = a.opt("purpose");
      r.channel = a.opt("channel", "cli");
      return emitResult(ports.writeDataAccessLog.writeLog(r));
    default:
      throw new CliUsageError("unknown 'data-access' subcommand '" ~ a.arg(1) ~ "'");
    }
  }

  protected int configChanges(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "":
      auto logs = ports.browseRecords.listConfigChangeLogs(tenant);
      return emitTable(logs, configChangeTable(logs));
    case "get":
      auto e = ports.browseRecords.getConfigChangeLog(tenant, ConfigChangeLogId(a.requireArg(2, "id")));
      if (e.id.isEmpty)
        notFound("Config change log", a.arg(2));
      return emitOne(e);
    case "write":
      WriteConfigChangeLogRequest r;
      r.tenantId = tenant;
      r.changedBy = UserId(a.requireOpt("user"));
      r.configType = a.requireOpt("config-type");
      r.configObjectId = a.requireOpt("object-id");
      if (a.has("name"))
        r.changes ~= AuditAttribute(a.opt("name"), a.opt("old"), a.opt("new"));
      r.reason = a.opt("reason");
      return emitResult(ports.writeConfigChange.writeChange(r));
    default:
      throw new CliUsageError("unknown 'config-changes' subcommand '" ~ a.arg(1) ~ "'");
    }
  }

  protected int retention(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "":
      auto policies = ports.manageRetention.listPolicies(tenant);
      return emitTable(policies, retentionTable(policies));

    case "get":
      auto id = RetentionPolicyId(a.requireArg(2, "policy id"));
      if (!ports.manageRetention.existsPolicy(tenant, id))
        notFound("Retention policy", id.value);
      return emitOne(ports.manageRetention.getPolicy(tenant, id));

    case "create":
      CreateRetentionPolicyRequest r;
      r.tenantId = tenant;
      r.name = a.requireOpt("name");
      r.description = a.opt("description");
      r.retentionDays = a.intOpt("days", 90);
      r.categories = a.listOpt("categories").toAuditCategory;
      r.isDefault = a.flag("default");
      return emitResult(ports.manageRetention.createPolicy(r));

    case "update":
      auto id = RetentionPolicyId(a.requireArg(2, "policy id"));
      if (!ports.manageRetention.existsPolicy(tenant, id))
        notFound("Retention policy", id.value);
      auto current = ports.manageRetention.getPolicy(tenant, id);
      UpdateRetentionPolicyRequest r;
      r.tenantId = tenant;
      r.retentionPolicyId = id;
      r.name = a.opt("name", current.name);
      r.description = a.opt("description", current.description);
      r.retentionDays = a.intOpt("days", current.retentionDays);
      r.categories = a.has("categories") ? a.listOpt("categories").toAuditCategory : current.categories.dup;
      r.status = a.has("status") ? a.opt("status").toRetentionStatus : current.status;
      return emitResult(ports.manageRetention.updatePolicy(r));

    case "delete":
      return emitResult(ports.manageRetention.deletePolicy(tenant,
          RetentionPolicyId(a.requireArg(2, "policy id"))));

    case "enforce":
      return emitResult(ports.enforceRetention.enforce(tenant));

    default:
      throw new CliUsageError("unknown 'retention' subcommand '" ~ a.arg(1) ~ "'");
    }
  }

  protected int auditConfig(const CliArgs a) {
    switch (a.arg(1)) {
    case "show", "list", "":
      auto configs = ports.manageAuditConfig.listAuditConfigs(tenant);
      return emitTable(configs, auditConfigTable(configs));

    case "set":
      bool onOff(string key, bool current) {
        if (!a.has(key))
          return current;
        auto v = a.opt(key).toLower;
        return v == "on" || v == "true" || v == "yes" || v == "1";
      }

      if (!ports.manageAuditConfig.existsAuditConfig(tenant)) {
        CreateAuditConfigRequest c;
        c.tenantId = tenant;
        c.name = a.opt("name", tenant.value ~ " audit configuration");
        c.logDataAccess = onOff("data-access", true);
        c.logDataModification = onOff("data-modification", true);
        c.logSecurityEvents = onOff("security-events", true);
        c.logConfigurationChanges = onOff("config-changes", true);
        c.enableDataMasking = onOff("masking", false);
        c.maskedFields = a.listOpt("masked-fields");
        c.excludedServices = a.listOpt("excluded-services");
        c.minimumSeverity = a.opt("min-severity", "info").toAuditSeverity;
        c.rateLimitPerSecond = a.intOpt("rate-limit", 8);
        return emitResult(ports.manageAuditConfig.createAuditConfig(c));
      }

      auto cur = ports.manageAuditConfig.getAuditConfig(tenant);
      UpdateAuditConfigRequest u;
      u.id = cur.id;
      u.tenantId = tenant;
      u.name = a.opt("name", cur.name);
      u.status = a.has("status") ? a.opt("status").toConfigStatus : cur.status;
      u.logDataAccess = onOff("data-access", cur.logDataAccess);
      u.logDataModification = onOff("data-modification", cur.logDataModification);
      u.logSecurityEvents = onOff("security-events", cur.logSecurityEvents);
      u.logConfigurationChanges = onOff("config-changes", cur.logConfigurationChanges);
      u.enableDataMasking = onOff("masking", cur.enableDataMasking);
      u.maskedFields = a.has("masked-fields") ? a.listOpt("masked-fields") : cur.maskedFields.dup;
      u.excludedServices = a.has("excluded-services") ? a.listOpt("excluded-services") : cur.excludedServices.dup;
      u.minimumSeverity = a.has("min-severity") ? a.opt("min-severity").toAuditSeverity : cur.minimumSeverity;
      u.rateLimitPerSecond = a.intOpt("rate-limit", cur.rateLimitPerSecond);
      return emitResult(ports.manageAuditConfig.updateAuditConfig(u));

    default:
      throw new CliUsageError("unknown 'audit-config' subcommand '" ~ a.arg(1) ~ "'");
    }
  }

  protected int exports(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "":
      auto jobs = ports.manageExports.listExports(tenant);
      return emitTable(jobs, exportTable(jobs));

    case "get":
      auto id = ExportJobId(a.requireArg(2, "export id"));
      if (!ports.manageExports.hasExport(tenant, id))
        notFound("Export job", id.value);
      return emitOne(ports.manageExports.getExport(tenant, id));

    case "create":
      CreateExportJobRequest r;
      r.tenantId = tenant;
      r.requestedBy = UserId(a.opt("user", "cli"));
      r.format_ = a.opt("format", "json").toExportFormat;
      r.categories = a.listOpt("categories").toAuditCategory;
      r.timeFrom = parseCliTime(a.opt("from"));
      r.timeTo = parseCliTime(a.opt("to"));
      return emitResult(ports.manageExports.createExport(r));

    case "delete":
      return emitResult(ports.manageExports.deleteExport(tenant, ExportJobId(a.requireArg(2, "export id"))));

    case "download":
      auto id = ExportJobId(a.requireArg(2, "export id"));
      if (!ports.manageExports.hasExport(tenant, id))
        notFound("Export job", id.value);
      auto content = ports.manageExports.renderExport(tenant, id);
      auto file = a.opt("out");
      if (file.length == 0) {
        output(content ~ "\n");
      } else {
        import std.file : write;

        (() @trusted => write(file, content))();
        output("written %d bytes to %s\n".format(content.length, file));
      }
      return 0;

    default:
      throw new CliUsageError("unknown 'exports' subcommand '" ~ a.arg(1) ~ "'");
    }
  }
}

///
unittest {
  mixin(ShowTest!("AuditLogCli"));

  AuditLogConfig cfg;
  cfg.storage = "memory";
  auto container = buildContainer(cfg);
  string captured;
  auto cli = new AuditLogCli(container.ports, cfg, (string s) { captured ~= s; });

  assert(cli.run(["logs", "write", "--message=hello cli", "--category=dataAccess"]) == 0);
  captured = null;
  assert(cli.run(["logs", "list"]) == 0);
  assert(captured.canFind("hello cli"));

  assert(cli.run(["retention", "create", "--name=short", "--days=30", "--default"]) == 0);
  captured = null;
  assert(cli.run(["retention", "list", "--json"]) == 0);
  assert(parseJsonString(captured).length == 1);

  captured = null;
  assert(cli.run(["stats", "--json"]) == 0);
  assert(parseJsonString(captured)["totalEntries"].get!long == 1);

  assert(cli.run(["nonsense"]) == 2);
  assert(cli.run(["logs", "get", "missing"]) == 1);
}
