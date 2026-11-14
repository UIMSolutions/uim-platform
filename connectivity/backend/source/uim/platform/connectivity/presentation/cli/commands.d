/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Generic over the resource registry, so every
/// resource supports the same verbs — exactly like the REST/OData/GUI adapters.
module uim.platform.connectivity.presentation.cli.commands;

import std.file : readText, exists;
import uim.platform.connectivity;
import uim.platform.connectivity.presentation.cli.args;
import uim.platform.connectivity.presentation.resources;
import uim.platform.connectivity.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-connectivity-cli — SAP BTP style connectivity administration

Usage: uim-connectivity-cli <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --actor=<id>         acting user, recorded as createdBy/updatedBy (default: cli)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     volatile storage (testing)
  --json               machine readable JSON output

Commands:
  resources                              resource kinds, their input fields and actions
  stats                                  aggregated figures of the tenant
  health-check                           run one health check pass now
  access-check <connector> <url>         would the Cloud Connector allow this request?
  purge-logs [--before=<date>]           delete event log entries (default: all until now)
  config                                 effective service configuration

  <resource> list   [--<field>=<value> ...]       filter by payload fields
  <resource> get    <id|name>
  <resource> create --<field>=<value> ... [--file=body.json]
  <resource> update <id|name> --<field>=<value> ...
  <resource> delete <id|name>
  <resource> fields                               settable fields
  <resource> <action> <id|name> [--<param>=..]    e.g. certificates renew erp-client --valid-days=365

Resources: %s

Values: lists "a,b" · key/value lists "k=v,k2=v2" · structured fields as JSON ·
"@file" reads the value from a file · connector references (connectorId) accept
an id or a unique connector name · --kebab-case = --camelCase.

Example:
  uim-connectivity-cli connectors create --name="Frankfurt DC" --location-id=fra --host=scc.corp.local
  uim-connectivity-cli access-rules create --connector-id="Frankfurt DC" --virtual-host=erp.virtual \
      --virtual-port=443 --internal-host=erp.corp.local --internal-port=44300 --url-path-prefix=/sap/opu/odata
  uim-connectivity-cli destinations create --name=ERP_ODATA --url=https://erp.virtual/sap/opu/odata \
      --proxy-type=onPremise --cloud-connector-location-id=fra --authentication-type=basicAuthentication \
      --user=ODATA_USER --password=@secret.txt --properties="sap-client=100"
  uim-connectivity-cli destinations check ERP_ODATA
  uim-connectivity-cli access-check "Frankfurt DC" https://erp.virtual/sap/opu/odata/sap/API_BUSINESS_PARTNER
  uim-connectivity-cli channels create --connector-id="Frankfurt DC" --name=ERP_HTTP --virtual-host=erp.virtual \
      --virtual-port=8000 --backend-host=erp.corp.local --backend-port=8000
  uim-connectivity-cli channels open ERP_HTTP
  uim-connectivity-cli logs list --severity=warning
`;

/// Options that belong to the CLI itself, not to a resource payload.
enum string[] globalOptions = ["tenant", "actor", "data-dir", "dataDir", "storage", "json", "help", "file", "yes", "wide", "before"];

/// "namespace-id" → "namespaceId".
string camelCase(string option) pure {
  string result;
  bool upper;
  foreach (c; option) {
    if (c == '-') {
      upper = true;
      continue;
    }
    result ~= upper && c >= 'a' && c <= 'z' ? cast(char)(c - 32) : c;
    upper = false;
  }
  return result;
}

/// The command line adapter.
class ConnectivityCli {
  protected ResourceRegistry registry;
  protected ConnectivityConfig config;
  protected void delegate(string) @safe output;
  protected RequestIdentity who;
  protected bool json;

  this(ResourceRegistry registry, ConnectivityConfig config, void delegate(string) @safe output) {
    this.registry = registry;
    this.config = config;
    this.output = output;
  }

  string usage() {
    return cliUsage.format(registry.adapters.map!(a => a.path).join(" "));
  }

  /// Run one command. Returns the process exit code (0 ok, 1 failure, 2 usage).
  int run(const string[] argv) {
    auto a = CliArgs.parse(argv);
    who.tenantId = TenantId(a.opt("tenant", config.defaultTenant));
    who.userId = UserId(a.opt("actor", "cli"));
    who.userName = who.userId.value;
    json = a.flag("json");

    try {
      if (a.positional.length == 0 || a.flag("help") || a.arg(0) == "help") {
        output(usage);
        return a.positional.length == 0 && !a.flag("help") ? 2 : 0;
      }
      switch (a.arg(0)) {
      case "resources":
        return resources();
      case "stats":
        auto s = registry.statistics(who.tenantId);
        return emit(s, detailTable(s).render);
      case "health-check":
        auto r = registry.healthCheck(who.tenantId);
        return emit(r, "%d object(s) examined, %d changed\n%s".format(r["examined"].get!long,
            r["changed"].get!long, r["changes"].get!(Json[]).map!(c => "  " ~ c.get!string ~ "\n").join));
      case "access-check":
        auto r = registry.checkAccess(who, a.requireArg(1, "connector"), a.requireArg(2, "url"));
        return emit(r, (r["allowed"].get!bool ? "ALLOWED" : "DENIED") ~ " — " ~ r["reason"].get!string ~ "\n");
      case "purge-logs":
        auto before = a.has("before") ? parseIsoTime(a.opt("before")) : nowStdTime() + 1;
        auto removed = registry.ports.logs.purge(who.tenantId, before, who.userId);
        return emit(Json.emptyObject.set("removed", removed), "%d log entries removed\n".format(removed));
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      default:
        auto adapter = registry.byPath(a.arg(0));
        if (adapter is null)
          throw new CliUsageError("unknown command '" ~ a.arg(0) ~ "'");
        return resource(adapter, a);
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-connectivity-cli help' for usage.\n");
      return 2;
    } catch (ResourceError e) {
      output("error %d (%s): %s\n".format(e.status, e.code, e.msg));
      return 1;
    } catch (Exception e) {
      output("error: " ~ e.msg ~ "\n");
      return 1;
    }
  }

  // ── commands ───────────────────────────────────────────────────────────

  protected int resources() {
    Table t;
    t.headers = ["Resource", "Title", "Parent", "Actions"];
    foreach (a; registry.adapters)
      t.rows ~= [a.path, a.title, a.parentField, a.actions.map!(x => x.name).join(", ")];
    auto arr = Json.emptyArray;
    foreach (a; registry.adapters)
      arr ~= Json(a.path);
    return emit(arr, t.render);
  }

  protected int resource(IResourceAdapter adapter, CliArgs a) {
    auto verb = a.arg(1);
    switch (verb) {
    case "", "list":
      string[string] filters;
      foreach (k, v; a.options)
        if (!globalOptions.canFind(k))
          filters[camelCase(k)] = v;
      return emitRows(adapter, adapter.list(who.tenantId, filters));
    case "get":
      auto row = adapter.get(who.tenantId, resolveId(adapter, a.requireArg(2, "id or name")));
      return emit(row, detailTable(row).render);
    case "create":
      return emitChange(adapter, "created", adapter.create(who, payload(adapter, a, true)));
    case "update":
      auto id = resolveId(adapter, a.requireArg(2, "id or name"));
      return emitChange(adapter, "updated", adapter.update(who, id, payload(adapter, a, false)));
    case "delete":
      auto id = resolveId(adapter, a.requireArg(2, "id or name"));
      adapter.remove(who, id);
      return emit(Json.emptyObject.set("deleted", id), adapter.typeName ~ " " ~ id ~ " deleted\n");
    case "fields":
      Table t;
      t.headers = ["Field", "Kind", "Options"];
      foreach (f; adapter.inputFields)
        t.rows ~= [f.name, enumText(f.kind) ~ (f.recordType.length ? " (" ~ f.recordType ~ ")" : ""), f.options.join("|")];
      return emit(Json(adapter.inputFields.map!(f => f.name).join(",")), t.render);
    default:
      auto action = adapter.actions.filter!(x => x.name == verb);
      if (action.empty)
        throw new CliUsageError(adapter.path ~ ": unknown verb '" ~ verb ~ "' (actions: "
            ~ adapter.actions.map!(x => x.name).join(", ") ~ ")");
      auto id = resolveId(adapter, a.requireArg(2, "id or name"));
      auto params = Json.emptyObject;
      foreach (k, v; a.options) // --valid-days and --validDays
        if (action.front.parameters.canFind(camelCase(k)))
          params[camelCase(k)] = v;
      return emitChange(adapter, verb, adapter.invoke(who, id, verb, params));
    }
  }

  // ── input ──────────────────────────────────────────────────────────────

  /// Build the payload from --file and the resource options.
  protected Json payload(IResourceAdapter adapter, CliArgs a, bool creating) {
    auto body = Json.emptyObject;
    if (a.has("file"))
      body = parseJsonString(readFile(a.opt("file")));
    foreach (k, v; a.options) {
      if (globalOptions.canFind(k))
        continue;
      body[camelCase(k)] = v.length > 1 && v[0] == '@' ? readFile(v[1 .. $]) : v;
    }
    auto parent = adapter.parentField;
    if (creating && parent.length > 0 && fieldString(body, parent).length == 0)
      throw new CliUsageError(adapter.path ~ " create needs --" ~ parent);
    return registry.withReferences(who.tenantId, body);
  }

  protected static string readFile(string path) @trusted {
    if (!path.exists)
      throw new CliUsageError("file not found: " ~ path);
    return readText(path);
  }

  protected string resolveId(IResourceAdapter adapter, string idOrName) {
    return registry.resolve(adapter, who.tenantId, idOrName);
  }

  // ── output ─────────────────────────────────────────────────────────────

  protected int emit(Json data, lazy string text) {
    output(json ? data.toPrettyString ~ "\n" : text);
    return 0;
  }

  protected int emitRows(IResourceAdapter adapter, Json[] rows) {
    auto arr = Json.emptyArray;
    foreach (r; rows)
      arr ~= r;
    auto table = tableOf(adapter.columns, rows);
    return emit(arr, table.render ~ "%d %s\n".format(table.length, adapter.path));
  }

  protected int emitChange(IResourceAdapter adapter, string verb, Json row) {
    auto status = fieldString(row, "status");
    return emit(row, "%s '%s' %s (id %s%s)\n".format(adapter.typeName, fieldString(row, "name"), verb,
        fieldString(row, "id"), status.length > 0 ? ", status " ~ status : ""));
  }
}

///
unittest {
  mixin(ShowTest!("ConnectivityCli"));

  ConnectivityConfig cfg;
  cfg.storage = "memory";
  cfg.defaultTenant = "t1";
  string out_;
  auto cli = new ConnectivityCli(new ResourceRegistry(buildContainer(cfg).ports), cfg, (s) { out_ ~= s; });

  assert(cli.run([]) == 2);
  assert(cli.run(["connectors", "create", "--name=dc1", "--location-id=fra", "--host=scc.corp.local"]) == 0, out_);
  assert(out_.canFind("created"));
  assert(cli.run(["access-rules", "create", "--connector-id=dc1", "--virtual-host=erp.virtual", "--virtual-port=443",
      "--internal-host=erp.corp.local", "--internal-port=44300", "--url-path-prefix=/sap/opu"]) == 0, out_);
  assert(cli.run(["destinations", "create", "--name=ERP", "--url=https://erp.virtual/sap/opu/odata",
      "--proxy-type=onPremise", "--cloud-connector-location-id=fra", "--properties=sap-client=100"]) == 0, out_);
  out_ = "";
  assert(cli.run(["destinations", "check", "ERP"]) == 0, out_);
  assert(out_.canFind("status reachable"), out_);
  out_ = "";
  assert(cli.run(["access-check", "dc1", "https://erp.virtual/sap/bc/gui"]) == 0);
  assert(out_.canFind("DENIED"), out_);
  assert(cli.run(["channels", "create", "--connector-id=dc1", "--name=ERP_HTTP", "--virtual-host=erp.virtual",
      "--virtual-port=8000", "--backend-host=erp.corp.local", "--backend-port=8000"]) == 0, out_);
  assert(cli.run(["channels", "open", "ERP_HTTP"]) == 0, out_);
  assert(cli.run(["connectors", "delete", "dc1"]) == 1); // open channel
  assert(cli.run(["connectors", "disconnect", "dc1"]) == 0, out_);
  assert(cli.run(["health-check"]) == 0);
  out_ = "";
  assert(cli.run(["destinations", "get", "ERP", "--json"]) == 0);
  assert(parseJsonString(out_)["status"].get!string == "unreachable");
  out_ = "";
  assert(cli.run(["logs", "list", "--severity=warning"]) == 0);
  assert(out_.canFind("connectionLost"), out_);
  assert(cli.run(["destinations", "get", "nope"]) == 1);
  assert(cli.run(["destinations", "fly", "ERP"]) == 2);
  assert(cli.run(["certificates", "create", "--name=client", "--expires-at=2099-01-01"]) == 0, out_);
  assert(cli.run(["certificates", "renew", "client", "--valid-days=30"]) == 0, out_);
  assert(cli.run(["purge-logs"]) == 0);
  assert(cli.run(["destinations", "delete", "ERP"]) == 0);
  // --user is a payload field (destination user), not the acting user
  assert(cli.run(["destinations", "create", "--name=BASIC", "--url=https://a.example.com", "--actor=jane",
      "--authentication-type=basicAuthentication", "--user=SVC", "--password=x"]) == 0, out_);
  out_ = "";
  assert(cli.run(["destinations", "get", "BASIC", "--json"]) == 0);
  assert(parseJsonString(out_)["user"].get!string == "SVC" && parseJsonString(out_)["createdBy"].get!string == "jane");
  assert(camelCase("cloud-connector-location-id") == "cloudConnectorLocationId");
}
