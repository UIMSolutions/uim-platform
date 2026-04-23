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
    private ScheduleRepository repo;

    this(ScheduleRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateScheduleRequest request) {
        if (request.jobId.isEmpty)
            return CommandResult(false, "", "Job ID is required");

        // Validate cron if provided
        if (request.cronExpression.length > 0 && !ScheduleValidator.isValidCron(request.cronExpression))
            return CommandResult(false, "", "Invalid cron expression");

        import std.uuid : randomUUID;
        auto id = randomUUID();

        Schedule s;
        s.id = id;
        s.jobId = request.jobId;
        s.tenantId = request.tenantId;
        s.description = request.description;
        s.type = parseScheduleType(request.type);
        s.format = parseScheduleFormat(request.format);
        s.status = request.active ? ScheduleStatus.active : ScheduleStatus.inactive;
        s.active = request.active;
        s.cronExpression = request.cronExpression;
        s.humanReadableSchedule = request.humanReadableSchedule;
        s.repeatInterval = request.repeatInterval;
        s.repeatAt = request.repeatAt;
        s.time = request.time;
        s.startTime = request.startTime;
        s.endTime = request.endTime;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        s.createdAt = now;
        s.modifiedAt = now;

        repo.save(s);
        return CommandResult(true, s.id, "");
    }

    Schedule getById(TenantId tenantId, ScheduleId id, JobId jobId) {
        return repo.findById(id, jobId, tenantId);
    }

    Schedule[] list(TenantId tenantId, JobId jobId) {
        return repo.findByJob(jobId, tenantId);
    }

    Schedule[] search(TenantId tenantId, string query) {
        return repo.search(query, tenantId);
    }

    CommandResult update(UpdateScheduleRequest request) {
        auto existing = repo.findById(request.scheduleId, request.jobId, request.tenantId);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Schedule not found");

        if (request.cronExpression.length > 0 && !ScheduleValidator.isValidCron(request.cronExpression))
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

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ScheduleId id, JobId jobId, TenantId tenantId) {
        auto existing = repo.findById(id, jobId, tenantId);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Schedule not found");

        repo.remove(id, jobId, tenantId);
        return CommandResult(true, id.toString, "");
    }

    CommandResult removeAllByJob(TenantId tenantId, JobId jobId) {
        repo.removeAllByJob(jobId, tenantId);
        return CommandResult(true, jobId, "");
    }

    CommandResult activateAll(ActivateAllSchedulesRequest request) {
        auto schedules = repo.findByJob(request.jobId, request.tenantId);
        foreach (s; schedules) {
            s.active = request.active;
            s.status = request.active ? ScheduleStatus.active : ScheduleStatus.inactive;
            import core.time : MonoTime;
            s.modifiedAt = MonoTime.currTime.ticks;
            repo.update(s);
        }
        return CommandResult(true, request.jobId, "");
    }

    private static ScheduleType parseScheduleType(string s) {
        switch (s) {
            case "recurring": return ScheduleType.recurring;
            default: return ScheduleType.oneTime;
        }
    }

    private static ScheduleFormat parseScheduleFormat(string s) {
        switch (s) {
            case "humanReadable": return ScheduleFormat.humanReadable;
            case "repeatInterval": return ScheduleFormat.repeatInterval;
            case "repeatAt": return ScheduleFormat.repeatAt;
            default: return ScheduleFormat.cron;
        }
    }
}
