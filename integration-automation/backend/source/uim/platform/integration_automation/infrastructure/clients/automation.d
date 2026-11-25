/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Adapters of the IAutomationGateway port.
///
///   simulate  (default) no network: automated tasks succeed unless their
///             payload asks for {"simulate":"failure"} or {"simulate":"timeout"};
///             notifications are recorded only
///   http      automated tasks call their URL (destination URL + endpoint):
///             POST with the payload (GET without one), 2xx = success.
///             Credentials never live in this service: the Authorization
///             header of a destination comes from the environment variable
///             IA_DESTINATION_<NAME>_AUTHORIZATION (name upper case, other
///             characters "_"). Notifications are posted to the optional
///             notification webhook as JSON.
module uim.platform.integration_automation.infrastructure.clients.automation;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class SimulatedAutomationGateway : IAutomationGateway {
  string mode() {
    return "simulate";
  }

  AutomationResult execute(AutomationRequest r) {
    AutomationResult result;
    auto payload = r.task.automationPayload.replace(" ", "");
    auto method = r.task.automationPayload.strip.length ? "POST" : "GET";
    if (payload.canFind(`"simulate":"timeout"`)) {
      result.timedOut = true;
      result.message = "Simulated timeout calling " ~ r.url;
      result.details = "simulate=timeout";
      return result;
    }
    if (payload.canFind(`"simulate":"failure"`)) {
      result.message = "Simulated failure: HTTP 500 from " ~ method ~ " " ~ r.url;
      result.details = "simulate=failure; status=500";
      return result;
    }
    if (!r.destination.isNull && !r.destination.enabled) {
      result.message = "Destination '" ~ r.destination.name ~ "' is disabled";
      return result;
    }
    result.success = true;
    result.message = "Simulated " ~ method ~ " " ~ r.url ~ " — HTTP 200";
    result.details = "simulate=success; status=200";
    return result;
  }

  AutomationResult notify(TenantId t, const WorkflowTask task) {
    AutomationResult result;
    result.success = true;
    result.message = "Notification recorded for " ~ recipientsOf(task);
    return result;
  }
}

class HttpAutomationGateway : IAutomationGateway {
  protected Duration timeout;
  protected string webhookUrl;
  protected size_t maxResponseBytes = 16 * 1024;

  this(uint timeoutSeconds, string webhookUrl = "") {
    this.timeout = dur!"seconds"(timeoutSeconds > 0 ? timeoutSeconds : 30);
    this.webhookUrl = webhookUrl.strip;
  }

  string mode() {
    return "http";
  }

  AutomationResult execute(AutomationRequest r) {
    if (!isHttpUrl(r.url)) {
      AutomationResult result;
      result.message = "No http(s) URL for the automated task (endpoint '" ~ r.task.automationEndpoint ~ "')";
      return result;
    }
    if (!r.destination.isNull && !r.destination.enabled) {
      AutomationResult result;
      result.message = "Destination '" ~ r.destination.name ~ "' is disabled";
      return result;
    }
    string[string] headers;
    headers["X-Correlation-Id"] = r.task.id.value;
    headers["X-Workflow-Id"] = r.task.workflowId.value;
    if (!r.destination.isNull) {
      auto auth = destinationAuthorization(r.destination.name);
      if (auth.length)
        headers["Authorization"] = auth;
      else if (r.destination.authentication != AuthenticationType.noAuthentication)
        headers["X-Credentials-Missing"] = cast(string) r.destination.authentication;
    }
    return call(r.url, r.task.automationPayload, headers);
  }

  AutomationResult notify(TenantId t, const WorkflowTask task) {
    if (!isHttpUrl(webhookUrl)) {
      AutomationResult result;
      result.success = true;
      result.message = "Notification recorded for " ~ recipientsOf(task) ~ " (no webhook configured)";
      return result;
    }
    auto body = Json.emptyObject;
    body["tenantId"] = t.value;
    body["workflowId"] = task.workflowId.value;
    body["taskId"] = task.id.value;
    body["name"] = task.name;
    body["role"] = task.assignedRole;
    body["assignedTo"] = task.assignedTo;
    body["message"] = task.instructions.length ? task.instructions : task.description;
    string[string] headers;
    auto r = call(webhookUrl, body.toString, headers);
    if (r.success)
      r.message = "Notification sent to " ~ recipientsOf(task);
    return r;
  }

  protected AutomationResult call(string url, string payload, string[string] headers) @trusted {
    import vibe.http.client : requestHTTP, HTTPClientSettings, HTTPClientRequest, HTTPClientResponse;
    import vibe.http.common : HTTPMethod;

    AutomationResult result;
    auto started = nowStdTime();
    auto method = payload.strip.length ? "POST" : "GET";
    try {
      auto settings = new HTTPClientSettings;
      settings.connectTimeout = timeout;
      settings.readTimeout = timeout;
      settings.defaultKeepAliveTimeout = 0.seconds;
      int status;
      string text;
      requestHTTP(url, (scope HTTPClientRequest req) {
        req.method = payload.strip.length ? HTTPMethod.POST : HTTPMethod.GET;
        req.headers["Accept"] = "application/json";
        foreach (k, v; headers)
          req.headers[k] = v;
        if (payload.strip.length)
          req.writeBody(cast(const(ubyte)[]) payload, payload.strip.startsWith("{") || payload.strip.startsWith("[")
          ? "application/json" : "text/plain");
      }, (scope HTTPClientResponse res) {
        status = res.statusCode;
        ubyte[4096] buffer;
        while (!res.bodyReader.empty && text.length < maxResponseBytes) {
          auto n = min(cast(size_t) res.bodyReader.leastSize, buffer.length);
          res.bodyReader.read(buffer[0 .. n]);
          text ~= cast(string) buffer[0 .. n].idup;
        }
        if (!res.bodyReader.empty)
          res.disconnect();
      }, settings);
      result.success = status >= 200 && status < 300;
      result.message = format("%s %s — HTTP %d", method, url, status);
      result.details = format("status=%d; response=%s", status, text.length > 2000 ? text[0 .. 2000] ~ "…" : text);
    } catch (Exception e) {
      result.timedOut = e.msg.toLower.canFind("timeout") || e.msg.toLower.canFind("timed out");
      result.message = format("%s %s failed: %s", method, url, e.msg);
    }
    result.durationMs = millisBetween(started, nowStdTime());
    return result;
  }
}

/// "S4_API" → value of IA_DESTINATION_S4_API_AUTHORIZATION ("" if unset).
string destinationAuthorization(string destinationName) @trusted {
  import std.process : environment;

  return environment.get(destinationAuthorizationVariable(destinationName), "");
}

string destinationAuthorizationVariable(string destinationName) pure {
  import std.ascii : isAlphaNum, toUpper;

  string name;
  foreach (c; destinationName)
    name ~= isAlphaNum(c) ? toUpper(c) : '_';
  return "IA_DESTINATION_" ~ name ~ "_AUTHORIZATION";
}

/// "role 'HR' / user 'ada'"
string recipientsOf(const WorkflowTask task) {
  string[] to;
  if (task.assignedRole.length)
    to ~= "role '" ~ task.assignedRole ~ "'";
  if (task.assignedTo.length)
    to ~= "user '" ~ task.assignedTo ~ "'";
  return to.length ? to.join(" / ") : "the workflow participants";
}

///
unittest {
  auto g = new SimulatedAutomationGateway;
  AutomationRequest r;
  r.url = "https://api.example.com/run";
  r.task.automationPayload = `{"a":1}`;
  auto ok = g.execute(r);
  assert(ok.success && ok.message.canFind("POST"));
  r.task.automationPayload = `{"simulate": "failure"}`;
  assert(!g.execute(r).success);
  r.task.automationPayload = `{"simulate":"timeout"}`;
  assert(g.execute(r).timedOut);
  assert(destinationAuthorizationVariable("s4-api.v2") == "IA_DESTINATION_S4_API_V2_AUTHORIZATION");
  WorkflowTask n;
  n.assignedRole = "HR";
  assert(g.notify(TenantId("t"), n).message.canFind("role 'HR'"));
  auto http = new HttpAutomationGateway(1);
  AutomationRequest bad;
  bad.url = "ftp://nowhere";
  assert(!http.execute(bad).success);
}
