from firebase_admin import messaging, credentials
import datetime, firebase_admin



def send_notification(data: list, deviceToken: str):
    """
    This function will trigger firebase push notification.

    Args:
        deviceToken: receiver device token: ``str``
        data: A dictionary of data fields. Example data;

        ``data = { "title": "sender_username", "body":"hello!", "sender_image":"localhost/images/profileurl", ... }``.

    Finally, will return response.
    """
    firebase_cred = credentials.Certificate("/home/vitae/Desktop/Sprojects/OtherProjects/ChatApp/api_app/app/common/pushnotif-78183-firebase-adminsdk-dwgqs-50f4ba7d6f.json")
    firebase_app = firebase_admin.initialize_app(firebase_cred)
    
    #device_token = "droA182wRrivyJi3GInMFv:APA91bGKXbWWq6uQc3v1ZwpjBfFxqMHyl5IG8cW6_QD35Fu88HYfZjRdUZsXbqPoxEwD2KPtH3m8gUmw0Yvfx3FONXufDyhub-e_U5lueyTDLRxNcYM_uOO-yho2vLL6k9RwEk-9lmdB"

    print()
    print(str(data))
    print()
    
    message = messaging.Message(
        notification=messaging.Notification(
            title=f"{data[-1]['user']}",
            body=f"{data[-1]['data']}",
        ),
        #android=messaging.AndroidConfig(
        #    ttl=datetime.timedelta(seconds=3600),
        #    priority='normal',
        #    notification=messaging.AndroidNotification(
        #        icon='stock_ticker_update',
        #        color='#f45342'
        #    ),
        #),
        data= data[-1],
        apns=messaging.APNSConfig(
            payload=messaging.APNSPayload(
                aps=messaging.Aps(badge=42),
            ),
        ),

        #topic='industry-tech',
        #token=device_token,
        token = deviceToken
   

    )
    

    return messaging.send(message)

#send_notification([{ "title": "sloon", "body":"hello bro!"}], "droA182wRrivyJi3GInMFv:APA91bGKXbWWq6uQc3v1ZwpjBfFxqMHyl5IG8cW6_QD35Fu88HYfZjRdUZsXbqPoxEwD2KPtH3m8gUmw0Yvfx3FONXufDyhub-e_U5lueyTDLRxNcYM_uOO-yho2vLL6k9RwEk-9lmdB")