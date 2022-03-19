import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/models/User/UserBuilder.dart';

class PrimaryUserBuilder implements UserBuilder
{
	User? _user;
	
	PrimaryUserBuilder()
	{
		reset();
	}
	
	void reset()
	{
		_user = new User();
	}
	
	void setUsername(String? username)
	{
		_user?.setUsername(username);
	}
	
	void setPassword(String? password)
	{
		_user?.setPassword(password);
	}
	
	void setEmail(String? email)
	{
		_user?.setEmail(email);
	}
	
	void setName(String? name)
	{
		_user?.setName(name);
	}
	
	void setProfilePicturePath(String? profilePicturePath)
	{
		_user?.setProfilePicturePath(profilePicturePath);
	}

  void setFriendsUsernames(List<String>? friendsUsernames)
  {
    _user?.setFriendsUsernames(friendsUsernames);
  }

  void setRequestsUsernames(List<String>? requestsUsernames)
  {
    _user?.setRequestsUsernames(requestsUsernames);
  }
	
	User? getUser()
	{
		return _user;
	}
}