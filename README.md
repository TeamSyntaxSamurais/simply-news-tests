## Sinatra web app with SQL database boilerplate

### Instructions
1. Create SQL database
2. Clone this repository
3. Add database name in app.rb
4. Create a model for each table
5. For each table, create a migration
```ruby
  bundle exec rake db:create_migration NAME=create_table_name
```
6. Create table columns in CreateTableName class with this format:
```ruby
  class CreateTableName < ActiveRecord::Migration
    def change
      create_table :table_name do |t|
        t.string :column_name
      end
    end
  end
```
7. Run the migration
```ruby
bundle exec rake db:migrate
```
8. Require models in config.ru
9. Create routes
10. Create views
