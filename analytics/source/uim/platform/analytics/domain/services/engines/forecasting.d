/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.services.engines.forecasting;

// import std.math : exp, pow;

/// Domain service: simple time-series forecasting (exponential smoothing).
struct ForecastingEngine
{

  /// Simple exponential smoothing forecast.
  static double[] forecast(double[] historicalData, int periods, double alpha = 0.3)
  {
    if (historicalData.length == 0)
      return [];

    double[] result;
    result.length = periods;

    // Initialize level with first data point
    double level = historicalData[0];

    // Update level with all historical observations
    foreach (i; 1 .. historicalData.length)
      level = alpha * historicalData[i] + (1.0 - alpha) * level;

    // Project forward
    foreach (i; 0 .. periods)
      result[i] = level;

    return result;
  }

  /// Double exponential smoothing (Holt's method) for trend.
  static double[] forecastWithTrend(double[] data, int periods, double alpha = 0.3, double beta = 0.1)
  {
    if (data.length < 2)
      return forecast(data, periods, alpha);

    double level = data[0];
    double trend = data[1] - data[0];

    foreach (i; 1 .. data.length)
    {
      double newLevel = alpha * data[i] + (1.0 - alpha) * (level + trend);
      double newTrend = beta * (newLevel - level) + (1.0 - beta) * trend;
      level = newLevel;
      trend = newTrend;
    }

    double[] result;
    result.length = periods;
    foreach (i; 0 .. periods)
      result[i] = level + (i + 1) * trend;

    return result;
  }

  /// Moving average.
  static double[] movingAverage(double[] data, int window)
  {
    if (data.length < window)
      return [];

    double[] result;
    result.length = data.length - window + 1;

    double windowSum = 0;
    foreach (i; 0 .. window)
      windowSum += data[i];
    result[0] = windowSum / window;

    foreach (i; window .. data.length)
    {
      windowSum += data[i] - data[i - window];
      result[i - window + 1] = windowSum / window;
    }
    return result;
  }
}
