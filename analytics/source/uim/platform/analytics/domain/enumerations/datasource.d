module uim.platform.analytics.domain.enumerations.datasource;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

enum DataSourceType {
  Database,
  CSV,
  Excel,
  OData,
  RestAPI,
  HANA,
  S3,
  GoogleSheets,
  LiveConnection,
}

enum DataSourceStatus {
  Connected,
  Disconnected,
  Error,
  Importing,
}