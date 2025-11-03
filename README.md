# Line Server

This project implements a simple line server.

## Concept
The system eagerly loads a text file when booting.
The `LineReader` class creates a byte index of the text file that stores where each line is.
This makes the system very performant, as we are not really loading the file into memory all at once. There's a small startup process (depending on the size of the file) and a small memory overhead. `LineReader` reads file as binary as a way to handle any file encoding correctly.

When the user requests a line via [http://localhost:3000/lines/100](http://localhost:3000/lines/100), the `LineReader` fetches the correct index
from the index array and instantly displays it.

The system provides fast lookups, by providing a O(1) access to any line without any sequential reading, with Puma being able to provide multiple concurrent requests with workers and thread pools.

## Research

Research on the topic took approximately 2 hours.
Some tests were conducted around the best way to load and scan file with big amounts of data.

In the end, after consulting some articles, including the one by Jorge Manrubia, I've opted to go for Enumerators, not because their faster overall, but because it's a more maintainable implementation and enables future optimizations.

During research, I thought about using some other language than Ruby, but it makes sense to guarantee familiarity inside the organization by using a language that the engineering team in proficient with.

Serving the project is Puma. Puma is lightweight and good enough for the task in hand. In case we need some extra performance we can tweak the workers to give it the extra power we need.

## References
- https://www.jorgemanrubia.com/2019/04/14/processing-text-files-in-ruby-simultaneously/
- https://ruby-doc.org/3.1.4/gems/rake/rake-13_0_6/doc/rakefile_rdoc.html
- https://medium.com/geekculture/writing-custom-rake-tasks-f656f43336cc
- https://www.cloudbees.com/blog/advanced-enumeration-with-ruby
- https://compile7.org/character-encoding-decoding/how-to-handle-character-encoding-with-ascii-in-ruby/

## Libraries and Dependencies
For this project, I chose the following libraries:
- Sinatra (small footprint framework for web applications)
- Faker (generate fake data for the test files)
- Minitest (test framework)
- Puma (Web server)
- Rake (similar to Make, allows the run of tasks)
- Dotenv (load information from `.env` files)

Objectively I wanted to choose something of that has a small, configurable, with proven value.
Sinatra is a DSL web framework that is much easier to understand and to configure than WebBrick.
Puma is the prefered way to serve Web apps and a perfect fit for a production service.
The other chosen packages have more to do with configurability and file generation. Faker allows me to generate fake information for sample files and the Dotenv package let's me load values from `.env` files, giving me the configurability that we might need in the future.

## Time allocation
- Research: 2h
- Coding and testing: 6h

About a days worth of work.

## Future developments
With no time restriction, I could think about simple things, like line caching. I also thought about adding a search functionatily to search for a specific term on the chosen line, similar to how the grep command works.
Could also see some new endpoints, as a way to get text excerpts between line ranges. This might be useful for users that want multiple lines of the documents.
Finally, having a way to load files remotely, from an FTP or a S3 bucket would make sense for this type of service.
As a further optimization step, we could think and benchmark the possibility of spliting large files into smaller files to see if access time would improve, using threading to process and, possibly, switching from Puma to Falcon as a way to gain some extra performance. If it was doable, we could also check on doing some text cleanup and transformations as a way to reduce the size of the document.

As for time and effort allocation, I would always start with the smaller, battle tested options, like having a cache layer that allows a line that was previously search for to be served without hitting the text file.

I'm always seeing and exploring this exercise from a web service perspective, because I feel that this is way more than a script. That's why I'm focussing all my attention on the web performance aspect of it.

## Code critic
Overall, I tried to follow all SOLID principles and to keep the code as DRY as possible, but there are a few things that I could do to improve the code.
I could extract the app login into 2 files, one to initialize the app and a Controller that contains the defined endpoints, so I can keep this more structured. This would help future developments.

One of the things that could improve as well is documentation and naming, which is the hardest task in programming. I could've called the class `LineIndexer` or `LineAccessor` but ended up with `LineReader`, expecting it to be easily understandable.
The Rake commands to generate the data file are also quite simplistic and might not have all the necessary edge use cases to properly test the system.

Also, I haven't tested this on Windows, only in Linux, so there might be issues with using it via a Windows OS.

At the end, I could've build a better build script to understand the current environment and some more tests for the Sinatra service itself, but I didn't feel that it was useful for the project.

## Performance
Using Grafana K6, I did some comparative tests for 1000 concurrent users requesting random line information from the server.

### For a 10MB file
Initial load was pretty fast and after that, I registered the following results
```
Average:    129ms  
Median:     129ms
p(95):      142ms
Max:        1.3s 

Failed requests: 0.00% 
Success rate:    100%  

7,700 requests/second 
463,075 total requests
```
Great performance, overall, with an average of 129ms per request.
The system could easily handle 1000 users without any issues or errors.

### For a 1000MB file
Increasing the file size will increase the inital load time for the service, as the index takes a bit longer to be created.
For this test, with the same 1000 users, this was the result:
```
Average:    141ms  
p(95):      154ms  
Max:        1.19s  

Failed requests: 0.00%
Success rate:    100% 

7,065 requests/second 
425,799 total requests
```
Although there's a slight increase in average response times, overall the system continues to perform in a very performant and reliant way.
Going from 10MB to 1GB increase the response times 8-12ms, which shows the system still performing great.

It is expected that the trend continues with larger 10GB files. Initial load will take some extra time but the service will guarantee scallability.

In the eventuality that we need more performance, we can always configure `puma` to have more worker and, that way, guarantee a higher throughput.

## Setup
This project was built using Ruby v3.4.2

To install Ruby you can either install it manually using the following instructions [https://mac.install.guide/ruby/13](https://mac.install.guide/ruby/13) or use `mise install` to install all dependencies from the `mise.toml` file, if you have [https://mise.jdx.dev/](https://mise.jdx.dev/) installed on your system.
There's also a `.ruby-version` file that specifies the Ruby version used to develop the project.

### Build the project
The build step will check that a version of Ruby is installed on the system, install the necessary dependencies and generate the default text files to test the service.

A build script is available via:
```bash
./build.sh
```
If you have docker installed, you can also run the docker command to build the project and run it from inside a container.
```bash
docker compose build
```

## Usage
The service can be started via the `run.sh` script.
```bash
./run.sh
```

If you have docker installed, you can also run the docker command to start the service.
```bash
docker compose up -d
```

To stop the service, use:
```bash
docker compose stop
```

You can then access the service via `http://localhost:3000`.

### Changing the text file
To change the text file that is served by the service, go to the `.env` file and change the route.

```bash
SOURCE_FILE=data/sample_data_10mb.txt
```

### Endpoints

#### `GET /lines/:line_number`
Returns the following information in a json format:

- the index in the request
- the file line count
- the text line with the specific index

Example:
```json
{
    "index": 1,
    "line_count": 1000,
    "line": "This is line 1"
}
```

If it reaches EOF without finding it in the index, returns a 413 status code.

## Additional Commands

### Generate files of a specified size (in Megabytes)
You can generate files of a specified size (in Megabytes) by running the following command:
```bash
rake generate_data[size]
```

The default size of the generated file is 10MB.

## Tests
The system includes some unit test for te LineReader class.
This is useful in case we need to do some refactoring or changes.

To run the test, run the following command:
```bash
rake test
```

### Performance testing with Grafana K6
You can also perform tests with Grafana K6.
To do so, start by installing grafana https://grafana.com/docs/k6/latest/set-up/install-k6/

After the installation of K6, you can run the tests via the following command:
```bash
k6 run load_test.js
```
Results for 1000 users are displayed above.