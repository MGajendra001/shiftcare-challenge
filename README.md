# ShiftCare Technical Challenge

A Ruby command-line application to search clients by name and identify duplicate emails in a JSON dataset.

## Setup

### Prerequisites
- Ruby 2.7+ installed

### Installation
1. Clone or download this project.
2. Download the `clients.json` file from [appassets02.shiftcare.com/manual/clients.json](appassets02.shiftcare.com/manual/clients.json) and place it in the project root.
3. Install RSpec for testing (optional):
   ```bash
   gem install rspec
   ```

### Usage

Run the application with:

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

#### Running the Tests
- Tests cover happy paths, edge cases and negative scenarios. You can run tests using:
    ```bash
    rspec
    ```

### Assumptions and Decisions

- The JSON file is named `clients.json` and located in the project root.
- Search is case-insensitive and matches partial strings in the `full_name` field.
- Clients missing `full_name` or `email` fields are handled gracefully:
  - Missing names are excluded from search results.
  - Missing emails are not considered duplicates.
- The entire dataset is loaded into memory, assuming it’s not excessively large.

### Known Limitations

- File path is hardcoded to `clients.json`. Could be made configurable.
- Search is limited to the `full_name` field.
- No pagination; all results are displayed.
- Memory usage may be an issue with very large datasets.

### Future Improvements

- **Configurable JSON File**: Allow specifying the file path via a command-line argument.
- **Dynamic Search**: Extend search to other fields (e.g., `ruby app.rb search email hello@example.com`).
- **REST API**: Extract logic into a library and serve via Sinatra/Rails (e.g., `GET /query?q=hello`).
- **Scalability**: Use a database or stream JSON for large datasets.