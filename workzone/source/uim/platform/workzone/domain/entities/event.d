/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.event;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A calendar event within a workspace.
struct Event {
  mixin TenantEntity!(EventId);

  WorkspaceId workspaceId;
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
  
  Json toJson() const {
    return entityToJson
      .set("workspaceId", workspaceId.value)
      .set("title", title)
      .set("description", description)
      .set("location", location)
      .set("meetingUrl", meetingUrl)
      .set("organizerId", organizerId.value)
      .set("organizerName", organizerName)
      .set("attendeeIds", attendeeIds.map!(id => id.value).array)
      .set("status", status.toString())
      .set("allDay", allDay)
      .set("startTime", startTime)
      .set("endTime", endTime)
      .set("timezone", timezone)
      .set("recurrenceRule", recurrenceRule);
  }
}
