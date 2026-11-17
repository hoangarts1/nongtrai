# ISO-9 morning bulletin (D46)

## Phase7.1b weather transaction (D86; no scene edits)

Main uses the existing WeatherState instance at actual GameClock day. On a legitimate next morning, reserve captured weather before outgoing-rain/farm callbacks; keep farm->animal->machine ordering, finish the weather day once, apply morning rain, reconcile ledger and then safe autosave/bulletin. Weather busy blocks save/load/new/title/sleep commands during callbacks; duplicate/skipped/stale signals do nothing. Saved3 forecasts remain exact through load/migration, newly needed tail uses DetRandom tag1. Save12 weather day must match saved clock; missing/corrupt weather is explicitly initialized at loaded day without replaying simulation. Existing typed events/views/modal tree/input/Inspector remain unchanged. Bulletin and tomorrow card only read forecast; no view rolls weather.

Manual: record today/three forecasts, sleep once through review, confirm new today equals saved first forecast; save/load and repeat through all three predictions. Compare water/coop/items/coins and ensure no duplicated care/eggs/bookkeeping, one morning bulletin, unchanged rain presentation. Continue/load alone must neither advance a day nor open bulletin. No editor setup required; full automated evidence/current acceptance in PROGRESS.

Owner approved “Duyệt, commit ISO-8b và triển khai ISO-9”. Existing Main gains morning_flow: LifeMorningFlow, constructed/configured before UiCoordinator. Existing scenes/core/domain/data/DayEndFlow/save format remain untouched. UiCoordinator registers morning_flow.panel with the same modal ownership/clock/input lock and day-end precedence; UiLayout supplies wide summary bounds. No new InputMap/autoload/Events signals.

Main queues current day at the end of its existing day_started handler, after care/simulation/weather/ledger and direct-morning save attempt. LifeMorningFlow waits for completed day-end guard/panel/sleep/other modal/title to clear before rendering/showing. DayEndFlow's synchronous final autosave finishes before the next process frame. View-only pending/last-shown ints deduplicate; stale older pending days are discarded. Reset on New Game/load/return-to-title. No automatic bulletin for initial tutorial/Continue/load and no saved dismissal flag.

| Scene / class | Root | Typed view API |
|---|---|---|
| morning_sheet / LifeMorningSheet | PanelContainer (LifeHudFrame) | title/date: Label; weather: LifeMorningWeather; garden: LifeMorningGarden; market: LifeMorningMarket; tasks: LifeMorningTasks; begin_button: Button; dismissed() |
| weather_column / LifeMorningWeather | VBoxContainer | display(weather: StringName, forecast: Array[StringName], day: int) -> void; existing LifeDayWeatherSymbol and actual three future slots |
| garden_column / LifeMorningGarden | VBoxContainer | display(snapshot: Dictionary) -> void; real onboarding progress/incomplete hints and farm counts in scroll |
| market_column / LifeMorningMarket | VBoxContainer | display(rows: Array[Dictionary]) -> void; scroll: ScrollContainer; rows_box: VBoxContainer; current produce prices only |
| price_row / LifeMorningPriceRow | HBoxContainer | display(id: StringName, name_key: StringName, price: int) -> void; item icon/name/unit-price Labels, no transaction |
| task_strip / LifeMorningTasks | PanelContainer | display(ready: int, water: int, empty: int) -> void; informational footer, no actions |

LifeMorningFlow.configure(main: Node), queue_day(day: int), dismiss(), reset(), refresh() -> void, panel: LifeMorningSheet. No simulation/roll/save/money/item mutations. MorningSnapshot.capture(main: Node) -> Dictionary builds a read-only value snapshot: day/day_in_season/year/season/weather/forecast, ready/water/empty/withered, incomplete quest keys/completed/total and sorted produce rows{id,name_key,price}. Uses FarmGridState.can_harvest/serialized coordinates and CropData.water_need Resource field; seasonal date is already one-based. No new gameplay numbers. MorningPresenter.render(panel: LifeMorningSheet, snapshot: Dictionary) -> void localizes actual state.

Begin Day/Escape closes presentation only; native Tab/Enter/Space and normal modal replacement retain world locks. Prior pause hold is restored by UiCoordinator. Price table matches ItemData sell_price used by ShippingBinPanel. Calendar/events and trends are explicitly unavailable, not invented. Header uses project valley name; reference05 is composition-only, never a texture.

Fixed masthead/footer/button surround three independently readable columns; garden/market scroll. Existing Theme/icons/weather symbols reused. vi/en/1152x648/1280x720/1920x1080 checks include rain/empty/ripe/wither/repeat states, old saves, completed quests and native scroll/input.

Manual: F5/start/continue, reach evening, sleep through day-end review; completed morning appears once. Compare crop/weather/ledger/coins/items before/after dismissal, double Begin/Escape, save/load/return-title resets and original forced-review behavior. No editor tree/Inspector/project changes needed.
