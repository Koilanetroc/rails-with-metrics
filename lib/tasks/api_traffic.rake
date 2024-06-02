require 'net/http'

namespace :api do
  desc "Generate API traffic by creating, reading, updating, and deleting authors and books randomly"
  task generate_traffic: :environment do
    base_url = ENV['BASE_URL'] || 'http://0.0.0.0:3000'
    end_time = Time.now + 10.minutes

    def perform_request(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.request(request)
    end

    puts "Wait a few seconds for app to start..."
    sleep(5)

    puts "Generating API traffic..."
    while Time.now < end_time
      # Create an author
      uri = URI.parse("#{base_url}/authors")
      request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type': 'application/json'})
      request.body = { author: { name: Faker::Book.author } }.to_json
      response = perform_request(uri, request)
      author = JSON.parse(response.body)

      # Create a book
      uri = URI.parse("#{base_url}/books")
      request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type': 'application/json'})
      request.body = {
        book: {
          title: Faker::Book.title,
          description: Faker::Lorem.paragraph,
          author_id: author['id']
        }
      }.to_json
      response = perform_request(uri, request)
      book = JSON.parse(response.body)

      # 30% chance to read a book and author
      if rand < 0.3
        uri = URI.parse("#{base_url}/authors/#{author['id']}")
        request = Net::HTTP::Get.new(uri.request_uri)
        perform_request(uri, request)

        uri = URI.parse("#{base_url}/books/#{book['id']}")
        request = Net::HTTP::Get.new(uri.request_uri)
        perform_request(uri, request)
      end

      # 30% chance to update book or author
      if rand < 0.3
        uri = URI.parse("#{base_url}/authors/#{author['id']}")
        request = Net::HTTP::Patch.new(uri.request_uri, {'Content-Type': 'application/json'})
        request.body = { author: { name: Faker::Book.author } }.to_json
        perform_request(uri, request)
      end

      if rand < 0.3
        uri = URI.parse("#{base_url}/books/#{book['id']}")
        request = Net::HTTP::Patch.new(uri.request_uri, {'Content-Type': 'application/json'})
        request.body = { book: { title: Faker::Book.title, description: Faker::Lorem.paragraph } }.to_json
        perform_request(uri, request)
      end

      # 50% chance to delete book or author
      if rand < 0.5
        # it may fail and it will add some errors to dashboard
        uri = URI.parse("#{base_url}/authors/#{author['id']}")
        request = Net::HTTP::Delete.new(uri.request_uri)
        perform_request(uri, request)
      end

      if rand < 0.5
        uri = URI.parse("#{base_url}/books/#{book['id']}")
        request = Net::HTTP::Delete.new(uri.request_uri)
        perform_request(uri, request)
      end

      # Sleep for a random duration between 1 and 5 seconds
      sleep rand(1..5)
    end
  end
end
