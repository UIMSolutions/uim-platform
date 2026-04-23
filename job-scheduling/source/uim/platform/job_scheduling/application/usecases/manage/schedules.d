/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.schedules;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.schedule;
// import uim.platform.job_scheduling.domain.ports.repositories.schedules;
// import uim.platform.job_scheduling.domain.services.schedule_validator;
// import uim.platform.job_scheduling.application.dto;

// import uim.platform.service;
// import std.conv : to;

// alias Schedule = uim.platform.job_scheduling.domain.entities.schedule.Schedule;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class ManageSchedulesUseCase { // TODO: UIMUseCase {
    private ScheduleRepository schedules;

    this(ScheduleRepository schedules) {
        this.schedules = schedules;
    }

    CommandResult create(CreateScheduleRequest request) {
        if (request.jobId.isEmpty)
            return CommandResult(false, "", "Job ID is required");

        // Validate cron if provided
        if (request.cronExpression.length > 0 && !ScheduleValidator.isValidCron(
                request.cronExpression))
            return CommandResult(false, "", "Invalid cron expression");

        Schedule schedule = Schedule.createFromRequest(request);
        schedules.save(schedule);
        return CommandResult(true, schedule.id.value, "");
    }

    Schedule getById(TenantId tenantId, ScheduleId id, JobId jobId) {
        return schedules.findById(id, jobId, tenantId);
    }

    Schedule[] list(TenantId tenantId, JobId jobId) {
        return schedules.findByJob(tenantId, jobId);
    }

    Schedule[] search(TenantId tenantId, string query) {
        return schedules.search(tenantId, query);
    }

    CommandResult update(UpdateScheduleRequest request) {
        auto existing = schedules.findById(request.tenantId, request.scheduleId, request.jobId);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Schedule not found");

        if (request.cronExpression.length > 0 && !ScheduleValidator.isValidCron(
                request.cronExpression))
            return CommandResult(false, "", "Invalid cron expression");

        if (request.description.length > 0)
            existing.description = request.description;
        existing.active = request.active;
        existing.status = request.active ? ScheduleStatus.active : ScheduleStatus.inactive;
        if (request.cronExpression.length > 0)
            existing.cronExpression = request.cronExpression;
        if (request.humanReadableSchedule.length > 0)
            existing.humanReadableSchedule = request.humanReadableSchedule;
        if (request.repeatInterval > 0)
            existing.repeatInterval = request.repeatInterval;
        if (request.repeatAt.length > 0)
            existing.repeatAt = request.repeatAt;
        if (request.time.length > 0)
            existing.time = request.time;
        existing.startTime = request.startTime;
        existing.endTime = request.endTime;

        import core.time : MonoTime;

        existing.modifiedAt = MonoTime.currTime.ticks;

        schedules.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult remove(TenantId tenantId, ScheduleId id, JobId jobId) {
        auto existing = schedules.findById(tenantId, id, jobId);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Schedule not found");

        schedules.remove(tenantId, id, jobId);
        return CommandResult(true, id.toString, "");
    }

    CommandResult removeAllByJob(TenantId tenantId, JobId jobId) {
        schedules.removeAllByJob(tenantId, jobId);
        return CommandResult(true, jobId, "");
    }

    CommandResult activateAll(ActivateAllSchedulesRequest request) {
        auto schedules = schedules.findByJob(request.tenantId, request.jobId);
        foreach (s; schedules) {
            s.active = request.active;
            s.status = request.active ? ScheduleStatus.active : ScheduleStatus.inactive;
            import core.time : MonoTime;

            s.modifiedAt = MonoTime.currTime.ticks;
            schedules.update(s);
        }
        return CommandResult(true, request.jobId, "");
    }

    private static ScheduleType parseScheduleType(string s) {
        switch (s) {
        case "recurring":
            return ScheduleType.recurring;
        default:
            return ScheduleType.oneTime;
        }
    }

    private static ScheduleFormat parseScheduleFormat(string s) {
        switch (s) {
        case "humanReadable":
            return ScheduleFormat.humanReadable;
        case "repeatInterval":
            return ScheduleFormat.repeatInterval;
        case "repeatAt":
            return ScheduleFormat.repeatAt;
        default:
            return ScheduleFormat.cron;
        }
    }
}
