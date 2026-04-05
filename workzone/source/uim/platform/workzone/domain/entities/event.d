/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.event;

import uim.platform.workzone.domain.types;

/// A calendar event within a workspace.
struct Event {
  EventId id;
  WorkspaceId workspaceId;
  TenantId tenantId;
  string title;
  string description;
  string location;
  string meetingUrl;
  UserId organizerId;
  string organizerName;
  UserId[] attendeeIds;
  EventStatus status = EventStatus.scheduled;
  bool allDay;
  long startTime;
  long endTime;
  string timezone;
  string recurrenceRule; // iCal RRULE
  long createdAt;
  long updatedAt;
}
