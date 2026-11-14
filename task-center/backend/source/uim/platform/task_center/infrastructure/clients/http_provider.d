/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// vibe.d HTTP client implementing the task provider gateway.
///
/// GET <endpointUrl> with
///   oauth2      Bearer token (client credentials grant against authEndpointUrl,
///               cached until shortly before it expires)
///   basicAuth   Authorization: Basic base64(clientId:clientSecret)
///   apiKey      X-API-Key: clientSecret
///   none / certificate / saml   no header (mTLS / SAML are handled by the
///               destination or the runtime)
///
/// Accepted feeds: a JSON array, {"value": [...]} (OData v4), {"d": {"results":
/// [...]}} (OData v2) or {"tasks": [...]}. Field names of SAP Task Center /
/// SAP Workflow (InstanceID, TaskTitle, Status READY|RESERVED|IN_PROGRESS|
/// COMPLETED|CANCELED, Priority VERY_HIGH, CompletionDeadline, …) are mapped too.
module uim.platform.task_center.infrastructure.clients.http_provider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class HttpTaskProviderClient : ITaskProviderGateway {
  protected uint timeoutSeconds;
  protected string[string] tokens; /// tokenUrl|clientId → access token
  protected long[string] tokenExpiry; /// std time

  this(uint timeoutSeconds = 15) {
    this.timeoutSeconds = timeoutSeconds;
  }

  ProviderTask[] fetchTasks(const ProviderConnection c) @trusted {
    import std.base64 : Base64;
    import vibe.http.client : requestHTTP, HTTPClientRequest, HTTPClientResponse;
    import vibe.http.common : HTTPMethod;

    string authorization;
    final switch (c.authType) {
    case AuthenticationType.none, AuthenticationType.certificate, AuthenticationType.saml, AuthenticationType.apiKey:
      break;
    case AuthenticationType.basicAuth:
      authorization = "Basic " ~ cast(string) Base64.encode(cast(const(ubyte)[])(c.clientId ~ ":" ~ c.clientSecret));
      break;
    case AuthenticationType.oauth2:
      authorization = "Bearer " ~ accessToken(c.authEndpointUrl, c.clientId, c.clientSecret);
      break;
    }

    int status;
    string body;
    requestHTTP(c.endpointUrl, (scope HTTPClientRequest req) {
      req.method = HTTPMethod.GET;
      req.headers["Accept"] = "application/json";
      if (authorization.length)
        req.headers["Authorization"] = authorization;
      if (c.authType == AuthenticationType.apiKey)
        req.headers["X-API-Key"] = c.clientSecret;
    }, (scope HTTPClientResponse res) {
      status = res.statusCode;
      body = res.bodyReader.readAllUTF8();
    }, settings());
    if (status < 200 || status >= 300)
      throw TaskCenterException.gateway(format("%s answered HTTP %d", c.endpointUrl, status));
    Json j;
    try
      j = parseJsonString(body);
    catch (Exception e)
      throw TaskCenterException.gateway(c.endpointUrl ~ " did not return JSON: " ~ e.msg);
    return parseProviderFeed(j);
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
      throw TaskCenterException.gateway(format("token endpoint answered HTTP %d", status));
    auto j = parseJsonString(body);
    if ("access_token" !in j)
      throw TaskCenterException.gateway("token response has no access_token");
    auto token = j["access_token"].get!string;
    long lifetime = "expires_in" in j && j["expires_in"].type == Json.Type.int_ ? j["expires_in"].get!long : 300;
    tokens[key] = token;
    tokenExpiry[key] = expiryAfter(now, lifetime > 60 ? lifetime - 30 : lifetime);
    return token;
  }
}

/// Parse a provider feed (see module documentation). Throws gateway on an unknown shape.
ProviderTask[] parseProviderFeed(Json j) @trusted {
  Json items;
  if (j.type == Json.Type.array)
    items = j;
  else if (j.type == Json.Type.object && "value" in j && j["value"].type == Json.Type.array)
    items = j["value"];
  else if (j.type == Json.Type.object && "tasks" in j && j["tasks"].type == Json.Type.array)
    items = j["tasks"];
  else if (j.type == Json.Type.object && "d" in j && j["d"].type == Json.Type.object && "results" in j["d"]
    && j["d"]["results"].type == Json.Type.array)
    items = j["d"]["results"];
  else
    throw TaskCenterException.gateway("Unknown task feed format (expected an array, value, tasks or d.results)");

  ProviderTask[] result;
  foreach (item; items) {
    if (item.type != Json.Type.object)
      continue;
    ProviderTask t;
    t.externalId = pick(item, "externalId", "InstanceID", "id", "ID");
    t.title = pick(item, "title", "TaskTitle", "subject", "Subject");
    t.description = pick(item, "description", "Description");
    t.status = normalizeStatus(pick(item, "status", "Status"));
    t.priority = normalizePriority(pick(item, "priority", "Priority"));
    t.category = pick(item, "category", "Category");
    t.assignee = pick(item, "assignee", "Processor", "processor");
    t.creator = pick(item, "creator", "CreatedByName", "CreatedBy");
    t.dueDate = pick(item, "dueDate", "CompletionDeadline");
    t.definitionName = pick(item, "definitionName", "TaskDefinitionName");
    if ("allowedActions" in item && item["allowedActions"].type == Json.Type.array)
      foreach (a; item["allowedActions"])
        if (a.type == Json.Type.string)
          t.allowedActions ~= a.get!string;
    foreach (name; ["customAttributes", "CustomAttributeData"])
      if (name in item && item[name].type == Json.Type.object)
        t.customAttributes = item[name].toString;
    result ~= t;
  }
  return result;
}

/// First string (or number) valued property of the names.
private string pick(Json item, string[] names...) @trusted {
  foreach (n; names)
    if (n in item) {
      auto v = item[n];
      if (v.type == Json.Type.string)
        return v.get!string;
      if (v.type == Json.Type.int_)
        return v.get!long.to!string;
    }
  return "";
}

/// SAP workflow statuses → TaskStatus values.
string normalizeStatus(string s) {
  switch (s.strip.toUpper.replace("_", "")) {
  case "READY", "OPEN", "NEW":
    return "open";
  case "RESERVED":
    return "reserved";
  case "INPROGRESS", "STARTED":
    return "inProgress";
  case "COMPLETED", "DONE":
    return "completed";
  case "CANCELED", "CANCELLED":
    return "cancelled";
  case "FAILED", "ERROR":
    return "failed";
  default:
    return s;
  }
}

/// LOW | MEDIUM | HIGH | VERY_HIGH → TaskPriority values.
string normalizePriority(string s) {
  switch (s.strip.toUpper.replace("_", "")) {
  case "LOW":
    return "low";
  case "MEDIUM":
    return "medium";
  case "HIGH":
    return "high";
  case "VERYHIGH", "URGENT":
    return "veryHigh";
  default:
    return s;
  }
}

/// Gateway for tests, demos and dry runs: answers with configured tasks per endpoint.
class StaticTaskProviderGateway : ITaskProviderGateway {
  ProviderTask[][string] feeds; /// endpointUrl → tasks
  string[string] failures; /// endpointUrl → error message
  string[] requested;

  ProviderTask[] fetchTasks(const ProviderConnection c) {
    requested ~= c.endpointUrl;
    if (auto f = c.endpointUrl in failures)
      throw TaskCenterException.gateway(*f);
    if (auto tasks = c.endpointUrl in feeds)
      return (*tasks).dup;
    return null;
  }
}

///
unittest {
  auto sap = parseJsonString(`{"value": [
    {"InstanceID": "W-1", "TaskTitle": "Approve PR 10001", "Status": "READY", "Priority": "VERY_HIGH",
     "CompletionDeadline": "2026-12-01T12:00:00Z", "CustomAttributeData": {"amount": "5"}},
    {"InstanceID": 42, "TaskTitle": "Done", "Status": "COMPLETED"}, "noise"]}`);
  auto tasks = parseProviderFeed(sap);
  assert(tasks.length == 2);
  assert(tasks[0].externalId == "W-1" && tasks[0].status == "open" && tasks[0].priority == "veryHigh");
  assert(dayOf(tasks[0].dueDate) == "2026-12-01" && tasks[0].customAttributes.canFind("amount"));
  assert(tasks[1].externalId == "42" && tasks[1].status == "completed");
  assert(parseProviderFeed(parseJsonString(`{"d": {"results": [{"id": "x", "title": "t"}]}}`)).length == 1);
  assert(failsWith(TaskCenterErrorKind.gateway, () { parseProviderFeed(parseJsonString(`{"items": []}`)); }));
}
