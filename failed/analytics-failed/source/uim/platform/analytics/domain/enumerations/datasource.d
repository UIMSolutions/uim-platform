/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.enumerations.datasource;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

enum DataSourceType {
  database, // Used for relational databases like MySQL, PostgreSQL, SQL Server, etc.
  csv, // Used for comma-separated values files, often imported from spreadsheets or exported from other systems
  excel, // Used for Microsoft Excel files, which can contain multiple sheets and more complex data structures than CSV
  odata, // Used for OData services, which provide a standardized way to query and manipulate data over HTTP
  restApi, // Used for RESTful APIs, which can provide data in various formats (e.g., JSON, XML) and require custom handling for authentication and pagination
  hana, // Used for SAP HANA databases, which have specific connection and query requirements
  s3, // Used for Amazon S3 storage, which can contain various file types and requires handling for authentication and data retrieval
  googlesheets, // Used for Google Sheets, which can be accessed via the Google Sheets API and require handling for authentication and data retrieval
  liveconnection, // Used for live connections to data sources, which allow real-time querying and analysis without importing data into the analytics platform 
}
DataSourceType toDataSourceType(string type) {
  mixin(EnumSwitch("DataSourceType", "database"));
}
DataSourceType[] toDataSourceTypes(string[] types) {
  return types.map!(toDataSourceType).array;
}
string toString(DataSourceType type) {
  return type.to!string;
}
string[] toStrings(DataSourceType[] types) {
  return types.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("DataSourceType"));

  assert(DataSourceType.database.toString == "database");
  assert(DataSourceType.csv.toString == "csv");
  assert(DataSourceType.excel.toString == "excel");
  assert(DataSourceType.odata.toString == "odata");
  assert(DataSourceType.restApi.toString == "restApi");
  assert(DataSourceType.hana.toString == "hana");
  assert(DataSourceType.s3.toString == "s3");
  assert(DataSourceType.googlesheets.toString == "googlesheets");
  assert(DataSourceType.liveconnection.toString == "liveconnection");

  assert("database".toDataSourceType == DataSourceType.database);
  assert("csv".toDataSourceType == DataSourceType.csv);
  assert("excel".toDataSourceType == DataSourceType.excel);
  assert("odata".toDataSourceType == DataSourceType.odata);
  assert("restApi".toDataSourceType == DataSourceType.restApi);
  assert("hana".toDataSourceType == DataSourceType.hana);
  assert("s3".toDataSourceType == DataSourceType.s3);
  assert("googlesheets".toDataSourceType == DataSourceType.googlesheets);
  assert("liveconnection".toDataSourceType == DataSourceType.liveconnection);

  assert(["database", "csv", "excel", "odata", "restApi", "hana", "s3", "googlesheets", "liveconnection"].toDataSourceTypes ==
         [DataSourceType.database, DataSourceType.csv, DataSourceType.excel, DataSourceType.odata, DataSourceType.restApi, DataSourceType.hana, DataSourceType.s3, DataSourceType.googlesheets, DataSourceType.liveconnection]);
  assert(toString([DataSourceType.database, DataSourceType.csv, DataSourceType.excel, DataSourceType.odata, DataSourceType.restApi, DataSourceType.hana, DataSourceType.s3, DataSourceType.googlesheets, DataSourceType.liveconnection]) ==
         ["database", "csv", "excel", "odata", "restApi", "hana", "s3", "googlesheets", "liveconnection"]);
}


enum DataSourceStatus {
  connected,
  disconnected,
  error,
  importing
}
DataSourceStatus toDataSourceStatus(string status) {
  mixin(EnumSwitch("DataSourceStatus", "disconnected"));
}
DataSourceStatus[] toDataSourceStatuses(string[] statuses) {
  return statuses.map!(toDataSourceStatus).array;
}
string toString(DataSourceStatus status) {
  return status.to!string;
}
string[] toStrings(DataSourceStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("DataSourceStatus"));

  assert(DataSourceStatus.connected.toString == "connected");
  assert(DataSourceStatus.disconnected.toString == "disconnected");
  assert(DataSourceStatus.error.toString == "error");
  assert(DataSourceStatus.importing.toString == "importing"); 

  assert("connected".toDataSourceStatus == DataSourceStatus.connected);
  assert("disconnected".toDataSourceStatus == DataSourceStatus.disconnected);
  assert("error".toDataSourceStatus == DataSourceStatus.error);
  assert("importing".toDataSourceStatus == DataSourceStatus.importing); 
  assert("unknown".toDataSourceStatus == DataSourceStatus.disconnected); // Default case
  assert("".toDataSourceStatus == DataSourceStatus.disconnected); // Default case 

  assert(["connected", "disconnected", "error", "importing"].toDataSourceStatuses ==
         [DataSourceStatus.connected, DataSourceStatus.disconnected, DataSourceStatus.error, DataSourceStatus.importing]);
  assert(toString([DataSourceStatus.connected, DataSourceStatus.disconnected, DataSourceStatus.error, DataSourceStatus.importing]) ==
         ["connected", "disconnected", "error", "importing"]);
}