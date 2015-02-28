default: build

build:
	- dmd -L-lcurl -L-lphobos2 src/bit.d src/consoled/source/consoled.d

install:
	- mv bit /usr/bin/bit

test: build
	- cp std.sh ~/std.sh
	- ./bit std.sh

clean:
	- rm bit
