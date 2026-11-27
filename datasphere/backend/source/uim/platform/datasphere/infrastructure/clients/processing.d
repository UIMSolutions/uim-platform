/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Simulated processing engine (processingMode "simulate"): deterministic
/// results, so demos, tests and the UI behave reproducibly.
///
///   * hosts ending in ".invalid" or containing "unreachable" are not reachable
///   * connections of types with an endpoint need user and password
///   * a remote object yields 1 000 – 250 000 rows (derived from its name);
///     a remote object containing "MISSING" does not exist
///   * every "filter" transformation keeps 40 % of the rows, an
///     "aggregation" 5 %; views keep all rows of their sources
///   * the duration grows with the rows (≈ 1 ms per 500 rows, at least 40 ms)
///   * failurePercent > 0 fails that share of the runs (chaos testing)
module uim.platform.datasphere.infrastructure.clients.processing;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class SimulatedProcessingEngine : IProcessingEngine {
  protected uint failurePercent;
  protected ulong counter;

  this(uint failurePercent = 0) {
    this.failurePercent = failurePercent;
  }

  string mode() {
    return "simulate";
  }

  ProcessingResult checkConnection(const Connection c) {
    if (c.host.endsWith(".invalid") || c.host.canFind("unreachable"))
      return ProcessingResult(false, 0, 3000, "host '" ~ c.host ~ "' is not reachable (connect timed out)");
    if (c.connectionType.needsEndpoint && !c.hasCredentials)
      return ProcessingResult(false, 0, 120, "authentication failed: user and password are required");
    return ProcessingResult(true, 0, 180, "connected to " ~ c.endpoint ~ " as " ~ (c.user.length ? c.user : "anonymous"));
  }

  ProcessingResult replicate(const Connection c, const RemoteTable table) {
    ProcessingResult chaos;
    if (randomFailure(chaos))
      return chaos;
    auto check = checkConnection(c);
    if (!check.ok)
      return check;
    if (table.remoteObject.toUpper.canFind("MISSING"))
      return ProcessingResult(false, 0, 90, "remote object '" ~ table.remotePath ~ "' does not exist");
    auto rows = 1_000 + cast(long)(stableHash(c.id.value ~ "/" ~ table.remotePath) % 249_001);
    return ProcessingResult(true, rows, durationFor(rows), format("%d rows replicated from %s", rows, table.remotePath));
  }

  ProcessingResult runDataFlow(const DataFlow flow, long sourceRows) {
    ProcessingResult chaos;
    if (randomFailure(chaos))
      return chaos;
    double share = 1;
    foreach (t; flow.transforms) {
      auto kind = t.split(":")[0].strip.toLower;
      if (kind == "filter")
        share *= 0.4;
      else if (kind == "aggregation")
        share *= 0.05;
    }
    auto rows = cast(long)(sourceRows * share);
    return ProcessingResult(true, rows, durationFor(sourceRows), format("%d of %d rows loaded into %s", rows, sourceRows,
        flow.targetTable));
  }

  ProcessingResult persistView(const DataView view, long sourceRows) {
    ProcessingResult chaos;
    if (randomFailure(chaos))
      return chaos;
    return ProcessingResult(true, sourceRows, durationFor(sourceRows), format("%d rows persisted", sourceRows));
  }

  protected static long durationFor(long rows) {
    return max(40, rows / 500);
  }

  /// FNV-1a (stable across runs and platforms).
  protected static ulong stableHash(string s) {
    ulong h = 1_469_598_103_934_665_603UL;
    foreach (c; s) {
      h ^= c;
      h *= 1_099_511_628_211UL;
    }
    return h;
  }

  /// Every n-th run fails when failurePercent is set (deterministic sequence).
  protected bool randomFailure(out ProcessingResult failure) {
    if (failurePercent == 0)
      return false;
    counter++;
    if ((stableHash(counter.to!string) % 100) >= failurePercent)
      return false;
    failure = ProcessingResult(false, 0, 500, "simulated failure of the processing engine (out of memory)");
    return true;
  }
}

///
unittest {
  auto e = new SimulatedProcessingEngine;
  Connection c;
  c.id = ConnectionId("S4");
  c.connectionType = ConnectionType.s4hana;
  c.host = "my-s4.example.com";
  c.port = 443;
  assert(!e.checkConnection(c).ok, "no credentials");
  c.user = "u";
  c.password = "p";
  assert(e.checkConnection(c).ok);
  RemoteTable t;
  t.remoteObject = "I_SALESORDER";
  auto r = e.replicate(c, t);
  assert(r.ok && r.rows >= 1000 && r.rows <= 250_000 && r.rows == e.replicate(c, t).rows);
  t.remoteObject = "MISSING_TABLE";
  assert(!e.replicate(c, t).ok);
  c.host = "db.unreachable.invalid";
  assert(!e.checkConnection(c).ok);
  DataFlow f;
  f.transforms = ["filter: A = 1", "projection: A"];
  assert(e.runDataFlow(f, 1000).rows == 400);
  auto chaos = new SimulatedProcessingEngine(100);
  assert(!chaos.persistView(DataView.init, 10).ok);
}
