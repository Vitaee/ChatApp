from email.policy import default
from firebase_admin import messaging, credentials, delete_app, get_app
import datetime, firebase_admin



def send_notification(datas: list, deviceToken: str):
    """
    This function will trigger firebase push notification.

    Args:
        deviceToken: receiver device token: ``str``
        datas: A dictionary of data fields. Example data;

        ``datas = { "title": "sender_username", "body":"hello!", "sender_image":"localhost/images/profileurl", ... }``.

    Finally, will return response. 
    """
    
    
    try:
        firebase_cred = credentials.Certificate("./pushnotif-78183-firebase-adminsdk-dwgqs-50f4ba7d6f.json")
        firebase_app = firebase_admin.initialize_app(firebase_cred)
    except:   pass

    print()
    print("\n\n\n\nNotif data in backend -->", datas['chats'][-1], "\n\n\n\n")
    print()
    
    message = messaging.Message(
        data= datas["chats"][-1],
        notification=messaging.Notification(
            title=f"{datas['chats'][-1]['currentUser']}",
            body=f"{datas['chats'][-1]['lastMessage']}",
        ),
        #android=messaging.AndroidConfig(
        #    ttl=datetime.timedelta(seconds=3600),
        #    priority='normal',
        #    notification=messaging.AndroidNotification(
        #        icon='stock_ticker_update',
        #        color='#f45342'
        #    ),
        #),
        apns=messaging.APNSConfig(
            payload=messaging.APNSPayload(
                aps=messaging.Aps(badge=42),
            ),
        ),
        #android=messaging.AndroidConfig(notification=messaging.AndroidNotification(image="")) should put sender user image.

        #topic='industry-tech',
        #token=device_token,
        token = deviceToken
   

    )

    
    return messaging.send(message)

#send_notification([{ "title": "sloon", "body":"hello bro!"}], "droA182wRrivyJi3GInMFv:APA91bGKXbWWq6uQc3v1ZwpjBfFxqMHyl5IG8cW6_QD35Fu88HYfZjRdUZsXbqPoxEwD2KPtH3m8gUmw0Yvfx3FONXufDyhub-e_U5lueyTDLRxNcYM_uOO-yho2vLL6k9RwEk-9lmdB")