import time
from apns import APNs, Frame, Payload
import sys
import logging

CERT_FILE = 'LabQueuePush.pem'
USE_SANDBOX=True
ZACH = '4b1a5b8a8f5dc1b414ff0db55a8fe49c385a163268beb0cce9de69352b9c009b'

apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)

# Send a notification
token_hex = '7b45ee4d83ac7855ea1996ac6f6b9f82871f23c83ebafb0ce7607a0c4fbe5031'
payload = Payload(alert="Hi Dean", sound="default", badge=1)
#apns.gateway_server.send_notification(token_hex, payload)
#apns.gateway_server.send_notification('4b1a5b8a8f5dc1b414ff0db55a8fe49c385a163268beb0cce9de69352b9c009b', payload)

identifier = 1
expiry = time.time() + 3600
priority = 10
frame = Frame()
frame.add_item(token_hex, payload, identifier, expiry, priority)
apns.gateway_server.send_notification_multiple(frame)
frame = Frame()
frame.add_item(ZACH, payload, identifier, expiry, priority)
apns.gateway_server.send_notification_multiple(frame)

# Send multiple notifications in a single transmission
#frame = Frame()
#identifier = 1
#expiry = time.time()+3600
#priority = 10
#frame.add_item('b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b87', payload, identifier, expiry, priority)

#frame.add_item('4b1a5b8a8f5dc1b414ff0db55a8fe49c385a163268beb0cce9de69352b9c009b', payload, identifier, expiry, priority)
#apns.gateway_server.send_notification_multiple(frame)