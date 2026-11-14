/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Talks to the application exclusively via the
/// driving ports (AgentryPorts) — exactly like the HTTP/OData/GUI adapters.
module uim.platform.agentry.presentation.cli.commands;

import std.file : readText;
import uim.platform.agentry;
import uim.platform.agentry.presentation.cli.args;
import uim.platform.agentry.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-agentry-cli — Agentry mobile platform administration

Usage: uim-agentry-cli <resource> <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --user=<id>          acting user recorded in createdBy/updatedBy (default: cli)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     use volatile storage (testing)
  --json               machine readable JSON output

Resources and commands:
  stats                                       tenant figures
  config                                      effective service configuration

  apps list [--status=S] [--platform=P] | get <id> | delete <id>
  apps create --name=N --package=com.x.y [--platform=android|ios|windows|web|cross]
              [--vendor=V] [--category=C] [--description=D] [--email=E] [--min-os=V]
              [--offline] [--push]
  apps update <id> [same options]
  apps status <id> <draft|active|deprecated|archived>

  definitions list [--app=ID] [--status=S] | get <id> [--content] | delete <id>
  definitions create --app=ID --name=N (--file=PATH | --content=TEXT) [--format=json|xml]
                     [--schema=V] [--platform=P] [--bom=MODEL] [--description=D]
  definitions update <id> [same options]
  definitions validate|publish|archive <id>

  versions list [--app=ID] [--status=S] | get <id> | delete <id>
  versions create --app=ID --definition=ID --version=1.0.0 [--artifact=URL]
                  [--checksum=SHA] [--notes=TEXT] [--changelog=TEXT] [--min-os=V] [--mandatory]
  versions update <id> [same options]
  versions publish|withdraw <id>

  devices list [--app=ID] [--status=S] [--group=G] | get <id> | remove <id>
  devices enroll --app=ID --name=N --os=V [--platform=P] [--model=M] [--manufacturer=M]
                 [--group=G] [--email=E] [--user-id=U] [--mdm=ID] [--managed]
  devices update <id> [same options]
  devices status <id> <enrolled|active|suspended|removed>

  syncs list [--device=ID] [--status=S] | get <id> | delete <id>
  syncs create --device=ID --app=ID --connection=ID [--direction=upload|download|bidirectional]
               [--client-version=V]
  syncs start|cancel <id>
  syncs complete <id> [--bytes-sent=N] [--bytes-received=N] [--records-sent=N] [--records-received=N]
  syncs fail <id> [--error=TEXT]
  syncs expire [--timeout=MINUTES]

  connections list [--type=T] [--status=S] | get <id> | delete <id>
  connections create --name=N --url=URL [--type=s4hana|ecc|btp|crm|custom] [--auth=oauth2]
                     [--client-id=ID] [--sys-id=SID] [--sys-number=NN] [--client=NNN]
                     [--language=EN] [--destination=NAME] [--description=D] [--ssl]
  connections update <id> [same options]
  connections test <id>

  deployments list [--app=ID] [--status=S] | get <id> | delete <id>
  deployments create --version=ID [--app=ID] [--scope=tenant|group|device]
                     [--group=G] [--device=ID] [--scheduled=DATE] [--notes=TEXT]
  deployments update <id> [same options]
  deployments start|rollback <id>
  deployments complete <id> --succeeded=N [--failed=N]

  help

DATE: 2026-11-09 or 2026-11-09T10:00:00Z
`;

/// Option → payload key maps of the create/update commands.
private enum string[2][] appOptions = [
    ["name", "name"], ["package", "packageName"], ["platform", "platform"], ["vendor", "vendor"],
    ["category", "category"], ["description", "description"], ["email", "contactEmail"],
    ["min-os", "minOsVersion"], ["icon", "iconUrl"], ["backend", "backendSystemId"],
    ["offline", "offlineCapable"], ["push", "pushNotificationsEnabled"]
  ];
private enum string[2][] definitionOptions = [
    ["app", "applicationId"], ["name", "name"], ["content", "definitionContent"], ["format", "definitionFormat"],
    ["schema", "schemaVersion"], ["platform", "targetPlatform"], ["bom", "businessObjectModel"],
    ["description", "description"]
  ];
private enum string[2][] versionOptions = [
    ["app", "applicationId"], ["definition", "definitionId"], ["version", "versionNumber"],
    ["artifact", "artifactUrl"], ["checksum", "checksum"], ["notes", "releaseNotes"],
    ["changelog", "changeLog"], ["min-os", "minOsVersion"], ["mandatory", "isMandatoryUpdate"]
  ];
private enum string[2][] deviceOptions = [
    ["app", "applicationId"], ["name", "deviceName"], ["os", "osVersion"], ["platform", "platform"],
    ["model", "deviceModel"], ["manufacturer", "manufacturer"], ["group", "groupName"],
    ["email", "userEmail"], ["user-id", "userId"], ["mdm", "mdmDeviceId"], ["managed", "isManaged"],
    ["app-version", "appVersionInstalled"], ["push-token", "pushToken"]
  ];
private enum string[2][] syncOptions = [
    ["device", "deviceId"], ["app", "applicationId"], ["connection", "connectionId"],
    ["direction", "direction"], ["client-version", "clientAppVersion"]
  ];
private enum string[2][] connectionOptions = [
    ["name", "name"], ["url", "backendUrl"], ["type", "backendType"], ["auth", "authMethod"],
    ["client-id", "clientId"], ["sys-id", "sysId"], ["sys-number", "sysNumber"], ["client", "client"],
    ["language", "language"], ["destination", "destinationName"], ["description", "description"],
    ["ssl", "sslEnabled"], ["fingerprint", "certificateFingerprint"]
  ];
private enum string[2][] deploymentOptions = [
    ["version", "appVersionId"], ["app", "applicationId"], ["scope", "scope"], ["group", "targetGroupName"],
    ["device", "targetDeviceId"], ["notes", "notes"]
  ];

/// The command line adapter.
class AgentryCli {
  protected AgentryPorts ports;
  protected AgentryConfig config;
  protected void delegate(string) @safe output;
  protected TenantId tenant;
  protected UserId user;
  protected bool json;

  this(AgentryPorts ports, AgentryConfig config, void delegate(string) @safe output) {
    this.ports = ports;
    this.config = config;
    this.output = output;
  }

  /// Run one command. Returns the process exit code (0 ok, 1 failure, 2 usage).
  int run(const string[] argv) {
    auto a = CliArgs.parse(argv);
    tenant = TenantId(a.opt("tenant", config.defaultTenant));
    user = UserId(a.opt("user", "cli"));
    json = a.flag("json");

    try {
      if (a.positional.length == 0 || a.flag("help") || a.arg(0) == "help") {
        output(cliUsage);
        return a.positional.length == 0 && !a.flag("help") ? 2 : 0;
      }
      switch (a.arg(0)) {
      case "stats":
        auto s = ports.statistics.statistics(tenant);
        return emit(s.toJson, statisticsTable(s).render);
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      case "apps":
        return apps(a);
      case "definitions":
        return definitions(a);
      case "versions":
        return versions(a);
      case "devices":
        return devices(a);
      case "syncs":
        return syncs(a);
      case "connections":
        return connections(a);
      case "deployments":
        return deployments(a);
      default:
        throw new CliUsageError("unknown resource '" ~ a.arg(0) ~ "'");
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-agentry-cli help' for usage.\n");
      return 2;
    } catch (PayloadException e) {
      output("error: " ~ e.msg ~ "\n");
      return 2;
    } catch (Exception e) {
      output("error: " ~ e.msg ~ "\n");
      return 1;
    }
  }

  // ── resources ──────────────────────────────────────────────────────────

  protected int apps(const CliArgs a) {
    auto p = ports.mobileApplications;
    switch (command(a)) {
    case "list":
      auto items = p.listMobileApplications(tenant);
      if (a.has("status"))
        items = items.filter!(e => enumValue(e.status) == a.opt("status")).array;
      if (a.has("platform"))
        items = items.filter!(e => enumValue(e.platform) == a.opt("platform")).array;
      return emitTable(items, mobileApplicationTable(items));
    case "get":
      return emitOne(found(p.getMobileApplication(tenant, MobileApplicationId(a.requireArg(2, "id")))));
    case "create":
      MobileApplicationDTO dto;
      readPayload(dto, body(a, appOptions));
      dto.tenantId = tenant;
      dto.createdBy = user;
      return emitResult(p.createMobileApplication(dto));
    case "update":
      auto id = MobileApplicationId(a.requireArg(2, "id"));
      auto dto = MobileApplicationDTO.fromEntity(found(p.getMobileApplication(tenant, id)));
      readPayload(dto, body(a, appOptions));
      dto.updatedBy = user;
      return emitResult(p.updateMobileApplication(dto));
    case "status":
      return emitResult(p.setMobileApplicationStatus(tenant, MobileApplicationId(a.requireArg(2, "id")),
          enumArg!AppStatus(a, 3), user));
    case "delete":
      return emitResult(p.deleteMobileApplication(tenant, MobileApplicationId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int definitions(const CliArgs a) {
    auto p = ports.appDefinitions;
    switch (command(a)) {
    case "list":
      auto items = a.has("app") ? p.listDefinitions(tenant, MobileApplicationId(a.opt("app")))
        : p.listDefinitions(tenant);
      if (a.has("status"))
        items = items.filter!(e => enumValue(e.status) == a.opt("status")).array;
      return emitTable(items, appDefinitionTable(items));
    case "get":
      auto def = found(p.getDefinition(tenant, AppDefinitionId(a.requireArg(2, "id"))));
      if (a.flag("content") && !json) {
        output(def.definitionContent ~ "\n");
        return 0;
      }
      return emit(def.toJson.set("definitionContent", def.definitionContent),
        def.toJson.set("definitionContent", def.definitionContent).toPrettyString ~ "\n");
    case "create":
      AppDefinitionDTO dto;
      readPayload(dto, definitionBody(a));
      dto.tenantId = tenant;
      dto.createdBy = user;
      return emitResult(p.createDefinition(dto));
    case "update":
      auto id = AppDefinitionId(a.requireArg(2, "id"));
      auto dto = AppDefinitionDTO.fromEntity(found(p.getDefinition(tenant, id)));
      readPayload(dto, definitionBody(a));
      dto.updatedBy = user;
      return emitResult(p.updateDefinition(dto));
    case "validate":
      auto r = p.validateDefinition(tenant, AppDefinitionId(a.requireArg(2, "id")));
      if (!json && r.isSuccess)
        foreach (e; r.data["errors"].get!(Json[]))
          output("  - " ~ e.get!string ~ "\n");
      return emitResult(r);
    case "publish":
      return emitResult(p.publishDefinition(tenant, AppDefinitionId(a.requireArg(2, "id")), user));
    case "archive":
      return emitResult(p.archiveDefinition(tenant, AppDefinitionId(a.requireArg(2, "id")), user));
    case "delete":
      return emitResult(p.deleteDefinition(tenant, AppDefinitionId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int versions(const CliArgs a) {
    auto p = ports.appVersions;
    switch (command(a)) {
    case "list":
      auto items = a.has("app") ? p.listByMobileApplication(tenant, MobileApplicationId(a.opt("app")))
        : p.listAppVersions(tenant);
      if (a.has("status"))
        items = items.filter!(e => enumValue(e.status) == a.opt("status")).array;
      return emitTable(items, appVersionTable(items));
    case "get":
      return emitOne(found(p.getAppVersion(tenant, AppVersionId(a.requireArg(2, "id")))));
    case "create":
      AppVersionDTO dto;
      readPayload(dto, body(a, versionOptions));
      dto.tenantId = tenant;
      dto.createdBy = user;
      return emitResult(p.createAppVersion(dto));
    case "update":
      auto id = AppVersionId(a.requireArg(2, "id"));
      auto dto = AppVersionDTO.fromEntity(found(p.getAppVersion(tenant, id)));
      readPayload(dto, body(a, versionOptions));
      dto.updatedBy = user;
      return emitResult(p.updateAppVersion(dto));
    case "publish":
      return emitResult(p.publishAppVersion(tenant, AppVersionId(a.requireArg(2, "id")), user));
    case "withdraw":
      return emitResult(p.withdrawAppVersion(tenant, AppVersionId(a.requireArg(2, "id")), user));
    case "delete":
      return emitResult(p.deleteAppVersion(tenant, AppVersionId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int devices(const CliArgs a) {
    auto p = ports.devices;
    switch (command(a)) {
    case "list":
      auto items = a.has("app") ? p.listByMobileApplication(tenant, MobileApplicationId(a.opt("app")))
        : p.listDevices(tenant);
      if (a.has("status"))
        items = items.filter!(e => enumValue(e.status) == a.opt("status")).array;
      if (a.has("group"))
        items = items.filter!(e => e.groupName == a.opt("group")).array;
      return emitTable(items, deviceTable(items));
    case "get":
      return emitOne(found(p.getDevice(tenant, DeviceId(a.requireArg(2, "id")))));
    case "enroll", "create":
      DeviceDTO dto;
      readPayload(dto, body(a, deviceOptions));
      dto.tenantId = tenant;
      dto.createdBy = user;
      return emitResult(p.enrollDevice(dto));
    case "update":
      auto id = DeviceId(a.requireArg(2, "id"));
      auto dto = DeviceDTO.fromEntity(found(p.getDevice(tenant, id)));
      readPayload(dto, body(a, deviceOptions));
      dto.updatedBy = user;
      return emitResult(p.updateDevice(dto));
    case "status":
      return emitResult(p.setDeviceStatus(tenant, DeviceId(a.requireArg(2, "id")), enumArg!DeviceStatus(a, 3), user));
    case "remove", "delete":
      return emitResult(p.removeDevice(tenant, DeviceId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int syncs(const CliArgs a) {
    auto p = ports.syncSessions;
    switch (command(a)) {
    case "list":
      auto items = a.has("device") ? p.listByDevice(tenant, DeviceId(a.opt("device"))) : p.listSyncSessions(tenant);
      if (a.has("status"))
        items = items.filter!(e => enumValue(e.status) == a.opt("status")).array;
      return emitTable(items, syncSessionTable(items));
    case "get":
      return emitOne(found(p.getSyncSession(tenant, SyncSessionId(a.requireArg(2, "id")))));
    case "create":
      SyncSessionDTO dto;
      readPayload(dto, body(a, syncOptions));
      dto.tenantId = tenant;
      dto.createdBy = user;
      return emitResult(p.createSyncSession(dto));
    case "start":
      return emitResult(p.startSyncSession(tenant, SyncSessionId(a.requireArg(2, "id"))));
    case "complete":
      SyncMetricsDTO metrics;
      readPayload(metrics, body(a, [
          ["bytes-sent", "bytesSent"], ["bytes-received", "bytesReceived"],
          ["records-sent", "recordsSent"], ["records-received", "recordsReceived"]
        ]));
      return emitResult(p.completeSyncSession(tenant, SyncSessionId(a.requireArg(2, "id")), metrics));
    case "fail":
      return emitResult(p.failSyncSession(tenant, SyncSessionId(a.requireArg(2, "id")), a.opt("error")));
    case "cancel":
      return emitResult(p.cancelSyncSession(tenant, SyncSessionId(a.requireArg(2, "id"))));
    case "expire":
      return emitResult(p.expireStaleSessions(tenant, a.intOpt("timeout", config.syncTimeoutMinutes)));
    case "delete":
      return emitResult(p.deleteSyncSession(tenant, SyncSessionId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int connections(const CliArgs a) {
    auto p = ports.backendConnections;
    switch (command(a)) {
    case "list":
      auto items = p.listBackendConnections(tenant);
      if (a.has("type"))
        items = items.filter!(e => enumValue(e.backendType) == a.opt("type")).array;
      if (a.has("status"))
        items = items.filter!(e => enumValue(e.status) == a.opt("status")).array;
      return emitTable(items, backendConnectionTable(items));
    case "get":
      return emitOne(found(p.getBackendConnection(tenant, BackendConnectionId(a.requireArg(2, "id")))));
    case "create":
      BackendConnectionDTO dto;
      readPayload(dto, body(a, connectionOptions));
      dto.tenantId = tenant;
      dto.createdBy = user;
      return emitResult(p.createBackendConnection(dto));
    case "update":
      auto id = BackendConnectionId(a.requireArg(2, "id"));
      auto dto = BackendConnectionDTO.fromEntity(found(p.getBackendConnection(tenant, id)));
      readPayload(dto, body(a, connectionOptions));
      dto.updatedBy = user;
      return emitResult(p.updateBackendConnection(dto));
    case "test":
      return emitResult(p.testBackendConnection(tenant, BackendConnectionId(a.requireArg(2, "id")), user));
    case "delete":
      return emitResult(p.deleteBackendConnection(tenant, BackendConnectionId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int deployments(const CliArgs a) {
    auto p = ports.deployments;
    switch (command(a)) {
    case "list":
      auto items = a.has("app") ? p.listByMobileApplication(tenant, MobileApplicationId(a.opt("app")))
        : p.listDeployments(tenant);
      if (a.has("status"))
        items = items.filter!(e => enumValue(e.status) == a.opt("status")).array;
      return emitTable(items, deploymentTable(items));
    case "get":
      return emitOne(found(p.getDeployment(tenant, DeploymentId(a.requireArg(2, "id")))));
    case "create":
      DeploymentDTO dto;
      readPayload(dto, deploymentBody(a));
      dto.tenantId = tenant;
      dto.createdBy = user;
      return emitResult(p.createDeployment(dto));
    case "update":
      auto id = DeploymentId(a.requireArg(2, "id"));
      auto dto = DeploymentDTO.fromEntity(found(p.getDeployment(tenant, id)));
      readPayload(dto, deploymentBody(a));
      dto.updatedBy = user;
      return emitResult(p.updateDeployment(dto));
    case "start":
      return emitResult(p.startDeployment(tenant, DeploymentId(a.requireArg(2, "id")), user));
    case "complete":
      return emitResult(p.completeDeployment(tenant, DeploymentId(a.requireArg(2, "id")),
          a.intOpt("succeeded", -1) < 0 ? requireCount(a, "succeeded") : a.intOpt("succeeded", 0),
          a.intOpt("failed", 0)));
    case "rollback":
      return emitResult(p.rollbackDeployment(tenant, DeploymentId(a.requireArg(2, "id")), user));
    case "delete":
      return emitResult(p.deleteDeployment(tenant, DeploymentId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  // ── option → payload ───────────────────────────────────────────────────

  /// Build a payload from the options that are present (others stay untouched).
  protected static Json body(const CliArgs a, const string[2][] map) {
    auto b = Json.emptyObject;
    foreach (m; map)
      if (a.has(m[0]))
        b[m[1]] = a.opt(m[0]);
    return b;
  }

  protected Json definitionBody(const CliArgs a) {
    auto b = body(a, definitionOptions);
    if (a.has("file")) {
      auto path = a.opt("file");
      b["definitionContent"] = (() @trusted => readText(path))();
      if (!a.has("format") && path.endsWith(".xml"))
        b["definitionFormat"] = "xml";
    }
    return b;
  }

  protected static Json deploymentBody(const CliArgs a) {
    auto b = body(a, deploymentOptions);
    if (a.has("scheduled"))
      b["scheduledAt"] = parseCliTime(a.opt("scheduled"));
    return b;
  }

  // ── helpers ────────────────────────────────────────────────────────────

  protected static string command(const CliArgs a) {
    return a.requireArg(1, "command (list, get, create, …)");
  }

  protected static int unknown(const CliArgs a) {
    throw new CliUsageError("unknown command '" ~ a.arg(1) ~ "' for " ~ a.arg(0));
  }

  protected static long requireCount(const CliArgs a, string key) {
    throw new CliUsageError("missing option: --" ~ key ~ "=N");
  }

  protected static E enumArg(E)(const CliArgs a, size_t index) {
    auto text = a.requireArg(index, "status (" ~ enumValues!E().join("|") ~ ")");
    E value;
    if (!tryParseEnum!E(text, value))
      throw new CliUsageError("'" ~ text ~ "' is not one of " ~ enumValues!E().join(", "));
    return value;
  }

  protected static T found(T)(T entity) {
    if (entity.isNull)
      throw new Exception(T.stringof ~ " not found");
    return entity;
  }

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
      output("error: " ~ r.message ~ "\n");
    return r.isSuccess ? 0 : 1;
  }
}

///
unittest {
  mixin(ShowTest!("AgentryCli"));

  AgentryConfig cfg;
  cfg.storage = "memory";
  auto c = buildContainer(cfg);
  string out_;
  auto cli = new AgentryCli(c.ports, cfg, (string s) { out_ ~= s; });

  assert(cli.run(["apps", "create", "--name=Field Service", "--package=com.example.fs", "--platform=ios", "--offline"]) == 0);
  auto appId = c.ports.mobileApplications.listMobileApplications(TenantId("default"))[0].id.value;
  assert(c.ports.mobileApplications.getMobileApplication(TenantId("default"), MobileApplicationId(appId)).offlineCapable);

  out_ = "";
  assert(cli.run(["apps", "list"]) == 0);
  assert(out_.canFind("Field Service") && out_.canFind("1 record(s)"));

  assert(cli.run(["apps", "status", appId, "active"]) == 0);
  assert(cli.run(["apps", "status", appId, "draft"]) == 1); // lifecycle violation
  assert(cli.run(["apps", "status", appId, "bogus"]) == 2);
  assert(cli.run(["apps", "frobnicate"]) == 2);
  assert(cli.run(["nothing"]) == 2);
  assert(cli.run([]) == 2);
  assert(cli.run(["help"]) == 0);

  assert(cli.run(["definitions", "create", "--app=" ~ appId, "--name=Main", `--content={"screens":[]}`]) == 0);
  auto defId = c.ports.appDefinitions.listDefinitions(TenantId("default"))[0].id.value;
  assert(cli.run(["definitions", "publish", defId]) == 0);

  out_ = "";
  assert(cli.run(["stats", "--json"]) == 0);
  assert(parseJsonString(out_)["publishedDefinitions"].get!long == 1);
}
