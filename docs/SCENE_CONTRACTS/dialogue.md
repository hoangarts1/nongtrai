# Dialogue presentation — mockup12 (AUDIT-F15 / D101)

Screen reflows on its own resize and deferred body/choice minimum-size changes. Body height respects the current minimum before positioning at the bottom; this prevents a previous long/wide snapshot from leaving an oversized panel after resize/locale switch. Root below normal desktop size is checked at800×420. This is native layout, not extra test waits or weaker bounds.

F15 creates independent passive components only; existing NpcSystem/NpcPanel/Main are not wired untilF16. Use the current NPC avatar renderer, not a fabricated illustrated portrait. No new quest/reward/story/relationship or InputMap values.

| New scene/class | Root | Typed fields and requests |
|---|---|---|
| ui/dialogue/dialogue_screen.tscn / LifeDialogueScreen | Control | speaker:LifeDialogueSpeaker, body:LifeDialogueBody, choices:LifeDialogueChoices, close_button:Button; requested(id:StringName), closed(); display(snapshot:Dictionary)->void |
| dialogue_speaker.tscn / LifeDialogueSpeaker | VBoxContainer | portrait:LifeCharacterPortrait, name_label:Label; display(snapshot:Dictionary)->void |
| dialogue_body.tscn / LifeDialogueBody | PanelContainer (LifeHudFrame) | text:Label, details:Label, friendship:Label, scroll:ScrollContainer; display(snapshot:Dictionary)->void |
| dialogue_choices.tscn / LifeDialogueChoices | VBoxContainer | close_button:Button, revision:int; requested(id:StringName), closed(); display(actions:Array[Dictionary])->void; stable close button, direct action-button children named AcceptQuest/DeliverQuest/ConfirmOffer |

LifeDialogueSnapshot is a stateless VIEW RefCounted: static build(state:NpcSocialState,inventory:InventoryState,npc_id:StringName,day:int,season:StringName)->Dictionary. It reads actual dialogue/quest/offer/possession/friendship, preserves action IDs/enabled rules, never calls talk/accept/deliver/trade or stores callbacks. Result keys npc_id/name/color/body/details/friendship/friendship_max/quest_id/dialogue_id/actions are detached view values; strings are translated from actual Resource keys.

Composition: portrait/name left above the full-width bottom dialogue frame; real action choices right, stable native Close last. Body text/details scroll, friendship remains visible. Root reflows from its actual rectangle; all minimums and insets are UI geometry only. Existing Theme variations/portrait scene are reused; no local StyleBox/shared resource mutation. Native buttons and wheel/focus use GUI input. No numeric shortcut badges without real bindings. Choice revision/visibility/enabled guards reject stale/disabled requests but execute no domain command. Read-only display and requests must preserve all owners. Each scene has only a root/script in its file; runtime nodes/signals are constructed in code. No manual Inspector/scene steps.
