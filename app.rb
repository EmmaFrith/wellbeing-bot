require 'sinatra'
require 'net/http'
require 'json'
require 'dotenv/load'


# Define a helper method to find the conversation by name
def find_conversation(name)
  uri = URI("https://slack.com/api/conversations.list")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{SLACK_API_TOKEN}"
  request["Content-Type"] = "application/json"

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  if response.is_a?(Net::HTTPSuccess)
    result = JSON.parse(response.body)

    if result["ok"]
      # Find the channel with the matching name
      result["channels"].each do |channel|
        if channel["name"] == name
          puts "Found conversation ID: #{channel['id']}"
          return channel['id']
        end
      end
      puts "Channel not found"
      return nil
    else
      puts "Error from Slack API: #{result['error']}"
    end
  else
    puts "HTTP request failed: #{response.message}"
  end
end

# Define a Sinatra route to call find_conversation
get '/find_conversation/:name' do
  channel_name = params['name']
  conversation_id = find_conversation(channel_name)

  if conversation_id
    "Found conversation ID: #{conversation_id}"
  else
    "Channel #{channel_name} not found."
  end
end
