require 'elastec'
require 'colorize'

namespace :elastec do
  namespace :indices do
    desc 'Create or update described indices'
    task :update do
      puts 'Creating and updating indices:'

      Elastec::Indices.update do |name, action, exeption = nil|
        if exeption.nil?
          puts "#{name.dup.green} done...".green
        else
          puts "#{name.dup.red} failed: #{exeption.message}"
        end
      end
    end

    desc 'Delete all indices'
    task :delete do
      puts 'Deleting indices:'

      Elastec::Indices.delete do |name, exeption = nil|
        if exeption.nil?
          puts "#{name.dup.green} deleted..."
        else
          puts "#{name.dup.red} failed to delete: #{exeption.message}"
        end
      end
    end
  end
end