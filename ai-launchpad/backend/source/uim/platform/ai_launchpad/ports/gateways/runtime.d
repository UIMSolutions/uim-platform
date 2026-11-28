/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port to the AI runtimes behind the connections (AI API of SAP AI
/// Core or compatible): validate a connection, poll the state of executions
/// and deployments, complete prompts. The adapter in infrastructure/clients
/// simulates a runtime deterministically.
module uim.platform.ai_launchpad.ports.gateways.runtime;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct RuntimeCheck {
  bool ok;
  string message;
}

/// State reported by the runtime. status: the name of an ExecutionStatus /
/// DeploymentStatus value; url: inference URL of a running deployment.
struct RuntimeState {
  string status;
  string message;
  string url;
}

struct PromptCompletion {
  string output;
  int promptTokens;
  int completionTokens;
  long latencyMs;
}

interface IAiRuntime {
  /// "simulate" (deterministic simulation) or the name of the real adapter.
  string mode();
  RuntimeCheck validateConnection(const Connection c);
  RuntimeState pollExecution(const Connection c, const Configuration cfg, const Execution e, long now);
  RuntimeState pollDeployment(const Connection c, const Configuration cfg, const Deployment d, long now);
  PromptCompletion complete(const Prompt p, string systemMessage, string userMessage);
}
