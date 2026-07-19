/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.types;

import uim.platform.hana;

mixin(ShowModule!());

@safe:
// ID aliases
struct DatabaseInstanceId  {
  mixin(IdTemplate);
}
struct DataLakeId  {
  mixin(IdTemplate);
}
struct SchemaId  {
  mixin(IdTemplate);
}
struct DatabaseUserId  {
  mixin(IdTemplate);
}
struct BackupId  {
  mixin(IdTemplate);
}
struct AlertId  {
  mixin(IdTemplate);
}
struct HDIContainerId  {
  mixin(IdTemplate);
}
struct ReplicationTaskId  {
  mixin(IdTemplate);
}
struct ConfigurationId  {
  mixin(IdTemplate);
}
struct DatabaseConnectionId  {
  mixin(IdTemplate);
}