abstract class UserBuilder
{
	void reset();
	
	void setUsername(String? username);
	
	void setPassword(String? password);
	
	void setEmail(String? email);
	
	void setName(String? name);
	
	void setProfilePicturePath(String? profilePicturePath);

  void setFriendsUsernames(List<String>? friendsUsernames);

  void setRequestsUsernames(List<String>? requestsUsernames);
}