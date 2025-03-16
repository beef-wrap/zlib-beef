clang -c -g -gcodeview -o zlib-windows.lib -target x86_64-pc-windows -fuse-ld=llvm-lib -Wall zlib\zlib.c

mkdir libs
move zlib-windows.lib libs
