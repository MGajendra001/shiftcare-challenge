# ShiftCare Technical Challenge

A Ruby command-line application to search clients by name and identify duplicate emails in a JSON dataset.

## Setup

### Prerequisites
- Ruby 2.7+ installed ( if running locally)
- Docker installed (for containerized execution)
- Internet connection (to fetch client data from the remote URL)

### Installation
1. Clone or download this project.
2. Install RSpec and Webmock for testing (optional, if running locally):
   ```bash
   gem install rspec
   gem install rspec webmock
   ```

### Usage

  - ### Running Loacally

    ```bash
    ruby app.rb [options] <command> [arguments]
    ```

    #### Options
      - `--source SOURCE`: Specify a JSON data source (file path or URL). Defaults to https://appassets02.shiftcare.com/manual/clients.json. Example: `ruby app.rb --source custom.json search name ali`
    #### Commands

    - **Search**: Find clients with values matching a query in the specified field (case-insensitive, partial matches). Fields are automatically detected from the JSON data (e.g., `name`, `email`, `phone`).

        ```bash
        ruby app.rb search <field> <query>
        ```
        Example:
         - `ruby app.rb search name ali`
         - `ruby app.rb search email alice@example.com`

    - **Duplicates**: List clients with duplicate data by fields (e.g.,`email`, `name`).

        ```bash
        ruby app.rb duplicates <field>
        ```
        Example:
         - `ruby app.rb duplicates email`

  - ### Running with Docker

    1. Build the Docker image:

          ```bash
          docker build -t shiftcare-challenge .
          ```
    2. Run the application:
          ```bash
          docker run --rm shiftcare-challenge [options] <command> [arguments]
          ```
       Examples:
        - Search by full name: `docker run --rm shiftcare-challenge search full_name ali`
        - Search by email: `docker run --rm shiftcare-challenge search email alice@example.com`
        - Duplicates email: `docker run --rm shiftcare-challenge duplicates email`
        - Duplicates full name: `docker run --rm shiftcare-challenge duplicates full_name`
        - Use a **local JSON file**:
            ```bash
            docker run --rm -v $(pwd)/test.json:/app/test.json shiftcare-challenge --source test.json search name ali
            ```

#### Running the Tests
- Tests cover happy paths, edge cases and negative scenarios. You can run tests using:
  - Locally:

    ```bash
    rspec
    ```
  - With Docker:

    ```bash
    docker run --rm shiftcare-challenge rspec
    ```

### Assumptions and Decisions

- Client data can be loaded from a file or URL, specified via `--source`.
- Client data is fetched from https://appassets02.shiftcare.com/manual/clients.json at runtime (if source is not passed).
- Search methods (e.g., `search_by_full_nam`e, `search_by_email`) and duplicate methods (e.g., `find_by_email`) are defined using metaprogramming for flexibility.
- Clients missing the specified field or with non-string values except *Integer* are excluded from search and duplicate results
- The entire dataset is loaded into memory, assuming it’s not excessively large.
- Dockerized setup simplifies deployment and ensures consistent environments.

### Known Limitations

- Network dependency: Requires internet access to fetch data.
- No pagination; all results are displayed.
- Memory usage may be an issue with very large datasets.

### Future Improvements

- **Advanced Search**: Support regex or exact-match searches.
- **REST API**: Extract logic into a library and serve via Sinatra/Rails (e.g., `GET /query?q=hello`).
- **Scalability**: Use a database or stream JSON for large datasets.