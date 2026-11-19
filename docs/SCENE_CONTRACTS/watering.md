# Phase6.5h2b runtime watering contract (owner approved)

## Phase7.5h current Director modifier (D125)

Existing WateringRuntime applies fresh LifeDirectorWaterBridge terms before every actual manual command, then holds water/source receipt guard through can/farm callbacks and activity record. set_director_terms(terms)->bool,get_charge_cost()->int; old APIs stay. Default DATAcost1, active saved dust total2 only for actual active day without rain/current measured canopy exemption. Insufficient positive water fails before farm; existing well/stream/pond E remains immediate refill. Rain/bulk/day/debug never creates manual receipts or consumes extra can/stamina. No source/HUD/scene/input/Player edit yet; expanded cost text follows approved7.5j. Save14 preserves same can2field wire; modifier derived from Director owner only.

## D83 save-version independence
WateringRuntime.restore recognizes watering data from WATERING_INTRODUCED_VERSION10, independent of current savev11. Existing valid partial/empty40-tier stock survives v10; olderv1-v9 grant existing initial20 as before. No watering scene/price/source/input/state change.


No .tscn/InputMap binding/Player/CameraRig/source geometry/Theme/art edit. Existing ToolActionController still receives mouse stroke/Space/Inspector actions. Its new configure_watering(runtime:WateringRuntime) routes real manual water to one Main-owned can via runtime, while other ToolAction paths remain. Low-level ToolAction/FarmGridState/rain/day APIs retain their existing meaning.

Main adds watering_can:WateringCanState and WateringRuntime child; Runtime is an application adapter, never a second charge owner. configure(main:Node), water(cell:Vector2i)->Dictionary, can_refill()->Dictionary, refill()->Dictionary, reset()/restore(payload:Dictionary)/refresh()->void. Local typed water_changed(charges:int,capacity:int) updates HUD/dirty tracking after completed commands. busy protects water debit/refund and Main lifecycle batches. During reset/restore, notify only after the whole owner batch is consistent. Existing Main entry guards include this busy state.

GrayBoxWorld.configure_water_refill(query:Callable,request:Callable) delegates source query/command. Only selected water tool, unlocked gameplay, actual dry bank in shared source data qualifies. Existing E/interact is consumed by refill there (including honest full-can feedback); other tool contexts retain old bin/shop/bed/NPC behavior. No mouse-water-on-source special command, new key or signal bus. NPC/GUI/E-tab routing keeps existing precedence.

Generated HUD subtree (only documented internal caption composition changes):

```text
HotbarPanel/Toolbar (LifeHudToolbar; existing public caption/buttons/APIs)
  StatusRow (HBoxContainer; centered, same caption-row height)
    CaptionPanel (existing caption panel / caption reference retained)
    WaterMeter (LifeHudWaterMeter; pointer ignore, Theme caption style)
      Row (HBoxContainer)
        Icon (existing watering_can icon)
        Amount (Label; localized actual charges/capacity)
  existing frame / eight slots
```

LifeHudWaterMeter.display(charges:int,capacity:int) is read-only presentation; presenter refreshes on actual Runtime change and live locale, no UI owner. Existing HUD rectangle/right cards/layout/slot ordering/selection/hidden adapters remain. Verify vi/en800/1152/1600, GUI/Shift-wheel/normal map zoom, pause/title/modal and all source banks. Refill dry cells are well(7,9), stream(-14,6), pond(15,9), using actual Player/grid conversion.

Save schema10 adds watering_can:{capacity,charges}. Old formats1..9 get data-owned full base via explicit migration; malformedcurrent format restores conservatively through state codec. New game resets full base; load/Continue/overnight/rain keep actual saved amount. No saved Node/source/UI/busy flag, purchase UI or overnight refill. Tests run in isolated user://, real player saves remain read-only.

## Phase6.5h3 upgrade integration (D79)

Main configures existing WateringCanUpgradeService with actual can/wallet and Resource20/40/200. Separate transient WateringUpgradeFlow joins shared busy guard; existing Runtime/Service/source geometry/manual commands remain byte-identical. Post-command Runtime.refresh updates HUD/dirty after actual can changes, including independent changes during rejected grant. Capacity40 preserves charges; source refill still authorizes actual dry bank/current context. Savev10 unchanged. See watering_upgrade.md.
