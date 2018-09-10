enum FoodTruckStopState {
  // Stop is of course cancelled
  cancelled,
  // When the stop is happening today
  arriving_soon,
  // Stop is currently happening
  active,
  // Stop has passed already
  passed,
  // Stop is upcoming and is not today
  upcoming
}