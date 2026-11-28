/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An entry of the audit log (administration → logging): what happened
/// (event type, e.g. "execution.stopped"), to which resource (subject), by
/// whom (createdBy) and when (createdAt). Entries carry ids, states and
/// changed field names — never passwords, secrets or prompt contents.
module uim.platform.ai_launchpad.domain.entities.log_entry;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct LogEntry {
  mixin TenantEntity!LogEntryId;

  LogCategory category = LogCategory.system;
  LogSeverity severity = LogSeverity.info;
  string eventType;
  string subject;
  string message;
  string details; /// JSON object as text

  void validate() const {
    requireText(eventType, "Event type");
    requireMaxLength(eventType, 100, "Event type");
    requireMaxLength(subject, 256, "Subject");
    requireMaxLength(message, 2000, "Message");
    requireMaxLength(details, 8000, "Details");
  }
}

/// Category of an event type by its prefix ("login.failed" → security).
LogCategory categoryOf(string eventType) pure {
  auto dot = eventType.indexOf('.');
  auto prefix = dot > 0 ? eventType[0 .. dot] : eventType;
  switch (prefix) {
  case "login":
  case "password":
  case "token":
  case "session":
    return LogCategory.security;
  case "user":
  case "role":
  case "tile":
  case "log":
    return LogCategory.administration;
  case "workspace":
  case "connection":
  case "resourceGroup":
    return LogCategory.runtime;
  case "scenario":
  case "configuration":
  case "execution":
  case "deployment":
  case "model":
  case "dataset":
    return LogCategory.lifecycle;
  case "promptCollection":
  case "prompt":
    return LogCategory.genai;
  default:
    return LogCategory.system;
  }
}

/// Severity of an event type by its outcome ("….failed" → warning).
LogSeverity severityOf(string eventType) pure {
  if (eventType.endsWith(".error") || eventType.endsWith(".dead"))
    return LogSeverity.error;
  if (eventType.endsWith(".failed") || eventType.endsWith(".locked") || eventType.endsWith(".deleted")
    || eventType.endsWith(".invalid") || eventType.endsWith(".expired") || eventType.endsWith(".purged"))
    return LogSeverity.warning;
  return LogSeverity.info;
}

///
unittest {
  assert(categoryOf("login.failed") == LogCategory.security && severityOf("login.failed") == LogSeverity.warning);
  assert(categoryOf("execution.completed") == LogCategory.lifecycle && severityOf("execution.completed") == LogSeverity.info);
  assert(categoryOf("prompt.run") == LogCategory.genai && categoryOf("user.created") == LogCategory.administration);
  assert(categoryOf("reconcile") == LogCategory.system && severityOf("deployment.dead") == LogSeverity.error);
  LogEntry e;
  e.id = LogEntryId("x");
  assert(failsWith(AilpErrorKind.invalid, () { e.validate(); }));
}
