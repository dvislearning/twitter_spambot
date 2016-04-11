require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			puts "Message needs to be less than 140 characters."
		end
	end

	def dm(target, message)
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		if screen_names.include?(target)
			puts "Trying to send #{target} this direct message"
			puts message
			message = "d @#{target} #{message}"
			tweet(message)
		else
			puts "Sorry, you can only DM people who follow you."
		end
	end

	def followers_list
		screen_names = []
		@client.followers.each { |follower| screen_names << @client.user(follower).screen_name }
		screen_names
	end

	def spam_my_followers(message)
		followers = followers_list
		followers.each { |follower| dm(follower, message) }
	end
	

	def everyones_last_tweet
		friends = @client.friends.sort_by { |name| @client.user(name).screen_name.downcase }
		friends.each do |friend|
		 	last_message =  @client.user(friend).status
		 	timestamp = last_message.created_at.strftime("%A, %b %d") 
		 	puts "#{@client.user(friend).screen_name} said this on #{timestamp}... "
		 	puts "#{last_message.text}"
		 	puts ""
		 end
	end

	def shorten(original_url)
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		shorten =  bitly.shorten(original_url).short_url
		puts shorten
		shorten
	end 

	def run
    puts "Welcome to the JSL Twitter Client!"
    command = ''
    while command != "q"
    	printf "enter command: "
    	input = gets.chomp
    	parts = input.split(" ")
    	command = parts[0]
    	case command
    	when 'q' then puts "Goodbye!"
    	when 't' then tweet(parts[1..-1].join(" "))
    	when 'dm' then dm(parts[1], parts[2..-1].join(" "))
    	when 'spam' then spam_my_followers(parts[1..-1].join(" "))
    	when 'elt' then everyones_last_tweet
    	when 's' then shorten(parts[1])
    	when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
    	else
    		puts "Sorry, I don't know how to #{command}"
    	end
    end
  end

end

#exactly_140 = "abcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcd"
blogger = MicroBlogger.new
blogger.run