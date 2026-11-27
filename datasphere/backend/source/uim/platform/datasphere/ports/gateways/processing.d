/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port of the processing engine that does the actual data work:
/// connection checks, remote table snapshots, data flow runs and view
/// persistence. The service ships a deterministic simulation
/// (infrastructure/clients/processing); a HANA Cloud adapter would
/// implement the same interface.
module uim.platform.datasphere.ports.gateways.processing;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct ProcessingResult {
  bool ok;
  long rows; /// rows read / written
  long durationMs;
  string message;
}

interface IProcessingEngine {
  /// "simulate", "hana", …
  string mode();
  /// Reach the source system and check the credentials.
  ProcessingResult checkConnection(const Connection c);
  /// Copy the remote object into the space.
  ProcessingResult replicate(const Connection c, const RemoteTable table);
  /// Run the transformations over sourceRows rows and load the target.
  ProcessingResult runDataFlow(const DataFlow flow, long sourceRows);
  /// Materialise the view over sourceRows rows of its sources.
  ProcessingResult persistView(const DataView view, long sourceRows);
}
