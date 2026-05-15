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


// alias Schedule = uim.platform.job_scheduling.domain.entities.schedule.Schedule;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class ManageSchedulesUseCase { // TODO: UIMUseCase {
    private ScheduleRepository schedules;

    this(ScheduleRepository schedules) {
        this.schedules = schedules;
    }

    CommandResult createSchedule(CreateScheduleRequest request) {
        if (request.jobId.isEmpty)
            return CommandResult(false, "", "Job ID is required");

        // Validate cron if provided
        if (request.cronExpression.length > 0 && !ScheduleValidator.isValidCron(
                request.cronExpression))
            return CommandResult(false, "", "Invalid cron expression");

        Schedule schedule;
        schedule.initEntity(request.tenantId);

        schedule.jobId = request.jobId;
        schedule.description = request.description;
        schedule.type = request.type.to!ScheduleType;
        schedule.format = request.format.to!ScheduleFormat;
        schedule.status = request.active ? JobScheduleStatus.active : JobScheduleStatus.inactive;
        schedule.active = request.active;
        schedule.cronExpression = request.cronExpression;
        schedule.humanReadableSchedule = request.humanReadableSchedule;
        schedule.repeatInterval = request.repeatInterval;
        schedule.repeatAt = request.repeatAt;
        schedule.time = request.time;
        schedule.startTime = request.startTime;
        schedule.endTime = request.endTime;

        schedules.save(schedule);
        return CommandResult(true, schedule.id.value, "");
    }

    Schedule getSchedule(TenantId tenantId, ScheduleId id) {
        return schedules.findById(tenantId, id);
    }

    Schedule[] listSchedules(TenantId tenantId, JobId jobId) {
        return schedules.findByJob(tenantId, jobId);
    }

    Schedule[] searchSchedules(TenantId tenantId, string query) {
        return schedules.search(tenantId, query);
    }

    CommandResult updateSchedule(UpdateScheduleRequest request) {
        auto existing = schedules.findById(request.tenantId, request.scheduleId);
        if (existing.isNull)
            return CommandResult(false, "", "Schedule not found");

        if (request.cronExpression.length > 0 && !ScheduleValidator.isValidCron(
                request.cronExpression))
            return CommandResult(false, "", "Invalid cron expression");

        if (request.description.length > 0)
            existing.description = request.description;
        existing.active = request.active;
        existing.status = request.active ? JobScheduleStatus.active : JobScheduleStatus.inactive;
        if (request.cronExpression.length > 0)
            existing.cronExpression = request.cronExpression;
        if (request.humanReadableSchedule.length > 0)
            existing.humanReadableSchedule = request.humanReadableSchedule;
        if (request.repeatInterval > 0)
            existing.repeatInterval = request.repeatInterval;
        if (request.repeatAt > 0)
            existing.repeatAt = request.repeatAt;
        if (request.time.length > 0)
            existing.time = request.time;
        existing.startTime = request.startTime;
        existing.endTime = request.endTime;

        import core.time : MonoTime;

        existing.updatedAt = MonoTime.currTime.ticks;

        schedules.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSchedule(TenantId tenantId, ScheduleId id) {
        auto existing = schedules.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Schedule not found");

        schedules.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteAllSchedules(TenantId tenantId, JobId jobId) {
        auto findings = schedules.findByJob(tenantId, jobId);
        if (findings.length == 0)
            return CommandResult(false, jobId.value, "No schedules found for the job");
        
        findings.each!(s => schedules.remove(s));
        return CommandResult(true, jobId.value, "");
    }

    CommandResult activateAllSchedules(ActivateAllSchedulesRequest request) {
        auto findings = schedules.findByJob(request.tenantId, request.jobId);
        foreach (s; findings) {
            s.active = request.active;
            s.status = request.active ? JobScheduleStatus.active : JobScheduleStatus.inactive;
            import core.time : MonoTime;

            s.updatedAt = MonoTime.currTime.ticks;
            schedules.update(s);
        }
        return CommandResult(true, request.jobId.value, "");
    }

}
