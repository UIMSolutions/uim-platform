/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Generic over the resource registry, so every
/// resource supports the same verbs — exactly like the REST/OData/GUI adapters.
module uim.platform.workzone.presentation.cli.commands;

import std.file : readText, exists;
import uim.platform.workzone;
import uim.platform.workzone.presentation.cli.args;
import uim.platform.workzone.presentation.resources;
import uim.platform.workzone.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-workzone-cli — SAP Build Work Zone style workspace, content and site administration

Usage: uim-workzone-cli <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --user=<id>          acting user (default: cli)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     volatile storage (testing)
  --json               machine readable JSON output

Commands:
  resources                              resource kinds, their parents and actions
  seed                                   install predefined roles, themes, page templates and tags
  stats                                  aggregated figures of the tenant
  housekeeping                           apply time driven transitions now (overdue, expired, syncs)
  config                                 effective service configuration

  <resource> list   [--<field>=<value> ...]       filter by payload fields
  <resource> get    <id|name>
  <resource> create --<field>=<value> ... [--file=body.json]
  <resource> update <id|name> --<field>=<value> ...
  <resource> delete <id|name>
  <resource> fields                               settable fields
  <resource> <action> <id|name> [--<param>=..]    e.g. workspaces add-member Sales --user-id=bob --role=admin

Resources: %s

Values: lists "a,b" · key/value lists "k=v,k2=v2" · structured fields (members,
questions, sections) as JSON · "@file" reads the value from a file · timestamps
"2026-11-20" or "2026-11-20T09:00:00Z" · references (workspaceId, workpageId,
siteId, themeId, templateId, cardId, appId, ...) accept an id or a unique name /
title · --kebab-case = --camelCase.

Example:
  uim-workzone-cli seed
  uim-workzone-cli workspaces create --name="Sales EMEA" --type=team
  uim-workzone-cli workspaces add-member "Sales EMEA" --user-id=bob --role=contributor
  uim-workzone-cli workpages create --workspace-id="Sales EMEA" --title=Pipeline --template-id=Dashboard
  uim-workzone-cli cards create --title="Open Opportunities" --data-source-url=/odata/v4/sales/Opportunities
  uim-workzone-cli widgets create --workpage-id=Pipeline --card-id="Open Opportunities" --size=large
  uim-workzone-cli content create --workspace-id="Sales EMEA" --title="Q4 Plan" --body=@q4.md --tags=Sales
  uim-workzone-cli content publish "Q4 Plan"
  uim-workzone-cli tasks create --title="Approve discount" --assignee-id=bob --due-at=2026-11-30
  uim-workzone-cli sites create --name="Sales Portal"
  uim-workzone-cli navigation-items create --site-id="Sales Portal" --title=Pipeline --item-type=workpage \
      --target-workpage-id=Pipeline
  uim-workzone-cli sites publish "Sales Portal"
  uim-workzone-cli housekeeping
`;

/// Options that belong to the CLI itself, not to a resource payload.
enum string[] globalOptions = ["tenant", "user", "data-dir", "dataDir", "storage", "json", "help", "file", "yes", "wide"];

/// "workspace-id" → "workspaceId".
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
class WorkzoneCli {
  protected ResourceRegistry registry;
  protected WorkzoneConfig config;
  protected void delegate(string) @safe output;
  protected RequestIdentity who;
  protected bool json;

  this(ResourceRegistry registry, WorkzoneConfig config, void delegate(string) @safe output) {
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
        auto r = registry.seed(who);
        return emit(r, "%d item(s) created, %d already present\n%s".format(r["created"].get!long,
            r["skipped"].get!long, r["items"].get!(Json[]).map!(c => "  " ~ c.get!string ~ "\n").join));
      case "housekeeping":
        auto r = registry.housekeeping(who.tenantId);
        return emit(r, "%d object(s) examined, %d changed\n%s".format(r["examined"].get!long,
            r["changed"].get!long, r["changes"].get!(Json[]).map!(c => "  " ~ c.get!string ~ "\n").join));
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      default:
        auto adapter = registry.byPath(a.arg(0));
        if (adapter is null)
          throw new CliUsageError("unknown command '" ~ a.arg(0) ~ "'");
        return resource(adapter, a);
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-workzone-cli help' for usage.\n");
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
      foreach (k, v; a.options)
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
    return emit(row, "%s '%s' %s (id %s%s)\n".format(adapter.typeName, displayOf(row), verb,
        fieldString(row, "id"), status.length > 0 ? ", status " ~ status : ""));
  }
}

///
unittest {
  mixin(ShowTest!("WorkzoneCli"));

  WorkzoneConfig cfg;
  cfg.storage = "memory";
  cfg.defaultTenant = "t1";
  string out_;
  auto cli = new WorkzoneCli(new ResourceRegistry(buildContainer(cfg).ports), cfg, (s) { out_ ~= s; });

  assert(cli.run([]) == 2);
  assert(cli.run(["seed"]) == 0, out_);
  assert(out_.canFind("20 item(s) created"), out_);
  assert(cli.run(["workspaces", "create", "--name=Sales EMEA", "--type=team"]) == 0, out_);
  assert(cli.run(["workspaces", "add-member", "Sales EMEA", "--user-id=bob", "--role=admin"]) == 0, out_);
  assert(cli.run(["workpages", "create", "--workspace-id=Sales EMEA", "--title=Pipeline", "--template-id=Dashboard"]) == 0, out_);
  assert(cli.run(["cards", "create", "--title=Open Opportunities", "--data-source-url=/odata/v4/sales/Opportunities"]) == 0, out_);
  assert(cli.run(["widgets", "create", "--workpage-id=Pipeline", "--card-id=Open Opportunities", "--size=large"]) == 0, out_);
  assert(cli.run(["widgets", "create", "--card-id=Open Opportunities"]) == 2); // parent missing
  assert(cli.run(["content", "create", "--workspace-id=Sales EMEA", "--title=Q4 Plan", "--body=Targets", "--tags=Sales"]) == 0, out_);
  assert(cli.run(["content", "publish", "Q4 Plan"]) == 0, out_);
  assert(cli.run(["content", "publish", "Q4 Plan"]) == 1); // already published
  assert(cli.run(["tasks", "create", "--title=Approve discount", "--assignee-id=bob", "--due-at=2099-11-30"]) == 0, out_);
  assert(cli.run(["tasks", "complete", "Approve discount"]) == 0, out_);
  assert(cli.run(["sites", "create", "--name=Sales Portal"]) == 0, out_);
  assert(cli.run(["sites", "publish", "Sales Portal"]) == 1); // no navigation
  assert(cli.run(["navigation-items", "create", "--site-id=Sales Portal", "--title=Pipeline", "--item-type=workpage",
      "--target-workpage-id=Pipeline"]) == 0, out_);
  assert(cli.run(["sites", "publish", "Sales Portal"]) == 0, out_);
  out_ = "";
  assert(cli.run(["content", "list", "--status=published"]) == 0);
  assert(out_.canFind("Q4 Plan") && out_.canFind("1 content"), out_);
  out_ = "";
  assert(cli.run(["workspaces", "get", "sales-emea", "--json"]) == 0); // by alias
  assert(parseJsonString(out_)["members"].length == 2);
  assert(cli.run(["housekeeping"]) == 0);
  assert(cli.run(["workspaces", "get", "nope"]) == 1);
  assert(cli.run(["workspaces", "fly", "Sales EMEA"]) == 2);
  assert(camelCase("target-workpage-id") == "targetWorkpageId");
}
