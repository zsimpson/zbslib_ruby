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
		versions = version_get_all

		# < 0 indicates latest version
		version = version.to_i
		if version < 0
			version = versions.length-1
		end

		# BOUND version
		version = [ versions.length-1, version ].min
		version = [ 0, version ].max
		
		return versions[version], version, versions.length
	end

	def version_all_newest( count )
		return @version_model_owner_class
			.includes( :user )
			.order( "id desc" )
			.limit( count )
	end

	def version_all_recent_edits( count )
		return @version_model_owner_class
			.includes(:user)
			.joins( @version_model_class.table_name.to_sym )
			.select( @version_model_owner_class.table_name+".*, "+@version_model_class.table_name+".created_at as versioned_at")
			.group( @version_model_owner_class.table_name+".id" )
			.order( @version_model_class.table_name+".id desc" )
			.limit( count )
	end
	
end

