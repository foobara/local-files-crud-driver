# Foobara::LocalFilesCrudDriver

`foobara-local-files-crud-driver` supports reading or writing records from or to local files.

Defaults to `local_data/<entity_name>.yml` but can be overridden.

## Installation

You can install the gem into an exiting Foobara project by running `foob g local-files-crud-driver`.

Or add `foobara-local-files-crud-driver` to your Gemfile or .gemspec file and `bundle install`.

Or even just `gem install foobara-local-files-crud-driver` if just playing with it directly in the scripts.

## Usage

Set up the local files CRUD driver:

```ruby
require "foobara/local_files_crud_driver"

driver = Foobara::LocalFilesCrudDriver.new
Foobara::Persistence.default_crud_driver = driver
```

### Things to know

- **Where the files go**: If you don't pass `data_path:`, files are written under `./local_data/`.

### Choosing how the driver stores data

Below are the available options you can pass to `Foobara::LocalFilesCrudDriver.new`:

| Option | What it does |
| --- | --- |
| `data_path:` | The folder where the files are written. Defaults to `./local_data/` |
| `multi_process:` | Defaults to `false`. Set to true if you plan to allow multiple processes to access this data so that a process can see data changed by a different process. |

## Contributing

Bug reports and pull requests are welcome at [github.com/foobara/local-files-crud-driver](https://github.com/foobara/local-files-crud-driver).

To work on an existing issue or submit a Pull Request:

1. Fork the repository and clone it to your local machine
2. Run `bundle install` to install dependencies
3. Run `rake` to ensure that everything works as expected before making any changes
4. Implement your changes
5. Re-run `rake` to make sure that all tests and Rubocop pass
6. Commit your changes, push to GitHub and open a Pull Request for review

## License

This project is licensed under the MPL-2.0 license. Please see [LICENSE.txt](LICENSE.txt) for more information.
