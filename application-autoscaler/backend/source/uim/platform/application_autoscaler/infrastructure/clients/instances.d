/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Adapters of the IInstanceController gateway.
///
///   simulate  the instance count is accepted as is (development, demos,
///             tests); a counter of calls is kept
///   http      POST {appGuid, appName, instances, currentInstances, reason,
///             tenant, bindingId} as JSON to instanceUrl; a 2xx answer
///             succeeds, an optional {"instances": n} reports the count the
///             platform actually set. Authorization from the environment
///             variable AUTOSCALER_INSTANCE_AUTHORIZATION (e.g. a bearer token
///             of a Cloud Foundry technical user or a Kubernetes adapter).
module uim.platform.application_autoscaler.infrastructure.clients.instances;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class SimulatedInstanceController : IInstanceController {
  size_t calls;
  /// Tests: make the next call fail with this message.
  string failNext;

  string mode() {
    return "simulate";
  }

  ScaleOutcome scale(ScaleRequest r) {
    calls++;
    ScaleOutcome o;
    if (failNext.length) {
      o.message = failNext;
      failNext = null;
      return o;
    }
    o.success = true;
    o.instances = r.targetInstances;
    o.message = format("simulated: %s set to %d instances", r.appName, r.targetInstances);
    return o;
  }
}

class HttpInstanceController : IInstanceController {
  enum size_t maxResponseBytes = 64 * 1024;
  protected string url;
  protected Duration timeout;

  this(string url, uint timeoutSeconds) {
    this.url = url.strip;
    this.timeout = dur!"seconds"(timeoutSeconds > 0 ? timeoutSeconds : 30);
  }

  string mode() {
    return "http";
  }

  static Json requestBody(const ScaleRequest r) {
    auto j = Json.emptyObject;
    j["tenant"] = r.tenantId.value;
    j["bindingId"] = r.bindingId.value;
    j["appGuid"] = r.appGuid;
    j["appName"] = r.appName;
    j["currentInstances"] = r.currentInstances;
    j["instances"] = r.targetInstances;
    j["reason"] = r.reason;
    return j;
  }

  ScaleOutcome scale(ScaleRequest r) @trusted {
    import std.process : environment;
    import vibe.http.client : requestHTTP, HTTPClientSettings, HTTPClientRequest, HTTPClientResponse;
    import vibe.http.common : HTTPMethod;

    ScaleOutcome o;
    try {
      auto body = requestBody(r).toString;
      auto settings = new HTTPClientSettings;
      settings.connectTimeout = timeout;
      settings.readTimeout = timeout;
      settings.defaultKeepAliveTimeout = 0.seconds;
      auto auth = environment.get("AUTOSCALER_INSTANCE_AUTHORIZATION", "");
      int status;
      string text;
      requestHTTP(url, (scope HTTPClientRequest req) {
        req.method = HTTPMethod.POST;
        req.headers["Accept"] = "application/json";
        req.headers["X-Correlation-Id"] = r.bindingId.value;
        if (auth.length)
          req.headers["Authorization"] = auth;
        req.writeBody(cast(const(ubyte)[]) body, "application/json");
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
      if (status < 200 || status >= 300) {
        o.message = format("platform answered HTTP %d: %s", status, text.length > 300 ? text[0 .. 300] : text);
        return o;
      }
      o.success = true;
      o.instances = r.targetInstances;
      o.message = format("HTTP %d", status);
      if (text.strip.length) {
        try {
          auto j = parseJsonString(text);
          if (j.isObject && "instances" in j && j["instances"].type == Json.Type.int_)
            o.instances = cast(int) j["instances"].get!long;
          if (j.isObject && "message" in j && j["message"].type == Json.Type.string)
            o.message = j["message"].get!string;
        } catch (Exception) {
        }
      }
    } catch (Exception e) {
      o.success = false;
      o.message = "platform call failed: " ~ e.msg;
    }
    return o;
  }
}

///
unittest {
  auto c = new SimulatedInstanceController;
  ScaleRequest r;
  r.appName = "shop";
  r.targetInstances = 4;
  assert(c.scale(r).success && c.scale(r).instances == 4 && c.calls == 2);
  c.failNext = "quota exceeded";
  assert(!c.scale(r).success && c.scale(r).success);
  auto j = HttpInstanceController.requestBody(r);
  assert(j["instances"].get!long == 4 && j["appName"].get!string == "shop");
}
