/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A job: an HTTP endpoint (the action) that the scheduler calls whenever
/// one of the job's schedules is due. The name is unique per tenant.
/// Inactive jobs and jobs outside their [startTime, endTime] window do not run.
module uim.platform.job_scheduling.domain.entities.job;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

enum int maxJobRetries = 10;
enum int maxTimeoutSeconds = 86_400;

struct Job {
  mixin TenantEntity!JobId;

  string name; /// unique per tenant
  string description;
  string actionUrl; /// http(s) endpoint called on every run
  JobHttpMethod httpMethod = JobHttpMethod.post;
  bool active = true;
  bool asyncMode; /// the endpoint answers 202 Accepted and reports the result later (callback)
  long startTime; /// no runs before (std time, 0 = open)
  long endTime; /// no runs after (std time, 0 = open)
  int retries = -1; /// retries after a failed call (-1 = configuration default)
  int timeoutSeconds; /// synchronous call / asynchronous callback timeout (0 = configuration default)

  /// Active and inside its time window.
  bool isRunnableAt(long now) const {
    return active && (startTime == 0 || now >= startTime) && (endTime == 0 || now <= endTime);
  }

  void validate() const {
    requireId(id.value, "Job ID");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 2000, "Description");
    requireText(actionUrl, "Action URL");
    requireMaxLength(actionUrl, 2048, "Action URL");
    if (!isHttpUrl(actionUrl))
      throw JobSchedulingException.invalid("Action URL '" ~ actionUrl ~ "' must be an absolute http:// or https:// URL");
    if (startTime > 0 && endTime > 0 && endTime <= startTime)
      throw JobSchedulingException.invalid("The end time of a job must be after its start time");
    requireRange(retries, -1, maxJobRetries, "Retries");
    requireRange(timeoutSeconds, 0, maxTimeoutSeconds, "Timeout");
  }
}

/// Absolute http(s) URL with a host.
bool isHttpUrl(string url) pure {
  auto u = url.strip;
  if (u != url || u.canFind!(c => c == ' ' || c == '\n' || c == '\r' || c == '\t'))
    return false;
  return urlHost(u).length > 0;
}

/// Host of an http(s) URL in lower case ("" if not an http(s) URL).
string urlHost(string url) pure {
  string rest;
  if (url.startsWith("http://"))
    rest = url[7 .. $];
  else if (url.startsWith("https://"))
    rest = url[8 .. $];
  else
    return "";
  auto end = rest.length;
  foreach (i, c; rest)
    if (c == '/' || c == '?' || c == '#') {
      end = i;
      break;
    }
  auto authority = rest[0 .. end];
  auto at = authority.lastIndexOf('@');
  if (at >= 0)
    authority = authority[at + 1 .. $];
  if (authority.startsWith("[")) { // IPv6 literal
    auto close = authority.indexOf(']');
    return close > 1 ? authority[0 .. close + 1].toLower : "";
  }
  auto colon = authority.indexOf(':');
  return (colon >= 0 ? authority[0 .. colon] : authority).toLower;
}

///
unittest {
  Job j;
  j.id = JobId("nightly");
  j.name = "Nightly export";
  j.actionUrl = "https://erp.example.com/jobs/export?full=1";
  j.validate();
  assert(j.isRunnableAt(1));
  j.endTime = 10;
  assert(!j.isRunnableAt(11));
  j.startTime = 20;
  assert(failsWith(JsErrorKind.invalid, () { j.validate(); }));
  j.startTime = j.endTime = 0;
  j.actionUrl = "ftp://x";
  assert(failsWith(JsErrorKind.invalid, () { j.validate(); }));
  j.actionUrl = "https://ok.example.com";
  j.retries = 11;
  assert(failsWith(JsErrorKind.invalid, () { j.validate(); }));

  assert(urlHost("https://User:pw@Api.Example.com:8443/x") == "api.example.com");
  assert(urlHost("http://[::1]:8080/") == "[::1]" && urlHost("mailto:x@y") == "");
  assert(isHttpUrl("http://localhost:8096/health") && !isHttpUrl("https://") && !isHttpUrl("https://a b"));
}
