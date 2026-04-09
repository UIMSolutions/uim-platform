/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.events;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.event;
import uim.platform.workzone.domain.ports.repositories.events;
import uim.platform.workzone.application.dto;

class ManageEventsUseCase : UIMUseCase {
  private EventRepository repo;

  this(EventRepository repo) {
    this.repo = repo;
  }

  CommandResult createEvent(CreateEventRequest req) {
    if (req.title.length == 0)
      return CommandResult("", "Event title is required");

    auto now = Clock.currStdTime();
    auto e = Event();
    e.id = randomUUID();
    e.workspaceId = req.workspaceId;
    e.tenantId = req.tenantId;
    e.title = req.title;
    e.description = req.description;
    e.location = req.location;
    e.meetingUrl = req.meetingUrl;
    e.organizerId = req.organizerId;
    e.organizerName = req.organizerName;
    e.attendeeIds = req.attendeeIds;
    e.status = EventStatus.scheduled;
    e.allDay = req.allDay;
    e.startTime = req.startTime;
    e.endTime = req.endTime;
    e.timezone = req.timezone;
    e.recurrenceRule = req.recurrenceRule;
    e.createdAt = now;
    e.updatedAt = now;

    repo.save(e);
    return CommandResult(e.id, "");
  }

  Event* getEvent(EventId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Event[] listByWorkspace(WorkspaceId workspacetenantId, id tenantId) {
    return repo.findByWorkspace(workspacetenantId, id);
  }

  CommandResult updateEvent(UpdateEventRequest req) {
    auto e = repo.findById(req.id, req.tenantId);
    if (e is null)
      return CommandResult("", "Event not found");

    if (req.title.length > 0)
      e.title = req.title;
    if (req.description.length > 0)
      e.description = req.description;
    e.location = req.location;
    e.meetingUrl = req.meetingUrl;
    e.startTime = req.startTime;
    e.endTime = req.endTime;
    e.status = req.status;
    e.updatedAt = Clock.currStdTime();

    repo.update(*e);
    return CommandResult(e.id, "");
  }

  CommandResult deleteEvent(EventId tenantId, id tenantId) {
    auto e = repo.findById(tenantId, id);
    if (e is null)
      return CommandResult("", "Event not found");

    repo.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
