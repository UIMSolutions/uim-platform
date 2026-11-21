/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Execution schedules (AI API /lm/executionSchedules).
module uim.platform.ai_core.application.usecases.manage.schedules;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageSchedulesUseCase : AiCoreInteractor, IManageSchedules {
  protected ManageExecutionsUseCase executions;

  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy, ManageExecutionsUseCase executions) {
    super(repos, clock, events, policy);
    this.executions = executions;
  }

  ExecutionSchedule createSchedule(CreateScheduleRequest r) {
    auto t = r.tenantId, rg = r.resourceGroupId;
    groupOf(t, rg);
    auto c = configurationOf(t, rg, ConfigurationId(r.configurationId.strip));
    if (executableOf(t, rg, c.executableId).deployable)
      throw AiCoreException.ruleViolation("Only workflow configurations can be scheduled");
    auto id = idOrNew(r.id);
    if (repos.schedules.existsById(t, rg, ScheduleId(id)))
      throw AiCoreException.conflict("Execution schedule '" ~ id ~ "' already exists");
    ExecutionSchedule s;
    stampCreated!(ExecutionSchedule, ScheduleId)(s, t, r.actor, id, now);
    s.resourceGroupId = rg;
    s.configurationId = c.id;
    s.name = r.name.strip.length > 0 ? r.name.strip : id;
    s.cron = CronExpression.parse(r.cron).text;
    s.status = parseDomainEnumOr!ScheduleStatus(r.status, ScheduleStatus.active, "schedule status");
    s.startTime = r.startTime;
    s.endTime = r.endTime;
    s.validate();
    planSchedule(s, now);
    repos.schedules.save(s);
    emit("schedule.created", t, resourceKey(rg.value, id), Json(["cron": Json(s.cron)]));
    return s;
  }

  ExecutionSchedule updateSchedule(UpdateScheduleRequest r) {
    auto s = getSchedule(r.tenantId, r.resourceGroupId, ScheduleId(r.id));
    r.name.applyTo(s.name);
    if (r.cron.isSet)
      s.cron = CronExpression.parse(r.cron.value).text;
    if (r.status.isSet)
      s.status = parseDomainEnum!ScheduleStatus(r.status.value, "schedule status");
    r.startTime.applyTo(s.startTime);
    r.endTime.applyTo(s.endTime);
    s.validate();
    planSchedule(s, now);
    stampUpdated(s, r.actor, now);
    repos.schedules.save(s);
    return s;
  }

  ExecutionSchedule getSchedule(TenantId t, ResourceGroupId rg, ScheduleId id) {
    return required(repos.schedules.findById(t, rg, id), "Execution schedule '" ~ id.value ~ "'");
  }

  ExecutionSchedule[] listSchedules(TenantId t, ResourceGroupId rg, ConfigurationId configuration = ConfigurationId.init) {
    auto all = repos.schedules.findByGroup(t, rg);
    return configuration.isNull ? all : all.filter!(s => s.configurationId == configuration).array;
  }

  void deleteSchedule(TenantId t, ResourceGroupId rg, ScheduleId id) {
    getSchedule(t, rg, id);
    repos.schedules.removeById(t, rg, id);
    emit("schedule.deleted", t, resourceKey(rg.value, id.value));
  }

  Execution triggerSchedule(TenantId t, ResourceGroupId rg, ScheduleId id, UserId actor) {
    auto s = getSchedule(t, rg, id);
    return fire(s, actor);
  }

  /// Start an execution for the schedule and record the run.
  Execution fire(ref ExecutionSchedule s, UserId actor) {
    auto c = configurationOf(s.tenantId, s.resourceGroupId, s.configurationId);
    auto e = executions.submit(s.tenantId, s.resourceGroupId, c, actor, s.id);
    recordScheduleRun(s, e.id, now);
    stampUpdated(s, actor, now);
    repos.schedules.save(s);
    emit("schedule.fired", s.tenantId, resourceKey(s.resourceGroupId.value, s.id.value), Json(["executionId": Json(e.id.value)]));
    return e;
  }
}
