//
//  KeyNamesConstants.swift
//  ELFramework
//
//  Created by Admin on 14/12/17.
//  Copyright © 2017 EL. All rights reserved.
//

import Foundation
import UIKit

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

let GetDeviceToken:String = UserDefaultManager.getStringFromUserDefaults(key: kAppDeviceToken)

//MARK:- SOCKET EVENTS
let keyJoinSocket = "Join_Socket"
let keyGetChatUsers = "Get_ChatUsers"
let keyGetChatMessages = "Get_ChatMessages"
let keyGet_ChatMessagesByDate = "Get_ChatMessagesByLastId"
let keySendMessage = "Send_Message"
let keyNewMessage = "New_message"
let keyGetMyGroups = "Get_MyGroups"
let keyGroupMessage = "Group_Message"
let keyCreateGroup = "Create_Group"
let keySendGroupMessage = "Send_Group_Message"
let keyGroupCreated = "GroupCreated"
let keyAddMembersInGroup = "Add_MembersInGroup"
let keyGetGroupChatMessagesByLastId = "Get_GroupChatMessagesByLastId"
let keyinForeground = "inForeground"
let keyinBackground = "inBackground"
let keyChangeMuteStatus = "ChangeMute_Status"
let keySendBroadcastMessage = "Send_Broadcast_Message"
let keyGetAllMyStatusStory = "Get_AllMyStatusStory"
let keyGetFriendsStory = "Get_FriendsStory"
let keyDeleteStory = "DeleteStory"
let keyUpdateReadStatusStory = "Update_ReadMultipleStatusStory"
let keyFriendViewed = "Friend_Viewed"
let keyStoryDeleted = "Story_Deleted"
let keyCreateStory = "Add_StatusStory"
let keyScheduleCreateStory = "Add_ScheduleStatusStory"
let keyGetGroupMessageReadInfo = "Get_GroupMessageReadInfo"
let keyGetChatMessageReadInfo = "Get_ChatMessageReadInfo"
let keyUpdateStatusPrivacy = "Update_StatusPrivacy"

let GoogleAPI = "AIzaSyBuxiOrT4aWBcsQpQOwEQXHv-QPSOg0MTM"

//PV
//Privacy Change related Socket API
let keyPrivacyChange_Status = "StatusPrivacyNotify" // Get Updated handler - "RefreshStatus"
let keyEditPrivacy = "EditPrivacy" // Get Updated handler - "Edit action perfor in status setting screen"
let keyInform_BlockedUser = "Inform_BlockedUser" // Get Updated handler - "Edit action perfor in status setting screen"
let keyNotify_Update_UserBioProfile = "Notify_Update_UserBioProfile"

let SupportUserID = "0"

//MARK:- COREDATA ENTITY NAMES
let ENTITY_CALL_HISTORY = "CD_CallHistory"
let ENTITY_CHAT = "CD_Messages"
let ENTITY_FRIENDS = "CD_Friends"
let ENTITY_GROUPS = "CD_Groups"
let ENTITY_GROUP_CHAT = "CD_GroupMessages"
let ENTITY_BROADCASTLIST = "CD_BroadcastList"
let ENTITY_BROADCAST_MESSAGE = "CD_BoardcastMessages"
//let ENTITY_STORY = "CD_Story"
//let ENTITY_VIEWER = "CD_Viewers"
let ENTITY_STORIES = "CD_Stories"
let ENTITY_STORIES_VIEWERS = "CD_Stories_Viewers"

//MARK:- APP NAME
public let APPNAME :String = "WakeUpp"

//MARK:- STORY BOARD NAMES
public let SB_MAIN :String = "Main"
public let SB_CHAT :String = "Chat"
public let SB_FEEDS :String = "Feeds"
public let SB_CHANNEL :String = "Channels"
public let SB_STORIES :String = "UserStories"
public let SB_ASSET_PICKER :String = "AssetPicker"

//MARK:- VIEW CONTROLLER ID
public let idLoginVC = "loginvc"
public let idChatVC = "chatvc"
public let idGroupChatVC = "groupchatvc"
public let idBroadcastChatVC = "broadcastchatvc"
public let idCountrypickerVC = "countrypickervc"
public let idVerificationVC = "verificationvc"
public let idRegisterVC = "registervc"
public let idChatListVC = "chatlistvc"
public let idFeedListVC = "feedlistvc"
public let idFeedVC = "FeedVC"
public let idCommentsVC = "commentsvc"
public let idStoryVC = "storyvc"
public let idStoryListVC = "storylistvc"
public let idGalleryVC = "GalleryVC"
public let idPostVC = "PostVC"
public let idPostCaptionVC = "PostCaptionVC"
public let idChatAttachVC = "ChatAttachVC"
public let idGroupInfoVC = "GroupInfoVC"
public let idBroadcastListInfoVC = "BroadcastListInfoVC"
public let idBroadcastListVC = "BroadcastListVC"
public let idSelectMembersVC = "SelectMembersVC"
public let idChannelListVC = "channellistvc"
public let idCreateChannelVC = "createchannelvc"
public let idCreateVideoVC = "idcreatevideovc"
public let idChannelProfileVC = "idchannelprofilevc"
public let idAssetPickerVC = "AssetPickerVC"
public let idAssetFiltersVC = "AssetFiltersVC"
public let idImageCropperVC = "ImageCropperVC"
public let idProfileSettingVC = "ProfileSettingVC"
public let idChannelCommentVC = "ChannelCommentVC"
public let idProfileVC = "ProfileVC"
public let idEditProfileVC = "EditProfileVC"
public let idPopupVC = "PopupVC"
public let idMyStoryDetailVC = "idmystorydetailvc"
public let idStoryViewerListVC = "idstoryviewerlistvc"
public let idCreateStoryVC = "idCreateStoryVC"
public let idEditStoryVC = "idEditStoryVC"
public let idStoriesVC = "storiesvc"
public let idMyStoriesVC = "mystoriesvc"
public let idStoryNavigatorVC = "storynavigatorvc"
public let idVideoCallVC = "VideoCallVC"
public let idVoiceCallVC = "VoiceCallVC"
public let idChannelNotificationVC = "ChannelNotificationVC"
public let idOtherProfileVC = "OtherProfileVC" 
public let idSearchVC = "SearchVC" 
public let idAccountSettingsVC = "AccountSettingsVC" 
public let idPrivacyVC = "PrivacyVC" 
public let idChatSettingsVC = "ChatSettingsVC" 
public let idNotificationSettingsVC = "NotificationSettingsVC" 
public let idHelpAboutUsVC = "HelpAboutUsVC" 
public let idWebviewVC = "WebviewVC"
public let idDeleteMyAccountVC = "DeleteMyAccountVC"
public let idChangeNumberVC = "ChangeNumberVC"
public let idTwoStepVerificationVC = "TwoStepVerificationVC"
public let idTwoStepVerification_SetPasswordVC = "TwoStepVerification_SetPasswordVC"
public let idChannelSearchVC = "ChannelSearchVC"
public let idSearchContactVC = "SearchContactVC"
public let idWakeUppAppWebVC = "WakeUppAppWebVC" 
public let idFeedbackVC = "FeedbackVC"
public let idChatUserInfoVC = "ChatUserInfoVC"
public let idGroupSettingsVC = "GroupSettingsVC"
public let idCallHistoryVC = "CallHistoryVC"


//MARK:- REQUEST KEYS
public let PlatformName = "2"

//MARK:- USER DEFAULTS KEY
let kIsLoggedIn:String = "UDLoggedIn"
let kAppDeviceToken:String = "UDDeviceToken"
let kAppUser = "User"
let kAppUserId =  "UserId"
let kAppUserFName = "FirstName"
let kAppUserFullName = "full_name"
let kAppUserLName = "LastName"
let kAppUserEmail  = "UserEmail"
let kAppUserProfile = "UserProfile"
let kAppUserProfile_Banner = "UserProfile_Banner"
let kAppUserMobile = "UserMobileNo"
let kAppUserCountryCode = "Countrycode"
let kAppKnowLocation = "UserLocation"
let kAppVerified = "IsVerified"
let kAlreadyRegisterd = "IsRegistered"
let kMutedByMe = "MutedByMe"
let kPreviouslySavedAppUsers = "isPreviouslySavedAppUsers"
let kAppUsers = "AppUsers"
let kPreviouslyCachedThumbnails = "isPreviouslyCachedThumbnails"
let kCachedThumbnails = "CachedThumbnails"
let kPreviouslyCachedFeeds = "isPreviouslyCachedFeeds"
let kCachedFeeds = "CachedFeeds"
let kUsername = "Username"
let kBio = "Bio"
let kIsPreviouslyCachedChannels = "IsPreviouslyCachedChannels"
let kAllChannelVideo = "AllChannelVideo" // Show data if internet not avalable.
let kPrivacy_LastSeen = "kPrivacy_LastSeen"
let kPrivacy_ProfilePhoto = "kPrivacy_ProfilePhoto"
let kPrivacy_About = "kPrivacy_About"
let kIsTwoStepVerification = "kIsTwoStepVerification"
let kPrivacy_Status = "kPrivacy_Status"
let kPrivacy_Status_Useridlist = "kPrivacy_Status_Useridlist"
let kOnlySharewith_Useridlist = "kOnlySharewith_Useridlist"
let kPrivacy_ReadReceipts = "kPrivacy_ReadReceipts"
let kPrivacy_Notification_Message = "kPrivacy_Notification_Message"
let kPrivacy_Notification_Group = "kPrivacy_Notification_Group"
let kBlockContact = "kBlockContact"
let kHiddenChatSetupDone = "kHiddenChatSetupDone"
let kHiddenChatPin = "kHiddenChatPin"
let kHiddenChatUserList = "kHiddenChatUserList"
let kHiddenGroupChatList = "kHiddenGroupChatList"
let kIsChatWallpaperSet = "kIsChatWallpaperSet"
let kChatWallpaper = "kChatWallpaper.jpg"
let kIsChatFontCurrentSizeSet = "kIsChatFontCurrentSizeSet"
let kChatFontCurrentSize = "kChatFontCurrentSize"
let kIsDNDActive = "kIsDNDActive"
let kDateOfBrith = "kDateOfBrith"
let kEnterKeyIsSend = "kEnterKeyIsSend"
let kFolderURL_WakeUpp = "kFolderURL_WakeUpp"
let kFolderURL_Chat = "kFolderURL_Chat"
let kFolderURL_Group = "kFolderURL_Group"
let kFolderURL_Broadcast = "kFolderURL_Broadcast"
let kFolderURL_HinndenChat = "kFolderURL_HinndenChat"
let kIsUserLocationSet = "kIsUserLocationSet"
let kUserLocation = "kUserLocation"
let kChatBackupRestore = "kChatBackupRestore"
let kIsRestored = "kIsRestored"
//MARK:- Static Name Key
//let kReport_Spam_Post = "Report this post"
let kReport_Spam_Post = "Report"
let kReport_Spam_ChannelVideo = "Report"


//MARK:- IMAGE
let PlaceholderImage:UIImage = UIImage.init(named: "imageplaceholder")!
let ProfilePlaceholderImage:UIImage = UIImage.init(named: "user_notification")!
let GroupPlaceholderImage:UIImage = UIImage.init(named: "group_pic_dflt")! //addgroup_pic
let ChatLeftTopImage:UIImage = UIImage.init(named: "left1")!
let ChatLeftCenterImage:UIImage = UIImage.init(named: "left2")!
let ChatLeftBottomImage:UIImage = UIImage.init(named: "left3")!
let ChatRightTopImage:UIImage = UIImage.init(named: "right1")!
let ChatRightCenterImage:UIImage = UIImage.init(named: "right2")!
let ChatRightBottomImage:UIImage = UIImage.init(named: "right3")!
let StoryPlaceHolder:UIImage = UIImage.init(named: "my_story_add")!
let UserPlaceholder:UIImage = UIImage.init(named: "user_notification")!
let SquarePlaceHolderImage:UIImage = #imageLiteral(resourceName: "squareplaceholder")
//let SquarePlaceHolderImage_Chat:UIImage = #imageLiteral(resourceName: "initializing_w")
let SquarePlaceHolderImage_Chat:UIImage = #imageLiteral(resourceName: "img_Placeholder")
let SquarePlaceHolderImage_ChatBG:UIColor = Color_Hex(hex: "E2EEE9")

//MARK:- NOTIFICATION CENTER NAMES
let NC_DismissPopUp = "NC_DismissPopUp"
let NC_PauseStory  = "NC_PauseStory"
let NC_ResumeStory = "NC_ResumeStory"
let NC_VideoStoryDownloaded = "NC_VideoStoryDownloaded"
let NC_GoBackStory = "NC_GoBackStory"
let NC_UserStoryFinished = "NC_UserStoryFinished"
let NC_NewMessage = "NC_NewMessage"
let NC_UserListRefresh = "NC_UserListRefresh"
let NC_OnlineStatusRefresh = "NC_OnlineStatusRefresh"
let NC_NewGroupMessage = "NC_NewGroupMessage"
let NC_GroupListRefresh = "NC_GroupListRefresh"
let NC_LoadMessageFromServer = "NC_LoadMessageFromServer"
let NC_AddChannelRefresh = "NC_AddChannelRefresh"
let NC_AddChannelVideoRefresh = "NC_AddChannelVideoRefresh"
let NC_MySingalChannelVideoList = "NC_MySingalChannelVideoList"
let NC_MySingalChannelVideoListActivityEffect = "NC_MySingalChannelVideoListActivityEffect"
let NC_MyChannelSubscribeCountActon = "NC_MyChannelSubscribeCountActon"
let NC_UpdateProfile = "NC_UpdateProfile"
let NC_ViewerRefresh = "NC_ViewerRefresh"
let NC_FriendStoryRefresh = "NC_FriendStoryRefresh"
let NC_AddStoryToList = "NC_AddStoryToList"
let NC_RefreshAfterDelete = "NC_RefreshAfterDelete"
let NC_MyStoryRefresh = "NC_MyStoryRefresh"
let NC_DisableScroll = "NC_DisableScroll"
let NC_UnableScroll = "NC_UnableScroll"
let NC_CallDidConnect = "NC_CallDidConnect"
let NC_CallDidDisConnect = "NC_CallDidDisConnect"
let NC_StartCallAction = "NC_StartCallAction"
let NC_UpdateProfile_Followings = "NC_UpdateProfile_Followings" 
let NC_DeleteChannelVideoRefresh = "NC_DeleteChannelVideoRefresh" 
let NC_ChannelUpdateRefresh_AllChannelListVC = "NC_ChannelUpdateRefresh_AllChannelListVC" 
let NC_ChannelUpdateRefresh_ChannelProfileVC = "NC_ChannelUpdateRefresh_ChannelProfileVC"
let NC_AddPostCommentRefresh = "NC_AddPostCommentRefresh"
let NC_RemovePostCommentRefresh = "NC_RemovePostCommentRefresh"
let NC_HiddenChatLockToggle = "NC_HiddenChatLockToggle"
let NC_ChatDotChanged = "NC_ChatDotChanged"
let NC_StoryDotChanged = "NC_StoryDotChanged"
let NC_DNDStatusChanged = "NC_DNDStatusChanged"
let NC_ChatAttachmentDownloaded = "NC_ChatAttachmentDownloaded"
let NC_ChatAttachmentDownloadFailed = "NC_ChatAttachmentDownloadFailed"
let NC_UserOnlineStatusChanged = "NC_UserOnlineStatusChanged"
let NC_SocketConnected = "NC_SocketConnected"
let NC_ReadReceiptUpdate = "NC_ReadReceiptUpdate"
let NC_UpdatePushReceivedReceipt = "NC_UpdatePushReceivedReceipt"
//PV
let NC_PrivacyChange_Refresh_ChatListVC = "NC_PrivacyChange_Refresh_ChatListVC"
let NC_PrivacyChange_Refresh_ChatVC = "NC_PrivacyChange_Refresh_ChatVC"
let NC_PrivacyChange_Refresh_ChatUserInfoVC = "NC_PrivacyChange_Refresh_ChatUserInfoVC"
let NC_PrivacyChange_Refresh_ReadInfoVC = "NC_PrivacyChange_Refresh_ReadInfoVC"
let NC_PrivacyChange_Refresh_GroupInfoVC = "NC_PrivacyChange_Refresh_GroupInfoVC"
let NC_PrivacyChange_Refresh_SelectMembersVC = "NC_PrivacyChange_Refresh_SelectMembersVC"
let NC_PrivacyChange_LastSeen_Refresh_ChatVC = "NC_PrivacyChange_LastSeen_Refresh_ChatVC"
let NC_PrivacyChange_About_Refresh_ChatUserInfoVC = "NC_PrivacyChange_About_Refresh_ChatUserInfoVC"

//MARK:- FONT NAMES
let FT_Light = "Roboto-Light"
let FT_Medium = "Roboto-Medium"
let FT_Regular = "Roboto-Regular"
let FT_Bold = "Roboto-Bold"

//MARK:- COLOR NAMES
/*let themeWakeUppColor = Color_Hex(hex: "#fda303")
let themeTextColor = Color_Hex(hex: "#cc0000")
let themeBgColor = Color_Hex(hex: "#F6EAEA")
let COLOR_PopupBG = RGBA(0, 0, 0, 0.750)*/
let themeWakeUppColor = Color_Hex(hex: "#2FCA97")
let themeGreenColor = Color_Hex(hex: "#82C247")
let themeTextColor = Color_Hex(hex: "#25a178")
let themeBgColor = Color_Hex(hex: "#F6EAEA")
let COLOR_PopupBG = RGBA(0, 0, 0, 0.750)

//MARK:- MESSAGES
let ServerResponseError = "Server Response Error"
let RetryMessage = "Something went wrong please try again..."
let InternetNotAvailable = "Internet connection appears to be offline."
let EnterEmail = "Email address is required."
let EnterValidEmail = "Please enter valid email address."
let EnterPassword = "Password is required."
let EnterPasswordInvalid = "Enter valid password."
let EnterOLDPassword = "Old Password is required."
let EnterNEWPassword = "New Password is required."
let EnterMinLengthPassword = "Minimum length of password is 6 character."
let EnterMinLengthMobile = "Minimum length of mobile is 6 character."
let EnterConfirmPassword = "Confirm password is required."
let PasswordMismatch = "Password Mismatch."
let PasswordChange = "Password Changed Successfully"
let EnterPhone = "Mobile number is required."
let EnterUserName = "User name is required."
let EnterName = "Enter Name"
let PasswordRecovery = "Please check your mail box"
let CodeSelect = "Please select county code."
let EnterMobileNumber = "Please enter mobile number."
let InvalidOTP = "Invalid OTP."
let SelectBirthDate = "Please select birthdate."
let EnterBio = "Please enter Bio."
let SelectChannelCover = "Channel cover is required."
let SelectChannelPhoto = "Channel photo is required."
let EnterChannelName = "Channel name is required."
let EnterChannelDesc = "Channel description is required."
let SelectChannel = "Select Channel is required."
let SelectVideo = "Select video is required."
let EnterVideoTitle = "Video title is required."
let EnterVideoDesc = "Video description is required."
let Enter_Old_CountryCode = "Please enter old county code."
let Enter_Old_MobileNumber = "Please enter old mobile number."
let Enter_New_CountryCode = "Please enter new county code."
let Enter_New_MobileNumber = "Please enter new mobile number."

//MARK: - Document File Types
let FILE_DOC = "doc"
let FILE_DOCX = "docx"
let FILE_XLS = "xls"
let FILE_XLSX = "xlsx"
let FILE_PDF = "pdf"
let FILE_TXT = "txt"
let FILE_RTF = "rtf"
let FILE_WAV = "wav"
let FILE_MP3 = "mp3"
let FILE_M4A = "m4a"


//MARK: - Asset Picker & Filter
let thumbnailImageSize = CGSize.init(width: 125, height: 125)

let maxImageSize = CGSize.init(width: 450, height: 450)

let arrFilters = [
    "Original",
    "CIPhotoEffectChrome",
    "CIPhotoEffectProcess",
    "CIPhotoEffectTransfer",
    "CILinearToSRGBToneCurve",
    "CIPhotoEffectFade",
    "CIPhotoEffectInstant",
    "CIPhotoEffectMono",
    "CIPhotoEffectNoir",
    "CIPhotoEffectTonal"
]

let arrFilterNames = [
    "Original",
    "Chrome",
    "Process",
    "Transfer",
    "Tone",
    "Fade",
    "Instant",
    "Mono",
    "Noir",
    "Tonal",
]

public let Limit_Age :Int = 14
public let Limit_GroupSize :Int = 256

let kBrightness : Float = 0.0
let kContrast : Float = 1.0
let kSaturation : Float = 1.0
let kWarmth : Float = 0.0
let kFade : Float = 1.0
let kExposure : Float = 0.0

let FilterAssetsDirectory = "FilterAssetsExportedDirectory"

let kMaxMembersInGroup = 255 // +1 will be the logged-in user
let kMaxMembersInBroadcast = 256

let kStoryMessageSeparator = "|$@*@$|"
let kLinkMessageSeparator = "|$@^@$|"

let kChatFontSizeSmall = "kChatFontSizeSmall"
let kChatFontSizeMedium = "kChatFontSizeMedium"
let kChatFontSizeLarge = "kChatFontSizeLarge"


let kChatFont = UIFont.init(name: FT_Medium, size: 17)!

let kChatFontSmallForNameReply:CGFloat = 13
let kChatFontSmallForMsgReply:CGFloat = 12
let kChatFontSmallForMessage:CGFloat = 15
let kChatFontSmallForTime:CGFloat = 9
let kGroupChatFontSmallForSenderName:CGFloat = 10
let kChatFontSmallForLinkTitle:CGFloat = 10
let kChatFontSmallForLinkDetails:CGFloat = 8

let kChatFontMediumForNameReply:CGFloat = 15
let kChatFontMediumForMsgReply:CGFloat = 14
let kChatFontMediumForMessage:CGFloat = 17
let kChatFontMediumForTime:CGFloat = 11
let kGroupChatFontMediumForSenderName:CGFloat = 12
let kChatFontMediumForLinkTitle:CGFloat = 12
let kChatFontMediumForLinkDetails:CGFloat = 10

let kChatFontLargeForNameReply:CGFloat = 17
let kChatFontLargeForMsgReply:CGFloat = 16
let kChatFontLargeForMessage:CGFloat = 19
let kChatFontLargeForTime:CGFloat = 13
let kGroupChatFontLargeForSenderName:CGFloat = 14
let kChatFontLargeForLinkTitle:CGFloat = 14
let kChatFontLargeForLinkDetails:CGFloat = 12


let uploadImageCompression:CGFloat = 0.85
