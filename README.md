# Foobara::LocalFilesCrudDriver

`foobara-local-files-crud-driver` supports reading or writing records from or to local files. Defaults to local_data/records.yml but can be overwritten.

## Installation

Add `gem "foobara-local-files-crud-driver"` to your Gemfile or .gemspec file and `bundle install`.

Or even just `gem install foobara-local-files-crud-driver` if just playing with it directly in the scripts.

## Usage

Save the code below in a file such as `widget_example.rb`.

```ruby
require "foobara/local_files_crud_driver"

driver = Foobara::LocalFilesCrudDriver.new(data_path: "./data", format: :yaml) # sets up driver
Foobara::Persistence.default_crud_driver = driver

class Widget < Foobara::Entity
  attributes do
    id :integer
    name :string, :required
  end

  primary_key :id
end

class CreateWidget < Foobara::Command # command to create a Widget
  inputs Widget.attributes_for_create
  result Widget

  def execute
    Widget.create(inputs)
  end
end

class FindWidget < Foobara::Command # command to find a Widget
  inputs do
    id Widget.primary_key_type, :required
  end
  result Widget

  def execute
    Widget.load(id)
  end
end

widget = CreateWidget.run!(name: "Example")
puts FindWidget.run!(id: widget.id).name # => "Example"
```

Running the command below in your project folder will print `Example` as the output signifying that the record was successfully saved locally.

```sh
ruby widget_example.rb
```

### Things to know

- **Where the files go**: If you don't pass `data_path:`, files are written under `#{Dir.pwd}/local_data/`. `Dir.pwd` is the folder you were in when you started the program.

- **One file per entity type**: The driver creates one file for each entity table, named `{table_name}.yml`, inside `data_path`.

- **Use commands, or open a transaction**: Foobara requires an open transaction for successful CRUD operations.

- **YAML is the only supported format**: `format: :yaml` is the only supported value.

### Choosing how the driver stores data

Below are the available options you can pass to `Foobara::LocalFilesCrudDriver.new`:

| Option | What it does |
| --- | --- |
| `data_path:` | The folder where the files are written. Defaults to `#{Dir.pwd}/local_data/` |
| `format:` | How records are stored. Only `:yaml` is supported |
| `multi_process:` | Specifies whether several programs can safely use the same files and defaults to `false` |

`multi_process:`

- `false` (**default**): Keeps the data cached in memory between operations. Simplest choice when only one program accesses the files.

- `true`: Reloads the file on every operation, using **file locks** while reading or writing. Use it when multiple programs access the same files.

## Contributing

Bug reports and pull requests are always welcome at [github.com/foobara/local-files-crud-driver](https://github.com/foobara/local-files-crud-driver).

To work on an existing issue or submit a Pull Request:

1. Fork the repository and clone it to your local machine
2. Run `bundle install` to install dependencies
3. Run `rake` to ensure that everything works as expected before making any changes
4. Implement your changes
5. Re-run `rake` to make sure that all tests and Rubocop pass
6. Commit your changes, push to GitHub and open a Pull Request for review

## License

This project is licensed under the MPL-2.0 license. Please see [LICENSE.txt](LICENSE.txt) for more information.
