/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus data quality commands.
module uim.platform.data_quality.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-data-quality-cli";

/// Options that select storage/configuration; read before the container is built.
enum string[] cliBootstrapOptions = ["storage", "data-file", "config-dir"];

CliApplication buildDqCli(DqContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "Data quality administration: datasets, records, validation and cleansing rules, violations, profiles, duplicates, jobs, addresses, scorecards",
    output);
  app.defaultTenant = config.defaultTenant;
  app.defaultUser = "cli";
  app.globalOption("tenant", "<id>", "tenant to operate on (default: " ~ app.defaultTenant ~ ")");
  app.globalOption("storage", "memory|file", "storage backend (default: " ~ config.storage ~ ")");
  app.globalOption("data-file", "<path>", "JSON snapshot shared with server and GUI (implies --storage=file)");
  app.globalOption("config-dir", "<dir>", "directory with default.json (default: config)");

  registerEntityCommands(app, engine);

  int show(CliContext c, Json row) {
    return c.emit(row, TextTable.keyValue(row, row.get!(Json[string]).keys.sort.array));
  }

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("seed", "", "Create the demo content in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d datasets, %d records, %d validation rules, %d cleansing rules, "
      ~ "%d violations, %d match groups, %d addresses", c.request.tenantId, r["datasets"].get!long, r["records"].get!long,
      r["validationRules"].get!long, r["cleansingRules"].get!long, r["violations"].get!long, r["matchGroups"].get!long,
      r["addresses"].get!long));
  }, []);

  app.command("validate", "<dataset>", "Validate every record of a dataset", (CliContext c) {
    return show(c, engine.invoke(c.request, "ValidateDataset", Json(["datasetId": Json(c.operand(0, "dataset"))])));
  }, []);

  app.command("profile", "<dataset>", "Profile the fields of a dataset", (CliContext c) {
    return show(c, engine.invoke(c.request, "ProfileDataset", Json(["datasetId": Json(c.operand(0, "dataset"))])));
  }, []);

  app.command("duplicates", "<dataset> <field,field…> [--strategy=fuzzy|exact|phonetic|composite] [--threshold=85]",
    "Detect duplicate records", (CliContext c) {
    auto p = Json(["datasetId": Json(c.operand(0, "dataset")), "matchFields": Json(c.operand(1, "match fields"))]);
    if (c.args.has("strategy"))
      p["strategy"] = c.args.opt("strategy");
    if (c.args.has("threshold"))
      p["threshold"] = c.args.intOpt("threshold", 85);
    return show(c, engine.invoke(c.request, "DetectDuplicates", p));
  }, ["strategy", "threshold"]);

  app.command("scorecard", "<dataset>", "Compute the quality scorecard of a dataset", (CliContext c) {
    return show(c, engine.invoke(c.request, "ComputeScorecard", Json(["datasetId": Json(c.operand(0, "dataset"))])));
  }, []);

  app.command("cleanse", "<dataset> [--dry-run] [--rules=a,b]", "Create and run a cleansing job", (CliContext c) {
    auto p = Json(["datasetId": Json(c.operand(0, "dataset")), "dryRun": Json(c.args.has("dry-run"))]);
    if (c.args.has("rules"))
      p["ruleIds"] = texts(c.args.opt("rules").split(",").map!(s => s.strip).filter!(s => s.length > 0).array);
    auto job = engine.create(c.request, "CleansingJobs", p);
    if (job["status"].get!string == "pending")
      job = engine.invoke(c.request, "RunCleansingJob", Json(["key": job["key"]]));
    return c.done(job, format("Cleansing job %s %s: %d records, %d fields changed%s", job["id"].get!string,
      job["status"].get!string, job["changedRecords"].get!long, job["changedFields"].get!long,
      c.args.has("dry-run") ? " (dry run)" : ""));
  }, ["dry-run", "rules"]);

  app.command("import", "<dataset> <file.csv> [--create]", "Import records from a CSV file (header line = field names)",
    (CliContext c) @trusted {
    import std.file : readText;

    auto csv = readText(c.operand(1, "CSV file"));
    auto r = engine.invoke(c.request, "ImportCsv", Json(["datasetId": Json(c.operand(0, "dataset")), "csv": Json(csv),
        "createDataset": Json(c.args.has("create"))]));
    return c.done(r, format("Imported into '%s': %d created, %d updated, %d skipped", r["datasetId"].get!string,
      r["created"].get!long, r["updated"].get!long, r["skipped"].get!long));
  }, ["create"]);

  app.command("config", "", "Show the effective configuration (secrets masked)", (CliContext c) {
    c.print(config.toMaskedJson().toPrettyString ~ "\n");
    return 0;
  }, []);

  return app;
}

/// Configuration overrides from the bootstrap options.
Json[string] cliOverrides(CliArgs a) {
  Json[string] o;
  if (a.has("data-file")) {
    o["storage"] = "file";
    o["dataFile"] = a.opt("data-file");
  }
  if (a.has("storage"))
    o["storage"] = a.opt("storage");
  return o;
}

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  o["jobIntervalSeconds"] = 0;
  auto container = new DqContainer(loadDqConfig(o, "/nonexistent"));
  container.events.log = false;
  string out_;
  auto cli = buildDqCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed", "--json"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // not empty → conflict
  assert(cli.run(["list", "Violations"]) == 0 && cli.run(["stats"]) == 0);
  out_ = "";
  assert(cli.run(["cleanse", "customers", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["status"].get!string == "completed", out_);
  assert(cli.run(["validate", "customers"]) == 0 && cli.run(["profile", "customers"]) == 0);
  assert(cli.run(["duplicates", "customers", "name,city", "--strategy=composite"]) == 0);
  assert(cli.run(["scorecard", "customers"]) == 0);
  assert(cli.run(["validate", "nope"]) == 1);
  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0 && cli.run(["config"]) == 0);
}
