default: build

build:
	- dmd -L-lcurl -L-lphobos2 src/bashc.d src/consoled/source/consoled.d

install:
	- mv bashc /usr/bin/bashc

test: build
	- cp std.sh ~/std.sh
	- ./bashc std.sh

clean:
	- rm bashc
