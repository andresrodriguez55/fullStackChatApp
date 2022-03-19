import 'package:chatapp/models/Memory/Memory.dart';
import 'package:chatapp/models/User/PrimaryUserBuilder.dart';
import 'package:chatapp/models/User/SecondaryUserBuilder.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/models/User/UserBuilder.dart';

class UserMakerDirector
{	
	static Future<User?> makePrimaryUser(String? username, String? password, String? email, 
                                      String? name, String? profilePictureBase64Encoded,
                                      List<String> friendsUsernames, List<String> requestsUsernames) async
	{
		PrimaryUserBuilder _primaryUserBuilder = new PrimaryUserBuilder();
		_primaryUserBuilder.setUsername(username);
		_primaryUserBuilder.setPassword(password);
		_primaryUserBuilder.setEmail(email);
		_primaryUserBuilder.setName(name);
    _primaryUserBuilder.setFriendsUsernames(friendsUsernames);
    _primaryUserBuilder.setRequestsUsernames(requestsUsernames);

    String? profilePicturePath;
    if(username!=null)
      profilePicturePath = await Memory.saveBase64EncodedProfilePictureAndReturnPath(profilePictureBase64Encoded, username);
		_primaryUserBuilder.setProfilePicturePath(profilePicturePath);
    
		return _primaryUserBuilder.getUser();
	}
	
	static Future<User?> makeSecondaryUser(String? username, String? name, 
                                        String? profilePictureBase64Encoded) async
	{
		SecondaryUserBuilder _secondaryUserBuilder = new SecondaryUserBuilder();
		_secondaryUserBuilder.setUsername(username);
		_secondaryUserBuilder.setName(name);

    String? profilePicturePath;
    if(username!=null)
      profilePicturePath = await Memory.saveBase64EncodedProfilePictureAndReturnPath(profilePictureBase64Encoded, username);
		_secondaryUserBuilder.setProfilePicturePath(profilePicturePath);
    
		return _secondaryUserBuilder.getUser();
	}
}