module analytics.app.ports.export_port;

/// Outgoing port: export analytics artifacts to various formats.
interface ExportPort {
    /// Export artifact to PDF bytes.
    ubyte[] exportPdf(string artifactId, string artifactType);

    /// Export data to CSV string.
    string exportCsv(string datasetId, string[] columns);

    /// Export data to Excel bytes.
    ubyte[] exportExcel(string datasetId, string[] columns);
}
