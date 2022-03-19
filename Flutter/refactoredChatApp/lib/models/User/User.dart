import 'package:hive/hive.dart';

part 'User.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject 
{
  @HiveField(0)
  String? username;

	String? password;

	String? email;

  @HiveField(1)
	String? name;

  @HiveField(2)
	String? profilePicturePath;

  List<String>? friendsUsernames;

  List<String>? requestsUsernames;

	void setUsername(String? username)
	{
		this.username=username;
	}
	
	void setPassword(String? password)
	{
		this.password=password;
	}
	
	void setEmail(String? email)
	{
		this.email=email;
	}
	
	void setName(String? name)
	{
		this.name=name;
	}
	
	void setProfilePicturePath(String? profilePicturePath)
	{
		this.profilePicturePath=profilePicturePath;
	}

  void setFriendsUsernames(List<String>? friendsUsernames)
  {
    this.friendsUsernames = friendsUsernames;
  }

  void setRequestsUsernames(List<String>? requestsUsernames)
  {
    this.requestsUsernames = requestsUsernames;
  }

  void addFriendUsername(String username)
  {
    this.friendsUsernames?.add(username);
  }

  void deleteFriendUsername(String username)
  {
    this.friendsUsernames?.removeWhere((friendUsername) => friendUsername == username);
  }

  void addRequestUsername(String username)
  {
    this.requestsUsernames?.add(username);
  }

  void deleteRequestUsername(String username)
  {
    this.requestsUsernames?.removeWhere((requestUsername) => requestUsername == username);
  }
}