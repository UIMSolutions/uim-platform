/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.ports.dataconnector;

@safe:
/// Outgoing port: abstracts fetching raw data from external sources.
interface DataConnector
{
  /// Retrieve rows from source; returns an array of associative-array rows.
  string[][string][] fetchData(string connectionString, string query);

  /// Test whether the connection is alive.
  bool testConnection(string connectionString);
}
