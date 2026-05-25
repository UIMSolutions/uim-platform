module uim.platform.databricks.presentation.web;

/++
  Web presentation layer — MVC pattern with Diet templates (planned).

  Model      : JSON / serialized domain entities served to templates
  View       : Diet HTML templates (.dt files) under views/
  Controller : vibe.d WebInterface classes

  Planned routes:
    GET  /web/databricks/workspaces           — workspace dashboard
    GET  /web/databricks/workspaces/:id       — workspace detail
    GET  /web/databricks/clusters             — cluster list
    GET  /web/databricks/notebooks            — notebook browser
    GET  /web/databricks/notebooks/:id        — notebook viewer/editor
    GET  /web/databricks/jobs                 — job list
    GET  /web/databricks/jobs/:id/runs        — run history
    GET  /web/databricks/tables               — Unity Catalog browser
    GET  /web/databricks/dataproducts         — SAP BDC data product list
    GET  /web/databricks/experiments          — MLflow experiment list
    GET  /web/databricks/models               — model registry
    GET  /web/databricks/warehouses           — SQL warehouse list
+/
