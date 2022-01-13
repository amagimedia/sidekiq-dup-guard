a = ENV['Dummy']
puts a
puts "some change"

f = File.open("coverage/script_dummy", "w+")
f.write(a)
f.close

exit(0)
