/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Generic over the resource registry, so every
/// resource supports the same verbs — exactly like the REST/OData/GUI adapters.
module uim.platform.identity_provisioning.presentation.cli.commands;

import std.file : readText, exists;
import uim.platform.identity_provisioning;
import uim.platform.identity_provisioning.presentation.cli.args;
import uim.platform.identity_provisioning.presentation.resources;
import uim.platform.identity_provisioning.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-ips-cli — SAP BTP style Identity Provisioning administration

Usage: uim-ips-cli <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --actor=<id>         acting user, recorded as createdBy/updatedBy (default: cli)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     volatile storage (testing)
  --json               machine readable JSON output

Commands:
  run <job>                                   run a provisioning job now (= provisioning-jobs run <job>)
  run-due-jobs [--limit=<n>]                  run every due scheduled job
  logs <job> [--run=<n>] [--status=failed]     audit log of a job (default: last run)
  preview <transformation> --attributes=k=v,... [--entity-type=group]
                                              apply a transformation to sample attributes
  purge-logs [--older-than=<days>]            delete log entries (default: all)
  demo                                        create demo systems, transformations and jobs
  resources                                   resource kinds, their input fields and actions
  stats                                       aggregated figures of the tenant
  config                                      effective service configuration

  <resource> list   [--<field>=<value> ...]       filter by payload fields
  <resource> get    <id|name>
  <resource> create --<field>=<value> ... [--file=body.json]
  <resource> update <id|name> --<field>=<value> ...
  <resource> delete <id|name>
  <resource> fields                               settable fields
  <resource> <action> <id|name>                   e.g. source-systems test-connection HR

Resources: %s

Values: lists "a,b" · properties and attributes "k=v,k2=v2" · mappings and
conditions as JSON · "@file" reads the value from a file · references
(sourceSystemId, targetSystemId, systemId, jobId) accept an id or a unique
name · --kebab-case = --camelCase · passwords are never printed.

Example:
  uim-ips-cli source-systems create --name=HR --system-type=successFactors \
      --url=https://api4.successfactors.com/odata/v2 --user=sfadmin --password=secret \
      --properties=sim.users=8,sim.groups=3
  uim-ips-cli source-systems activate HR
  uim-ips-cli target-systems create --name=IAS --system-type=ias --url=https://acme.accounts.ondemand.com \
      --authentication-type=oauth2ClientCredentials --user=client --password=secret
  uim-ips-cli target-systems activate IAS
  uim-ips-cli transformations create --name="IAS users" --system-role=target --system-id=IAS --scope=user \
      --mappings='[{"sourcePath":"email","targetPath":"emails[0].value","mandatory":true}]'
  uim-ips-cli preview "IAS users" --attributes=email=Ada@ACME.com
  uim-ips-cli provisioning-jobs create --source-system-id=HR --target-system-id=IAS --interval-minutes=60
  uim-ips-cli run "HR → IAS (delta)"
  uim-ips-cli logs "HR → IAS (delta)" --status=failed
  uim-ips-cli provisioned-entities list --entity-type=group
`;

/// Options that belong to the CLI itself, not to a resource payload.
enum string[] globalOptions = ["tenant", "actor", "data-dir", "dataDir", "storage", "json", "help", "file", "yes",
    "wide", "out"];

/// "source-system-id" → "sourceSystemId".
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
class ProvisioningCli {
  protected ResourceRegistry registry;
  protected ProvisioningConfig config;
  protected void delegate(string) @safe output;
  protected RequestIdentity who;
  protected bool json;

  this(ResourceRegistry registry, ProvisioningConfig config, void delegate(string) @safe output) {
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
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      case "run":
        auto jobs = registry.byPath("provisioning-jobs");
        return emitChange(jobs, "run", jobs.invoke(who, resolveId(jobs, a.requireArg(1, "job")), "run", Json.emptyObject));
      case "run-due-jobs":
        auto r = registry.runDueJobs(who.tenantId, a.intOpt("limit", 0));
        return emit(r, "%d job(s) run, %d completed, %d failed\n%s".format(r["processed"].get!long,
            r["completed"].get!long, r["failed"].get!long,
            r["messages"].get!(Json[]).map!(m => "  " ~ m.get!string ~ "\n").join));
      case "logs":
        return logs(a);
      case "preview":
        return preview(a);
      case "purge-logs":
        auto r = registry.purgeLogs(who.tenantId, a.intOpt("older-than", 0));
        return emit(r, "%d log entries deleted\n".format(r["purged"].get!long));
      case "demo":
        auto r = registry.seedDemo(who.tenantId, who.userId);
        return emit(r, r["seeded"].get!bool ? "demo data created in tenant " ~ who.tenantId.value ~ "\n"
            : "tenant " ~ who.tenantId.value ~ " already has systems — nothing created\n");
      default:
        auto adapter = registry.byPath(a.arg(0));
        if (adapter is null)
          throw new CliUsageError("unknown command '" ~ a.arg(0) ~ "'");
        return resource(adapter, a);
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-ips-cli help' for usage.\n");
      return 2;
    } catch (ResourceError e) {
      output("error %d (%s): %s\n".format(e.status, e.code, e.msg));
      return 1;
    } catch (Exception e) {
      output("error: " ~ e.msg ~ "\n");
      return 1;
    }
  }

  // ── provisioning commands ──────────────────────────────────────────────

  /// Log entries of one run of a job (default: the last run).
  protected int logs(CliArgs a) {
    auto jobs = registry.byPath("provisioning-jobs");
    auto job = jobs.get(who.tenantId, resolveId(jobs, a.requireArg(1, "job")));
    auto runNumber = a.intOpt("run", cast(int) fieldLong(job, "runCount"));
    string[string] filters = ["jobId": fieldString(job, "id"), "runNumber": runNumber.to!string];
    if (a.has("status"))
      filters["status"] = a.opt("status");
    auto adapter = registry.byPath("provisioning-logs");
    auto rows = adapter.list(who.tenantId, filters);
    rows.sort!((x, y) => fieldString(x, "createdAt") < fieldString(y, "createdAt"));
    ResourceColumn[] columns = [ResourceColumn("Operation", "operation"), ResourceColumn("Type", "entityType"),
      ResourceColumn("Entity", "entityName"), ResourceColumn("Status", "status"), ResourceColumn("Message", "message")];
    auto arr = Json.emptyArray;
    foreach (r; rows)
      arr ~= r;
    return emit(arr, "%s — run %d: %s\n".format(fieldString(job, "name"), runNumber, fieldString(job, "statusMessage"))
        ~ tableOf(columns, rows).render ~ "%d entries\n".format(rows.length));
  }

  protected int preview(CliArgs a) {
    auto body = Json.emptyObject
      .set("id", a.requireArg(1, "transformation"))
      .set("entityType", a.opt("entity-type", a.opt("entityType", "user")))
      .set("attributes", a.requireOpt("attributes"));
    auto r = registry.previewTransformation(who, body);
    auto verdict = fieldBool(r, "accepted") ? "accepted" : fieldBool(r, "failed") ? "FAILED" : "filtered";
    Table t;
    t.headers = ["Attribute", "Value"];
    foreach (attr; member(r, "attributes").get!(Json[]))
      t.rows ~= [fieldString(attr, "key"), fieldString(attr, "value")];
    return emit(r, "%s: %s%s\n".format(fieldString(r, "transformationName"), verdict,
        fieldString(r, "reason").length ? " — " ~ fieldString(r, "reason") : "") ~ t.render);
  }

  // ── resource commands ──────────────────────────────────────────────────

  protected int resources() {
    Table t;
    t.headers = ["Resource", "Title", "Access", "Actions"];
    foreach (a; registry.adapters)
      t.rows ~= [a.path, a.title, a.readOnly ? "read-only" : a.updatable ? "read/write" : "create/delete",
        a.actions.map!(x => x.name).join(", ")];
    auto arr = Json.emptyArray;
    foreach (a; registry.adapters)
      arr ~= Json(a.path);
    return emit(arr, t.render);
  }

  protected int resource(IResourceAdapter adapter, CliArgs a) {
    auto verb = a.arg(1);
    switch (verb) {
    case "", "list":
      auto query = Json.emptyObject;
      foreach (k, v; a.options)
        if (!globalOptions.canFind(k))
          query[camelCase(k)] = v;
      string[string] filters;
      foreach (k, v; registry.withReferences(who.tenantId, query).get!(Json[string]))
        filters[k] = jsonText(v);
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
      foreach (f; adapter.readOnly ? adapter.fields : adapter.inputFields)
        t.rows ~= [f.name, enumText(f.kind) ~ (f.recordType.length ? " (" ~ f.recordType ~ ")" : ""), f.options.join("|")];
      return emit(Json((adapter.readOnly ? adapter.fields : adapter.inputFields).map!(f => f.name).join(",")), t.render);
    default:
      auto action = adapter.actions.filter!(x => x.name == verb);
      if (action.empty)
        throw new CliUsageError(adapter.path ~ ": unknown verb '" ~ verb ~ "'" ~ (adapter.actions.length
            ? " (actions: " ~ adapter.actions.map!(x => x.name).join(", ") ~ ")" : ""));
      auto id = resolveId(adapter, a.requireArg(2, "id or name"));
      auto params = Json.emptyObject;
      foreach (k, v; a.options)
        if (action.front.parameters.canFind(camelCase(k)))
          params[camelCase(k)] = v.length > 1 && v[0] == '@' ? readFile(v[1 .. $]) : v;
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
    auto message = fieldString(row, "statusMessage");
    return emit(row, "%s '%s' %s (id %s%s)%s\n".format(adapter.typeName, fieldString(row, "name"), verb,
        fieldString(row, "id"), status.length > 0 ? ", status " ~ status : "",
        message.length > 0 ? "\n  " ~ message : ""));
  }
}

///
unittest {
  mixin(ShowTest!("ProvisioningCli"));

  assert(camelCase("source-system-id") == "sourceSystemId");

  ProvisioningConfig cfg;
  cfg.storage = "memory";
  cfg.defaultTenant = "t1";
  string out_;
  auto cli = new ProvisioningCli(new ResourceRegistry(buildContainer(cfg).ports), cfg, (s) { out_ ~= s; });

  assert(cli.run([]) == 2);
  assert(cli.run(["help"]) == 0 && out_.canFind("source-systems"));
  out_ = "";
  assert(cli.run(["source-systems", "create", "--name=HR", "--system-type=successFactors",
      "--url=https://api.sf.com", "--user=admin", "--password=secret", "--properties=sim.users=3,sim.groups=1"]) == 0, out_);
  assert(!out_.canFind("secret"));
  assert(cli.run(["source-systems", "activate", "HR"]) == 0, out_);
  assert(cli.run(["target-systems", "create", "--name=IAS", "--system-type=ias", "--url=https://a.accounts.ondemand.com",
      "--authentication-type=oauth2ClientCredentials", "--user=client"]) == 0, out_);
  out_ = "";
  assert(cli.run(["target-systems", "activate", "IAS"]) == 1); // no client secret
  assert(out_.canFind("401"), out_);
  assert(cli.run(["target-systems", "update", "IAS", "--password=s3cret"]) == 0, out_);
  assert(cli.run(["target-systems", "test-connection", "IAS"]) == 0, out_); // error → active

  assert(cli.run(["transformations", "create", "--name=IAS users", "--system-role=target", "--system-id=IAS",
      "--scope=user", `--mappings=[{"sourcePath":"email","targetPath":"emails[0].value","function":"lowerCase","mandatory":true}]`]) == 0, out_);
  out_ = "";
  assert(cli.run(["preview", "IAS users", "--attributes=email=Ada@ACME.com"]) == 0, out_);
  assert(out_.canFind("accepted") && out_.canFind("ada@acme.com"), out_);
  assert(cli.run(["preview", "IAS users"]) == 2); // --attributes missing

  assert(cli.run(["provisioning-jobs", "create", "--source-system-id=HR", "--target-system-id=IAS"]) == 0, out_);
  out_ = "";
  assert(cli.run(["run", "HR → IAS (delta)"]) == 0, out_);
  assert(out_.canFind("status completed") && out_.canFind("4 created"), out_);
  out_ = "";
  assert(cli.run(["logs", "HR → IAS (delta)", "--json"]) == 0);
  assert(parseJsonString(out_).length == 4, out_);
  out_ = "";
  assert(cli.run(["provisioned-entities", "list", "--entity-type=user", "--json"]) == 0);
  assert(parseJsonString(out_).length == 3);
  assert(cli.run(["provisioned-entities", "create", "--name=x"]) == 1); // read-only
  assert(cli.run(["provisioning-jobs", "fly", "x"]) == 2);
  assert(cli.run(["source-systems", "delete", "HR"]) == 1); // used by the job
  out_ = "";
  assert(cli.run(["system-types", "get", "ldap"]) == 0 && out_.canFind("LDAP"), out_);
  assert(cli.run(["stats"]) == 0);
  assert(cli.run(["run-due-jobs"]) == 0);
  out_ = "";
  assert(cli.run(["purge-logs"]) == 0 && out_.canFind("4 log entries"), out_);
  assert(cli.run(["demo", "--tenant=demo"]) == 0);
  assert(cli.run(["provisioning-jobs", "delete", "HR → IAS (delta)"]) == 0, out_);
}
