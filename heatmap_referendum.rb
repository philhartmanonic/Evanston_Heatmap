require 'csv'
require 'rmagick'
include Magick

results = CSV.read('results/referendum.csv')
totals = []
values = {}
percentages = []
results[1..-1].each { |x| totals << x[5].to_i; values[x[0]] = [x[3].to_i, x[4].to_i]; percentages << (x[3].to_i.to_f / x[5].to_i) }
max = totals.sort[-1]
med = 0
if percentages.count % 2 == 1
	med = percentages.sort[(percentages.count.to_f / 2).floor]
else
	med = (percentages.sort[(percentages.count.to_f / 2).floor] + percentages[((percentages.count / 2).floor - 1)]) / 2
end
ten = percentages.sort[4]
ninety = percentages.sort[-5]
div = ((ninety - ten) / 80) * 100

def color(y, n, max, ninety, d)
	p = y.to_f / (y + n)
	wpy = 0.9 + ((p - ninety) / d)
	if wpy > 1
		wpy = 1
	elsif wpy < 0
		wpy = 0
	end
	blue = (255 * wpy).to_i
	green = (255 * (1 - wpy)).to_i 
	red = 0
	if blue > green
		red = (0.2 * (blue - (blue.to_f / max))).to_i
	else
		red = (0.2 * (green - (green.to_f / max))).to_i
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
	colors = color(votes[0], votes[1], max, ninety, div)
	layers[-1].colormap(0, "rgb(#{colors[0]}, #{colors[1]}, #{colors[2]}")
	layers[-1].class_type=DirectClass
end

map = layers.flatten_images
map.write('overlays/test_referendum_overlay.png')