require 'csv'
require 'rmagick'
include Magick

results = CSV.read('results/hvt.csv')
totals = []
values = {}
results[1..-1].each { |x| totals << x[5].to_i; values[x[0]] = [x[3].to_i, x[4].to_i] }
max = totals.sort[-1]

def color(h, t, m)
	blue = (255 * (h.to_f / (h + t))).to_i
	green = (255 * (t.to_f / (h + t))).to_i
	red = 0
	if h > t
		red = (0.2 * (blue - (blue.to_f / m))).to_i
	else
		red = (0.2 * (green - (green.to_f / m))).to_i
	end
	return [red, green, blue]
end

layers = ImageList.new

Dir.entries('precinct_pngs').delete_if{ |x| ['.', '..', 'background.png'].include?(x) or x[-3..-1] != 'png' or x[1] != '-' }.each do |lay|
	layers << ImageList.new(lay).first
	layers[-1].colorspace=RGBColorspace
	layers[-1].background_color = 'none'
	layers[-1].compress_colormap!
	votes = values["Evanston Ward #{lay[0..-5].gsub('-', ' Precinct ')}"]
	colors = color(votes[0], votes[1], max)
	layers[-1].colormap(0, "rgb(#{colors[0]}, #{colors[1]}, #{colors[2]}")
	layers[-1].class_type=DirectClass
end

map = layers.flatten_images
map.write('overlays/final_overlay.png')