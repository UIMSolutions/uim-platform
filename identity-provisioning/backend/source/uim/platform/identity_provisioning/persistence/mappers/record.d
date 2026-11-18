/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.persistence.mappers.record;

import uim.platform.identity_provisioning;

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

alias SourceSystemMapper = RecordMapper!SourceSystem;
alias TargetSystemMapper = RecordMapper!TargetSystem;
alias ProxySystemMapper = RecordMapper!ProxySystem;
alias TransformationMapper = RecordMapper!Transformation;
alias JobMapper = RecordMapper!ProvisioningJob;
alias LogMapper = RecordMapper!ProvisioningLog;
alias ProvisionedEntityMapper = RecordMapper!ProvisionedEntity;

///
unittest {
  mixin(ShowTest!("RecordMapper"));

  auto s = SourceSystem(TenantId("t1"));
  s.name = "HR";
  s.systemType = SystemType.successFactors;
  s.password = "secret";
  s.properties = [Attribute("sim.users", "3")];
  auto record = SourceSystemMapper.toRecord(s);
  assert(record["systemType"].get!string == "successFactors");
  assert(record["password"].get!string == "secret"); // records keep secrets, adapters mask them
  assert(record["properties"][0]["key"].get!string == "sim.users");
  assert(record["createdAt"].type == Json.Type.int_);
  assert(SourceSystemMapper.fromRecord(record) == s);

  auto t = Transformation(TenantId("t1"));
  t.name = "IAS";
  t.mappings = [AttributeMapping("mail", "emails[0].value", MappingFunction.lowerCase, "", true)];
  t.conditions = [EntityCondition("active", ConditionOperator.equals, "true")];
  auto back = TransformationMapper.fromRecord(TransformationMapper.toRecord(t));
  assert(back == t && back.mappings[0].mandatory);
  assert(TransformationMapper.toRecord(t)["mappings"][0]["function"].get!string == "lowerCase");

  // older snapshots ("sap_hr", missing fields) stay readable
  auto old = SourceSystemMapper.fromRecord(parseJsonString(`{"id": "s1", "tenantId": "t1", "systemType": "sap_hr"}`));
  assert(old.systemType == SystemType.sapHr && old.status == SystemStatus.configuring);
  auto log = LogMapper.fromRecord(parseJsonString(`{"id": "l1", "tenantId": "t1", "operation": "delete"}`));
  assert(log.operation == OperationType.delete_);
}
