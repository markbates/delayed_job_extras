watch('spec/.*_spec\.rb') {|md| system "spec -O spec/spec.opts #{md[0]}"}
watch('lib/(.*)\.rb')     {|md| system "spec -O spec/spec.opts spec/#{md[1]}_spec.rb"}