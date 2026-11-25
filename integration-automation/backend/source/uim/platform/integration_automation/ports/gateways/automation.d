/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports to the outside world:
///   IAutomationGateway   executes automated and notification tasks
///   IConnectivityProbe   tests whether a system of the landscape is reachable
module uim.platform.integration_automation.ports.gateways.automation;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// What an automated call needs (resolved by the use case).
struct AutomationRequest {
  TenantId tenantId;
  WorkflowTask task;
  Destination destination; /// isNull if the endpoint is absolute
  string url; /// effective URL (destination URL + endpoint, or the endpoint)
}

struct AutomationResult {
  bool success;
  bool timedOut;
  string message; /// short, shown as task result / error
  string details; /// e.g. HTTP status and a response excerpt
  long durationMs;
}

interface IAutomationGateway {
  /// "simulate" | "http"
  string mode();
  /// Execute an automated task. Never throws: failures are results.
  AutomationResult execute(AutomationRequest request);
  /// Deliver a notification task to its role / assignee. Never throws.
  AutomationResult notify(TenantId t, const WorkflowTask task);
}

struct ProbeResult {
  bool reachable;
  string message;
  long durationMs;
}

interface IConnectivityProbe {
  /// "simulate" | "tcp"
  string mode();
  /// Never throws: failures are results.
  ProbeResult probe(string host, int port, string protocol);
}
