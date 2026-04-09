/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.schedules;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.schedule;
import uim.platform.job_scheduling.domain.ports.repositories.schedules;
import uim.platform.job_scheduling.domain.services.schedule_validator;
import uim.platform.job_scheduling.application.dto;

import uim.platform.service;
import std.conv : to;

alias Schedule = uim.platform.job_scheduling.domain.entities.schedule.Schedule;

class ManageSchedulesUseCase : UIMUseCase {
    private ScheduleRepository repo;

    this(ScheduleRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateScheduleRequest r) {
        if (r.jobid.isEmpty)
            return CommandResult(false, "", "Job ID is required");

        // Validate cron if provided
        if (r.cronExpression.length > 0 && !ScheduleValidator.isValidCron(r.cronExpression))
            return CommandResult(false, "", "Invalid cron expression");

        import std.uuid : randomUUID;
        auto id = randomUUID();

        Schedule s;
        s.id = id;
        s.jobId = r.jobId;
        s.tenantId = r.tenantId;
        s.description = r.description;
        s.type = parseScheduleType(r.type);
        s.format = parseScheduleFormat(r.format);
        s.status = r.active ? ScheduleStatus.active : ScheduleStatus.inactive;
        s.active = r.active;
        s.cronExpression = r.cronExpression;
        s.humanReadableSchedule = r.humanReadableSchedule;
        s.repeatInterval = r.repeatInterval;
        s.repeatAt = r.repeatAt;
        s.time = r.time;
        s.startTime = r.startTime;
        s.endTime = r.endTime;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        s.createdAt = now;
        s.modifiedAt = now;

        repo.save(s);
        return CommandResult(true, s.id, "");
    }

    Schedule get_(ScheduleId id, JobId jobtenantId, id tenantId) {
        return repo.findById(id, jobtenantId, id);
    }

    Schedule[] list(JobId jobtenantId, id tenantId) {
        return repo.findByJob(jobtenantId, id);
    }

    Schedule[] search(string query, TenantId tenantId) {
        return repo.search(query, tenantId);
    }

    CommandResult update(UpdateScheduleRequest r) {
        auto existing = repo.findById(r.scheduleId, r.jobId, r.tenantId);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Schedule not found");

        if (r.cronExpression.length > 0 && !ScheduleValidator.isValidCron(r.cronExpression))
            return CommandResult(false, "", "Invalid cron expression");

        if (r.description.length > 0)
            existing.description = r.description;
        existing.active = r.active;
        existing.status = r.active ? ScheduleStatus.active : ScheduleStatus.inactive;
        if (r.cronExpression.length > 0)
            existing.cronExpression = r.cronExpression;
        if (r.humanReadableSchedule.length > 0)
            existing.humanReadableSchedule = r.humanReadableSchedule;
        if (r.repeatInterval > 0)
            existing.repeatInterval = r.repeatInterval;
        if (r.repeatAt.length > 0)
            existing.repeatAt = r.repeatAt;
        if (r.time.length > 0)
            existing.time = r.time;
        existing.startTime = r.startTime;
        existing.endTime = r.endTime;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ScheduleId id, JobId jobtenantId, id tenantId) {
        auto existing = repo.findById(id, jobtenantId, id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Schedule not found");

        repo.remove(id, jobtenantId, id);
        return CommandResult(true, id.toString, "");
    }

    CommandResult removeAllByJob(JobId jobtenantId, id tenantId) {
        repo.removeAllByJob(jobtenantId, id);
        return CommandResult(true, jobId, "");
    }

    CommandResult activateAll(ActivateAllSchedulesRequest r) {
        auto schedules = repo.findByJob(r.jobId, r.tenantId);
        foreach (ref s; schedules) {
            s.active = r.active;
            s.status = r.active ? ScheduleStatus.active : ScheduleStatus.inactive;
            import core.time : MonoTime;
            s.modifiedAt = MonoTime.currTime.ticks;
            repo.update(s);
        }
        return CommandResult(true, r.jobId, "");
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
