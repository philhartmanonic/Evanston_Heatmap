def color(h, t, m)
	blue = (255 * (h.to_f / (h + t))).to_i
	green = (255 * (t.to_f / (h + t))).to_i
	red = 0
	if h > t
		red = (blue - (blue.to_f / m)).to_i
	else
		red = (green - (green.to_f / m)).to_i
	end
	return [red, green, blue]
end