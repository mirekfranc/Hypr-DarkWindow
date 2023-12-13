# use with make target VERSION=tags/0.31.0
VERSION = HEAD
EXTRA_INCLUDES= -I/usr/include/wayland/ -I/usr/include/libinput/ -I/usr/include/libxkbcommon/ -I/usr/include/hyprland/


all:
	mkdir -p out
	$(CXX) -shared -fPIC --no-gnu-unique src/*.cpp -Isrc/ $(EXTRA_INCLUDES) -o out/hypr-darkwindow.so -g `pkg-config --cflags pixman-1 libdrm hyprland` -std=c++2b -DWLR_USE_UNSTABLE

build-version:
	mkdir -p "out/$(VERSION)" 
	$(CXX) -shared -fPIC --no-gnu-unique src/*.cpp -Isrc/ $(EXTRA_INCLUDES) -I"hyprland/$(VERSION)/include/hyprland/protocols" -I"hyprland/$(VERSION)/include/hyprland/wlroots" -I"hyprland/$(VERSION)/include/" -o "out/$(VERSION)/hypr-darkwindow.so" -g `pkg-config --cflags pixman-1 libdrm` -std=c++2b -DWLR_USE_UNSTABLE

clean:
	rm -rf out
	rm -rf hyprland

load: unload
	hyprctl plugin load $(shell pwd)/out/hypr-darkwindow.so

unload:
	hyprctl plugin unload $(shell pwd)/out/hypr-darkwindow.so

setup-dev:
ifeq ("$(wildcard hyprland/$(VERSION))","")
	mkdir -p "hyprland/$(VERSION)"
	git clone https://github.com/hyprwm/Hyprland "hyprland/$(VERSION)"
	cd "hyprland/$(VERSION)" && git checkout "$(VERSION)" && git submodule update --init
endif
	cd "hyprland/$(VERSION)" && make debug

setup-headers:
ifeq ("$(wildcard hyprland/$(VERSION))","")
	mkdir -p "hyprland/$(VERSION)"
	git clone https://github.com/hyprwm/Hyprland "hyprland/$(VERSION)"
	cd "hyprland/$(VERSION)" && git checkout "$(VERSION)" && git submodule update --init
endif
	cd "hyprland/$(VERSION)" && make all && make installheaders PREFIX="$(pwd)"

dev:
	Hyprland/build/Hyprland
