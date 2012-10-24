module Versionable
	# expects:
	# @version_model_class = The ActiveRecord class that represents the version table e.g. ProgramVersion
	# @version_model_owner_class = The ActiveRecord class that represents the owner table e.g. Program
	# @version_key_name = The name of the field in the version that link to the owner, e.g. program_id

	def version_get_all
		return @version_model_class.all( :conditions=>{ @version_key_name=>self.id }, :order=>"created_at" )
	end

	def version_get_count
		return @version_model_class.count( :conditions=>{ @version_key_name=>self.id } )
	end

	def version_get( version )
		# OPTIMIZE for getting latest
		begin
			if version.to_i == -1
				head = @version_model_class.where( @version_key_name=>self.id, :head=>1 ).first
				if ! head
					raise
				end
				count = self.version_get_count
				return head, count-1, count
			end
		rescue
		end

		versions = version_get_all

		# < 0 indicates latest version
		if !version || version.to_i < 0
			version = versions.length-1
		end
		version = version.to_i

		# BOUND version
		version = [ versions.length-1, version ].min
		version = [ 0, version ].max
		
		return versions[version], version, versions.length
	end

	def version_get_mark( version_mark )
		# Find the newest version not newer than version_mark id
		versions = version_get_all
		
		ver = -1
		for i in versions
			if i[:id] > version_mark
				break
			end
			ver += 1
		end
		
		if ver == -1
			raise "No version older then mark"
		end
		
		return versions[ver], ver, versions.length
	end

	def version_all_newest( count )
		return @version_model_owner_class
			.includes( :user )
			.order( "id desc" )
			.limit( count )
	end

	def version_all_recent_edits( count )
		owners = @version_model_owner_class
			.includes(:user)
			.joins( @version_model_class.table_name.to_sym )
			.select( @version_model_owner_class.table_name+".*, "+@version_model_class.table_name+".created_at as versioned_at")
			.order( @version_model_class.table_name+".id desc" )
			.limit( count )
			
		# For some reason I had a "select( distinct(owner_class.table_name.id) ... in here and it worked perfectly
		# on one machine and didn't work on another with the very same mysql.  So I'm implementing the distinct by hand
		list = []
		seen_owners = {}
		for i in owners
			if ! seen_owners[ i.id ]
				list.push( i )
				seen_owners[ i.id ] = true
			end
		end
		return list
	end
	
end

