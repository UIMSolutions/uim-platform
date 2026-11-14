/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP client adapter of the IBackendProbe gateway port: a HEAD request
/// against the backend URL. Any HTTP answer (even 401/403) proves the
/// system is reachable; 5xx and network errors do not.
module uim.platform.agentry.infrastructure.clients.backend_probe;

import core.time : MonoTime, seconds;
import vibe.http.client : HTTPClientSettings, requestHTTP;
import vibe.http.common : HTTPMethod;
import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class HttpBackendProbe : IBackendProbe {
  protected int timeoutSeconds;

  this(int timeoutSeconds) {
    this.timeoutSeconds = timeoutSeconds;
  }

  BackendProbeResult probe(const BackendConnection connection) {
    BackendProbeResult result;
    auto url = connection.backendUrl;
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      result.message = "Unsupported URL: " ~ url;
      return result;
    }

    auto settings = new HTTPClientSettings;
    settings.connectTimeout = timeoutSeconds.seconds;
    settings.readTimeout = timeoutSeconds.seconds;
    auto started = MonoTime.currTime;
    try {
      requestHTTP(url, (scope req) { req.method = HTTPMethod.HEAD; }, (scope res) {
        result.statusCode = res.statusCode;
        res.dropBody();
      }, settings);
      result.latencyMs = (MonoTime.currTime - started).total!"msecs";
      result.reachable = result.statusCode > 0 && result.statusCode < 500;
      result.message = "HTTP %d".format(result.statusCode);
    } catch (Exception e) {
      result.latencyMs = (MonoTime.currTime - started).total!"msecs";
      result.message = e.msg;
    }
    return result;
  }
}

/// Probe used when connectivity tests are disabled (probeTimeoutSeconds = 0).
class DisabledBackendProbe : IBackendProbe {
  BackendProbeResult probe(const BackendConnection connection) {
    return BackendProbeResult(false, 0, 0, "Connectivity tests are disabled (probeTimeoutSeconds = 0)");
  }
}

///
unittest {
  mixin(ShowTest!("HttpBackendProbe"));

  BackendConnection c;
  c.backendUrl = "ftp://example.com";
  assert(!new HttpBackendProbe(1).probe(c).reachable);
  assert(!new DisabledBackendProbe().probe(c).reachable);
}
