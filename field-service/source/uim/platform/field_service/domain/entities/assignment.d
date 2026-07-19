/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.assignment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Assignment {
  mixin TenantEntity!AssignmentId;

  ActivityId activityId;
  TechnicianId technicianId;
  AssignmentStatus status = AssignmentStatus.proposed;
  string assignedDate;
  string acceptedDate;
  string startedDate;
  string completedDate;
  string travelDistance;
  string schedulingPolicy;
  string matchScore;
  string notes;

  Json toJson() const {
    return entityToJson
      .set("activityId", activityId)
      .set("technicianId", technicianId)
      .set("status", status.to!string)
      .set("assignedDate", assignedDate)
      .set("acceptedDate", acceptedDate)
      .set("startedDate", startedDate)
      .set("completedDate", completedDate)
      .set("travelDistance", travelDistance)
      .set("schedulingPolicy", schedulingPolicy)
      .set("matchScore", matchScore)
      .set("notes", notes);
  }
}
