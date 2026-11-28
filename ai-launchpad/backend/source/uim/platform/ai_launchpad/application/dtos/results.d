/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Results of the reconciliation, the playground, the launchpad, the log
/// purge and the demo content.
module uim.platform.ai_launchpad.application.dtos.results;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// Outcome of a reconciliation of the active executions and deployments.
struct ReconcileSummary {
  long checked;
  long started; /// executions pending → running
  long completed;
  long failed;
  long deployed; /// deployments pending → running
  long dead;
  long expired; /// deployments stopped at the end of their TTL
  string[] messages;

  long changes() const {
    return started + completed + failed + deployed + dead + expired;
  }

  string summary() const {
    return format("%d checked: %d started, %d completed, %d failed, %d deployed, %d dead, %d expired", checked, started,
      completed, failed, deployed, dead, expired);
  }
}

struct PromptRunResult {
  string promptId;
  int promptVersion;
  string modelName;
  string renderedPrompt;
  string output;
  int promptTokens;
  int completionTokens;
  long latencyMs;
}

/// A tile as shown on the launchpad, with its current KPI value.
struct LaunchpadTile {
  Tile tile;
  bool hasKpi;
  long kpiValue;
}

struct PurgeResult {
  long entries;
}

struct SeedResult {
  long workspaces;
  long connections;
  long resourceGroups;
  long scenarios;
  long configurations;
  long executions;
  long deployments;
  long models;
  long datasets;
  long promptCollections;
  long prompts;
}

///
unittest {
  ReconcileSummary s;
  s.checked = 3;
  s.started = 1;
  s.expired = 1;
  assert(s.changes == 2 && s.summary.startsWith("3 checked: 1 started"));
}
