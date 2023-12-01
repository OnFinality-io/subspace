FROM ubuntu:22.04 as builder

# This is being set so that no interactive components are allowed when updating.
ARG DEBIAN_FRONTEND=noninteractive
# show backtraces
ENV RUST_BACKTRACE 1

# Necessary libraries for Rust execution
RUN apt-get update && apt-get install -y curl build-essential protobuf-compiler clang git

WORKDIR /subspace

# Copy the source code
COPY . .

# Install cargo and Rust
ENV PATH="/root/.cargo/bin:${PATH}"
RUN ./scripts/install_rust_env.sh

# Cargo build
RUN cargo build --release --locked

FROM ubuntu:22.04

WORKDIR /subspace

COPY --from=builder /subspace/target/release/node-subspace /usr/local/bin/
COPY --from=builder /subspace/specs/ /subspace/specs/

ENTRYPOINT [ "/usr/local/bin/node-subspace", "--chain", "/subspace/specs/main.json", "--bootnodes", "/ip4/134.209.113.183/tcp/50053/p2p/12D3KooWCLPBiEDt1VTx3GAjUFADJFvshhLALxKqs2JKb7TcrRgM", "/ip4/165.22.186.112/tcp/50097/p2p/12D3KooWFuoHry2F3iBVxEyw6gkwvhkrMseApx2gQwojXqyXxEwK", "/ip4/165.22.186.112/tcp/50090/p2p/12D3KooWHJn5Zq7mUv7UV6EPzZpwveS3ehfixGgYofoSG9w49j25", "/ip4/165.22.186.112/tcp/50106/p2p/12D3KooWGVCPyJ5FHq8Ykee8qwFrEReUbpawLUNQBrUqTajJg9m1", "/ip4/67.207.85.224/tcp/50050/p2p/12D3KooWLs9NPQN9j71DUFRvcSJDpsTiKe4pHEhNWinof44iTFit", "/ip4/134.122.30.80/tcp/50056/p2p/12D3KooWE1LgVN3yqyhwiFko775MHRXGxW1VKM5SvQaG68AhjqCh", "/ip4/167.99.229.96/tcp/50050/p2p/12D3KooWA7XbMiRkMJmHEzNVkDwqjKgignwbRp2BBzGFWDicjia6", "/ip4/165.22.186.112/tcp/50056/p2p/12D3KooWQzbp5QPNVqRTW6A9yYuhQyU5LD15beokxB3U5MsWu37z", "/ip4/68.183.30.114/tcp/50050/p2p/12D3KooW9rTvrbBcaBFZiQHUpNjd9foDz1qzyKZNjxjX1XFRZAPw", "/ip4/67.207.85.224/tcp/50053/p2p/12D3KooWPe8hzEScYMUoo6kZhxMpADuph9UuKsmRrdzVdQcrFqC3" ]
