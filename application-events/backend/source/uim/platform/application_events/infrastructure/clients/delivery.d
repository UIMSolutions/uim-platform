/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Adapters of the IDeliveryGateway (push delivery to webhooks).
///
///   simulate  no network: endpoints whose host ends in ".invalid" or that
///             contain "/fail" answer 503, everything else 202 (development,
///             demos, tests); the attempts are counted
///   http      POST of the CloudEvent in structured mode
///             (Content-Type application/cloudevents+json) with the headers
///             ce-id, ce-type, ce-source and X-Correlation-Id; a 2xx answer
///             succeeds; timeouts and other answers fail (retry). An optional
///             Authorization header comes from APPEVENTS_DELIVERY_AUTHORIZATION.
module uim.platform.application_events.infrastructure.clients.delivery;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// Host of an http(s) URL ("" if none).
string urlHost(string url) pure {
  auto rest = url.startsWith("https://") ? url[8 .. $] : url.startsWith("http://") ? url[7 .. $] : "";
  foreach (i, c; rest)
    if (c == '/' || c == ':' || c == '?' || c == '#')
      return rest[0 .. i];
  return rest;
}

class SimulatedDeliveryGateway : IDeliveryGateway {
  size_t attempts;
  /// Tests: make the next n deliveries fail.
  int failNext;
  string[] endpoints; /// the endpoints of all attempts (tests)

  string mode() {
    return "simulate";
  }

  DeliveryOutcome deliver(const EventChannel channel, const EventMessage message) {
    attempts++;
    endpoints ~= channel.endpoint;
    DeliveryOutcome o;
    auto host = urlHost(channel.endpoint);
    if (failNext > 0 || host.endsWith(".invalid") || channel.endpoint.canFind("/fail")) {
      if (failNext > 0)
        failNext--;
      o.statusCode = 503;
      o.message = "simulated: " ~ (host.length ? host : channel.endpoint) ~ " answered HTTP 503";
      return o;
    }
    o.success = true;
    o.statusCode = 202;
    o.message = "simulated: HTTP 202 from " ~ host;
    return o;
  }
}

class HttpDeliveryGateway : IDeliveryGateway {
  enum size_t maxResponseBytes = 16 * 1024;
  protected Duration timeout;
  protected string userAgent;

  this(uint timeoutSeconds, string userAgent = "uim-application-events") {
    this.timeout = dur!"seconds"(timeoutSeconds > 0 ? timeoutSeconds : 10);
    this.userAgent = userAgent;
  }

  string mode() {
    return "http";
  }

  DeliveryOutcome deliver(const EventChannel channel, const EventMessage message) @trusted {
    import std.process : environment;
    import vibe.http.client : requestHTTP, HTTPClientSettings, HTTPClientRequest, HTTPClientResponse;
    import vibe.http.common : HTTPMethod;

    DeliveryOutcome o;
    try {
      auto body = message.toCloudEvent().toJson().toString;
      auto settings = new HTTPClientSettings;
      settings.connectTimeout = timeout;
      settings.readTimeout = timeout;
      settings.defaultKeepAliveTimeout = 0.seconds;
      auto auth = environment.get("APPEVENTS_DELIVERY_AUTHORIZATION", "");
      string text;
      requestHTTP(channel.endpoint, (scope HTTPClientRequest req) {
        req.method = HTTPMethod.POST;
        req.headers["User-Agent"] = userAgent;
        req.headers["ce-specversion"] = cloudEventsSpecVersion;
        req.headers["ce-id"] = message.eventId;
        req.headers["ce-type"] = message.eventType;
        req.headers["ce-source"] = message.producerSystemId.value;
        req.headers["X-Correlation-Id"] = message.id.value;
        if (auth.length)
          req.headers["Authorization"] = auth;
        req.writeBody(cast(const(ubyte)[]) body, "application/cloudevents+json; charset=utf-8");
      }, (scope HTTPClientResponse res) {
        o.statusCode = res.statusCode;
        ubyte[4096] buffer;
        while (!res.bodyReader.empty && text.length < maxResponseBytes) {
          auto n = min(cast(size_t) res.bodyReader.leastSize, buffer.length);
          res.bodyReader.read(buffer[0 .. n]);
          text ~= cast(string) buffer[0 .. n].idup;
        }
        if (!res.bodyReader.empty)
          res.disconnect();
      }, settings);
      o.success = o.statusCode >= 200 && o.statusCode < 300;
      auto snippet = text.strip.length > 200 ? text.strip[0 .. 200] : text.strip;
      o.message = format("HTTP %d", o.statusCode) ~ (o.success || snippet.length == 0 ? "" : ": " ~ snippet);
    } catch (Exception e) {
      o.success = false;
      o.message = "webhook call failed: " ~ e.msg;
    }
    return o;
  }
}

///
unittest {
  assert(urlHost("https://crm.example.com:8443/x") == "crm.example.com" && urlHost("ftp://x") == "");
  auto g = new SimulatedDeliveryGateway;
  EventChannel c;
  c.endpoint = "https://crm.example.com/events";
  EventMessage m;
  assert(g.deliver(c, m).success);
  c.endpoint = "https://down.unreachable.invalid/hook";
  auto o = g.deliver(c, m);
  assert(!o.success && o.statusCode == 503);
  c.endpoint = "https://crm.example.com/events";
  g.failNext = 1;
  assert(!g.deliver(c, m).success && g.deliver(c, m).success && g.attempts == 4);
}
