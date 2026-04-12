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
  AssignmentId id;
  TenantId tenantId;
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
  string createdBy;
  string modifiedBy;
  string createdAt;
  string modifiedAt;

  Json toJson() {
    return Json.emptyObject
      .set("id", id)
      .set("tenantId", tenantId)
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
      .set("notes", notes)
      .set("createdBy", createdBy)
      .set("modifiedBy", modifiedBy)
      .set("createdAt", createdAt)
      .set("modifiedAt", modifiedAt);
  }
}
///
unittest {
  Assignment assignment = Assignment(
    id: AssignmentId("a1"),
    tenantId: TenantId("t1"),
    activityId: ActivityId("act1"),
    technicianId: TechnicianId("tech1"),
    status: AssignmentStatus.accepted,
    assignedDate: "2024-01-01T10:00:00Z",
    acceptedDate: "2024-01-01T11:00:00Z",
    startedDate: "2024-01-01T12:00:00Z",
    completedDate: "2024-01-01T13:00:00Z",
    travelDistance: "10km",
    schedulingPolicy: "policy1",
    matchScore: "0.9",
    notes: "This is a test assignment.",
    createdBy: "user1",
    modifiedBy: "user2",
    createdAt: "2024-01-01T09:00:00Z",
    modifiedAt: "2024-01-01T14:00:00Z"
  );

  assert(assignment.id == "a1");
  assert(assignment.tenantId == "t1");
  assert(assignment.activityId == "act1");
  assert(assignment.technicianId == "tech1");
  assert(assignment.status == AssignmentStatus.accepted);
  assert(assignment.assignedDate == "2024-01-01T10:00:00Z");
  assert(assignment.acceptedDate == "2024-01-01T11:00:00Z");
  assert(assignment.startedDate == "2024-01-01T12:00:00Z");
  assert(assignment.completedDate == "2024-01-01T13:00:00Z");
  assert(assignment.travelDistance == "10km");
  assert(assignment.schedulingPolicy == "policy1");
  assert(assignment.matchScore == "0.9");
  assert(assignment.notes == "This is a test assignment.");
  assert(assignment.createdBy == "user1");
  assert(assignment.modifiedBy == "user2");
  assert(assignment.createdAt == "2024-01-01T09:00:00Z");
  assert(assignment.modifiedAt == "2024-01-01T14:00:00Z");

  auto json = assignment.toJson();
  assert(json["id"] == "a1");
  assert(json["tenantId"] == "t1");
  assert(json["activityId"] == "act1");
  assert(json["technicianId"] == "tech1");
  assert(json["status"] == "accepted");
  assert(json["assignedDate"] == "2024-01-01T10:00:00Z");
  assert(json["acceptedDate"] == "2024-01-01T11:00:00Z");
  assert(json["startedDate"] == "2024-01-01T12:00:00Z");
  assert(json["completedDate"] == "2024-01-01T13:00:00Z");
  assert(json["travelDistance"] == "10km");
  assert(json["schedulingPolicy"] == "policy1");
  assert(json["matchScore"] == "0.9");
  assert(json["notes"] == "This is a test assignment.");
  assert(json["createdBy"] == "user1");
  assert(json["modifiedBy"] == "user2");
  assert(json["createdAt"] == "2024-01-01T09:00:00Z");
  assert(json["modifiedAt"] == "2024-01-01T14:00:00Z");
}
