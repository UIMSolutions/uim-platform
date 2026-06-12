module uim.platform.analytics.domain.enumerations.datasource;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:

enum DataSourceType {
  Database, // Used for relational databases like MySQL, PostgreSQL, SQL Server, etc.
  CSV, // Used for comma-separated values files, often imported from spreadsheets or exported from other systems
  Excel, // Used for Microsoft Excel files, which can contain multiple sheets and more complex data structures than CSV
  OData, // Used for OData services, which provide a standardized way to query and manipulate data over HTTP
  RestAPI, // Used for RESTful APIs, which can provide data in various formats (e.g., JSON, XML) and require custom handling for authentication and pagination
  HANA, // Used for SAP HANA databases, which have specific connection and query requirements
  S3, // Used for Amazon S3 storage, which can contain various file types and requires handling for authentication and data retrieval
  GoogleSheets, // Used for Google Sheets, which can be accessed via the Google Sheets API and require handling for authentication and data retrieval
  LiveConnection, // Used for live connections to data sources, which allow real-time querying and analysis without importing data into the analytics platform 
}
DataSourceType toDataSourceType(string type) {
  const map = [
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
  const map = [
    "connected": DataSourceStatus.Connected,
    "disconnected": DataSourceStatus.Disconnected,
    "error": DataSourceStatus.Error,
    "importing": DataSourceStatus.Importing
  ];
  return map.get(status.toLower, DataSourceStatus.Disconnected);
}