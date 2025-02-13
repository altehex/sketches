ERL_INCLUDE_PATH = /usr/lib/erlang/usr/include

PHONY = all
all: termios_nif.so unistd_nif.so
	[[ -e bin ]] || mkdir bin
	mv $^ bin/

%.so: %.c
	gcc -fPIC -shared -I$(ERL_INCLUDE_PATH) -o $@ $^
