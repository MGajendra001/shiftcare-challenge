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
    ruby app.rb <command> [arguments]
    ```

    #### Commands

    - **Search**: Find clients with names matching a query (case-insensitive, partial matches).

        ```bash
        ruby app.rb search <query>
        ```
        Example: ruby app.rb search ali

    - **Duplicates**: List clients with duplicate email addresses.

        ```bash
        ruby app.rb duplicates
        ```

  - ### Running with Docker

    1. Build the Docker image:

          ```bash
          docker build -t shiftcare-challenge .
          ```
    2. Run the application:
          ```bash
          docker run --rm shiftcare-challenge <command> [arguments]
          ```
       Examples:
        - Search: `docker run --rm shiftcare-challenge search ali`
        - Duplicates: `docker run --rm shiftcare-challenge duplicates`

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

- Client data is fetched from https://appassets02.shiftcare.com/manual/clients.json at runtime.
- Search is case-insensitive and matches partial strings in the `full_name` field.
- Clients missing `full_name` or `email` fields are handled gracefully:
  - Missing names are excluded from search results.
  - Missing emails are not considered duplicates.
- The entire dataset is loaded into memory, assuming it’s not excessively large.
- Dockerized setup simplifies deployment and ensures consistent environments.

### Known Limitations

- Network dependency: Requires internet access to fetch data.
- Search is limited to the `full_name` field.
- No pagination; all results are displayed.
- Memory usage may be an issue with very large datasets.

### Future Improvements

- **Configurable Data Source**: Allow specifying a custom URL or local file via a command-line argument.
- **Dynamic Search**: Extend search to other fields (e.g., `ruby app.rb search email hello@example.com`).
- **REST API**: Extract logic into a library and serve via Sinatra/Rails (e.g., `GET /query?q=hello`).
- **Scalability**: Use a database or stream JSON for large datasets.