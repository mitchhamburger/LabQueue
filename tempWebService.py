#!flask/bin/python
from flask import Flask, jsonify, abort, make_response, request
import time
from apns import APNs, Frame, Payload
import sys
import logging
app = Flask(__name__)

LabTAs = [
	{
		'First Name': u"Mitchell",
		'Last Name': u"Hamburger",
		'NetID': u"mh20",
		'Class Year': 2018,
		'Is Active': True
	},
	{
		'First Name': u"Harry",
		'Last Name': u"Heffernan",
		'NetID': u"hmlh",
		'Class Year': 2018,
		'Is Active': False
	},
	{
		'First Name': u"Sergio",
		'Last Name': u"Cruz",
		'NetID': u"slc2",
		'Class Year': 2018,
		'Is Active': True
	}
]
Tokens = [
	{
		'NetID': 'mh20'
	}
]

Students = [
	{
		'Name': u"Matt McKinlay",
		'NetID': u"mckinlay",
		'Help Message': u"I don't know how to code",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"9:00",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 126"
	},
	{
		'Name': u"Sam Button",
		'NetID': u"sbutton",
		'Help Message': u"Chunks",
		'Been Helped': True,
		'Canceled': False,
		'In Queue': False,
		'Request Time': u"10:00",
		'Helped Time': u"10:30",
		'Attending TA': u"Mitchell Hamburger",
		'Course': u"COS 217"
	},
	{
		'Name': u"Rohan Patlolla",
		'NetID': u"rohanp",
		'Help Message': u"nbody",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"8:00",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 126"
	},
	{
		'Name': u"Austin Addison",
		'NetID': u"aaddison",
		'Help Message': u"I don't know how to code",
		'Been Helped': False,
		'Canceled': True,
		'In Queue': False,
		'Request Time': u"8:30",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 226"
	},
	{
		'Name': u"Maia Ezratty",
		'NetID': u"mezratty",
		'Help Message': u"iudhfivudhfiv",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"7:25",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 109"
	},
	{
		'Name': u"Jason Hamburger",
		'NetID': u"jh45",
		'Help Message': u"I need help",
		'Been Helped': True,
		'Canceled': False,
		'In Queue': False,
		'Request Time': u"7:25",
		'Helped Time': u" 8:30",
		'Attending TA': u"Mitch Hamburger",
		'Course': u"COS 109"
	},
	{
		'Name': u"Alexa Wojak",
		'NetID': u"awojak",
		'Help Message': u"oidfvfvfvfv",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"10:00",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 226"
	},
	{
		'Name': u"Zach Bedrosian",
		'NetID': u"zbedrosian",
		'Help Message': u"I don't need help with anything",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"7:25",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Alex Manoloff",
		'NetID': u"amanoloff",
		'Help Message': u"I'm not in any of these classes",
		'Been Helped': False,
		'Canceled': True,
		'In Queue': False,
		'Request Time': u"5:00",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Will Robinson",
		'NetID': u"laxerwill85",
		'Help Message': u"I need answers",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"9:05",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Gregor Clegane",
		'NetID': u"gc23",
		'Help Message': u"I can't type",
		'Been Helped': True,
		'Canceled': False,
		'In Queue': False,
		'Request Time': u"7:25",
		'Helped Time': u"7:30",
		'Attending TA': u"Harry Heffernan",
		'Course': u"COS 217"
	},
	{
		'Name': u"Colin Hay",
		'NetID': u"chay",
		'Help Message': u"I don't understand percolation",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"7:45",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 226"
	}
]


Queue = [
	{
		'Name': u"Matt McKinlay",
		'NetID': u"mckinlay",
		'Help Message': u"I don't know how to code",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"9:00",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 126"
	},
	{
		'Name': u"Sam Button",
		'NetID': u"sbutton",
		'Help Message': u"Chunks",
		'Been Helped': True,
		'Canceled': False,
		'In Queue': False,
		'Request Time': u"10:00",
		'Helped Time': u"10:30",
		'Attending TA': u"Mitchell Hamburger",
		'Course': u"COS 217"
	},
	{
		'Name': u"Rohan Patlolla",
		'NetID': u"rohanp",
		'Help Message': u"nbody",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"8:00",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 126"
	},
	{
		'Name': u"Austin Addison",
		'NetID': u"aaddison",
		'Help Message': u"I don't know how to code",
		'Been Helped': False,
		'Canceled': True,
		'In Queue': False,
		'Request Time': u"8:30",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 226"
	},
	{
		'Name': u"Maia Ezratty",
		'NetID': u"mezratty",
		'Help Message': u"iudhfivudhfiv",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"7:25",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 109"
	},
	{
		'Name': u"Jason Hamburger",
		'NetID': u"jh45",
		'Help Message': u"I need help",
		'Been Helped': True,
		'Canceled': False,
		'In Queue': False,
		'Request Time': u"7:25",
		'Helped Time': u" 8:30",
		'Attending TA': u"Mitch Hamburger",
		'Course': u"COS 109"
	},
	{
		'Name': u"Alexa Wojak",
		'NetID': u"awojak",
		'Help Message': u"oidfvfvfvfv",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"10:00",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 226"
	},
	{
		'Name': u"Zach Bedrosian",
		'NetID': u"zbedrosian",
		'Help Message': u"I don't need help with anything",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"7:25",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Alex Manoloff",
		'NetID': u"amanoloff",
		'Help Message': u"I'm not in any of these classes",
		'Been Helped': False,
		'Canceled': True,
		'In Queue': False,
		'Request Time': u"5:00",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Will Robinson",
		'NetID': u"laxerwill85",
		'Help Message': u"I need answers",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"9:05",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Gregor Clegane",
		'NetID': u"gc23",
		'Help Message': u"I can't type",
		'Been Helped': True,
		'Canceled': False,
		'In Queue': False,
		'Request Time': u"7:25",
		'Helped Time': u"7:30",
		'Attending TA': u"Harry Heffernan",
		'Course': u"COS 217"
	},
	{
		'Name': u"Colin Hay",
		'NetID': u"chay",
		'Help Message': u"I don't understand percolation",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': u"7:45",
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 226"
	}
]

Tokens = [ 
	{
	'NetID': u'mh20',
	'Device Tokens': [{
			'id': 1,
			'Token': u'a5b1a0b1cac5cb91ae0f22da18067f3653ae55d636be570007e3fdb11204c064'
		},
		{
			'id': 2,
			'Token': u'idufjviudhfivuhdfiuvhwiuhvidufhvidfhvidfhvidfhviudfviuhdfivuhdfi'
		},
		{
			'id': 3,
			'Token': u'3af63949a84b3fad2410a5b12df07ff3127fb6b9c86e9ab8fd455f1eb3533414'
		}] 
	}
]

@app.route('/LabQueue/v1/Tokens/<netid>/RegisterDeviceToken', methods = ['POST'])
def registerDeviceToken(netid):
	if not request.json:
		abort(400)

	entry = [entry for entry in Tokens if entry['NetID'] == netid]
	if len(entry) == 0:
		newEntry = {
			'NetID': netid,
			'Device Tokens': [{'id': 1, 'Token': request.json['Device Token']}]
		}
		Tokens.append(newEntry)
		return jsonify({'AllTokens': Tokens}), 201
	else:
		newEntry = {
			'id': (len(entry[0]['Device Tokens']) + 1),
			'Token': request.json['Device Token']
		}
		entry[0]['Device Tokens'].append(newEntry)
		return jsonify({'AllTokens': Tokens}), 201

@app.route('/LabQueue/v1/Tokens/<netid>/GetToken', methods = ['GET'])
def getToken(netid):
	return getTokenFromID(netid)

def getTokenFromID(netid):
	entry = [entry for entry in Tokens if entry['NetID'] == netid]
	if len(entry) == 0:
		return ""
	else:
		return entry[0]['Device Tokens'][len(entry[0]['Device Tokens']) - 1]['Token']

def notifyUser(netid):
	userToken = getTokenFromID(netid)
	if userToken == "":
		return "invalid netid"
	else:
		CERT_FILE = 'LabQueuePush.pem'
		USE_SANDBOX=True
		apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)
		payload = Payload(alert="Poop!", sound="default")                                      
		identifier = 1
		expiry = time.time() + 3600
		priority = 10
		frame = Frame()
		frame.add_item(userToken, payload, identifier, expiry, priority)
		apns.gateway_server.send_notification_multiple(frame)
		return "notification success"



@app.route('/LabQueue/v1/Queue', methods = ['GET', 'POST'])
def fullQueueOps():
	if request.method == 'GET':
		return jsonify({'Queue': Queue})
	else:
		if not request.json:
			abort(400)
		newEntry = {
			'Name': request.json['Name'],
			'NetID': request.json['NetID'],
			'Help Message': request.json['Help Message'],
			'Been Helped': False,
			'Canceled': False,
			'In Queue': True,
			'Request Time': request.json['Request Time'],
			'Helped Time': u"",
			'Attending TA': u"",
			'Course': request.json['Course']
		}
		Queue.append(newEntry)
		return jsonify({'Queue': Queue}), 201

@app.route('/LabQueue/v1/Queue/<netid>/Delete', methods = ['GET'])
def singleUserOps(netid):
	if request.method == 'GET':
		entry = [entry for entry in Queue if entry['NetID'] == netid]
		if len(entry) == 0:
			abort(404)
		Queue.remove(entry[0])
		return jsonify({'Queue': Queue})

@app.route('/LabQueue/v1/Queue/<netid>/Helped', methods = ['POST'])
def markAsHelped(netid):
	entry = [entry for entry in Queue if entry['NetID'] == netid]
	if len(entry) == 0:
		abort(404)
	entry[0]['Been Helped'] = True
	entry[0]['In Queue'] = False
	entry[0]['Helped Time'] = request.json['Helped Time']
	entry[0]['Attending TA'] = request.json['Attending TA']
	Queue.remove(entry[0])
	return jsonify({'entry': entry[0]})

@app.route('/LabQueue/v1/TAs/<netid>/Verify', methods = ['GET'])
def verify(netid):
	entry = [entry for entry in LabTAs if entry['NetID'] == netid]
	if len(entry) == 0:
		return "Student"
	else:
		return "TA"

@app.route('/LabQueue/v1/Queue/<netid>/Canceled', methods = ['GET'])
def markAsCanceled(netid):
	entry = [entry for entry in Queue if entry['NetID'] == netid]
	if len(entry) == 0:
		abort(404)
	entry[0]['In Queue'] = False
	entry[0]['Canceled'] = True
	Queue.remove(entry[0])
	return jsonify({'entry': entry[0]})

@app.route('/LabQueue/v1/TAs/<netid>/MarkActive', methods = ['GET'])
def markAsActive(netid):
	ta = [ta for ta in LabTAs if ta['NetID'] == email]
	if len(ta) == 0:
		abort(404)
	ta[0]['Is Active'] = True
	return jsonify({'TAs': LabTAs})

@app.route('/LabQueue/v1/TAs/<netid>/MarkInactive', methods = ['GET'])
def markAsInactive(netid):
	ta = [ta for ta in LabTAs if ta['NetID'] == email]
	if len(ta) == 0:
		abort(404)
	ta[0]['Is Active'] = False
	return jsonify({'TAs': LabTAs})

@app.route('/LabQueue/v1/TAs/<netid>/Delete', methods = ["GET"])
def deleteTA(netid):
	if request.method == 'DELETE':
		entry = [entry for entry in LabTAs if entry['NetID'] == email]
		if len(entry) == 0:
			abort(404)
		LabTAs.remove(entry[0])
		return jsonify({'TAs': LabTAs})

@app.route('/LabQueue/v1/TAs', methods = ['GET', 'POST'])
def allTAOps():
	if request.method == 'GET':
		return jsonify({'TAs': LabTAs})
	else:
		newTA = {
			'First Name': request.json['First Name'],
			'Last Name': request.json['Last Name'],
			'NetID': request.json['NetID'],
			'Class Year': request.json['Class Year'],
			'isActive': request.json['Is Active']
		}
		LabTAs.append(newTA)
		return jsonify({'TAs': LabTAs})

def sendNotification(netid):
	CERT_FILE = 'LabQueuePush.pem'
	USE_SANDBOX=True
	ZACH = '4b1a5b8a8f5dc1b414ff0db55a8fe49c385a163268beb0cce9de69352b9c009b'

	apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)

	# Send a notification                                                                                                               
	token_hex = '3af63949a84b3fad2410a5b12df07ff3127fb6b9c86e9ab8fd455f1eb3533414'
	payload = Payload(alert="Poop!", sound="default", badge=1)
	#apns.gateway_server.send_notification(token_hex, payload)                                                                          

	identifier = 1
	expiry = time.time() + 3600
	priority = 10
	frame = Frame()
	frame.add_item(token_hex, payload, identifier, expiry, priority)
	apns.gateway_server.send_notification_multiple(frame)

if __name__ == '__main__':
	notifyUser('mh20')
	app.run(debug = True)


