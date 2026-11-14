/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Generic over the resource registry, so every
/// resource supports the same verbs — exactly like the REST/OData/GUI adapters.
module uim.platform.application_studio.presentation.cli.commands;

import std.file : readText, exists;
import uim.platform.application_studio;
import uim.platform.application_studio.presentation.cli.args;
import uim.platform.application_studio.presentation.resources;
import uim.platform.application_studio.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-studio-cli — SAP Business Application Studio style dev space administration

Usage: uim-studio-cli <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --user=<id>          acting user (default: cli)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     volatile storage (testing)
  --json               machine readable JSON output

Commands:
  resources                              resource kinds, their parents and actions
  seed                                   install the predefined SAP catalogue (types, extensions, templates)
  stats                                  aggregated figures of the tenant
  reconcile                              run one reconciliation pass now
  config                                 effective service configuration

  <resource> list   [--<field>=<value> ...]       filter by payload fields
  <resource> get    <id|name>
  <resource> create --<field>=<value> ... [--file=body.json]
  <resource> update <id|name> --<field>=<value> ...
  <resource> delete <id|name>
  <resource> fields                               settable fields
  <resource> <action> <id|name> [--<param>=..]    e.g. dev-spaces add-extension FioriDev --extension=sap.kyma-tools

Resources: %s

Values: lists "a,b" · key/value lists "k=v,k2=v2" · structured fields as JSON ·
"@file" reads the value from a file · references (devSpaceId, devSpaceTypeId,
projectId, templateId) accept an id or a unique name · --kebab-case = --camelCase.

Example:
  uim-studio-cli seed
  uim-studio-cli dev-spaces create --name=FioriDev --dev-space-type-id="SAP Fiori" --owner=jane@example.com
  uim-studio-cli reconcile                                 # starting → running
  uim-studio-cli projects create --devSpaceId=FioriDev --name=travel-ui --templateId=fiori-list-report
  uim-studio-cli service-bindings create --devSpaceId=FioriDev --name=Northwind --provider-type=externalOData \
      --service-url=https://services.odata.org --service-path=/V4/Northwind/Northwind.svc/
  uim-studio-cli service-bindings connect Northwind
  uim-studio-cli run-configurations create --projectId=travel-ui --name=preview --entry-point="npm start" --port=8080
  uim-studio-cli run-configurations start preview
  uim-studio-cli build-configurations create --projectId=travel-ui --name=mta
  uim-studio-cli build-configurations build mta && uim-studio-cli reconcile
  uim-studio-cli build-configurations deploy mta
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
class StudioCli {
  protected ResourceRegistry registry;
  protected StudioConfig config;
  protected void delegate(string) @safe output;
  protected RequestIdentity who;
  protected bool json;

  this(ResourceRegistry registry, StudioConfig config, void delegate(string) @safe output) {
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
      case "seed":
        auto r = registry.seedCatalog(who);
        return emit(r, "%d catalogue item(s) created, %d already present\n%s".format(r["created"].get!long,
            r["skipped"].get!long, r["items"].get!(Json[]).map!(c => "  " ~ c.get!string ~ "\n").join));
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
      output("error: " ~ e.msg ~ "\nRun 'uim-studio-cli help' for usage.\n");
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
  mixin(ShowTest!("StudioCli"));

  StudioConfig cfg;
  cfg.storage = "memory";
  cfg.defaultTenant = "t1";
  string out_;
  auto cli = new StudioCli(new ResourceRegistry(buildContainer(cfg).ports), cfg, (s) { out_ ~= s; });

  assert(cli.run([]) == 2);
  assert(cli.run(["seed"]) == 0, out_);
  assert(out_.canFind("29 catalogue item(s) created"), out_);
  assert(cli.run(["dev-spaces", "create", "--name=FioriDev", "--dev-space-type-id=SAP Fiori",
      "--owner=jane@example.com"]) == 0, out_);
  assert(out_.canFind("created"));
  assert(cli.run(["reconcile"]) == 0);
  assert(cli.run(["projects", "create", "--devSpaceId=FioriDev", "--name=travel-ui", "--templateId=fiori-list-report"]) == 0, out_);
  assert(cli.run(["service-bindings", "create", "--devSpaceId=FioriDev", "--name=Northwind", "--provider-type=externalOData",
      "--service-url=https://services.odata.org", "--service-path=/V4/Northwind/Northwind.svc/"]) == 0, out_);
  assert(cli.run(["service-bindings", "connect", "Northwind"]) == 0, out_);
  assert(cli.run(["run-configurations", "create", "--projectId=travel-ui", "--name=preview", "--entry-point=npm start",
      "--port=8080", "--environment=NODE_ENV=development"]) == 0, out_);
  assert(cli.run(["run-configurations", "start", "preview"]) == 0, out_);
  assert(cli.run(["build-configurations", "create", "--projectId=travel-ui", "--name=mta"]) == 0, out_);
  assert(cli.run(["build-configurations", "deploy", "mta"]) == 1); // not built yet
  assert(cli.run(["build-configurations", "build", "mta"]) == 0, out_);
  assert(cli.run(["reconcile"]) == 0);
  assert(cli.run(["build-configurations", "deploy", "mta"]) == 0, out_);
  assert(cli.run(["reconcile"]) == 0);
  out_ = "";
  assert(cli.run(["build-configurations", "list", "--status=deployed"]) == 0);
  assert(out_.canFind("mta") && out_.canFind("1 build-configurations"), out_);
  out_ = "";
  assert(cli.run(["run-configurations", "get", "preview", "--json"]) == 0);
  assert(parseJsonString(out_)["status"].get!string == "running");
  assert(cli.run(["dev-spaces", "add-extension", "FioriDev", "--extension=sap.kyma-tools"]) == 1); // running
  assert(cli.run(["dev-spaces", "get", "nope"]) == 1);
  assert(cli.run(["dev-spaces", "fly", "FioriDev"]) == 2);
  assert(cli.run(["run-configurations", "stop", "preview"]) == 0);
  assert(cli.run(["run-configurations", "delete", "preview"]) == 0);
  assert(camelCase("dev-space-type-id") == "devSpaceTypeId");
}
