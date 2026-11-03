## PauseMenu — compatible modal adapter for the modular reference-14 screen.
## API:
##   func configure(save_callback: Callable, load_callback: Callable, main_menu_callback: Callable) -> void
##   func open() -> void
##   func close() -> void
##   func toggle() -> void
extends PanelContainer

var shell: LifePauseShell
var presenter: LifePausePresenter = LifePausePresenter.new()

func _ready() -> void:
	hide()
	LifeTheme.bind(self,&"LifeHudClearPanel")
	mouse_filter = Control.MOUSE_FILTER_STOP
	shell = preload("res://ui/pause/pause_shell.tscn").instantiate() as LifePauseShell
	add_child(shell)
	presenter.configure(self,shell,Callable(),Callable(),Callable())
	shell.close_button.pressed.connect(close)
	shell.actions.requested.connect(presenter.request)
	shell.settings.applied.connect(presenter.apply)
	shell.settings.defaulted.connect(presenter.defaults)
	shell.settings.audio.music.value_changed.connect(func(_value: float) -> void: presenter.show_result(&"PAUSE_DRAFT_NOTE"))
	shell.settings.audio.effects.value_changed.connect(func(_value: float) -> void: presenter.show_result(&"PAUSE_DRAFT_NOTE"))
	shell.settings.game.language.item_selected.connect(func(_index: int) -> void: presenter.show_result(&"PAUSE_DRAFT_NOTE"))

func configure(save_callback: Callable, load_callback: Callable, main_menu_callback: Callable) -> void:
	presenter.configure(self,shell,save_callback,load_callback,main_menu_callback)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func open() -> void:
	if GameClock.is_sleeping():
		return
	presenter.begin()
	show()
	# The coordinator may reject this opening while a day-end review is active.
	if visible:
		GameClock.paused = true
		_set_player_locked(true)
		shell.actions.resume_button.grab_focus()

func close() -> void:
	if not visible:
		return
	# Restore legacy standalone behavior before visibility lets the owner restore its hold.
	GameClock.paused = false
	_set_player_locked(false)
	hide()

func _set_player_locked(locked: bool) -> void:
	var world: GrayBoxWorld = get_parent().get_node_or_null("GrayBoxWorld") as GrayBoxWorld
	if world != null:
		world.player.movement_enabled = not locked

func _toggle_settings() -> void:
	shell.settings.select_tab(0)
	shell.settings.tabs[0].grab_focus()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and shell != null and shell.actions.summary != null:
		presenter.refresh_summary()
