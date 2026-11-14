/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.persistence.mappers.record;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Generic mapper between entities and database records, driven by
/// compile-time reflection (see helpers.codec). Records keep timestamps as raw
/// std-time numbers and enums by name; unknown or missing fields fall back to
/// the entity defaults, so older snapshots stay readable.
struct RecordMapper(TEntity) {
  static Json toRecord(const TEntity entity) {
    return encode(entity, false);
  }

  static TEntity fromRecord(Json record) {
    return decode!TEntity(record);
  }
}

alias SystemInstanceMapper = RecordMapper!SystemInstance;
alias SoftwareComponentMapper = RecordMapper!SoftwareComponent;
alias CommunicationArrangementMapper = RecordMapper!CommunicationArrangement;
alias ServiceBindingMapper = RecordMapper!ServiceBinding;
alias BusinessUserMapper = RecordMapper!BusinessUser;
alias BusinessRoleMapper = RecordMapper!BusinessRole;
alias TransportRequestMapper = RecordMapper!TransportRequest;
alias ApplicationJobMapper = RecordMapper!ApplicationJob;

///
unittest {
  mixin(ShowTest!("RecordMapper"));

  auto t = TransportRequest(TenantId("t1"));
  t.name = "H01K900001";
  t.transportType = TransportType.customizing;
  t.tasks = [TransportTask("H01K900001-01", "DEV", "Travel", TransportStatus.released, ["R3TR CLAS ZCL_TRAVEL"], 1, 2)];
  auto record = TransportRequestMapper.toRecord(t);
  assert(record["transportType"].get!string == "customizing");
  assert(record["tasks"][0]["status"].get!string == "released");
  assert(record["createdAt"].type == Json.Type.int_);
  assert(TransportRequestMapper.fromRecord(record) == t);

  auto job = ApplicationJob(TenantId("t1"));
  job.parameters = [KeyValue("days", "30")];
  job.frequency = JobFrequency.daily;
  assert(ApplicationJobMapper.fromRecord(ApplicationJobMapper.toRecord(job)) == job);
}
