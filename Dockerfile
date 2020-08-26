FROM ubuntu AS builder

ARG KRUSTLET_VERSION=v0.4.0
ARG KRUSTLET_SHA256=b77f6b4ce4cdbdc2612d2a5d3bb6944f3bc5c4518d0b74d722a287d437fa3d9c

# Get krustlet-wascc
RUN apt-get update && apt-get install -y curl && \
    curl -LO https://krustlet.blob.core.windows.net/releases/krustlet-${KRUSTLET_VERSION}-linux-amd64.tar.gz && \
    sha256sum krustlet-${KRUSTLET_VERSION}-linux-amd64.tar.gz | \
        grep "^${KRUSTLET_SHA256}  krustlet-${KRUSTLET_VERSION}-linux-amd64.tar.gz" && \
    tar -xvf krustlet-${KRUSTLET_VERSION}-linux-amd64.tar.gz && \
    /krustlet-wascc --help

FROM scratch
COPY --from=builder /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=builder /lib/x86_64-linux-gnu/libdl-2.31.so /lib/x86_64-linux-gnu/libdl.so.2
COPY --from=builder /lib/x86_64-linux-gnu/librt-2.31.so /lib/x86_64-linux-gnu/librt.so.1
COPY --from=builder /lib/x86_64-linux-gnu/libpthread-2.31.so /lib/x86_64-linux-gnu/libpthread.so.0
COPY --from=builder /lib/x86_64-linux-gnu/libc-2.31.so /lib/x86_64-linux-gnu/libc.so.6
COPY --from=builder /lib/x86_64-linux-gnu/libm-2.31.so /lib/x86_64-linux-gnu/libm.so.6
COPY --from=builder /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so.1
COPY --from=builder /lib/x86_64-linux-gnu/libssl.so.1.1 /lib/x86_64-linux-gnu/libssl.so.1.1
COPY --from=builder /lib/x86_64-linux-gnu/libcrypto.so.1.1  /lib/x86_64-linux-gnu/libcrypto.so.1.1
COPY --from=builder /krustlet-wascc /krustlet-wascc
COPY --from=builder /bin/sh /bin/sh
RUN /krustlet-wascc --help
ENTRYPOINT ["/krustlet-wascc"]

