import io, sys

f = open('test.coe')
f2 = open('test_binary.dat','w')
line = 1
f.readline()
f.readline()
i = 0
while line:
    line = f.readline()[:-2]
    if line:
	    line_binary = format(int(line, 16), '0>31b')
	    f2.write(line_binary)
	    f2.write("\n")
	    i = i + 1
	    
for n in range(100 - i):
	line_binary = format(0, '0>31b')
	f2.write(line_binary)
	f2.write("\n")
f.close
f2.close
