recurShape.o: recurShape.S
	as -o recurShape.o recurShape.S

recurShape: recurShape.o
	ld -s -o recurShape recurShape.o

clean:
	rm -f *.o recurShape
