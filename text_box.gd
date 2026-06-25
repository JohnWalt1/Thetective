extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var display_timer: Timer = $DisplayTimer

const MAX_WIDTH= 256
var text=""
var letter_idx=0

var letter_time= 0.03
var space_time= 0.06
var punctuation_time= 0.2

signal finished_displaying()

func display(text_to_display:String,tb_pos:Vector2):
	letter_idx=0
	text=text_to_display
	label.text=text_to_display
	display_timer.stop()
	await get_tree().process_frame
	#await resized
	custom_minimum_size.x=min(label.size.x,MAX_WIDTH)
	if size.x>MAX_WIDTH:
		label.autowrap_mode=TextServer.AUTOWRAP_WORD
		#await resized
		#await resized
		await get_tree().process_frame
		await get_tree().process_frame
		custom_minimum_size.y=size.y
	else:
		label.autowrap_mode=TextServer.AUTOWRAP_OFF
	global_position.x=tb_pos.x-size.x/2
	global_position.y= tb_pos.y- size.y -24
	
	label.text=""

	_display_letter()
	
func _display_letter():
	if letter_idx>=text.length():
		finished_displaying.emit()
		return
	label.text+=text[letter_idx]
	
	letter_idx+=1
	if letter_idx>=text.length():
		finished_displaying.emit()
		return
	match text[letter_idx]:
		"!",".",",","?":
			display_timer.start(punctuation_time)
		" ":
			display_timer.start(space_time)
		_:
			display_timer.start(letter_time)
		



func _on_display_timer_timeout() -> void:
	_display_letter()
