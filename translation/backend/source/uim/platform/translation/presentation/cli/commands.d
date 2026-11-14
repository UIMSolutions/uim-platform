/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Generic over the resource registry, so every
/// resource supports the same verbs — exactly like the REST/OData/GUI adapters.
module uim.platform.translation.presentation.cli.commands;

import std.file : readText, exists;
import uim.platform.translation;
import uim.platform.translation.presentation.cli.args;
import uim.platform.translation.presentation.resources;
import uim.platform.translation.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-translation-cli — SAP BTP style Translation Hub administration

Usage: uim-translation-cli <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --actor=<id>         acting user, recorded as createdBy/updatedBy (default: cli)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     volatile storage (testing)
  --json               machine readable JSON output

Commands:
  translate <text> [<text> ...] --from=<lang> --to=<lang> [--provider=..] [--domain=..] [--text-type=..]
  translate-document --from=<lang> --to=<lang> --file=<path> [--content-type=application/json] [--out=<path>]
  import-texts <project> <file.properties> [--text-type=uiText]   create/update texts from key=value lines
  export-texts <project> <lang> [--out=<path>]                    write key=translation lines
  process-jobs [--limit=<n>]             run pending translation jobs now
  resources                              resource kinds, their input fields and actions
  stats                                  aggregated figures of the tenant
  config                                 effective service configuration

  <resource> list   [--<field>=<value> ...]       filter by payload fields
  <resource> get    <id|name>
  <resource> create --<field>=<value> ... [--file=body.json]
  <resource> update <id|name> --<field>=<value> ...
  <resource> delete <id|name>
  <resource> fields                               settable fields
  <resource> <action> <id|name> [--<param>=..]    e.g. projects translate Webshop --force

Resources: %s

Values: lists "a,b" · structured fields as JSON · "@file" reads the value from
a file · project references (projectId) accept an id or a unique project name ·
--kebab-case = --camelCase.

Example:
  uim-translation-cli translate "Save" "Cancel" --from=en --to=de
  uim-translation-cli glossaries create --source-language=en --target-language=de --source-term=invoice \
      --target-term=Faktura --mandatory
  uim-translation-cli projects create --name=Webshop --source-language=en --target-languages=de,fr,es
  uim-translation-cli import-texts Webshop i18n.properties
  uim-translation-cli projects translate Webshop
  uim-translation-cli texts list --project-id=Webshop --status=partial
  uim-translation-cli texts set-translation <id> --language=de --text="Sichern"
  uim-translation-cli export-texts Webshop de --out=i18n_de.properties
  uim-translation-cli jobs create --job-type=document --source-language=en --target-language=fr --content=@readme.txt
  uim-translation-cli process-jobs
`;

/// Options that belong to the CLI itself, not to a resource payload.
enum string[] globalOptions = ["tenant", "actor", "data-dir", "dataDir", "storage", "json", "help", "file", "yes",
    "wide", "out"];

/// "source-language" → "sourceLanguage".
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

/// key=value lines of a .properties file (comments and blank lines skipped,
/// "\" line continuations joined, "\n" escapes kept).
string[2][] parseProperties(string text) {
  string[2][] result;
  string pending;
  foreach (raw; text.replace("\r", "").split("\n")) {
    auto line = pending ~ raw.stripLeft;
    pending = "";
    if (line.endsWith("\\") && !line.endsWith("\\\\")) {
      pending = line[0 .. $ - 1];
      continue;
    }
    auto t = line.strip;
    if (t.length == 0 || t[0] == '#' || t[0] == '!')
      continue;
    auto eq = t.indexOf('=');
    auto colon = t.indexOf(':');
    auto sep = eq < 0 ? colon : colon < 0 ? eq : min(eq, colon);
    if (sep <= 0)
      continue;
    result ~= [t[0 .. sep].strip, t[sep + 1 .. $].strip];
  }
  return result;
}

/// The command line adapter.
class TranslationCli {
  protected ResourceRegistry registry;
  protected TranslationConfig config;
  protected void delegate(string) @safe output;
  protected RequestIdentity who;
  protected bool json;

  this(ResourceRegistry registry, TranslationConfig config, void delegate(string) @safe output) {
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
      case "translate":
        return translate(a);
      case "translate-document":
        return translateDocument(a);
      case "import-texts":
        return importTexts(a);
      case "export-texts":
        return exportTexts(a);
      case "process-jobs":
        auto r = registry.processJobs(who.tenantId, a.intOpt("limit", 0));
        return emit(r, "%d job(s) processed, %d completed, %d failed\n%s".format(r["processed"].get!long,
            r["completed"].get!long, r["failed"].get!long,
            r["messages"].get!(Json[]).map!(m => "  " ~ m.get!string ~ "\n").join));
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      default:
        auto adapter = registry.byPath(a.arg(0));
        if (adapter is null)
          throw new CliUsageError("unknown command '" ~ a.arg(0) ~ "'");
        return resource(adapter, a);
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-translation-cli help' for usage.\n");
      return 2;
    } catch (ResourceError e) {
      output("error %d (%s): %s\n".format(e.status, e.code, e.msg));
      return 1;
    } catch (Exception e) {
      output("error: " ~ e.msg ~ "\n");
      return 1;
    }
  }

  // ── translation commands ───────────────────────────────────────────────

  protected int translate(CliArgs a) {
    auto texts = a.positional[1 .. $].dup;
    if (texts.length == 0)
      throw new CliUsageError("translate needs at least one text");
    auto body = Json.emptyObject
      .set("sourceLanguage", a.requireOpt("from"))
      .set("targetLanguage", a.requireOpt("to"))
      .set("provider", a.opt("provider"))
      .set("domainName", a.opt("domain"))
      .set("textType", a.opt("text-type", a.opt("textType")));
    auto arr = Json.emptyArray;
    foreach (t; texts)
      arr ~= Json(t);
    body["texts"] = arr;
    auto r = registry.translateTexts(who, body);

    Table t;
    t.headers = ["Source", "Translation", "Quality", "Glossary"];
    foreach (item; r["translations"].get!(Json[]))
      t.rows ~= [fieldString(item, "sourceText"), fieldString(item, "translatedText"),
        fieldString(item, "qualityScore") ~ " " ~ fieldString(item, "qualityLevel")
        ~ (fieldBool(item, "truncationRisk") ? " (too long)" : ""), fieldString(item, "glossaryHits")];
    return emit(r, t.render ~ "%s→%s via %s, average quality %s\n".format(fieldString(r, "sourceLanguage"),
        fieldString(r, "targetLanguage"), fieldString(r, "provider"), fieldString(r, "averageQuality")));
  }

  protected int translateDocument(CliArgs a) {
    auto path = a.requireOpt("file");
    auto body = Json.emptyObject
      .set("sourceLanguage", a.requireOpt("from"))
      .set("targetLanguage", a.requireOpt("to"))
      .set("content", readFile(path))
      .set("contentType", a.opt("content-type", a.opt("contentType", contentTypeOf(path))))
      .set("provider", a.opt("provider"))
      .set("domainName", a.opt("domain"));
    auto r = registry.translateDocument(who, body);
    auto summary = "%s characters, quality %s (%s), %s glossary term(s)\n".format(fieldString(r, "characterCount"),
      fieldString(r, "qualityScore"), fieldString(r, "qualityLevel"), fieldString(r, "glossaryHits"));
    if (a.has("out")) {
      writeFile(a.opt("out"), fieldString(r, "translatedContent"));
      return emit(r, "written to " ~ a.opt("out") ~ " — " ~ summary);
    }
    return emit(r, fieldString(r, "translatedContent") ~ "\n\n" ~ summary);
  }

  /// Create or update the texts of a project from a .properties file.
  protected int importTexts(CliArgs a) {
    auto projects = registry.byPath("projects"), texts = registry.byPath("texts");
    auto projectId = registry.resolve(projects, who.tenantId, a.requireArg(1, "project"));
    auto entries = parseProperties(readFile(a.requireArg(2, "file")));
    auto existing = texts.list(who.tenantId, ["projectId": projectId]);
    int created, updated, unchanged;
    foreach (e; entries) {
      auto found = existing.filter!(x => fieldString(x, "name") == e[0]);
      if (found.empty) {
        auto body = Json.emptyObject.set("projectId", projectId).set("name", e[0]).set("sourceText", e[1]);
        if (a.has("text-type"))
          body["textType"] = a.opt("text-type");
        texts.create(who, body);
        created++;
      } else if (fieldString(found.front, "sourceText") != e[1]) {
        texts.update(who, fieldString(found.front, "id"), Json.emptyObject.set("sourceText", e[1]));
        updated++;
      } else
        unchanged++;
    }
    return emit(Json.emptyObject.set("created", created).set("updated", updated).set("unchanged", unchanged),
      "%d text(s) created, %d updated, %d unchanged\n".format(created, updated, unchanged));
  }

  /// Write key=translation lines of one target language (source text if not translated).
  protected int exportTexts(CliArgs a) {
    auto projectId = registry.resolve(registry.byPath("projects"), who.tenantId, a.requireArg(1, "project"));
    auto lang = normalizeLanguage(a.requireArg(2, "language"));
    string[] lines;
    int missing;
    auto result = Json.emptyObject;
    auto texts = registry.byPath("texts").list(who.tenantId, ["projectId": projectId]);
    texts.sort!((x, y) => fieldString(x, "name") < fieldString(y, "name"));
    foreach (text; texts) {
      string value;
      foreach (tr; member(text, "translations").get!(Json[]))
        if (fieldString(tr, "language") == lang)
          value = fieldString(tr, "text");
      if (value.length == 0) {
        value = fieldString(text, "sourceText");
        missing++;
      }
      lines ~= fieldString(text, "name") ~ "=" ~ value.replace("\n", "\\n");
      result[fieldString(text, "name")] = value;
    }
    auto content = lines.join("\n") ~ (lines.length ? "\n" : "");
    if (a.has("out")) {
      writeFile(a.opt("out"), content);
      return emit(result, "%d text(s) written to %s (%d untranslated)\n".format(lines.length, a.opt("out"), missing));
    }
    return emit(result, content);
  }

  // ── resource commands ──────────────────────────────────────────────────

  protected int resources() {
    Table t;
    t.headers = ["Resource", "Title", "Parent", "Access", "Actions"];
    foreach (a; registry.adapters)
      t.rows ~= [a.path, a.title, a.parentField, a.readOnly ? "read-only" : a.updatable ? "read/write" : "create/delete",
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
      return emit(Json(adapter.inputFields.map!(f => f.name).join(",")), t.render);
    default:
      auto action = adapter.actions.filter!(x => x.name == verb);
      if (action.empty)
        throw new CliUsageError(adapter.path ~ ": unknown verb '" ~ verb ~ "'" ~ (adapter.actions.length
            ? " (actions: " ~ adapter.actions.map!(x => x.name).join(", ") ~ ")" : ""));
      auto id = resolveId(adapter, a.requireArg(2, "id or name"));
      auto params = Json.emptyObject;
      foreach (k, v; a.options) // --language and --text
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

  protected static void writeFile(string path, string content) @trusted {
    import std.file : write;

    write(path, content);
  }

  protected static string contentTypeOf(string path) {
    if (path.endsWith(".json"))
      return "application/json";
    if (path.endsWith(".properties"))
      return "text/x-java-properties";
    if (path.endsWith(".md"))
      return "text/markdown";
    if (path.endsWith(".html") || path.endsWith(".htm"))
      return "text/html";
    return "text/plain";
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
  mixin(ShowTest!("TranslationCli"));

  assert(parseProperties("# c\nbutton.save = Save\nmsg:Hello \\\n  world\n\n!x\n") ==
      [["button.save", "Save"], ["msg", "Hello world"]]);
  assert(camelCase("target-languages") == "targetLanguages");

  TranslationConfig cfg;
  cfg.storage = "memory";
  cfg.defaultTenant = "t1";
  string out_;
  auto cli = new TranslationCli(new ResourceRegistry(buildContainer(cfg).ports), cfg, (s) { out_ ~= s; });

  assert(cli.run([]) == 2);
  assert(cli.run(["translate", "Save", "Cancel", "--from=en", "--to=de"]) == 0, out_);
  assert(out_.canFind("Speichern") && out_.canFind("Abbrechen"), out_);
  assert(cli.run(["translate", "Save", "--from=en"]) == 2); // --to missing
  assert(cli.run(["translate", "Save", "--from=en", "--to=xx"]) == 1);

  assert(cli.run(["glossaries", "create", "--source-language=en", "--target-language=de", "--source-term=invoice",
      "--target-term=Faktura", "--mandatory"]) == 0, out_);
  assert(cli.run(["projects", "create", "--name=Webshop", "--target-languages=de,fr"]) == 0, out_);
  assert(cli.run(["texts", "create", "--name=X"]) == 2); // --projectId missing
  assert(cli.run(["texts", "create", "--project-id=Webshop", "--name=BUTTON_SAVE", "--source-text=Save"]) == 0, out_);
  assert(cli.run(["texts", "create", "--project-id=Webshop", "--name=MSG_INVOICE", "--source-text=Invoice not found",
      "--text-type=errorMessage"]) == 0, out_);
  out_ = "";
  assert(cli.run(["projects", "translate", "Webshop"]) == 0, out_);
  assert(out_.canFind("status completed"), out_);
  out_ = "";
  assert(cli.run(["texts", "list", "--project-id=Webshop", "--json"]) == 0);
  assert(parseJsonString(out_).length == 2);
  out_ = "";
  assert(cli.run(["export-texts", "Webshop", "de"]) == 0);
  assert(out_ == "BUTTON_SAVE=Speichern\nMSG_INVOICE=Faktura nicht gefunden\n", out_);
  assert(cli.run(["projects", "fly", "Webshop"]) == 2);
  assert(cli.run(["languages", "create", "--id=xx"]) == 1);
  out_ = "";
  assert(cli.run(["languages", "get", "de"]) == 0 && out_.canFind("Deutsch"));
  assert(cli.run(["jobs", "create", "--job-type=text", "--source-language=en", "--target-language=es",
      "--content=Welcome"]) == 0, out_);
  out_ = "";
  assert(cli.run(["process-jobs"]) == 0);
  assert(out_.canFind("1 job(s) processed, 1 completed"), out_);
  assert(cli.run(["stats"]) == 0);
  assert(cli.run(["projects", "archive", "Webshop"]) == 0, out_);
  assert(cli.run(["projects", "delete", "Webshop"]) == 0, out_);
}
