/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.adapters.stub_data_connector;

import uim.platform.analytics.app.ports.dataconnector;

/// Stub adapter: simulates data fetching for development / testing.
class StubDataConnector : DataConnector
{

  string[][string][] fetchData(string connectionString, string query)
  {
    // Return sample rows for demo purposes
    string[][string][] rows;
    rows ~= ["region": ["North"], "revenue": ["120000"], "quarter": ["Q1"]];
    rows ~= ["region": ["South"], "revenue": ["95000"], "quarter": ["Q1"]];
    rows ~= ["region": ["East"], "revenue": ["110000"], "quarter": ["Q2"]];
    rows ~= ["region": ["West"], "revenue": ["87000"], "quarter": ["Q2"]];
    return rows;
  }

  bool testConnection(string connectionString)
  {
    return connectionString.length > 0;
  }
}
