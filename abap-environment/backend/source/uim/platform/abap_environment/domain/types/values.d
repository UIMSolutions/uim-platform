/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects embedded in the aggregates (exchanged as OData complex types).
module uim.platform.abap_environment.domain.types.values;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// An ordered key/value pair (job parameter, label).
struct KeyValue {
  string key;
  string value;
}

/// Value of `key` in a list of pairs ("" if missing).
string valueOf(const KeyValue[] pairs, string key) {
  foreach (p; pairs)
    if (p.key == key)
      return p.value;
  return "";
}

/// A commit pulled into a software component.
struct ComponentCommit {
  string commitId;
  string branch;
  string message;
  string author;
  long committedAt;
}

/// An inbound or outbound service of a communication arrangement.
struct CommunicationEndpoint {
  string name;
  string url;
  CommunicationProtocol protocol = CommunicationProtocol.httpRest;
  int port;
  bool active = true;
}

/// A service path exposed by a service binding.
struct ExposedEndpoint {
  string path;
  string serviceName;
  string serviceVersion = "0001";
  bool requiresAuth = true;
}

/// A business role assigned to a business user.
struct RoleAssignment {
  BusinessRoleId roleId;
  string roleName;
  long assignedAt;
}

/// A task (one developer's changes) inside a transport request.
struct TransportTask {
  string taskId;
  string owner;
  string description;
  TransportStatus status = TransportStatus.modifiable;
  string[] objects; /// e.g. "R3TR CLAS ZCL_TRAVEL"
  long createdAt;
  long releasedAt;
}

/// One run of an application job.
struct JobExecutionLog {
  string runId;
  JobStatus status = JobStatus.running;
  long startedAt;
  long finishedAt;
  int returnCode;
  string message;
}

///
unittest {
  assert(valueOf([KeyValue("a", "1")], "a") == "1");
  assert(valueOf([KeyValue("a", "1")], "b") == "");
}
