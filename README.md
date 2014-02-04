# Elastec

Yet another ruby adapter for elasticsearch.

## Key difference

1. Focuses on documents. Allows to flexibly control relations between index,
document and model instance.
1. No extra code in models. All search and configuration logic can be stored
outside model class (except callbacks).
1. Query DSL. Provides powerful query builder transparent to elasticsearch api.
1. Framework isolated. Does not care about ORM you use. Has builtin ActiveRecord
adapter.
1. No magic. Tries to be as much transparent to ElasticSearch api as possible.

## Installation

Add this line to your application's Gemfile:

    gem 'elastec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elastec

## Maintaining indices

Put following somewhere in initializer:

```ruby
Elastec.indices_path = 'config/indices'
Elastec.connection = Elasticsearch::Client.new(reload_connections: true)
```

Now, put indices definition in user_index.yml under specified directory:

```yaml
---
user_index:
  settings:
    number_of_shards: 3

  mappings:
    user:
      properties:
        id:
          type: string
          index: not_analyzed
        name:
          type: string
```

Call:

```
rake elastec:indices:update
```

You can define your indexes in one file, or you can split it at multiple files. .yml.erb also accepted.

Rake task accepts ONLY and EXCEPT environment variables with index names.

## Undone

## Simple example of handling index data

class User < ActiveRecord::Base
  include Elastec::ActiveRecord

  notify_elastec_indexer 'Indexer::User'
  notify_elastec_indexer 'Indexer::Stats'
end

class Indexer::User < Elastec::Indexer
  index :user_index, if: :published?
  index :deleted_user_index, if: :deleted?
end

class Indexer::Stats < Elastec::Indexer
  index :stats_index, :stats do |object, action|
    {
      id: object.id,
      class: object.class.name,
      action: action
    }
  end
end

## Querying example

class Query::User < Elastec::Query
  def all(options)
    build do
      filtered do
        query do
          _merge(name(options))
        end
      end
    end
  end

  protected
  def name(options)
    build do
      query do

      end
    end
  end
end

Query::User.search(:all, query: 'test')

## TODO

1. IGNORE_CONFLICTS & OPEN_CLOSE parameters for index updater.
2. Specs on indicies creator.
3. Dumping of current index settings & mappings.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
