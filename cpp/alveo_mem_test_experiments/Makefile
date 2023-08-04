CC=g++ 			#taken out the compiler type as an environment variable 
CFLAGS=-g       #-Wall -g #-Wall is for activate all the warnings at debug -g is for enabling debuging 
DEBUG ?= true

.PHONY: clean	#says clean is not a target with a dependency "just run it, it's a command"

#to break a long line multiple lines go to the start of a variable or argument type '\' and enter it will do the thing maintaining the tabs

mem_read_test:
	$(CC) $(CFLAGS) \
	-I./include/ \
	-I../common/include/ \
	src/mem_read.cpp \
	$(PWD)/../common/src/read_master.cpp \
	test/mem_read_test.cpp \
	-o mem_read_test.exec \
	-DDEBUG=$(DEBUG)

mem_write_test:
	$(CC) $(CFLAGS) \
	-I./include/ \
	-I../common/include/ \
	src/mem_write.cpp \
	$(PWD)/../common/src/write_master.cpp \
	test/mem_write_test.cpp \
	-o mem_write_test.exec \
	-DDEBUG=$(DEBUG)

mem_read_write_test:
	$(CC) $(CFLAGS) \
	-I./include/ \
	-I../common/include/ \
	src/mem_read_write.cpp \
	$(PWD)/../common/src/read_master.cpp \
	$(PWD)/../common/src/write_master.cpp \
	test/mem_read_write_test.cpp \
	-o mem_read_write_test.exec \
	-DDEBUG=$(DEBUG)

clean:
	rm -rf *_test.exec