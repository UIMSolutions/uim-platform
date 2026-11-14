/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// vibe.d HTTP client implementing the webhook endpoint gateway.
///   basic   Authorization: Basic base64(credentials)      (credentials = "user:password")
///   apiKey  X-API-Key: <credentials>
///   oauth2  client credentials grant against tokenUrl (clientId + credentials
///           as secret); tokens are cached until shortly before they expire
module uim.platform.events.infrastructure.clients.http_webhook;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class HttpWebhookClient : IWebhookEndpointGateway {
  protected uint timeoutSeconds;
  protected string[string] tokens; /// tokenUrl|clientId → access token
  protected long[string] tokenExpiry; /// std time

  this(uint timeoutSeconds = 10) {
    this.timeoutSeconds = timeoutSeconds;
  }

  WebhookResponse push(const WebhookRequest r) @trusted {
    import std.base64 : Base64;
    import vibe.http.client : requestHTTP, HTTPClientSettings, HTTPClientRequest, HTTPClientResponse;
    import vibe.http.common : HTTPMethod;

    WebhookResponse result;
    string authorization;
    try {
      final switch (r.authenticationType) {
      case WebhookAuthType.none, WebhookAuthType.apiKey:
        break;
      case WebhookAuthType.basic:
        authorization = "Basic " ~ cast(string) Base64.encode(cast(const(ubyte)[]) r.credentials);
        break;
      case WebhookAuthType.oauth2:
        authorization = "Bearer " ~ accessToken(r.tokenUrl, r.clientId, r.credentials);
        break;
      }
      requestHTTP(r.url, (scope HTTPClientRequest req) {
        req.method = HTTPMethod.POST;
        foreach (k, v; r.headers)
          req.headers[k] = v;
        if (authorization.length)
          req.headers["Authorization"] = authorization;
        if (r.authenticationType == WebhookAuthType.apiKey)
          req.headers["X-API-Key"] = r.credentials;
        req.writeBody(cast(const(ubyte)[]) r.body, r.contentType.length ? r.contentType : "application/json");
      }, (scope HTTPClientResponse res) {
        result.status = res.statusCode;
        if (!result.succeeded)
          result.error = res.statusPhrase;
        res.dropBody();
      }, settings());
    } catch (Exception e) {
      result.status = 0;
      result.error = r.url ~ ": " ~ e.msg;
    }
    return result;
  }

  protected auto settings() @trusted {
    import vibe.http.client : HTTPClientSettings;

    auto s = new HTTPClientSettings;
    s.connectTimeout = timeoutSeconds.seconds;
    s.readTimeout = timeoutSeconds.seconds;
    return s;
  }

  protected string accessToken(string tokenUrl, string clientId, string secret) @trusted {
    import vibe.http.client : requestHTTP, HTTPClientRequest, HTTPClientResponse;
    import vibe.http.common : HTTPMethod;
    import vibe.inet.webform : formEncode;

    auto key = tokenUrl ~ "|" ~ clientId;
    auto now = nowStdTime();
    if (auto t = key in tokens)
      if (tokenExpiry.get(key, 0) > now)
        return *t;

    int status;
    string body;
    requestHTTP(tokenUrl, (scope HTTPClientRequest req) {
      req.method = HTTPMethod.POST;
      req.writeBody(cast(const(ubyte)[]) formEncode(["grant_type": "client_credentials", "client_id": clientId,
        "client_secret": secret]), "application/x-www-form-urlencoded");
    }, (scope HTTPClientResponse res) {
      status = res.statusCode;
      body = res.bodyReader.readAllUTF8();
    }, settings());
    if (status != 200)
      throw new Exception(format("token endpoint answered HTTP %d", status));
    auto j = parseJsonString(body);
    enforce("access_token" in j, "token response has no access_token");
    auto token = j["access_token"].get!string;
    long lifetime = "expires_in" in j && j["expires_in"].type == Json.Type.int_ ? j["expires_in"].get!long : 300;
    tokens[key] = token;
    tokenExpiry[key] = expiryAfter(now, lifetime > 60 ? lifetime - 30 : lifetime);
    return token;
  }
}

/// Gateway for tests and dry runs: records the requests and answers with a fixed status.
class RecordingWebhookGateway : IWebhookEndpointGateway {
  WebhookRequest[] requests;
  int status = 200;

  WebhookResponse push(const WebhookRequest r) {
    requests ~= WebhookRequest(r.url, null, r.contentType, r.body, r.authenticationType, "", r.tokenUrl, r.clientId);
    return WebhookResponse(status, status >= 200 && status < 300 ? "" : "simulated failure");
  }
}
