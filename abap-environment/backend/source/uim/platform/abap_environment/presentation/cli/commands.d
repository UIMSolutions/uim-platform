/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Generic over the resource registry, so every
/// resource supports the same verbs — exactly like the REST/OData/GUI adapters.
module uim.platform.abap_environment.presentation.cli.commands;

import std.file : readText, exists;
import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.cli.args;
import uim.platform.abap_environment.presentation.resources;
import uim.platform.abap_environment.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-abap-cli — SAP BTP ABAP environment administration

Usage: uim-abap-cli <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --user=<id>          acting user (default: cli)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     volatile storage (testing)
  --json               machine readable JSON output

Commands:
  resources                              resource kinds, their input fields and actions
  stats                                  aggregated figures of the tenant
  reconcile                              run one reconciliation pass now
  config                                 effective service configuration

  <resource> list   [--<field>=<value> ...]       filter by payload fields
  <resource> get    <id|name>
  <resource> create --<field>=<value> ... [--file=body.json]
  <resource> update <id|name> --<field>=<value> ...
  <resource> delete <id|name>
  <resource> fields                               settable fields
  <resource> <action> <id|name> [--<param>=..]    e.g. transports release-task H01K900001 --task=H01K900001-01

Resources: %s

Values: lists "a,b" · key/value lists "k=v,k2=v2" · structured fields as JSON ·
"@file" reads the value from a file · system references (systemInstanceId,
sourceSystemId, targetSystemId) accept an id or a unique system name ·
--kebab-case = --camelCase.

Example:
  uim-abap-cli systems create --name=dev --admin-email=admin@example.com
  uim-abap-cli systems create --name=prd --admin-email=admin@example.com --plan=production
  uim-abap-cli reconcile                                   # provisioning → active
  uim-abap-cli software-components create --systemInstanceId=dev --name=ZTRAVEL \
      --repository-url=https://github.com/acme/ztravel.git
  uim-abap-cli software-components clone ZTRAVEL
  uim-abap-cli transports create --sourceSystemId=dev --targetSystemId=prd --description="Travel app" --owner=DEV
  uim-abap-cli transports add-task DEVK900001 --objects="R3TR CLAS ZCL_TRAVEL,R3TR DDLS ZI_TRAVEL"
  uim-abap-cli transports release-task DEVK900001 --task=DEVK900001-01
  uim-abap-cli transports release DEVK900001 && uim-abap-cli transports import DEVK900001
`;

/// Options that belong to the CLI itself, not to a resource payload.
enum string[] globalOptions = ["tenant", "user", "data-dir", "dataDir", "storage", "json", "help", "file", "yes", "wide"];

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
class AbapCli {
  protected ResourceRegistry registry;
  protected AbapConfig config;
  protected void delegate(string) @safe output;
  protected RequestIdentity who;
  protected bool json;

  this(ResourceRegistry registry, AbapConfig config, void delegate(string) @safe output) {
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
    who.userId = UserId(a.opt("user", "cli"));
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
      case "reconcile":
        auto r = registry.reconcile(who.tenantId);
        return emit(r, "%d resource(s) examined, %d advanced\n%s".format(r["examined"].get!long,
            r["advanced"].get!long, r["changes"].get!(Json[]).map!(c => "  " ~ c.get!string ~ "\n").join));
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      default:
        auto adapter = registry.byPath(a.arg(0));
        if (adapter is null)
          throw new CliUsageError("unknown command '" ~ a.arg(0) ~ "'");
        return resource(adapter, a);
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-abap-cli help' for usage.\n");
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
      foreach (p; action.front.parameters)
        if (a.has(p))
          params[p] = a.opt(p);
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
  mixin(ShowTest!("AbapCli"));

  AbapConfig cfg;
  cfg.storage = "memory";
  cfg.defaultTenant = "t1";
  string out_;
  auto cli = new AbapCli(new ResourceRegistry(buildContainer(cfg).ports), cfg, (s) { out_ ~= s; });

  assert(cli.run([]) == 2);
  assert(cli.run(["systems", "create", "--name=dev", "--admin-email=admin@example.com"]) == 0, out_);
  assert(out_.canFind("created"));
  assert(cli.run(["systems", "create", "--name=prd", "--adminEmail=admin@example.com", "--plan=production"]) == 0, out_);
  assert(cli.run(["reconcile"]) == 0);
  assert(cli.run(["software-components", "create", "--system-instance-id=dev", "--name=ztravel",
      "--repository-url=https://github.com/acme/ztravel.git"]) == 0, out_);
  assert(cli.run(["software-components", "clone", "ZTRAVEL"]) == 0, out_);
  assert(cli.run(["transports", "create", "--sourceSystemId=dev", "--targetSystemId=prd",
      "--description=Travel app", "--owner=DEV"]) == 0, out_);
  assert(cli.run(["transports", "add-task", "DEVK900001", "--objects=R3TR CLAS ZCL_TRAVEL,R3TR DDLS ZI_TRAVEL"]) == 0, out_);
  assert(cli.run(["transports", "release", "DEVK900001"]) == 1); // task still modifiable
  assert(cli.run(["transports", "release-task", "DEVK900001", "--task=DEVK900001-01"]) == 0, out_);
  assert(cli.run(["transports", "release", "DEVK900001"]) == 0, out_);
  assert(cli.run(["transports", "import", "DEVK900001"]) == 0, out_);
  assert(cli.run(["reconcile"]) == 0);
  out_ = "";
  assert(cli.run(["transports", "list", "--status=imported"]) == 0);
  assert(out_.canFind("DEVK900001") && out_.canFind("1 transports"), out_);
  out_ = "";
  assert(cli.run(["software-components", "get", "ZTRAVEL", "--json"]) == 0);
  assert(parseJsonString(out_)["status"].get!string == "cloned");
  assert(cli.run(["systems", "get", "nope"]) == 1);
  assert(cli.run(["systems", "fly", "dev"]) == 2);
  assert(cli.run(["software-components", "delete", "ZTRAVEL"]) == 0);
  assert(camelCase("system-instance-id") == "systemInstanceId");
}
