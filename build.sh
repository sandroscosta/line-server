#!/bin/bash

# Check if Ruby is installed

if ! command -v ruby &> /dev/null
then
    echo "Ruby is not installed. Please install Ruby and try again."
    exit 1
fi

# Check if RubyGems is installed

if ! command -v gem &> /dev/null
then
    echo "RubyGems is not installed. Please install RubyGems and try again."
    exit 1
fi

# Check if Bundler is installed

if ! command -v bundle &> /dev/null
then
    echo "Bundler is not installed. Please install Bundler and try again."
    exit 1
fi

# Check if the project directory is the current directory

if ! [[ "$PWD" == */* ]]
then
    echo "Please run this script from the project directory."
    exit 1
fi

# Check if the project directory contains a Gemfile

if ! [[ -f Gemfile ]]
then
    echo "The project directory does not contain a Gemfile."
    exit 1
fi

# Check if the project directory contains a Rakefile

if ! [[ -f Rakefile ]]
then
    echo "The project directory does not contain a Rakefile."
    exit 1
fi

# Install Ruby dependencies
echo "Installing Ruby dependencies..."
bundle

# Generate the default data file
echo "Generating default data file... this may take a few minutes."
rake generate_data

echo "Setup complete."