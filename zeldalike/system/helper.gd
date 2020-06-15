extends Node

func string_strip(string):
	return string.rstrip("@1234567890").lstrip("@1234567890")