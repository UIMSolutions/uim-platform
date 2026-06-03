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
DataSourceType toDataSourceType(string type) {
  final map = [
    "database": DataSourceType.Database,
    "csv": DataSourceType.CSV,
    "excel": DataSourceType.Excel,
    "odata": DataSourceType.OData,
    "restapi": DataSourceType.RestAPI,
    "hana": DataSourceType.HANA,
    "s3": DataSourceType.S3,
    "googlesheets": DataSourceType.GoogleSheets,
    "liveconnection": DataSourceType.LiveConnection,
  ];
  return map.get(type.toLower, DataSourceType.Database);
}


enum DataSourceStatus {
  Connected,
  Disconnected,
  Error,
  Importing
}
DataSourceStatus toDataSourceStatus(string status) {
  final map = [
    "connected": DataSourceStatus.Connected,
    "disconnected": DataSourceStatus.Disconnected,
    "error": DataSourceStatus.Error,
    "importing": DataSourceStatus.Importing
  ];
  return map.get(status.toLower, DataSourceStatus.Disconnected);
}