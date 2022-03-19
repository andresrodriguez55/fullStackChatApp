import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/models/User/UserBuilder.dart';

class SecondaryUserBuilder implements UserBuilder
{
	User? _user;
	
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  
	SecondaryUserBuilder()
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
	
	void setName(String? name)
	{
		_user?.setName(name);
	}
	
	void setProfilePicturePath(String? profilePicturePath)
	{
		_user?.setProfilePicturePath(profilePicturePath);
	}
	
	User? getUser()
	{
		return _user;
	}
}