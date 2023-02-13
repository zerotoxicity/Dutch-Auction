# **Ketchup Token Dutch Auction**

## Overview

A demo initial coin offering (ICO) application for **_Ketchup_** token (ERC20 based) using dutch auction mechanism deployed with upgradeable smart contracts.

Includes a Flutter frontend to interact with the smart contracts.

## Getting Started

### Prerequisites

- Node Package Manager (NPM)

  > [Installation guide](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)

- Yarn
  ```
  npm install --global yarn
  ```
- Python

  ```
  python 3.X and above
  ```

- Metamask web extension

- Flutter [_optional_]
  > For running debug mode, if production does not work

```
Version 2.10.5 and above
```

### Installation

1. Install hardhat package dependencies.

   ```bash
   cd hardhat
   yarn install
   ```

2. **_[For running debug only]_** Install flutter package dependencies.

   ```bash
   cd ../flutter_frontend
   flutter pub get
   ```

## Usage

### Run application

1. Enter `hardhat` folder

   ```bash
   cd hardhat
   ```

2. Start a local node

   ```bash
   yarn hardhat node
   ```

3. Deploy the smart contract onto localhost network

   ```bash
   yarn deploy --network localhost
   ```

4. Run a web server using `python` to launch the app
   e.g. to run on port `8000`

   ```bash
   cd ../flutter_frontend/build/web
   python -m http.server 8000
   ```

   > directory should contain `index.html` and other supporting web files

5. Launch a browser with metamask extension to interact, paste following into url:

- _Allow metamask permission to interact with the app_
  ```
   localhost:8000
  ```

---

[***For running debug only***]

1.  Enter `flutter_frontend` folder

    ```bash
    cd ../flutter_frontend
    ```

2.  Create an instance to connect with

    ```bash
    flutter run -d web-server
    ```

3.  Copy the generated `localhost` url to browser with web3 provider.

- e.g. `localhost:8475`

4. Allow permission on metamask to interact with **_local blockchain_**

---

### Directions

[X] Smart Contracts deployed

1. Start the auction under _`Admin Page`_.
   - wait for the next block
2. Head back to _`Auction page`_ and click on _`refresh`_ icon
   - Auction should start
3. Interact with auction by _bidding_

4. Tokens can only be withdrawn _after_ auction has ended

### Compile smart contracts

```
yarn hardhat compile
```

### Run tests

To run all of the tests in the `hardhat` directory.

```
cd hardhat
yarn hardhat test
```

### Run tests with coverage tool

To run all of the tests in the `hardhat` directory and check the code coverage.

```
cd hardhat
yarn hardhat coverage
```
