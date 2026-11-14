/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.clients.landscape;

import std.digest : toHexString, LetterCase;
import std.digest.sha : sha1Of;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Simulated ABAP landscape: derives service URLs, commit ids, import and job
/// results deterministically and records every call. Replace with clients of
/// the ABAP environment provisioning API, gCTS and the job scheduling API to
/// manage real systems.
///
/// Conventions that let tests and demos exercise failure paths:
///   * repository URLs containing "invalid" cannot be read (clone/pull fails)
///   * a transport whose description contains "[fail]" fails to import
///   * a job parameter `simulateReturnCode=<n>` makes the run end with rc n
class SimulatedLandscapeGateway : IAbapLandscapeGateway {
  struct Operation {
    string verb;
    string target;
    string detail;
  }

  protected Operation[] _operations;
  protected size_t _capacity;
  protected string _domain;

  this(string domain = "abap.hana.ondemand.com", size_t capacity = 500) {
    _domain = domain;
    _capacity = capacity;
  }

  ProvisionedSystem provision(const SystemInstance system) {
    auto host = system.id.value.length >= 8 ? system.id.value[0 .. 8] : system.id.value;
    ProvisionedSystem p;
    p.serviceUrl = "https://" ~ host ~ ".abap." ~ system.region ~ ".hana.ondemand.com";
    p.webSocketUrl = "wss://" ~ host ~ ".abap-web." ~ system.region ~ ".hana.ondemand.com";
    p.stackVersion = "ABAP Cloud " ~ system.softwareVersion;
    record("provision", system.name, p.serviceUrl);
    return p;
  }

  void deprovision(const SystemInstance system) {
    record("deprovision", system.name, system.serviceUrl);
  }

  string headCommit(string repositoryUrl, string branch) {
    record("ls-remote", repositoryUrl, branch);
    if (repositoryUrl.canFind("invalid"))
      return "";
    // a new commit per minute and branch
    auto minute = nowStdTime() / 600_000_000L;
    auto digest = sha1Of(repositoryUrl ~ "#" ~ branch ~ "@" ~ minute.to!string);
    return toHexString!(LetterCase.lower)(digest)[0 .. 10].idup;
  }

  string importTransport(const TransportRequest request, const SystemInstance target) {
    record("import", target.name, request.name);
    if (request.description.canFind("[fail]"))
      return "Import of " ~ request.name ~ " into " ~ target.name ~ " ended with return code 8";
    return "";
  }

  JobRunOutcome runJob(const ApplicationJob job) {
    record("run", job.name, job.jobTemplateName);
    auto rc = valueOf(job.parameters, "simulateReturnCode");
    auto code = rc.length > 0 ? rc.to!int : 0;
    return JobRunOutcome(code, code == 0 ? "Job " ~ job.jobTemplateName ~ " finished successfully"
        : "Job " ~ job.jobTemplateName ~ " ended with return code " ~ rc);
  }

  /// The most recent calls (oldest first).
  const(Operation)[] operations() const {
    return _operations;
  }

  protected void record(string verb, string target, string detail) {
    _operations ~= Operation(verb, target, detail);
    if (_operations.length > _capacity)
      _operations = _operations[$ - _capacity .. $];
    logDebug("abap landscape: %s %s %s", verb, target, detail);
  }
}

///
unittest {
  auto gw = new SimulatedLandscapeGateway();
  auto s = SystemInstance(TenantId("t"));
  s.region = "eu10";
  assert(gw.provision(s).serviceUrl.endsWith(".abap.eu10.hana.ondemand.com"));
  assert(gw.headCommit("https://github.com/x/y.git", "main").length == 10);
  assert(gw.headCommit("https://invalid.example/x.git", "main") == "");
  auto job = ApplicationJob(TenantId("t"));
  job.parameters = [KeyValue("simulateReturnCode", "4")];
  assert(gw.runJob(job).returnCode == 4);
  assert(gw.operations.length == 4);
}
