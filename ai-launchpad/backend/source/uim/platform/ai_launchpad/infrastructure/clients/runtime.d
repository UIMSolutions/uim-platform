/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Adapter of the AI runtime gateway: a deterministic simulation of an AI
/// API runtime (SAP AI Core), so that the launchpad works without a real
/// tenant.
///
///   validate   https URL, auth URL, client id and secret are required; hosts
///              containing "unreachable" or "invalid" fail
///   execution  pending → running at the first poll; completed after
///              simulatedExecutionSeconds; failed if the configuration has
///              the parameter "simulate.outcome=failed" or by chance
///              (simulatedFailurePercent, derived from the id)
///   deployment running after simulatedDeploymentSeconds with the URL
///              <connection url>/inference/deployments/<id>; dead with
///              "simulate.outcome=dead"
///   prompts    a deterministic answer naming the model and the request
module uim.platform.ai_launchpad.infrastructure.clients.runtime;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class SimulatedAiRuntime : IAiRuntime {
  uint executionSeconds;
  uint deploymentSeconds;
  uint failurePercent;

  this(uint executionSeconds = 60, uint deploymentSeconds = 5, uint failurePercent = 0) {
    this.executionSeconds = executionSeconds;
    this.deploymentSeconds = deploymentSeconds;
    this.failurePercent = failurePercent;
  }

  string mode() {
    return "simulate";
  }

  RuntimeCheck validateConnection(const Connection c) {
    string[] missing;
    if (!c.url.startsWith("https://"))
      missing ~= "an https service URL";
    if (c.authUrl.length == 0)
      missing ~= "an auth URL";
    if (c.clientId.length == 0)
      missing ~= "a client ID";
    if (!c.hasSecret)
      missing ~= "a client secret";
    if (missing.length)
      return RuntimeCheck(false, "Not valid: the connection needs " ~ missing.join(", "));
    auto host = hostOf(c.url);
    if (host.canFind("unreachable") || host.canFind("invalid"))
      return RuntimeCheck(false, "Host '" ~ host ~ "' is not reachable (simulated)");
    return RuntimeCheck(true, "Connected to the AI API at " ~ host ~ " (simulated, " ~ cast(string) c.connectionType ~ ")");
  }

  RuntimeState pollExecution(const Connection c, const Configuration cfg, const Execution e, long now) {
    if (e.status == ExecutionStatus.pending)
      return RuntimeState("running", "Running");
    if (e.status != ExecutionStatus.running || now < plusSeconds(e.startedAt, executionSeconds))
      return RuntimeState(cast(string) e.status, e.statusMessage);
    if (outcome(cfg) == "failed" || chance(e.id.value))
      return RuntimeState("failed", "Training failed: the loss did not converge (simulated)");
    return RuntimeState("completed", format("Training completed after %d s (simulated)", secondsBetween(e.startedAt, now)));
  }

  RuntimeState pollDeployment(const Connection c, const Configuration cfg, const Deployment d, long now) {
    if (d.status != DeploymentStatus.pending)
      return RuntimeState(cast(string) d.status, d.statusMessage, d.deploymentUrl);
    if (outcome(cfg) == "dead" || chance(d.id.value))
      return RuntimeState("dead", "The serving container did not start (simulated)");
    if (now < plusSeconds(d.updatedAt, deploymentSeconds))
      return RuntimeState("pending", "Starting");
    return RuntimeState("running", "Serving", c.url ~ "/inference/deployments/" ~ d.id.value);
  }

  PromptCompletion complete(const Prompt p, string systemMessage, string userMessage) {
    auto words = userMessage.split.length;
    auto head = userMessage.strip.replace("\n", " ");
    if (head.length > 160)
      head = head[0 .. 160] ~ " …";
    PromptCompletion c;
    c.output = format("[%s %s, temperature %.1f] Simulated answer to a request of %d words: \"%s\"", p.modelName,
      p.modelVersion, p.temperature, words, head);
    c.promptTokens = cast(int)((systemMessage.split.length + words) * 4 / 3 + 1);
    c.completionTokens = cast(int) min(p.maxTokens, c.output.split.length * 4 / 3 + 1);
    c.latencyMs = 120 + (c.promptTokens + c.completionTokens) * 3;
    return c;
  }

  protected static string outcome(const Configuration cfg) {
    foreach (p; cfg.parameters)
      if (labelKey(p) == "simulate.outcome")
        return labelValue(p);
    return "";
  }

  /// Deterministic chance per id (stable across polls and restarts).
  protected bool chance(string id) {
    if (failurePercent == 0)
      return false;
    uint h = 2_166_136_261;
    foreach (c; id) {
      h ^= c;
      h *= 16_777_619;
    }
    return h % 100 < failurePercent;
  }

  protected static string hostOf(string url) {
    auto rest = url.findSplitAfter("://")[1];
    auto slash = rest.indexOf('/');
    return slash >= 0 ? rest[0 .. slash] : rest;
  }
}

///
unittest {
  auto r = new SimulatedAiRuntime(60, 0, 0);
  Connection c;
  c.url = "https://api.ai.example.com/v2";
  assert(!r.validateConnection(c).ok);
  c.authUrl = "https://auth.example.com/oauth/token";
  c.clientId = "id";
  c.clientSecret = "s";
  assert(r.validateConnection(c).ok, r.validateConnection(c).message);
  c.url = "https://api.unreachable.example.com";
  assert(!r.validateConnection(c).ok);

  Configuration cfg;
  Execution e;
  e.id = ExecutionId("e");
  assert(r.pollExecution(c, cfg, e, 0).status == "running");
  e.status = ExecutionStatus.running;
  e.startedAt = parseIsoTime("2026-11-27T10:00:00Z");
  assert(r.pollExecution(c, cfg, e, plusSeconds(e.startedAt, 59)).status == "running");
  assert(r.pollExecution(c, cfg, e, plusSeconds(e.startedAt, 60)).status == "completed");
  cfg.parameters = ["simulate.outcome=failed"];
  assert(r.pollExecution(c, cfg, e, plusSeconds(e.startedAt, 60)).status == "failed");

  Deployment d;
  d.id = DeploymentId("d");
  auto s = r.pollDeployment(c, Configuration.init, d, 1);
  assert(s.status == "running" && s.url.endsWith("/inference/deployments/d"));

  Prompt p;
  p.modelName = "gpt-4o-mini";
  auto out_ = r.complete(p, "", "Hello there");
  assert(out_.output.canFind("gpt-4o-mini") && out_.promptTokens > 0);
}
