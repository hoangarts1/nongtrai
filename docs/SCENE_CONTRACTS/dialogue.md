# Dialogue presentation — mockup12 (AUDIT-F15 / D101)

## F16 runtime adapter (D102)

NpcPanel.enable_dialogue(main:Node,system:NpcSystem) creates dialogue_screen:LifeDialogueScreen and dialogue_controller:LifeDialogueController for the dialogue instance only. show_dialogue(snapshot)->void hides the retained legacy margin, displays the new screen and maps existing column/title_label/close_button to actual choices/speaker name/stable Close. show_content still activates retained legacy fields for standalone callers. Journal/book remains its separate unchanged branch. Root stays Main/NpcDialogue; no existing .tscn edits.

LifeDialogueController.configure(main,system,panel), displayed(snapshot), request(id:StringName)->bool,is_busy()->bool,queue_render(_slots:Array[Dictionary]=[])->void are VIEW-only. A request rechecks the active visible NPC context and a fresh snapshot against displayed npc/dialogue/quest IDs, requires the fresh enabled action, rejects reentry, then asks NpcSystem to run existing handlers. True means dispatched, not a fabricated transaction success. Domain services retain all transaction results/ownership. Hidden/lifecycle changes reset the displayed identity; deferred inventory/locale refreshes are coalesced and context-checked. UI close/shortcuts are blocked during the synchronous dispatch. No raw numeric shortcuts.

NpcSystem adds get_dialogue_snapshot()->Dictionary,refresh_dialogue()->void,is_dialogue_context_valid()->bool,is_dialogue_busy()->bool,request_dialogue_action(id:StringName)->bool and execute_dialogue_action(id:StringName,quest_id:StringName)->void (only an active busy controller may route). Main/owners/save12 remain unchanged. UiLayout gives only dialogue a viewport-bounded wide rectangle and skips generic restyling for this modular branch. UiCoordinator remains the sole modal owner and additionally consumes input during dialogue dispatch. Existing E/Tab/Enter/Space/Esc and book/input contracts stay.

UiCoordinator orders actual HudRoot.toasts below the dialogue body and restores82 elsewhere; legacy Main.toast is not the live stack. Screen reserves1px bottom breathing room to avoid fractional transition edge rounding.

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
