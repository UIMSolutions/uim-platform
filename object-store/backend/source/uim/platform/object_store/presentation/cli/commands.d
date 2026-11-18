/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Generic over the resource registry, so every
/// resource supports the same verbs — exactly like the REST/OData/GUI adapters —
/// plus S3 style content commands (put, get, ls, rm).
module uim.platform.object_store.presentation.cli.commands;

import std.file : read, exists;
import uim.platform.object_store;
import uim.platform.object_store.presentation.cli.args;
import uim.platform.object_store.presentation.resources;
import uim.platform.object_store.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-object-store-cli — SAP BTP style Object Store administration

Usage: uim-object-store-cli <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --actor=<id>         acting user, recorded as createdBy/updatedBy (default: cli)
  --data-dir=<dir>     snapshot + blob directory shared with server and GUI
  --storage=memory     volatile storage (testing)
  --json               machine readable JSON output

Content (data plane — binding permissions and bucket policies apply):
  put <bucket> <key> <file> [--content-type=..] [--meta=k=v,k2=v2]   upload a file ("-" = --content text)
  get <bucket> <key> [--out=<path>] [--version=<n>]                  download (stdout if no --out)
  ls  <bucket> [<prefix>] [--recursive]                              list keys and folders
  rm  <bucket> <key>                                                 delete (delete marker if versioned)
  Use --access-key-id=.. --secret-access-key=.. to act as a service binding.

Operations:
  evaluate --bucket=<b> --principal=<p> --action=read|write|delete|list|all [--key=<k>]
  cors-check --bucket=<b> --origin=<url> --method=GET [--headers=a,b]
  verify --access-key-id=<id> --secret-access-key=<secret>
  lifecycle [--bucket=<b>]                apply the lifecycle rules now
  resources                               resource kinds, their input fields and actions
  stats                                   aggregated figures of the tenant
  config                                  effective service configuration

  <resource> list   [--<field>=<value> ...]       filter by payload fields
  <resource> get    <id|name>
  <resource> create --<field>=<value> ... [--file=body.json]
  <resource> update <id|name> --<field>=<value> ...
  <resource> delete <id|name>
  <resource> fields                               settable fields
  <resource> <action> <id|name> [--<param>=..]    e.g. objects copy <id> --target-key=b.txt

Resources: %s

Values: lists "a,b" · key/value lists "k=v,k2=v2" · structured fields as JSON ·
"@file" reads the value from a file · bucket references (bucketId) accept an id
or the bucket name · --kebab-case = --camelCase.

Example:
  uim-object-store-cli buckets create --name=media --provider=aws --region=eu-central-1 --versioning-enabled
  uim-object-store-cli put media docs/readme.md README.md --content-type=text/markdown
  uim-object-store-cli ls media
  uim-object-store-cli versions list --object-id=<id>
  uim-object-store-cli bindings create --bucket-id=media --name=ci --permission=readWrite
  uim-object-store-cli policies create --bucket-id=media --name=readers --principals=* --actions=read,list
  uim-object-store-cli lifecycle-rules create --bucket-id=media --name=logs --prefix=logs/ --expiration-days=90
  uim-object-store-cli evaluate --bucket=media --principal=jane --action=read --key=docs/readme.md
`;

/// Options that belong to the CLI itself, not to a resource payload.
enum string[] globalOptions = ["tenant", "actor", "data-dir", "dataDir", "storage", "json", "help", "file", "yes",
    "wide", "out", "access-key-id", "secret-access-key"];

/// "versioning-enabled" → "versioningEnabled".
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
class ObjectStoreCli {
  protected ResourceRegistry registry;
  protected ObjectStoreConfig config;
  protected void delegate(string) @safe output;
  protected RequestIdentity who;
  protected bool json;

  this(ResourceRegistry registry, ObjectStoreConfig config, void delegate(string) @safe output) {
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
      case "put":
        return put(a);
      case "get":
        return get(a);
      case "ls":
        return ls(a);
      case "rm":
        auto r = registry.deleteContent(caller(a), a.requireArg(1, "bucket"), a.requireArg(2, "key"));
        return emit(r, fieldString(r, "message") ~ "\n");
      case "evaluate":
        auto d = registry.evaluateAccess(who.tenantId, Json.emptyObject.set("bucketId", a.requireOpt("bucket"))
            .set("principal", a.opt("principal")).set("action", a.opt("action", "read")).set("key", a.opt("key")));
        return emit(d, (fieldBool(d, "allowed") ? "ALLOWED" : "DENIED") ~ " — " ~ fieldString(d, "reason") ~ "\n");
      case "cors-check":
        auto c = registry.checkCors(who.tenantId, Json.emptyObject.set("bucketId", a.requireOpt("bucket"))
            .set("origin", a.requireOpt("origin")).set("method", a.opt("method", "GET"))
            .set("requestHeaders", a.opt("headers")));
        return emit(c, (fieldBool(c, "allowed") ? "ALLOWED" : "DENIED") ~ " — " ~ fieldString(c, "reason") ~ "\n");
      case "verify":
        auto v = registry.verifyCredentials(who.tenantId, Json.emptyObject
            .set("accessKeyId", a.requireOpt("access-key-id")).set("secretAccessKey", a.requireOpt("secret-access-key")));
        output(json ? v.toPrettyString ~ "\n" : (fieldBool(v, "valid") ? "VALID" : "INVALID") ~ " — "
            ~ fieldString(v, "reason") ~ "\n");
        return fieldBool(v, "valid") ? 0 : 1;
      case "lifecycle":
        auto r = registry.applyLifecycle(who, Json.emptyObject.set("bucketId", a.opt("bucket")));
        return emit(r, "%s bucket(s), %s rule(s): %s expired, %s transitioned, %s version(s) purged, %s skipped\n%s"
            .format(fieldString(r, "bucketsEvaluated"), fieldString(r, "rulesEvaluated"), fieldString(r, "expired"),
              fieldString(r, "transitioned"), fieldString(r, "versionsPurged"), fieldString(r, "skipped"),
              fieldStrings(r, "messages").map!(m => "  " ~ m ~ "\n").join));
      default:
        auto adapter = registry.byPath(a.arg(0));
        if (adapter is null)
          throw new CliUsageError("unknown command '" ~ a.arg(0) ~ "'");
        return resource(adapter, a);
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-object-store-cli help' for usage.\n");
      return 2;
    } catch (ResourceError e) {
      output("error %d (%s): %s\n".format(e.status, e.code, e.msg));
      return 1;
    } catch (ObjectStoreException e) {
      output("error %d (%s): %s\n".format(e.status, errorCodeOf(e.status), e.msg));
      return 1;
    } catch (Exception e) {
      output("error: " ~ e.msg ~ "\n");
      return 1;
    }
  }

  // ── content commands ───────────────────────────────────────────────────

  protected DataPlaneCaller caller(CliArgs a) {
    DataPlaneCaller c;
    c.identity = who;
    c.accessKeyId = a.opt("access-key-id");
    c.secretAccessKey = a.opt("secret-access-key");
    return c;
  }

  protected int put(CliArgs a) {
    auto bucket = a.requireArg(1, "bucket"), key = a.requireArg(2, "key"), path = a.requireArg(3, "file");
    const(ubyte)[] data = path == "-" ? cast(const(ubyte)[]) a.opt("content") : readBytes(path);
    MetadataEntry[] meta;
    foreach (part; a.listOpt("meta")) {
      auto eq = part.indexOf('=');
      meta ~= eq < 0 ? MetadataEntry(part, "") : MetadataEntry(part[0 .. eq], part[eq + 1 .. $]);
    }
    auto row = registry.putContent(caller(a), bucket, key, data, a.opt("content-type", contentTypeOf(key)), meta);
    return emit(row, "%s/%s written: version %s, %s, etag %s\n".format(fieldString(row, "bucketName"), key,
        fieldString(row, "currentVersion"), formatBytes(fieldLong(row, "size")), fieldString(row, "etag")));
  }

  protected int get(CliArgs a) {
    auto content = registry.getContent(caller(a), a.requireArg(1, "bucket"), a.requireArg(2, "key"),
      a.intOpt("version", 0));
    if (a.has("out")) {
      writeBytes(a.opt("out"), content.data);
      return emit(encode(content.version_, true), "%s written to %s (version %d, %s)\n".format(content.object.name,
          a.opt("out"), content.version_.versionNumber, formatBytes(content.data.length)));
    }
    output((() @trusted => cast(string) content.data.idup)());
    return 0;
  }

  protected int ls(CliArgs a) {
    auto r = registry.listContent(caller(a), a.requireArg(1, "bucket"), a.arg(2), a.flag("recursive") ? "" : "/");
    Table t;
    t.headers = ["Key", "Size", "Class", "Version", "Modified"];
    foreach (f; fieldStrings(r, "commonPrefixes"))
      t.rows ~= [f, "<folder>", "", "", ""];
    foreach (o; r["objects"].get!(Json[]))
      t.rows ~= [fieldString(o, "name"), formatBytes(fieldLong(o, "size")), fieldString(o, "storageClass"),
        fieldString(o, "currentVersion"), cellText(member(o, "updatedAt"))];
    return emit(r, t.render ~ "%d folder(s), %d object(s)\n".format(r["commonPrefixes"].length, r["objects"].length));
  }

  // ── resource commands ──────────────────────────────────────────────────

  protected int resources() {
    Table t;
    t.headers = ["Resource", "Title", "Parent", "Access", "Actions"];
    foreach (a; registry.adapters)
      t.rows ~= [a.path, a.title, a.parentField, a.readOnly ? "read-only" : a.creatable ? (a.updatable
          ? "read/write" : "create/delete") : "read/delete", a.actions.map!(x => x.name).join(", ")];
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
      foreach (f; adapter.readOnly || !adapter.creatable ? adapter.fields : adapter.inputFields)
        t.rows ~= [f.name, enumText(f.kind) ~ (f.recordType.length ? " (" ~ f.recordType ~ ")" : ""), f.options.join("|")];
      return emit(Json(adapter.inputFields.map!(f => f.name).join(",")), t.render);
    default:
      auto action = adapter.actions.filter!(x => x.name == verb);
      if (action.empty)
        throw new CliUsageError(adapter.path ~ ": unknown verb '" ~ verb ~ "'" ~ (adapter.actions.length
            ? " (actions: " ~ adapter.actions.map!(x => x.name).join(", ") ~ ")" : ""));
      auto id = resolveId(adapter, a.requireArg(2, "id or name"));
      auto params = Json.emptyObject;
      foreach (k, v; a.options)
        if (action.front.parameters.canFind(camelCase(k)))
          params[camelCase(k)] = v.length > 1 && v[0] == '@' ? readText(v[1 .. $]) : v;
      return emitChange(adapter, verb, adapter.invoke(who, id, verb, registry.withReferences(who.tenantId, params)));
    }
  }

  // ── input ──────────────────────────────────────────────────────────────

  /// Build the payload from --file and the resource options.
  protected Json payload(IResourceAdapter adapter, CliArgs a, bool creating) {
    auto body = Json.emptyObject;
    if (a.has("file"))
      body = parseJsonString(readText(a.opt("file")));
    foreach (k, v; a.options) {
      if (globalOptions.canFind(k))
        continue;
      body[camelCase(k)] = v.length > 1 && v[0] == '@' ? readText(v[1 .. $]) : v;
    }
    auto parent = adapter.parentField;
    if (creating && parent.length > 0 && fieldString(body, parent).length == 0)
      throw new CliUsageError(adapter.path ~ " create needs --" ~ parent);
    return registry.withReferences(who.tenantId, body);
  }

  protected static const(ubyte)[] readBytes(string path) @trusted {
    if (!path.exists)
      throw new CliUsageError("file not found: " ~ path);
    return cast(const(ubyte)[]) read(path);
  }

  protected static string readText(string path) @trusted {
    return cast(string) readBytes(path).idup;
  }

  protected static void writeBytes(string path, const(ubyte)[] data) @trusted {
    import std.file : write;

    write(path, data);
  }

  /// A content type from the key's extension.
  static string contentTypeOf(string key) {
    immutable string[string] types = [
      "txt": "text/plain", "md": "text/markdown", "json": "application/json", "xml": "application/xml",
      "html": "text/html", "htm": "text/html", "css": "text/css", "js": "text/javascript", "csv": "text/csv",
      "pdf": "application/pdf", "zip": "application/zip", "gz": "application/gzip", "png": "image/png",
      "jpg": "image/jpeg", "jpeg": "image/jpeg", "gif": "image/gif", "svg": "image/svg+xml", "webp": "image/webp",
      "mp4": "video/mp4", "mp3": "audio/mpeg", "log": "text/plain", "properties": "text/x-java-properties",
      "yaml": "application/yaml", "yml": "application/yaml"
    ];
    auto dot = key.lastIndexOf('.');
    if (dot < 0)
      return "application/octet-stream";
    return types.get(key[dot + 1 .. $].toLower, "application/octet-stream");
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
    auto text = "%s '%s' %s (id %s%s)\n".format(adapter.typeName, fieldString(row, "name"), verb,
      fieldString(row, "id"), status.length > 0 ? ", status " ~ status : "");
    auto secret = fieldString(row, "secretAccessKey");
    if (secret.length > 0)
      text ~= "  access key id:     " ~ fieldString(row, "accessKeyId") ~ "\n  secret access key: " ~ secret
        ~ "\n  (the secret is shown only once — store it now)\n";
    return emit(row, text);
  }
}

///
unittest {
  mixin(ShowTest!("ObjectStoreCli"));

  import std.file : tempDir, remove;
  import std.path : buildPath;

  assert(camelCase("versioning-enabled") == "versioningEnabled");
  assert(ObjectStoreCli.contentTypeOf("a/b.JPG") == "image/jpeg");
  assert(ObjectStoreCli.contentTypeOf("noext") == "application/octet-stream");

  ObjectStoreConfig cfg;
  cfg.storage = "memory";
  cfg.defaultTenant = "t1";
  string out_;
  auto cli = new ObjectStoreCli(new ResourceRegistry(buildContainer(cfg).ports), cfg, (s) { out_ ~= s; });

  assert(cli.run([]) == 2);
  assert(cli.run(["buckets", "create", "--name=media", "--versioning-enabled"]) == 0, out_);
  assert(cli.run(["buckets", "create", "--name=Bad_Name"]) == 1);
  assert(cli.run(["put", "media", "docs/hello.txt", "-", "--content=Hello", "--meta=owner=jane"]) == 0, out_);
  assert(out_.canFind("version 1"), out_);
  assert(cli.run(["put", "media", "docs/hello.txt", "-", "--content=Hello again"]) == 0, out_);
  out_ = "";
  assert(cli.run(["get", "media", "docs/hello.txt"]) == 0);
  assert(out_ == "Hello again", out_);
  out_ = "";
  assert(cli.run(["get", "media", "docs/hello.txt", "--version=1"]) == 0);
  assert(out_ == "Hello", out_);

  auto file = buildPath(tempDir, "uim-object-store-cli-" ~ newSalt()[0 .. 8] ~ ".txt");
  scope (exit)
    if (file.exists)
      (() @trusted => remove(file))();
  assert(cli.run(["get", "media", "docs/hello.txt", "--out=" ~ file]) == 0, out_);
  assert((() @trusted => cast(string) read(file))() == "Hello again");

  out_ = "";
  assert(cli.run(["ls", "media"]) == 0);
  assert(out_.canFind("docs/") && out_.canFind("<folder>"), out_);
  out_ = "";
  assert(cli.run(["objects", "list", "--bucket-id=media", "--json"]) == 0);
  auto objects = parseJsonString(out_);
  assert(objects.length == 1 && objects[0]["metadata"][0]["value"].get!string == "jane");
  auto objectId = objects[0]["id"].get!string;
  assert(cli.run(["objects", "copy", objectId, "--target-key=docs/copy.txt"]) == 0, out_);
  assert(cli.run(["objects", "fly", objectId]) == 2);

  out_ = "";
  assert(cli.run(["bindings", "create", "--bucket-id=media", "--name=reader"]) == 0, out_);
  assert(out_.canFind("secret access key"), out_);
  auto key = out_[out_.indexOf("access key id:") + 14 .. $].strip.split("\n")[0].strip;
  auto secret = out_[out_.indexOf("secret access key:") + 18 .. $].strip.split("\n")[0].strip;
  assert(cli.run(["verify", "--access-key-id=" ~ key, "--secret-access-key=" ~ secret]) == 0, out_);
  assert(cli.run(["get", "media", "docs/hello.txt", "--access-key-id=" ~ key, "--secret-access-key=" ~ secret]) == 0);
  out_ = "";
  assert(cli.run(["put", "media", "x.txt", "-", "--content=x", "--access-key-id=" ~ key,
      "--secret-access-key=" ~ secret]) == 1); // readOnly binding
  assert(out_.canFind("403"), out_);

  assert(cli.run(["policies", "create", "--bucket-id=media", "--name=readers", "--principals=*",
      "--actions=read,list"]) == 0, out_);
  out_ = "";
  assert(cli.run(["evaluate", "--bucket=media", "--principal=bob", "--action=write", "--key=a"]) == 0);
  assert(out_.canFind("DENIED"), out_);
  assert(cli.run(["lifecycle-rules", "create", "--bucket-id=media", "--name=old", "--expiration-days=365"]) == 0, out_);
  out_ = "";
  assert(cli.run(["lifecycle", "--bucket=media"]) == 0);
  assert(out_.canFind("1 rule(s)"), out_);
  assert(cli.run(["regions", "list", "--provider=gcp"]) == 0);
  assert(cli.run(["regions", "create", "--id=x"]) == 1);
  assert(cli.run(["stats"]) == 0);
  assert(cli.run(["rm", "media", "docs/copy.txt"]) == 1); // policies: "cli" may not delete
  assert(cli.run(["buckets", "empty", "media"]) == 0, out_);
  assert(cli.run(["buckets", "delete", "media"]) == 0, out_);
}
