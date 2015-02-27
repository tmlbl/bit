default: build

build:
	- ldc2 -m64 src/bashc.d

install:
	- mv bashc /usr/bin/bashc

test:
	- dmd -run src/bashc.d std.sh
