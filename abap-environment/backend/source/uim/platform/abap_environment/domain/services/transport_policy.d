/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Rules of the transport workflow (CTS).
module uim.platform.abap_environment.domain.services.transport_policy;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// All reasons that prevent releasing a transport request (empty = releasable).
string[] releaseBlockers(const ref TransportRequest request) {
  string[] errors;
  if (request.status != TransportStatus.modifiable)
    errors ~= "transport request is not modifiable (status: " ~ enumText(request.status) ~ ")";
  if (request.description.strip.length == 0)
    errors ~= "transport request needs a description";
  if (request.owner.strip.length == 0)
    errors ~= "transport request needs an owner";
  if (request.tasks.length == 0)
    errors ~= "transport request has no tasks";
  foreach (task; request.tasks)
    if (task.status == TransportStatus.modifiable)
      errors ~= "task " ~ task.taskId ~ " is still modifiable — release all tasks first";
  if (request.transportType != TransportType.transportOfCopies && request.targetSystemId.isEmpty)
    errors ~= "transport request has no target system";
  return errors;
}

/// Throw a conflict listing every release blocker.
void ensureReleasable(const ref TransportRequest request) {
  auto errors = releaseBlockers(request);
  ensureState(errors.length == 0, "Cannot release " ~ request.name ~ ": " ~ errors.join("; "));
}

/// Index of the task in the request, or a not-found exception.
size_t taskIndex(const ref TransportRequest request, string taskId) {
  foreach (i, t; request.tasks)
    if (t.taskId == taskId)
      return i;
  throw new AbapNotFoundException("Task '" ~ taskId ~ "' not found in " ~ request.name);
}

/// Next transport number of a source system: "<SID>K9" + 5 digits, e.g. "H01K900003".
string transportNumber(string sid, size_t sequence) {
  auto prefix = (sid.length == 3 ? sid : "UIM") ~ "K9";
  return prefix ~ format("%05d", sequence % 100_000);
}

/// Task numbers follow the request number: "<request>-<n>".
string taskNumber(string requestNumber, size_t index) {
  return requestNumber ~ "-" ~ format("%02d", index + 1);
}

///
unittest {
  TransportRequest r;
  r.name = "H01K900001";
  r.description = "Travel app";
  r.owner = "DEV";
  assert(releaseBlockers(r).canFind("transport request has no tasks"));
  r.targetSystemId = SystemInstanceId("prd");
  r.tasks = [TransportTask("H01K900001-01", "DEV")];
  assert(releaseBlockers(r).length == 1); // task still modifiable
  r.tasks[0].status = TransportStatus.released;
  assert(releaseBlockers(r).length == 0);
  assert(taskIndex(r, "H01K900001-01") == 0);
  assert(transportNumber("H01", 3) == "H01K900003");
  assert(taskNumber("H01K900003", 0) == "H01K900003-01");
}
