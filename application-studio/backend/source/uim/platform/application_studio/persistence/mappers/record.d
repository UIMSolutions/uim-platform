/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.persistence.mappers.record;

import uim.platform.application_studio;

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

alias DevSpaceTypeMapper = RecordMapper!DevSpaceType;
alias ExtensionMapper = RecordMapper!Extension;
alias ProjectTemplateMapper = RecordMapper!ProjectTemplate;
alias DevSpaceMapper = RecordMapper!DevSpace;
alias ProjectMapper = RecordMapper!Project;
alias ServiceBindingMapper = RecordMapper!ServiceBinding;
alias RunConfigurationMapper = RecordMapper!RunConfiguration;
alias BuildConfigurationMapper = RecordMapper!BuildConfiguration;

///
unittest {
  mixin(ShowTest!("RecordMapper"));

  auto bc = BuildConfiguration(TenantId("t1"));
  bc.name = "mta";
  bc.deployTarget = DeployTarget.html5Repository;
  bc.history = [BuildRun("mta-1", BuildPhase.deploy, BuildStatus.deployed, 1, 2, "dist/x.zip", "ok")];
  auto record = BuildConfigurationMapper.toRecord(bc);
  assert(record["deployTarget"].get!string == "html5Repository");
  assert(record["history"][0]["phase"].get!string == "deploy");
  assert(record["createdAt"].type == Json.Type.int_);
  assert(BuildConfigurationMapper.fromRecord(record) == bc);

  auto ext = Extension(TenantId("t1"));
  ext.scope_ = ExtensionScope.thirdParty;
  ext.status = ExtensionStatus.deprecated_;
  auto er = ExtensionMapper.toRecord(ext);
  assert(er["scope"].get!string == "thirdParty" && er["status"].get!string == "deprecated" && er["version"].get!string == "1.0.0");
  assert(ExtensionMapper.fromRecord(er) == ext);

  auto rc = RunConfiguration(TenantId("t1"));
  rc.environment = [KeyValue("NODE_ENV", "development")];
  rc.mode = RunMode.debug_;
  assert(RunConfigurationMapper.fromRecord(RunConfigurationMapper.toRecord(rc)) == rc);
}
