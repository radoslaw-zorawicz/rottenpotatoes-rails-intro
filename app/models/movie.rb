class Movie < ActiveRecord::Base
	def self.all_ratings
		Movie.pluck(:rating).uniq.to_a()
	end
end
