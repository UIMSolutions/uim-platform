/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.import_queue_entry;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// A transport request waiting in (or processed by) the import queue of a node.
struct ImportQueueEntry {
  mixin TenantEntity!ImportQueueEntryId;

  TransportNodeId nodeId;
  TransportRequestId requestId;
  ImportStatus status = ImportStatus.initial;
  int queuePosition = 0;
  long queuedAt;
  long startedAt;
  long completedAt;
  string errorMessage;
  string importLog;
  /// Only selected entries are imported by "import all".
  bool isSelected = true;
  long scheduledAt;

  /// Waiting for an import (new or marked for repetition).
  bool isPending() const {
    return status == ImportStatus.initial || status == ImportStatus.repeating;
  }

  /// Picked up by an "import all selected" run.
  bool isImportable() const {
    return isPending && isSelected;
  }

  /// Finished (successfully, with warnings or failed).
  bool isFinished() const {
    return status == ImportStatus.success || status == ImportStatus.warning || status == ImportStatus.failed;
  }

  void start(long now) {
    status = ImportStatus.running;
    startedAt = now;
    completedAt = 0;
    errorMessage = "";
    updatedAt = now;
  }

  void finish(ImportStatus result, long now, string log, string error = "") {
    status = result;
    completedAt = now;
    importLog = log;
    errorMessage = error;
    updatedAt = now;
  }

  /// Put the entry back into the queue for another import.
  void reset(long now) {
    status = isFinished || status == ImportStatus.running ? ImportStatus.repeating : ImportStatus.initial;
    startedAt = 0;
    completedAt = 0;
    errorMessage = "";
    importLog = "";
    updatedAt = now;
  }

  Json toJson() const {
    return entityToJson
      .set("nodeId", nodeId.value)
      .set("requestId", requestId.value)
      .set("status", enumName(status))
      .set("queuePosition", queuePosition)
      .set("queuedAt", queuedAt)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("errorMessage", errorMessage)
      .set("importLog", importLog)
      .set("isSelected", isSelected)
      .set("scheduledAt", scheduledAt);
  }
}

///
unittest {
  mixin(ShowTest!("ImportQueueEntry"));

  ImportQueueEntry e;
  assert(e.isImportable);
  e.start(10);
  assert(e.status == ImportStatus.running && !e.isPending);
  e.finish(ImportStatus.failed, 20, "log", "boom");
  assert(e.isFinished && e.errorMessage == "boom");
  e.reset(30);
  assert(e.status == ImportStatus.repeating && e.isImportable && e.importLog == "");
}
