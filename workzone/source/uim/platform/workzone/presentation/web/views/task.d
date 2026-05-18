/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.views.task;

import uim.platform.workzone.presentation.web.models.task;
import uim.platform.workzone.presentation.web.views.layout;
import std.array : appender;
import std.conv  : to;

@safe:
/// Render the My Tasks inbox page.
string renderTaskList(TaskListViewModel vm) {
    auto buf = appender!string;

    if (vm.hasError) {
        buf ~= `<div class="alert alert-danger">` ~ escapeHtml(vm.errorMessage) ~ `</div>`;
    }

    buf ~= `
<div class="d-flex justify-content-between align-items-center mb-3">
  <h4 class="mb-0">My Tasks</h4>
  <div>
    <span class="badge bg-primary me-1">` ~ vm.openCount.to!string ~ ` open</span>`;
    if (vm.overdueCount > 0) {
        buf ~= `<span class="badge bg-danger">` ~ vm.overdueCount.to!string ~ ` overdue</span>`;
    }
    buf ~= `
  </div>
</div>
<div class="card shadow-sm">
  <div class="card-body p-0">
    <table class="table table-hover align-middle mb-0">
      <thead class="table-light">
        <tr>
          <th>Title</th><th>Priority</th><th>Status</th>
          <th>Source</th><th>Due</th><th></th>
        </tr>
      </thead>
      <tbody>`;

    if (vm.items.length == 0) {
        buf ~= `<tr><td colspan="6" class="text-center text-muted py-4">Your task inbox is empty.</td></tr>`;
    }
    foreach (t; vm.items) {
        immutable dueCss = t.isOverdue ? ` text-danger fw-bold` : ``;
        buf ~= `<tr>
          <td>
            <a href="` ~ escapeHtml(t.actionUrl.length > 0 ? t.actionUrl : "#") ~ `"
               target="_blank" class="text-decoration-none text-body">
              ` ~ escapeHtml(t.title) ~ `
            </a>
          </td>
          <td><span class="` ~ t.priorityCssClass ~ `">` ~ escapeHtml(t.priorityLabel) ~ `</span></td>
          <td><span class="badge ` ~ t.statusCssClass ~ `">` ~ escapeHtml(t.statusLabel) ~ `</span></td>
          <td><span class="text-muted small">` ~ escapeHtml(t.sourceApp) ~ `</span></td>
          <td class="` ~ dueCss ~ `">` ~ escapeHtml(t.dueDateFormatted) ~ (t.isOverdue ? ` &#x26A0;` : ``) ~ `</td>
          <td>
            <button class="btn btn-outline-success btn-sm"
                    onclick="completeTask('` ~ escapeHtml(t.id) ~ `')">&#10003;</button>
          </td>
        </tr>`;
    }

    buf ~= `
      </tbody>
    </table>
  </div>
</div>
<script>
function completeTask(id) {
  fetch("/api/v1/tasks/" + id, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "completed" })
  }).then(() => location.reload());
}
</script>`;

    return renderLayout("My Tasks", buf[], "tasks");
}
