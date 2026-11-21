/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus architecture specific commands.
module uim.platform.architecture.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-architecture-cli";

CliApplication buildArchitectureCli(ArchitectureContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "Architecture repository: TOGAF building blocks, ArchiMate relationships, lifecycle, gap and impact analysis",
    output);
  app.defaultTenant = config.defaultTenant;
  app.defaultUser = "cli";
  app.globalOption("tenant", "<id>", "tenant to operate on (default: " ~ app.defaultTenant ~ ")");
  app.globalOption("storage", "memory|file", "storage backend (default: " ~ config.storage ~ ")");
  app.globalOption("data-file", "<path>", "JSON snapshot shared with server and GUI (implies --storage=file)");
  app.globalOption("config-dir", "<dir>", "directory with default.json (default: config)");

  registerEntityCommands(app, engine);

  TextTable rowsTable(Json[] rows, string setName) {
    auto set = engine.model.find(setName);
    auto columns = set.listColumns;
    return TextTable.fromRows(rows, columns, columns.map!(n => set.labelOf(n)).array);
  }

  app.command("stats", "", "Show the key figures of the repository", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("seed", "", "Create the demo landscape in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d building blocks, %d relationships", c.request.tenantId,
      r["blocks"].get!long, r["relationships"].get!long));
  }, []);

  app.command("status", "<blockId> <status>", "Lifecycle transition (approved, inDevelopment, active, deprecated, retired)",
    (CliContext c) {
    auto r = engine.invoke(c.request, "ChangeStatus", Json([
        "id": Json(c.operand(0, "building block id")), "status": Json(c.operand(1, "status"))
      ]));
    return c.done(r, r["id"].get!string ~ ": " ~ r["previousStatus"].get!string ~ " → " ~ r["status"].get!string);
  }, []);

  app.command("relate", "<sourceId> <type> <targetId> [--description=TEXT]", "Create an ArchiMate relationship",
    (CliContext c) {
    auto payload = Json([
      "sourceId": Json(c.operand(0, "source id")), "type": Json(c.operand(1, "relationship type")),
      "targetId": Json(c.operand(2, "target id"))
    ]);
    if (c.args.has("description"))
      payload["description"] = c.args.opt("description");
    auto row = engine.create(c.request, "Relationships", payload);
    return c.done(row, format("%s: %s %s %s", row["id"].get!string, row["sourceName"].get!string, row["type"].get!string,
      row["targetName"].get!string));
  }, ["description"]);

  app.command("impact", "<blockId>", "Show what depends on a building block", (CliContext c) {
    auto rows = engine.invoke(c.request, "AnalyzeImpact", Json(["id": Json(c.operand(0, "building block id"))]));
    auto columns = ["depth", "id", "name", "kindAbbreviation", "status", "via", "viaBlockId"];
    return c.emit(rows, TextTable.fromRows(rows.get!(Json[]), columns));
  }, []);

  app.command("gaps", "", "Architecture building blocks without a realizing solution building block", (CliContext c) {
    auto page = engine.query(c.request, "Gaps", (string[string]).init);
    return c.emit(Json(page.rows), rowsTable(page.rows, "Gaps"));
  }, []);

  app.command("export", "[--model-name=NAME]", "Print the ArchiMate Model Exchange File (XML)", (CliContext c) {
    auto r = engine.invoke(c.request, "ExportArchiMate", Json(["modelName": Json(c.args.opt("model-name", ""))]));
    c.print(r["content"].get!string);
    return 0;
  }, ["model-name"]);

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
  auto container = new ArchitectureContainer(loadArchitectureConfig(o, "/nonexistent"));
  container.events.log = false;
  string out_;
  auto cli = buildArchitectureCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed", "--json"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // not empty → conflict
  assert(cli.run(["list", "BuildingBlocks"]) == 0 && cli.run(["stats"]) == 0 && cli.run(["gaps"]) == 0);
  out_ = "";
  assert(cli.run(["status", "abb-analytics", "approved", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["status"].get!string == "approved", out_);
  assert(cli.run(["status", "abb-analytics", "retired"]) == 0);
  assert(cli.run(["status", "abb-analytics", "active"]) != 0); // retired is final
  out_ = "";
  assert(cli.run(["impact", "tbb-postgres", "--json"]) == 0, out_);
  assert(parseJsonString(out_).length >= 2, out_);
  assert(cli.run(["relate", "tbb-kyma", "serving", "sbb-order-service"]) == 0);
  assert(cli.run(["relate", "dbb-customer", "serving", "sbb-order-service"]) != 0); // data does not serve
  out_ = "";
  assert(cli.run(["export"]) == 0 && out_.canFind("<model "), out_);
  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0 && cli.run(["config"]) == 0);
}
