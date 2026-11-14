/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A demo scenario for an empty tenant: three providers, four definitions,
/// tasks in several states, a substitution, a saved filter, comments and an
/// attachment. Goes through the driving ports, so every business rule applies.
module uim.platform.task_center.application.services.demo_data;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct DemoDataResult {
  size_t providers;
  size_t definitions;
  size_t tasks;
  size_t actions;
  size_t comments;
  size_t attachments;
  size_t substitutions;
  size_t filters;
}

DemoDataResult seedDemoData(TaskCenterPorts ports, TenantId tenantId, UserId actor) {
  if (ports.tasks.listTasks(tenantId).length > 0 || ports.providers.listTaskProviders(tenantId).length > 0)
    throw TaskCenterException.conflict("Tenant '" ~ tenantId.value ~ "' is not empty; demo data needs an empty tenant");

  DemoDataResult r;
  auto today = todayIso();

  // ── providers ───────────────────────────────────────────────────────────
  void provider(string id, string name, string type, string status, string endpoint, string description) {
    CreateTaskProviderRequest p;
    p.tenantId = tenantId;
    p.actor = actor;
    p.id = id;
    p.name = name;
    p.providerType = type;
    p.status = status;
    p.endpointUrl = endpoint;
    p.description = description;
    ports.providers.createTaskProvider(p);
    r.providers++;
  }

  provider("s4hana-procurement", "S/4HANA Procurement", "s4hana", "active",
    "https://s4hana.example.com/sap/opu/odata4/sap/api_workflow/tasks", "Purchase requisitions and orders");
  provider("successfactors-hr", "SuccessFactors HR", "successFactors", "active",
    "https://api.successfactors.example.com/odata/v2/Todo", "Leave requests and onboarding");
  provider("concur-expenses", "Concur Expenses", "concur", "inactive", "", "Expense reports (not yet connected)");

  // ── definitions ─────────────────────────────────────────────────────────
  void definition(string id, string provider, string name, string category, string priority, string[] actions,
    int dueInDays, bool requiresClaim) {
    CreateTaskDefinitionRequest d;
    d.tenantId = tenantId;
    d.actor = actor;
    d.id = id;
    d.providerId = provider;
    d.name = name;
    d.category = category;
    d.defaultPriority = priority;
    d.allowedActions = actions;
    d.dueInDays = dueInDays;
    d.requiresClaim = requiresClaim;
    ports.definitions.createTaskDefinition(d);
    r.definitions++;
  }

  definition("po-approval", "s4hana-procurement", "Purchase Order Approval", "approval", "high",
    ["approve", "reject", "escalate", "cancel"], 3, true);
  definition("leave-request", "successfactors-hr", "Leave Request", "approval", "medium", ["approve", "reject"], 5, false);
  definition("expense-review", "concur-expenses", "Expense Report Review", "review", "medium", null, 7, false);
  definition("onboarding", "successfactors-hr", "Onboarding Checklist", "toDoItem", "low", ["complete", "cancel"], 10, false);

  // ── substitution: dora is on leave, ben takes over (auto-forward) ───────
  CreateSubstitutionRuleRequest sub;
  sub.tenantId = tenantId;
  sub.actor = actor;
  sub.privileged = true;
  sub.id = "dora-to-ben";
  sub.userId = "dora";
  sub.substituteId = "ben";
  sub.startDate = addDays(today, -2);
  sub.endDate = addDays(today, 12);
  sub.isAutoForward = true;
  ports.substitutions.createSubstitutionRule(sub);
  r.substitutions++;

  sub.id = "anna-to-carl";
  sub.userId = "anna";
  sub.substituteId = "carl";
  sub.startDate = addDays(today, 30);
  sub.endDate = addDays(today, 44);
  sub.isAutoForward = false;
  ports.substitutions.createSubstitutionRule(sub);
  r.substitutions++;

  // ── tasks ───────────────────────────────────────────────────────────────
  void task(string id, string definition, string provider, string external, string title, string assignee,
    string priority = "", string due = "", string attributes = "") {
    CreateTaskRequest t;
    t.tenantId = tenantId;
    t.actor = actor;
    t.id = id;
    t.definitionId = definition;
    t.providerId = provider;
    t.externalTaskId = external;
    t.title = title;
    t.assignee = assignee;
    t.priority = priority;
    t.dueDate = due;
    t.customAttributes = attributes;
    t.description = "Demo task: " ~ title;
    ports.tasks.createTask(t);
    r.tasks++;
  }

  task("po-4711", "po-approval", "s4hana-procurement", "PO-4500004711", "Approve purchase order 4500004711 (12,400 EUR)",
    "anna", "", "", `{"supplier": "ACME Industrial", "amount": "12400.00", "currency": "EUR"}`);
  task("po-4712", "po-approval", "s4hana-procurement", "PO-4500004712", "Approve purchase order 4500004712 (980 EUR)",
    "anna", "medium", addDays(today, -1), `{"supplier": "Office Supplies Ltd", "amount": "980.00", "currency": "EUR"}`);
  task("po-4713", "po-approval", "s4hana-procurement", "PO-4500004713", "Approve purchase order 4500004713 (55,000 EUR)",
    "dora", "veryHigh");
  task("leave-ben", "leave-request", "successfactors-hr", "LR-2026-118", "Leave request Ben Becker, 5 days", "carl");
  task("leave-carl", "leave-request", "successfactors-hr", "LR-2026-121", "Leave request Carl Clark, 2 days", "anna");
  task("onboard-erin", "onboarding", "successfactors-hr", "ON-77", "Prepare onboarding for Erin Evans", "ben");
  task("quarterly-review", "", "", "", "Review quarterly vendor ratings", "", "low", addDays(today, 14));

  // ── processing ──────────────────────────────────────────────────────────
  void act(string taskId, string action, string user, string comment = "", string forwardTo = "") {
    PerformTaskActionRequest a;
    a.tenantId = tenantId;
    a.actor = UserId(user);
    a.taskId = TaskId(taskId);
    a.action = action;
    a.comment = comment;
    a.forwardTo = forwardTo;
    ports.processing.perform(a);
    r.actions++;
    if (comment.length > 0)
      r.comments++;
  }

  act("po-4711", "claim", "anna");
  act("leave-carl", "approve", "anna", "Enjoy your days off!");
  act("onboard-erin", "forward", "ben", "Dora coordinates IT onboarding", "carl");
  act("po-4712", "escalate", "anna");

  CreateTaskCommentRequest c;
  c.tenantId = tenantId;
  c.actor = UserId("anna");
  c.taskId = "po-4711";
  c.content = "Checking the delivery terms with the supplier before approving.";
  ports.comments.createTaskComment(c);
  r.comments++;

  CreateTaskAttachmentRequest at;
  at.tenantId = tenantId;
  at.actor = UserId("anna");
  at.taskId = "po-4711";
  at.fileName = "quotation-acme.pdf";
  at.fileSize = 184_320;
  at.mimeType = "application/pdf";
  at.url = "https://documents.example.com/po/4500004711/quotation-acme.pdf";
  ports.attachments.createTaskAttachment(at);
  r.attachments++;

  // ── saved filter ────────────────────────────────────────────────────────
  CreateUserTaskFilterRequest f;
  f.tenantId = tenantId;
  f.actor = UserId("anna");
  f.id = "anna-urgent";
  f.name = "My urgent approvals";
  f.criteria = "assignee=$me,priority=high,priority=veryHigh,status=open,status=inProgress";
  f.isDefault = true;
  ports.filters.createUserTaskFilter(f);
  r.filters++;
  return r;
}
