a = ENV['Dummy']
puts a

f = File.open("coverage/script_dummy", "w+")
f.write(a)
f.close

exit(0)