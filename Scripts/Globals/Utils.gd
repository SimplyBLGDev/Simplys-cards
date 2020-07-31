extends Node

enum TimeFormat {
	FORMAT_HOURS   = 1,
	FORMAT_MINUTES = 2,
	FORMAT_SECONDS = 4,
	FORMAT_DEFAULT = 7
}

static func format_time(time, format = TimeFormat.FORMAT_DEFAULT, digit_format = "%02d"):
	var digits = []

	if format & TimeFormat.FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)

	if format & TimeFormat.FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)

	if format & TimeFormat.FORMAT_SECONDS:
		var seconds = digit_format % [int(ceil(time)) % 60]
		digits.append(seconds)

	var formatted = String()
	var colon = " : "

	for digit in digits:
		formatted += digit + colon

	if not formatted.empty():
		formatted = formatted.rstrip(colon)

	return formatted

static func rand_range_i(from, to):
	return from + randi()%(to-from)
