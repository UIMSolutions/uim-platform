/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.values.types;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:

/// Strongly-typed identifier for a Dashboard aggregate root.
struct DashboardId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a Page within a Dashboard.
struct PageId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a Story aggregate root.
struct StoryId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a Section within a Story.
struct SectionId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a Widget aggregate root.
struct WidgetId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a DataSource aggregate root.
struct DataSourceId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a Dataset aggregate root.
struct DatasetId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a PlanningModel aggregate root.
struct PlanningModelId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a Prediction aggregate root.
struct PredictionId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

/// Strongly-typed identifier for a resource group (SAP BTP resource group concept).
struct ResourceGroupId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}
