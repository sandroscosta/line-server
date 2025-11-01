# Line Server

This project implements a simple line server.

## Setup
This project uses Ruby.

To install Ruby you can either install it manually or use `mise install` to install all dependencies from the `mise.toml` file.
There's also a `.ruby-version` file that specifies the Ruby version used to develop the project.

### Build the project
The build step will check that a version of Ruby is installed on the system, install the necessary dependencies and generate the default text files to test the service.

A build script is available via:
```bash
./build.sh
```
If you have docker installed, you can also run the docker command to build the project and run it from inside a container.
```bash
docker build -t line-server .
```

## Usage
The service can be started via the `run.sh` script.
```bash
./run.sh
```

If you have docker installed, you can also run the docker command to start the service.
```bash
docker run -p 3000:3000 line-server
```

You can then access the service via `http://localhost:3000`.

### Endpoints

#### `GET /lines/:line_number`
Return the line with the specified number.
If it reaches EOF without finding it in the index, returns a 413 status code.

## Additional Commands

### Generate files of a specified size (in Megabytes)
You can generate files of a specified size (in Megabytes) by running the following command:
```bash
rake generate_data[size]
```

The default size of the generated file is 10MB.
