# GymClient

This project provides an access to the [gym](https://github.com/openai/gym) open-source library, by REST API allowing development in languages [Swift](https://developer.apple.com/swift/).

## Installation

To download the code and install the requirements, you can run the following shell commands:
```
git clone https://github.com/openai/gym-http-api
cd gym-http-api
pip install -r requirements.txt
```
After that, you can add GymClient to your Package file:
```
dependencies: [
    .package(url: "https://github.com/Octadero/GymClient", from: "0.0.1")
]
```

## Getting started

This code is intended to be run locally by a single user. The server runs in python. You can implement your own HTTP clients using Swift.

To start the server from the command line, run this:
```
python gym_http_server.py
```
