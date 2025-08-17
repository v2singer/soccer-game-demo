class_name ScreenData

var tournament : Tournament = null

static func build() -> ScreenData:
	return ScreenData.new()


func set_tournament(t: Tournament) -> ScreenData:
	tournament = t
	return self
