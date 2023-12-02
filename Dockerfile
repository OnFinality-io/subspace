FROM rust as APP_PLANNER
WORKDIR /usr/local/src

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y protobuf-compiler clang

RUN rustup install 1.70.0
RUN rustup override set 1.70.0
RUN rustup target add wasm32-unknown-unknown

RUN cargo install cargo-chef
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM rust as APP_CACHER
WORKDIR /usr/local/src

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y protobuf-compiler clang

RUN rustup install 1.70.0
RUN rustup override set 1.70.0
RUN rustup target add wasm32-unknown-unknown

RUN cargo install cargo-chef
COPY --from=APP_PLANNER /usr/local/src/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

FROM rust as APP_BUILDER
WORKDIR /usr/local/src

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y protobuf-compiler clang

RUN rustup install 1.70.0
RUN rustup override set 1.70.0
RUN rustup target add wasm32-unknown-unknown

COPY . .
COPY --from=APP_CACHER /usr/local/src/target target
COPY --from=APP_CACHER $CARGO_HOME $CARGO_HOME
RUN cargo build --release --locked

FROM ubuntu:22.04
COPY --from=APP_BUILDER /usr/local/src/target/release/node-subspace /usr/local/bin/
COPY --from=APP_BUILDER /usr/local/src/specs /subspace/specs
COPY --from=APP_BUILDER /usr/local/src/snapshots /subspace/snapshots
WORKDIR /subspace

ENTRYPOINT [ "/usr/local/bin/node-subspace", "--bootnodes", "/ip4/134.209.113.183/tcp/50053/p2p/12D3KooWCLPBiEDt1VTx3GAjUFADJFvshhLALxKqs2JKb7TcrRgM", "/ip4/165.22.186.112/tcp/50097/p2p/12D3KooWFuoHry2F3iBVxEyw6gkwvhkrMseApx2gQwojXqyXxEwK", "/ip4/165.22.186.112/tcp/50090/p2p/12D3KooWHJn5Zq7mUv7UV6EPzZpwveS3ehfixGgYofoSG9w49j25", "/ip4/165.22.186.112/tcp/50106/p2p/12D3KooWGVCPyJ5FHq8Ykee8qwFrEReUbpawLUNQBrUqTajJg9m1", "/ip4/67.207.85.224/tcp/50050/p2p/12D3KooWLs9NPQN9j71DUFRvcSJDpsTiKe4pHEhNWinof44iTFit", "/ip4/134.122.30.80/tcp/50056/p2p/12D3KooWE1LgVN3yqyhwiFko775MHRXGxW1VKM5SvQaG68AhjqCh", "/ip4/167.99.229.96/tcp/50050/p2p/12D3KooWA7XbMiRkMJmHEzNVkDwqjKgignwbRp2BBzGFWDicjia6", "/ip4/165.22.186.112/tcp/50056/p2p/12D3KooWQzbp5QPNVqRTW6A9yYuhQyU5LD15beokxB3U5MsWu37z", "/ip4/68.183.30.114/tcp/50050/p2p/12D3KooW9rTvrbBcaBFZiQHUpNjd9foDz1qzyKZNjxjX1XFRZAPw", "/ip4/67.207.85.224/tcp/50053/p2p/12D3KooWPe8hzEScYMUoo6kZhxMpADuph9UuKsmRrdzVdQcrFqC3" ]
