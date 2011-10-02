module FriendableWithPrograms

	def add_friend_by_name( friend_name )
		friend = User.find_by_name!( friend_name )
		add_friend_by_id( friend.id )
	end
	
	def add_friend_by_id( friend_id )
		Friendship.create!( :user_id=>self.id, :friend_id=>friend_id )
	end
	
	def get_friends_programs
		programs_by_friend = {}
		friends_user_ids_by_name = {}

		programs = Program.find_by_sql(["select users.id as user_id, users.name as user_name, programs.id as program_id, programs.name as program_name from friendships,  programs, users where friendships.friend_id = programs.user_id and friendships.user_id = ? and users.id = friendships.friend_id order by upper(users.name)", self.id])
		for i in programs
			programs_by_friend[ i[:user_id] ] ||= {} 
			programs_by_friend[ i[:user_id] ][ :user_name ] = i[:user_name]
			(programs_by_friend[ i[:user_id] ][ :programs ] ||= []).push( {:program_id=>i[:program_id], :program_name=>i[:program_name]} )
			friends_user_ids_by_name[ i[:user_name] ] = i[:user_id]
		end
		
		# MAKE a nice list of names with a list of their programs like this
		# [
		#	{ :user_name=>"zack", :user_id=>1, :programs=>{} },
		#	{ :user_name=>"bob", :user_id=>2, :programs=>[ {:program_id=>1, :program_name=>"oink"}, {:program_id=>2, :program_name=>"boink"} ] },
		# ]
				
		friends_programs = []
		for f in self.friends.sort{ |a,b| a.name.downcase <=> b.name.downcase }
			friends_programs.push( {:user_name=>f.name, :user_id=>f.id, :programs=>programs_by_friend[f.id] ? programs_by_friend[f.id][:programs] : {} } )
		end
		
		return friends_programs
	end
end
