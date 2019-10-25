//
//  Constants.swift
//
//  Created by C237 on 30/10/17.
//  Copyright © 2017. All rights reserved.
//

import Foundation
import UIKit

let GET = "GET"
let POST = "POST"
let MEDIA = "MEDIA"

let DEFAULT_TIMEOUT:TimeInterval = 60.0
let Fetch_Data_Limit:NSInteger = 50

//MARK:- API URL
let liveAppUrl = "https://itunes.apple.com/us/app/wakeupp-messenger/id1385345964?ls=1&mt=8"

//Soul URL
let URL_Domain = "http://52.14.197.142"
let SocketServerURL = "http://52.14.197.142:1995"

//Upload URL
let Server_URL = "\(URL_Domain)/WakeUppApp/wake_upp/WebService/service"
let Upload_Profile_Pic_URL = "\(URL_Domain)/WakeUppApp/wake_upp/upload/upload_profile_picture"
let Upload_Chat_Attachment = "\(URL_Domain)/WakeUppApp/wake_upp/upload/upload_for_chat"
let uploadMedia = "\(URL_Domain)/WakeUppApp/wake_upp/upload/upload_image_or_video"
let UploadGroupIcon = "\(URL_Domain)/WakeUppApp/wake_upp/upload/upload_group_picture"
let Upload_Channel_ImageVideo = "\(URL_Domain)/WakeUppApp/wake_upp/upload/channel_upload_image_or_video"
let Upload_Story_URL = "\(URL_Domain)/WakeUppApp/wake_upp/upload/upload_status"

//Other URL
let Get_Profile_Pic_URL = "\(URL_Domain)/WakeUppApp/wake_upp/uploads/profile_pic/"
let Get_Group_Icon_URL = "\(URL_Domain)/WakeUppApp/wake_upp/uploads/group_pic/"
let Get_Chat_Attachment_URL = "\(URL_Domain)/WakeUppApp/wake_upp/uploads/chat_image/"
let Get_Status_URL = "\(URL_Domain)/WakeUppApp/wake_upp/uploads/user_status"
let PostImage_URL = "\(URL_Domain)/WakeUppApp/wake_upp/uploads/post_image"

//MARK:- Static URL
let URL_Domain_StaticPage = "\(URL_Domain)/WakeUppApp/wake_upp/page" //Date : 03-07-2018 11:05am
let URL_FAQ = "\(URL_Domain)/#faq"
let URL_AboutUs = "\(URL_Domain)"
let URL_TermsOfUse = "\(URL_Domain)/terms-condition.php"
let URL_PrivacyPolicy = "\(URL_Domain)/privacy-policy.php"

//MARK:- Server Place holder Image
let URL_ServerSidePlaceHolder = "\(URL_Domain)/WakeUppApp/wake_upp/assets/socketIo/uploads/img_Placeholder.png"

//MARK:- CallTokenUrl
let URL_VoiceCallToken = "\(URL_Domain)/WakeUppApp/wake_upp/assets/token.php"
let URL_VideoCallToken = "\(URL_Domain)/WakeUppApp/wake_upp/assets/token_video.php"

//MARK:- Folder Name
let Folder_WakeUpp = "\(APPNAME)"
let Folder_Chat = "Chat"
let Folder_Group = "Group"
let Folder_Broadcast = "Broadcast"
let Folder_Backup = "\(APPNAME)_Backup"
let Folder_HiddenChat = "\(APPNAME)_HiddenChat"

//MARK:- File Name
let File_HiddenChat_User = "\(Folder_Chat)_" //Append CountryCode and Phone number
let File_HiddenChat_Group = "\(Folder_Group)_" //Append Group ID

//MARK:- RESPONSE KEY
let kData = "data"
let kMessage = "message"
let kStatus = "success"
let kToken = "token"
let kCode = "code"
let kSecret_log_id = "secret_log_id"

//MARK:- API LOADER MESSAGES
let APICountryList = "Loading Countries"
let APIEmailCheck = "Checking Email Avaibility"
let APISendingCode = "Sending Verification Code"
let APIVerificationCode = "Verifying Code"
let APISignUpMessage = "REGISTERING"
let APISocialLoginMessage = "Login In"
let APISocialLogOutMessage = "Logout"
let APIPasswordRecovery = "Requesting Password"
let APIUpdateProfileMessage = "Updating Profile Details"
let APIUpdateProfilePicMessage = "Updating Profile Pic"
let APIUpdatePasswordMessage = "Updating Password"
let APINotificationMessage = "Loading Notification"
let APIMenuMessage = "Loading Menu"
let APIFeedsMessage = "Loading Feeds"
let SomethingWrongMessage = "Something was wrong"
let PleaseTryAgainMessage = "Please try again after sometime"
let APIGetUserProfileMessage = "Get Your Profile"
let APIAddChannelMessage = "Add Channel"
let APIMyChannelMessage = "Get My Channel"
let APIAddChannelVideoMessage = "Add Channel Video"
let APIGetAllChannelVideoMessage = "Get All Channel Video"
let APIGetSingalChannelVideoMessage = "Get Channel Video"
let APIUpdateUserMessage = "Update User Info"
let APIGetAllNotificationMessage = "Get Notification"
let APIUpdateUserPhotoMessage = "Update User Photo"
let APIUpdateUserBannerMessage = "Update User Banner Photo"
let APICheckUserWithPhoneMessage = "Please Wait"
let APIAddFeedbackMessage = "Sending Feedback"

//MARK:- API SERVICE NAMES
let NoResponseKey = "NoKey"
let ResponseKey = "data"

let APILogin = "login"
let APIVerifyUser = "verify_user"
let APISendOTP = "sendOTP"
let APILogOut = "logout"
let APIForgotPassword = "forgotpassword"
let APIUpdateUser = "update_user"
let APIPostFeeds = "add_post"
let APIGetTags = "get_all_tags"
let APIGetAllPost = "get_all_post"
let APIGetAllStatus = "get_all_status"
let APISyncContacts = "contact_sync"
let APIGetGroupInfo = "get_group_info"
let APIAddGroupAdmin = "add_group_admin"
let APIRemoveGroupAdmin = "remove_group_admin"
let APIChangeGroupName = "change_group_name"
let APIChangeGroupPhoto = "change_group_photo"
let APIExitGroup = "exit_group"
let APIGetUserProfile = "get_user_profile"
let APIUpdateUserProfile = "update_user"
let APIAddChannel = "add_channel"
let APIMyChannel = "my_channel"
let APIAddChannelVideo = "add_channel_video"
let APIAllChannelVideo = "get_all_channel_video"
let APIAddChannelLike = "add_channel_like"
let APIViewChannelVideo = "view_channel_video"
let APIAddChannelSubscribe = "add_channel_subscribe"
let APIGetSingalChannelVideo = "get_single_channel_video"
let APIAddChannelComment = "add_channel_comment"
let APIRemoveChannelComment = "remove_channel_comment"
let APIgetUserFollowing = "get_user_following" 
let APIFollowList = "follow_list" 
let APIUpdateChannel = "edit_channel" 
let APIGetSingalChannelDetails = "get_single_channel_details" 
let APIGetChannel_VideoCommentsLikes = "get_channelvideo_comments_likes" 
let APIGetSubscribeList = "get_subscribe_list" 
let APIUserFollow = "user_follow" 
let APIDeleteChannelVideo = "delete_channel_video"
let APIAddPostLike = "add_post_like"
let APIDeletePost  = "delete_post"
let APIGetAllPostLikeComment = "get_all_post_like_comment"
let APIAddPostComment = "add_post_comment"
let APIRemovePostComment = "remove_post_comment"
let APIUpdateUserSettings = "update_user_settings"
let APIGetAllNotification = "get_all_notification"
let APIUpdateStatusSetting = "updateStatusSetting"
let APIBlockUser = "blockUser"
let APIChangeNumber_SendOTP = "changeNumber"
let APIChangeNumber_VerficationByOTP = "changeNumberVerfication"
let APIGetUserBlocked = "getUserBlocked"
let APISearching_Contact = "searching"
let APISearching_Channel = "searching"
let APIReportSpam = "reportSpam"
let APIEditProfilePic = "editProfilePic"
let APIEditCoverPic = "editCoverPic"
let APICheckUserExistsWithPhone = "checkUserExistsWithPhone"
let APIAddFeedback = "addFeedback"
