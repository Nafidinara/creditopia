# `creditopia`

## pre
- install dfx
- install plug wallet extension
- install npm
- install cargo `curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh`
- install wasm `rustup target add wasm32-unknown-unknown`
- `dfx start --clean`

## local installation
1. clone repo `git clone `
2. go to directory `cd creditopia`
3. `npm install`
4. `cargo build`
5. `./scripts/setup.sh` don't forget to change mode with `chmod +x [filename]`
6. `dfx deploy`
7. `npm run start` for frontend
