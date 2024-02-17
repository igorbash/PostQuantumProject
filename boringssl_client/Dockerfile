FROM ubuntu:latest
RUN apt update
RUN apt install -y git cmake gcc ninja-build libunwind-dev pkg-config python3 python3-psutil golang-go
WORKDIR /app
COPY boringssl/ ./boringssl/
COPY liboqs/ ./liboqs/
RUN cd liboqs && mkdir build && cd build && cmake -G"Ninja" -DCMAKE_INSTALL_PREFIX=/app/boringssl/oqs -DOQS_USE_OPENSSL=OFF .. && ninja && ninja install
RUN cd boringssl && mkdir build && cd build && cmake -GNinja .. && ninja
RUN cp boringssl/build/tool/bssl /bin/
