/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.values.chart_type;

/// Supported visualization / chart types (mirrors SAC widget library).
enum ChartType
{
  Bar,
  Column,
  Line,
  Area,
  Pie,
  Donut,
  Scatter,
  Bubble,
  Heatmap,
  Treemap,
  Waterfall,
  Gauge,
  KPI,
  Table,
  CrossTab,
  GeoMap,
  Sankey,
  BoxPlot,
  Histogram,
  Combo,
}
