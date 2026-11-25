/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Pure domain service of the workflow progression: dependency resolution,
/// readiness of tasks and the progress of a workflow — computed from the
/// task list only (no repositories, no clock), so every adapter and test
/// gets the same answer.
module uim.platform.integration_automation.domain.services.workflow_engine;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// Progress of a workflow derived from its tasks.
struct WorkflowProgress {
  int total;
  int done; /// completed or skipped
  int completed;
  int skipped;
  int failed;
  int inProgress;
  int pending;
  int ready; /// pending with every dependency done
  int percent; /// done / total (0..100)
  WorkflowTaskId current; /// first ready or running task (by sequence number)
}

/// The tasks of a workflow ordered by sequence number (then id).
WorkflowTask[] inSequence(const WorkflowTask[] tasks) @trusted {
  auto sorted = (cast(WorkflowTask[]) tasks).dup;
  sorted.sort!((a, b) => a.sequenceNumber != b.sequenceNumber ? a.sequenceNumber < b.sequenceNumber : a.id.value < b.id.value);
  return sorted;
}

/// Tasks a task waits for that are not done yet (unknown ids count as open).
string[] openDependencies(const WorkflowTask task, const WorkflowTask[] all) {
  string[] open;
  foreach (d; task.dependsOn) {
    auto dep = all.find!(t => t.id.value == d);
    if (dep.empty || !dep.front.status.isDone)
      open ~= d;
  }
  return open;
}

bool dependenciesMet(const WorkflowTask task, const WorkflowTask[] all) {
  return openDependencies(task, all).length == 0;
}

/// Pending tasks whose dependencies are done, in sequence.
WorkflowTask[] readyTasks(const WorkflowTask[] all) {
  return inSequence(all).filter!(t => t.status == TaskStatus.pending && dependenciesMet(t, all)).array;
}

/// True if the task could be started now (status and dependencies).
bool isReady(const WorkflowTask task, const WorkflowTask[] all) {
  return task.status == TaskStatus.pending && dependenciesMet(task, all);
}

WorkflowProgress progressOf(const WorkflowTask[] all) {
  WorkflowProgress p;
  p.total = cast(int) all.length;
  foreach (t; inSequence(all)) {
    final switch (t.status) {
    case TaskStatus.completed:
      p.completed++;
      break;
    case TaskStatus.skipped:
      p.skipped++;
      break;
    case TaskStatus.failed:
      p.failed++;
      break;
    case TaskStatus.inProgress:
      p.inProgress++;
      if (p.current.isNull)
        p.current = t.id;
      break;
    case TaskStatus.pending:
      p.pending++;
      if (dependenciesMet(t, all)) {
        p.ready++;
        if (p.current.isNull)
          p.current = t.id;
      }
      break;
    }
  }
  p.done = p.completed + p.skipped;
  p.percent = p.total == 0 ? 0 : cast(int)(p.done * 100 / p.total);
  return p;
}

///
unittest {
  WorkflowTask task(string id, int seq, TaskStatus s, string[] deps = null) {
    WorkflowTask t;
    t.id = WorkflowTaskId(id);
    t.sequenceNumber = seq;
    t.status = s;
    t.dependsOn = deps;
    return t;
  }

  auto tasks = [
    task("c", 30, TaskStatus.pending, ["a", "b"]), task("a", 10, TaskStatus.completed),
    task("b", 20, TaskStatus.pending, ["a"]), task("d", 40, TaskStatus.pending, ["x"])
  ];
  assert(readyTasks(tasks).map!(t => t.id.value).array == ["b"]);
  assert(openDependencies(tasks[0], tasks) == ["b"] && !dependenciesMet(tasks[3], tasks));
  auto p = progressOf(tasks);
  assert(p.total == 4 && p.done == 1 && p.ready == 1 && p.percent == 25 && p.current.value == "b");
  tasks[2].status = TaskStatus.skipped;
  assert(isReady(tasks[0], tasks) && progressOf(tasks).current.value == "c");
}
