def time_to_ago_string(created_at)
	sec = (Time.now - created_at).to_i
	min = (sec/60).to_i;
	hrs = (min/60).to_i;
	dys = (hrs/24).to_i;

	if sec <= 1
		ago = "1 second ago"
	elsif sec < 60
		ago = sec.to_s + " seconds ago"
	elsif min == 1
		ago = min.to_s + " minute ago"
	elsif min < 60
		ago = min.to_s + " minutes ago"
	elsif hrs == 1
		ago = hrs.to_s + " hour ago"
	elsif hrs < 24
		ago = hrs.to_s + " hours ago"
	elsif dys == 1
		ago = dys.to_s + " day ago"
	else
		ago = dys.to_s + " days ago"
	end

	return ago
end

