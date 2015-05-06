# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :jasmine do
  watch(%r{spec/javascripts/spec\.(js\.erb|js|erb)$}) { 'spec/javascripts' }
  watch(%r{spec/javascripts/helpers/.+\.(js\.erb|js|erb)$}) { 'spec/javascripts' }
  watch(%r{spec/javascripts/.+_spec\.(js\.erb|js|erb)$})
  watch(%r{spec/javascripts/fixtures/.+$})
  watch(%r{app/assets/javascripts/(.+)\.(js\.erb|js)(?:\.\w+)*$}) do |m|
  	"spec/javascripts/jasmine/#{ m[1] }_spec.js" 
  end
end
