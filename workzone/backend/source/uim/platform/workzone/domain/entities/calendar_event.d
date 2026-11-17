/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.calendar_event;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A calendar event of a workspace (meeting, webinar, all-day event).
struct CalendarEvent {
  mixin TenantEntity!EventId;

  WorkspaceId workspaceId;
  string workspaceName;
  string title;
  string description;
  string location;
  string meetingUrl;
  UserId organizerId;
  string organizerName;
  string[] attendeeIds;
  EventStatus status = EventStatus.scheduled;
  bool allDay;
  long startsAt;
  long endsAt;
  string timezone = "UTC";
  string recurrenceRule; /// iCal RRULE
}
