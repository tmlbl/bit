default: build

build:
	- dmd -L-lcurl -L-lphobos2 src/bashc.d 

install:
	- mv bashc /usr/bin/bashc

test:
	- dmd -L-lcurl -L-lphobos2 -run src/bashc.d std.sh
