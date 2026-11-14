/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Talks to the application exclusively via the
/// driving ports (TransportPorts) — exactly like the REST/OData/GUI adapters.
module uim.platform.transport.presentation.cli.commands;

import uim.platform.transport;
import uim.platform.transport.presentation.cli.args;
import uim.platform.transport.presentation.tabular;
import uim.platform.transport.presentation.odata.metadata : buildMetadataXml;
import uim.platform.transport.presentation.odata.model : transportODataModel;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-transport-cli — SAP Cloud Transport Management style administration

Usage: uim-transport-cli <command> [subcommand] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     use volatile storage (testing)
  --user=<name>        acting user recorded in the audit trail (default: cli)
  --json               machine readable JSON output

<node> and <request> accept an ID or a name.

Commands:
  stats                                   key figures of the tenant
  landscape                               topology tree  (DEV → QA → PROD)
  config                                  effective service configuration
  metadata                                OData $metadata (CSDL) of the service
  demo                                    create a sample DEV → QA → PROD landscape

  nodes list | get <node> | enable <node> | disable <node> | delete <node> | check <node>
  nodes create --name=NAME [--type=cloudFoundry|abap|neo|kyma|other] [--description=..]
               [--region=..] [--environment=..] [--subaccount=..] [--space=..]
               [--no-forward] [--auto-import]
  nodes update <node> [--name=..] [--type=..] [--description=..] [--region=..]
               [--forward=on|off] [--auto-import=on|off]

  routes list | get <id> | enable <id> | disable <id> | delete <id>
  routes create --name=NAME --from=<node> --to=<node> [--sequence=N] [--description=..] [--disabled]
  routes update <id> [--name=..] [--description=..] [--sequence=N]

  requests list [--status=..] | get <request> | delete <request>
  requests create --name=NAME [--source=<node>] [--content-type=mtaArchive] [--version=..]
                  [--url=ARCHIVE_URL] [--checksum=..] [--description=..] [--export]
  requests update <request> [--name=..] [--version=..] [--url=..] [--description=..]
  requests status <request> <initial|running|success|failed|warning|outdated|repeating>
  requests export <request> [--node=<node>]
  requests forward <request> --from=<node>

  queue list [--node=<node>] | reset <entry> | select <entry> | deselect <entry> | delete <entry>
  queue add --node=<node> --request=<request> [--position=N]
  queue import <node> [--entries=id1,id2]     import all selected entries (or the given ones)

  actions list [--node=<node>] [--request=<request>] [--limit=N] | get <id>
  actions record --type=export|import|forward|reset|delete|schedule --request=<request>
                 [--node=<node>] [--status=success] [--description=..]
  help
`;

/// The command line adapter.
class TransportCli {
  protected TransportPorts ports;
  protected TransportConfig config;
  protected void delegate(string) @safe output;
  protected TenantId tenant;
  protected string user;
  protected bool json;

  this(TransportPorts ports, TransportConfig config, void delegate(string) @safe output) {
    this.ports = ports;
    this.config = config;
    this.output = output;
  }

  /// Run one command. Returns the process exit code (0 ok, 1 failure, 2 usage).
  int run(const string[] argv) {
    auto a = CliArgs.parse(argv);
    tenant = TenantId(a.opt("tenant", config.defaultTenant));
    user = a.opt("user", "cli");
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
      case "landscape":
        auto l = ports.landscape.landscape(tenant);
        return emit(Json(l.render), l.nodes.length ? l.render : "(no transport nodes)\n");
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      case "metadata":
        output(buildMetadataXml(transportODataModel()));
        return 0;
      case "demo":
        return demo();
      case "nodes":
        return nodes(a);
      case "routes":
        return routes(a);
      case "requests":
        return requests(a);
      case "queue":
        return queue(a);
      case "actions":
        return actions(a);
      default:
        throw new CliUsageError("unknown command '" ~ a.arg(0) ~ "'");
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-transport-cli help' for usage.\n");
      return 2;
    } catch (TransportException e) {
      output("error: " ~ e.msg ~ "\n");
      return e.code == 400 ? 2 : 1;
    } catch (Exception e) {
      output("error: " ~ e.msg ~ "\n");
      return 1;
    }
  }

  // ── output helpers ─────────────────────────────────────────────────────

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
      output("failed: " ~ r.message ~ "\n");
    return r.isSuccess ? 0 : 1;
  }

  protected NameLookup names() {
    return NameLookup.of(ports, tenant);
  }

  protected static bool onOff(const CliArgs a, string key, bool current) {
    if (!a.has(key))
      return current;
    auto v = a.opt(key).toLower;
    return v == "on" || v == "true" || v == "yes" || v == "1";
  }

  // ── resolution of <node> / <request> ───────────────────────────────────

  protected TransportNode node(string idOrName) {
    auto n = ports.nodes.findNode(tenant, idOrName);
    if (n.isNull)
      throw new TransportException(404, "transport node '" ~ idOrName ~ "' not found in tenant '" ~ tenant.value ~ "'");
    return n;
  }

  protected TransportRequest request(string idOrName) {
    auto r = ports.requests.getRequest(tenant, TransportRequestId(idOrName));
    if (!r.isNull)
      return r;
    auto matches = ports.requests.listRequests(tenant).filter!(x => x.name == idOrName).array;
    if (matches.length == 0)
      throw new TransportException(404, "transport request '" ~ idOrName ~ "' not found in tenant '" ~ tenant.value ~ "'");
    return matches[0]; // newest first
  }

  // ── commands ───────────────────────────────────────────────────────────

  protected int nodes(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "": {
      auto items = ports.nodes.listNodes(tenant);
      return emitTable(items, nodeTable(items));
    }
    case "get": {
      return emitOne(node(a.requireArg(2, "node")));
    }
    case "create": {
      CreateNodeInput c;
      c.tenantId = tenant;
      c.name = a.requireOpt("name");
      c.nodeType = a.opt("type");
      c.description = a.opt("description");
      c.region = a.opt("region");
      c.environment = a.opt("environment");
      c.globalAccount = a.opt("global-account");
      c.subaccountId = a.opt("subaccount");
      c.spaceId = a.opt("space");
      c.serviceKey = a.opt("service-key");
      c.isForwardEnabled = !a.flag("no-forward");
      c.autoImport = a.flag("auto-import");
      c.createdBy = UserId(user);
      return emitResult(ports.nodes.createNode(c));
    }
    case "update": {
      auto u = UpdateNodeInput.from(node(a.requireArg(2, "node")));
      u.name = a.opt("name", u.name);
      u.nodeType = a.opt("type", u.nodeType);
      u.description = a.opt("description", u.description);
      u.region = a.opt("region", u.region);
      u.environment = a.opt("environment", u.environment);
      u.subaccountId = a.opt("subaccount", u.subaccountId);
      u.spaceId = a.opt("space", u.spaceId);
      u.serviceKey = a.opt("service-key");
      u.isForwardEnabled = onOff(a, "forward", u.isForwardEnabled);
      u.autoImport = onOff(a, "auto-import", u.autoImport);
      u.updatedBy = UserId(user);
      return emitResult(ports.nodes.updateNode(u));
    }
    case "enable": {
      return emitResult(ports.nodes.enableNode(tenant, node(a.requireArg(2, "node")).id));
    }
    case "disable": {
      return emitResult(ports.nodes.disableNode(tenant, node(a.requireArg(2, "node")).id));
    }
    case "delete": {
      return emitResult(ports.nodes.deleteNode(tenant, node(a.requireArg(2, "node")).id));
    }
    case "check": {
      return emitResult(ports.operations.checkConnection(tenant, node(a.requireArg(2, "node")).id));
    }
    default: {
      throw new CliUsageError("unknown 'nodes' subcommand '" ~ a.arg(1) ~ "'");
    }
    }
  }

  protected int routes(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "": {
      auto items = ports.routes.listRoutes(tenant);
      return emitTable(items, routeTable(items, names));
    }
    case "get": {
      auto r = ports.routes.getRoute(tenant, TransportRouteId(a.requireArg(2, "route id")));
      if (r.isNull)
        throw new TransportException(404, "transport route '" ~ a.arg(2) ~ "' not found");
      return emitOne(r);
    }
    case "create": {
      CreateRouteInput c;
      c.tenantId = tenant;
      c.name = a.requireOpt("name");
      c.sourceNodeId = node(a.requireOpt("from")).id.value;
      c.destinationNodeId = node(a.requireOpt("to")).id.value;
      c.sequence = a.intOpt("sequence", 0);
      c.description = a.opt("description");
      c.status = a.flag("disabled") ? "disabled" : "enabled";
      c.createdBy = UserId(user);
      return emitResult(ports.routes.createRoute(c));
    }
    case "update": {
      auto id = TransportRouteId(a.requireArg(2, "route id"));
      auto current = ports.routes.getRoute(tenant, id);
      if (current.isNull)
        throw new TransportException(404, "transport route '" ~ id.value ~ "' not found");
      auto u = UpdateRouteInput.from(current);
      u.name = a.opt("name", u.name);
      u.description = a.opt("description", u.description);
      u.sequence = a.intOpt("sequence", u.sequence);
      u.updatedBy = UserId(user);
      return emitResult(ports.routes.updateRoute(u));
    }
    case "enable": {
      return emitResult(ports.routes.enableRoute(tenant, TransportRouteId(a.requireArg(2, "route id"))));
    }
    case "disable": {
      return emitResult(ports.routes.disableRoute(tenant, TransportRouteId(a.requireArg(2, "route id"))));
    }
    case "delete": {
      return emitResult(ports.routes.deleteRoute(tenant, TransportRouteId(a.requireArg(2, "route id"))));
    }
    default: {
      throw new CliUsageError("unknown 'routes' subcommand '" ~ a.arg(1) ~ "'");
    }
    }
  }

  protected int requests(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "": {
      auto items = a.has("status")
        ? ports.requests.listRequestsByStatus(tenant, requireEnum!RequestStatus(a.opt("status"), "status"))
        : ports.requests.listRequests(tenant);
      return emitTable(items, requestTable(items, names));
    }
    case "get": {
      return emitOne(request(a.requireArg(2, "request")));
    }
    case "create": {
      CreateRequestInput c;
      c.tenantId = tenant;
      c.name = a.requireOpt("name");
      c.contentType = a.opt("content-type");
      c.version_ = a.opt("version");
      c.storageUrl = a.opt("url");
      c.checksum = a.opt("checksum");
      c.description = a.opt("description");
      c.externalId = a.opt("external-id");
      c.systemId = a.opt("system");
      if (a.has("source"))
        c.sourceNodeId = node(a.opt("source")).id.value;
      c.createdBy = UserId(user);
      auto created = ports.requests.createRequest(c);
      if (!created.isSuccess || !a.flag("export"))
        return emitResult(created);
      emitResult(created);
      return emitResult(ports.operations.exportRequest(ExportInput(tenant, TransportRequestId(created.id),
          TransportNodeId.init, user)));
    }
    case "update": {
      auto u = UpdateRequestInput.from(request(a.requireArg(2, "request")));
      u.name = a.opt("name", u.name);
      u.version_ = a.opt("version", u.version_);
      u.storageUrl = a.opt("url", u.storageUrl);
      u.checksum = a.opt("checksum", u.checksum);
      u.description = a.opt("description", u.description);
      u.contentType = a.opt("content-type", u.contentType);
      u.updatedBy = UserId(user);
      return emitResult(ports.requests.updateRequest(u));
    }
    case "status": {
      auto r = request(a.requireArg(2, "request"));
      return emitResult(ports.requests.updateRequestStatus(tenant, r.id,
          requireEnum!RequestStatus(a.requireArg(3, "status"), "status")));
    }
    case "delete": {
      return emitResult(ports.requests.deleteRequest(tenant, request(a.requireArg(2, "request")).id, user));
    }
    case "export": {
      auto r = request(a.requireArg(2, "request"));
      ExportInput ex;
      ex.tenantId = tenant;
      ex.requestId = r.id;
      if (a.has("node"))
        ex.nodeId = node(a.opt("node")).id;
      ex.performedBy = user;
      return emitResult(ports.operations.exportRequest(ex));
    }
    case "forward": {
      ForwardInput fw;
      fw.tenantId = tenant;
      fw.requestId = request(a.requireArg(2, "request")).id;
      fw.fromNodeId = node(a.requireOpt("from")).id;
      fw.performedBy = user;
      return emitResult(ports.operations.forwardRequest(fw));
    }
    default: {
      throw new CliUsageError("unknown 'requests' subcommand '" ~ a.arg(1) ~ "'");
    }
    }
  }

  protected int queue(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "": {
      auto items = a.has("node")
        ? ports.queue.listEntriesByNode(tenant, node(a.opt("node")).id) : ports.queue.listEntries(tenant);
      return emitTable(items, queueTable(items, names));
    }
    case "add": {
      EnqueueInput e;
      e.tenantId = tenant;
      e.nodeId = node(a.requireOpt("node")).id.value;
      e.requestId = request(a.requireOpt("request")).id.value;
      e.queuePosition = a.intOpt("position", 0);
      e.createdBy = UserId(user);
      return emitResult(ports.queue.enqueue(e));
    }
    case "import": {
      ImportInput im;
      im.tenantId = tenant;
      im.nodeId = node(a.requireArg(2, "node")).id;
      foreach (id; a.listOpt("entries"))
        im.entryIds ~= ImportQueueEntryId(id);
      im.performedBy = user;
      auto r = ports.operations.importNode(im);
      auto code = emitResult(r);
      if (!json && r.isSuccess && r.data.type == Json.Type.object)
        foreach (id; fieldStrings(r.data, "entryIds")) {
          auto entry = ports.queue.getEntry(tenant, ImportQueueEntryId(id));
          output("  %-8s %s%s\n".format(enumName(entry.status), names.request(entry.requestId),
              entry.errorMessage.length ? " — " ~ entry.errorMessage : ""));
        }
      return code == 0 && r.isSuccess && fieldLong(r.data, "failed") > 0 ? 1 : code;
    }
    case "reset": {
      return emitResult(ports.queue.resetEntry(tenant, ImportQueueEntryId(a.requireArg(2, "entry id")), user));
    }
    case "select": {
      return emitResult(ports.queue.selectEntry(tenant, ImportQueueEntryId(a.requireArg(2, "entry id")), true));
    }
    case "deselect": {
      return emitResult(ports.queue.selectEntry(tenant, ImportQueueEntryId(a.requireArg(2, "entry id")), false));
    }
    case "delete": {
      return emitResult(ports.queue.deleteEntry(tenant, ImportQueueEntryId(a.requireArg(2, "entry id")), user));
    }
    default: {
      throw new CliUsageError("unknown 'queue' subcommand '" ~ a.arg(1) ~ "'");
    }
    }
  }

  protected int actions(const CliArgs a) {
    switch (a.arg(1)) {
    case "list", "": {
      TransportAction[] items;
      if (a.has("node"))
        items = ports.actions.listActionsByNode(tenant, node(a.opt("node")).id);
      else if (a.has("request"))
        items = ports.actions.listActionsByRequest(tenant, request(a.opt("request")).id);
      else
        items = ports.actions.listActions(tenant);
      auto limit = a.intOpt("limit", 50);
      if (limit > 0 && items.length > limit)
        items = items[0 .. limit];
      return emitTable(items, actionTable(items, names));
    }
    case "get": {
      auto x = ports.actions.getAction(tenant, TransportActionId(a.requireArg(2, "action id")));
      if (x.isNull)
        throw new TransportException(404, "transport action '" ~ a.arg(2) ~ "' not found");
      return emitOne(x);
    }
    case "record": {
      RecordActionInput r;
      r.tenantId = tenant;
      r.actionType = a.requireOpt("type");
      r.actionStatus = a.opt("status", "success");
      r.requestId = request(a.requireOpt("request")).id.value;
      if (a.has("node"))
        r.nodeId = node(a.opt("node")).id.value;
      r.performedBy = user;
      r.description = a.opt("description");
      return emitResult(ports.actions.recordAction(r));
    }
    default: {
      throw new CliUsageError("unknown 'actions' subcommand '" ~ a.arg(1) ~ "'");
    }
    }
  }

  /// Seed a sample landscape: DEV → QA → PROD with one exported request.
  protected int demo() {
    string[string] ids;
    foreach (spec; [["DEV", "cloudFoundry", "Development space"], ["QA", "cloudFoundry", "Quality assurance space"],
        ["PROD", "cloudFoundry", "Production space"]]) {
      auto existing = ports.nodes.findNode(tenant, spec[0]);
      if (!existing.isNull) {
        ids[spec[0]] = existing.id.value;
        continue;
      }
      CreateNodeInput c;
      c.tenantId = tenant;
      c.name = spec[0];
      c.nodeType = spec[1];
      c.description = spec[2];
      c.region = "eu10";
      c.isForwardEnabled = spec[0] != "PROD";
      c.createdBy = UserId(user);
      auto r = ports.nodes.createNode(c);
      if (!r.isSuccess)
        return emitResult(r);
      ids[spec[0]] = r.id;
    }
    foreach (spec; [["DEV-QA", "DEV", "QA"], ["QA-PROD", "QA", "PROD"]]) {
      CreateRouteInput c;
      c.tenantId = tenant;
      c.name = spec[0];
      c.sourceNodeId = ids[spec[1]];
      c.destinationNodeId = ids[spec[2]];
      c.createdBy = UserId(user);
      ports.routes.createRoute(c); // ignore "already exists"
    }
    CreateRequestInput rq;
    rq.tenantId = tenant;
    rq.name = "sample-app";
    rq.version_ = "1.0.0";
    rq.description = "Sample MTA";
    rq.storageUrl = "https://repository.example.com/sample-app-1.0.0.mtar";
    rq.sourceNodeId = ids["DEV"];
    rq.createdBy = UserId(user);
    auto created = ports.requests.createRequest(rq);
    if (created.isSuccess)
      ports.operations.exportRequest(ExportInput(tenant, TransportRequestId(created.id), TransportNodeId.init, user));
    auto l = ports.landscape.landscape(tenant);
    output(json ? Json(l.render).toString ~ "\n" : "Demo landscape for tenant '" ~ tenant.value ~ "':\n" ~ l.render
        ~ "Try: uim-transport-cli queue import QA\n");
    return 0;
  }
}

///
unittest {
  mixin(ShowTest!("TransportCli"));

  TransportConfig cfg;
  cfg.storage = "memory";
  auto container = buildContainer(cfg);
  string captured;
  auto cli = new TransportCli(container.ports, cfg, (string s) { captured ~= s; });

  assert(cli.run(["demo"]) == 0);
  assert(captured.canFind("QA-PROD"));
  captured = null;
  assert(cli.run(["nodes", "list", "--json"]) == 0);
  assert(parseJsonString(captured).length == 3);

  assert(cli.run(["queue", "import", "QA"]) == 0);
  captured = null;
  assert(cli.run(["queue", "list", "--node=PROD", "--json"]) == 0);
  assert(parseJsonString(captured).length == 1); // forwarded

  assert(cli.run(["requests", "create", "--name=broken", "--source=DEV", "--url=fail://x", "--export"]) == 0);
  assert(cli.run(["queue", "import", "QA"]) == 1); // contains a failed import
  assert(cli.run(["routes", "create", "--name=back", "--from=PROD", "--to=DEV"]) == 1); // cycle

  captured = null;
  assert(cli.run(["stats", "--json"]) == 0);
  assert(parseJsonString(captured)["nodes"].get!long == 3);

  assert(cli.run(["nonsense"]) == 2);
  assert(cli.run(["nodes", "get", "missing"]) == 1);
  assert(cli.run(["requests", "list", "--status=bogus"]) == 2);
}
