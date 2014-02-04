module Elastec
  module Indices
    extend self

    extend Elastec::Connection

    def update
      each do |name, index_data|
        begin
          if connection.indices.exists(index: name)
            settings = index_data['settings']
            mappings = index_data['mappings']

            if settings.present?
              connection.indices.put_settings(index: name, body: settings)
            end

            if mappings.present?
              mappings.each do |type, mapping|
                connection.indices.put_mapping(index: name, type: type, body: mappings)
              end
            end

            yield(name, :update) if block_given?
          else
            connection.indices.create(index: name, body: index_data)
            yield(name, :create) if block_given?
          end
        rescue Connection::SERVER_ERROR => e
          yield(name, nil, e) if block_given?
        end
      end
    end

    def delete
      if ENV['FORCE'] != 'yes' && (ENV['ONLY'].blank? && ENV['EXCEPT'].blank?)
        raise 'Can not destroy all indexes unless FORCE=yes specified'
      end

      each do |name, _|
        begin
          connection.indices.delete(index: name)
          yield(name) if block_given?
        rescue Connection::SERVER_ERROR => e
          yield(name, e) if block_given?
        end
      end
    end

    private
    def each(&block)
      definitions.each do |name, index_data|
        yield(name, index_data)
      end
    end

    def definitions
      Elastec.indices_path.present? or raise "Index data path not specified in Elastec.indices_path"

      {}.tap do |data|
        Dir[File.join(Elastec.indices_path, '*.yml*')].each do |path|
          yaml = File.read(path)
          yaml = ERB.new(yaml).result if File.extname(path) == '.erb'
          yaml = YAML.load(yaml)
          data.merge!(yaml)
        end

        data.present? or raise "No index data found in #{Elastec.indices_path}"

        delete_keys_if(data, 'ONLY')   { |name, only| not(name.in?(only)) }
        delete_keys_if(data, 'EXCEPT') { |name, except| name.in?(except) }

        data.present? or raise "Specify at least one index to work with"
      end
    end

    def delete_keys_if(data, env_var, &block)
      names = ENV[env_var]
      if names.present?
        names = names.split(',').map(&:strip)
        data.delete_if { |k, _| yield(k, names) }
      end
    end
  end
end