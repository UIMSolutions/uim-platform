module uim.platform.analytics.app.ports.data_connector;

/// Outgoing port: abstracts fetching raw data from external sources.
interface DataConnector {
    /// Retrieve rows from source; returns an array of associative-array rows.
    string[][string][] fetchData(string connectionString, string query);

    /// Test whether the connection is alive.
    bool testConnection(string connectionString);
}
