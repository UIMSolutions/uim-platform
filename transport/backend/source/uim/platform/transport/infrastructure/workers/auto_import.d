/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.workers.auto_import;

import core.time : minutes;
import vibe.core.core : Timer, setTimer;
import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Background task: imports the queues of all enabled nodes with autoImport = true.
/// Runs inside the vibe.d event loop of the HTTP server.
class AutoImportWorker {
  protected TransportPorts ports;
  protected string[] tenants;
  protected Timer timer;

  this(TransportPorts ports, string[] tenants) {
    this.ports = ports;
    this.tenants = tenants;
  }

  /// Start the periodic run. Does nothing if intervalMinutes <= 0.
  void start(int intervalMinutes) {
    if (intervalMinutes <= 0 || tenants.length == 0)
      return;
    timer = setTimer(intervalMinutes.minutes, () nothrow @safe {
      try
        runOnce();
      catch (Exception e)
        logError("transport: auto-import run failed: %s", e.msg);
    }, true);
    logInfo("transport: auto-import worker every %d min for %s", intervalMinutes, tenants);
  }

  /// Import all auto-import nodes once. Returns the number of import runs.
  size_t runOnce() {
    size_t runs;
    foreach (t; tenants) {
      auto tenant = TenantId(t);
      foreach (node; ports.nodes.listNodes(tenant)) {
        if (!node.autoImport || !node.isEnabled)
          continue;
        ImportInput input;
        input.tenantId = tenant;
        input.nodeId = node.id;
        input.performedBy = "auto-import";
        auto result = ports.operations.importNode(input);
        logInfo("transport: auto-import %s/%s: %s", t, node.name, result.message);
        runs++;
      }
    }
    return runs;
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
