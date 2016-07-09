#!flask/bin/python
from flask import Flask, jsonify, abort, make_response, request
import datetime
import time
from apns import APNs, Frame, Payload
import sys
import logging
import os
import zlib

app = Flask(__name__)

SILENTENQUEUE = 'SilentEnqueue'
SILENTREMOVE = 'SilentRemove'
NOTIFYTEN = 'NotifyTen'
NOTIFYFIVE = 'NotifyFive'
NOTIFYMATCH = 'NotifyMatch'

LabTAs = [
	{
		'First Name': u"Mitchell",
		'Last Name': u"Hamburger",
		'NetID': u"mh20",
		'Class Year': 2018,
		'Is Active': True
	},
	{
		'First Name': u"Sergio",
		'Last Name': u"Cruz",
		'NetID': u"slc2",
		'Class Year': 2018,
		'Is Active': True
	}
]

HelpRequests = [
	{
		'Name': u"Matt McKinlay",
		'NetID': u"mckinlay",
		'Help Message': u"I don't know how to code",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 126"
	},
	{
		'Name': u"Sam Button",
		'NetID': u"sbutton",
		'Help Message': u"Chunks",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Rohan Patlolla",
		'NetID': u"rohanp",
		'Help Message': u"nbody",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 126"
	},
	{
		'Name': u"Austin Addison",
		'NetID': u"aaddison",
		'Help Message': u"I don't know how to code",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
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
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 109"
	},
	{
		'Name': u"Jason Hamburger",
		'NetID': u"jh45",
		'Help Message': u"I need help",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 109"
	},
	{
		'Name': u"Alexa Wojak",
		'NetID': u"awojak",
		'Help Message': u"oidfvfvfvfv",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
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
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Alex Manoloff",
		'NetID': u"amanoloff",
		'Help Message': u"I'm not in any of these classes",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
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
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Gregor Clegane",
		'NetID': u"gc23",
		'Help Message': u"I can't type",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'Name': u"Colin Hay",
		'NetID': u"chay",
		'Help Message': u"I don't understand percolation",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 226"
	}
]

Tokens = [ 
	{
	'NetID': u'mh20',
	'Device Tokens': [
					u'a5b1a0b1cac5cb91ae0f22da18067f3653ae55d636be570007e3fdb11204c064',
					u'idufjviudhfivuhdfiuvhwiuhvidufhvidfhvidfhvidfhviudfviuhdfivuhdfi',
					u'3af63949a84b3fad2410a5b12df07ff3127fb6b9c86e9ab8fd455f1eb3533414'
					] 
	}
]

@app.route('/LabQueue/v2/<senderID>/Verify', methods = ['GET'])
def verifyUser(senderID):
	entry = [entry for entry in LabTAs if entry['NetID'] == senderID]
	if len(entry) == 0:
		return "Student"
	else:
		return "TA"

@app.route('/LabQueue/v2/<senderID>/Tokens/RegisterDeviceToken', methods = ['POST'])
def registerDeviceToken(senderID):
	if not request.json:
		abort(400)
	entry = [entry for entry in Tokens if entry['NetID'] == senderID]
	if len(entry) == 0:
		newEntry = {
			'NetID': senderID,
			'Device Tokens': [request.json['Device Token']]
		}
		Tokens.append(newEntry)
		return jsonify({'AllTokens': Tokens}), 201
	else:
		entry[0]['Device Tokens'].append(request.json['Device Token'])
		return jsonify({'AllTokens': Tokens}), 201

@app.route('/LabQueue/v2/<senderID>/Requests', methods = ['GET', 'POST'])
def fullQueueOps(senderID):
	if request.method == 'GET':
		activeQueue = []
		for entry in HelpRequests:
			if entry['In Queue'] == True:
				activeQueue.append(entry)
		return jsonify({'Queue': activeQueue})
	else:
		if not request.json:
			abort(400)
		newEntry = {
			'Name': request.json['Name'],
			'NetID': senderID,
			'Help Message': request.json['Help Message'],
			'Been Helped': False,
			'Canceled': False,
			'In Queue': True,
			'Request Time': datetime.datetime.now(),
			'Helped Time': u"",
			'Attending TA': u"",
			'Course': request.json['Course']
		}
		syncToken = getSyncToken()
		HelpRequests.append(newEntry)

		info = {
			'Name': request.json['Name'], 
			'NetID': senderID,
			'Help Message': request.json['Help Message'],
			'Course': request.json['Course']
			}
		notifyActiveUsers(senderID, SILENTENQUEUE, "", info, syncToken)
		return jsonify({'Queue': HelpRequests}), 201

@app.route('/LabQueue/v2/<senderID>/Requests/<requestID>/Helped', methods = ['GET'])
def markAsHelped(senderID, requestID):
	entry = [entry for entry in HelpRequests if entry['NetID'] == requestID and entry['In Queue'] == True]
	if len(entry) == 0:
		abort(404)
	else:
		syncToken = getSyncToken()
		entry[0]['Been Helped'] = True
		entry[0]['Helped Time'] = datetime.datetime.now()
		entry[0]['In Queue'] = False
		entry[0]['Attending TA'] = senderID
		activeQueue = []
		for entry in HelpRequests:
			if entry['In Queue'] == True:
				activeQueue.append(entry)
		notifyUser(senderID, requestID, NOTIFYMATCH, "", [], syncToken)
		if len(activeQueue) > 9:
			notifyUser(senderID, activeQueue[9]['NetID'], NOTIFYTEN, "", [], syncToken)
		if len(activeQueue) > 4:
			notifyUser(senderID, activeQueue[4]['NetID'], NOTIFYFIVE, "", [], syncToken)
		notifyActiveUsers(senderID, SILENTREMOVE, requestID, [], syncToken)
		return jsonify({requestID: entry}), 201

@app.route('/LabQueue/v2/<senderID>/Requests/<requestID>/Canceled', methods = ['GET'])
def markAsCanceled(senderID, requestID):
	entry = [entry for entry in HelpRequests if entry['NetID'] == requestID and entry['In Queue'] == True]
	if len(entry) == 0:
		abort(404)
	else:
		syncToken = getSyncToken()
		entry[0]['Canceled'] = True
		entry[0]['In Queue'] = False
		activeQueue = []
		for entry in HelpRequests:
			if entry['In Queue'] == True:
				activeQueue.append(entry)
		if len(activeQueue) > 9:
			notifyUser(senderID, activeQueue[9]['NetID'], NOTIFYTEN, "", [], syncToken)
		if len(activeQueue) > 4:
			notifyUser(senderID, activeQueue[4]['NetID'], NOTIFYFIVE, "", [], syncToken)
		notifyActiveUsers(senderID, SILENTREMOVE, requestID, [], syncToken)
		return jsonify({requestID: entry}), 201

@app.route('/LabQueue/v2/<senderID>/TAs/ActiveTAs', methods = ['GET'])
def getActiveTAs(senderID):
	activeTAs = []
	for entry in LabTAs:
		if entry['Is Active'] == True:
			activeTAs.append(entry)
	return jsonify({'TAs': activeTAs}), 201

@app.route('/LabQueue/v2/<senderID>/Sync', methods = ['POST'])
def verifySync(senderID):
	currentToken = getSyncToken()
	userToken = request.json['Sync Token']
	if userToken == currentToken:
		return jsonify({"Response": "In Sync"}), 201
	else:
		return jsonify({"Response": "Out of Sync"}), 201

def notifyActiveUsers(senderID, notificationType, removeID, enqueueStudentInfo, syncToken):
	for entry in HelpRequests:
		if entry['In Queue'] == True:
			notifyUser(senderID, entry['NetID'], notificationType, removeID, enqueueStudentInfo, syncToken)
	for entry in LabTAs:
		if entry['Is Active'] == True:
			notifyUser(senderID, entry['NetID'], notificationType, removeID, enqueueStudentInfo, syncToken)

def notifyUser(senderID, recieverID, notificationType, removeID, enqueueStudentInfo, syncToken):
	if senderID == recieverID:
		return "sender is reciever"
	userToken = getTokenFromID(recieverID)
	CERT_FILE = 'LabQueuePush.pem'
	USE_SANDBOX = True
	apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)
	if notificationType == SILENTENQUEUE:
		payload = Payload(content_available = 1, custom = {'type': 'SilentEnqueue', 'studentinfo': enqueueStudentInfo, 'Sync Token': syncToken})
	elif notificationType == SILENTREMOVE:
		payload = Payload(content_available = 1, custom = {'type': 'SilentRemove', 'id': removeID, 'Sync Token': syncToken})
	elif notificationType == NOTIFYMATCH:
		entry = [entry for entry in LabTAs if entry['NetID'] == senderID and entry['Is Active'] == True]
		if len(entry) == 0:
			return
		payload = Payload(alert=entry[0]['First Name'] + " " + entry[0]['Last Name'] +" is coming to help you", sound="default", custom = {'id': senderID, 'Sync Token': syncToken})
	elif notificationType == NOTIFYTEN:
		payload = Payload(alert="There are 10 students ahead of you in the queue.", sound="default", custom = {'type': NOTIFYTEN, 'id': senderID, 'Sync Token': syncToken})
	elif notificationType == NOTIFYFIVE:
		payload = Payload(alert="There are 5 students ahead of you in the queue.", sound="default", custom = {'type': NOTIFYFIVE, 'id': senderID, 'Sync Token': syncToken})
	#identifier = 1
	#expiry = time.time() + 3600
	#priority = 10
	#frame = Frame()
	#frame.add_item(userToken, payload, identifier, expiry, priority)
	#apns.gateway_server.send_notification_multiple(frame)
	apns.gateway_server.send_notification(userToken, payload)
	return 'notification success'

def getTokenFromID(netid):
	entry = [entry for entry in Tokens if entry['NetID'] == netid]
	if len(entry) == 0:
		return ""
	else:
		return entry[0]['Device Tokens'][len(entry[0]['Device Tokens']) - 1]

def getSyncToken():
	hashString = ""
	count = 0
	for entry in HelpRequests:
		if entry['In Queue'] == True:
			hashString += entry['NetID']
			count += 1
	hashString += ','
	hashString += str(count)
	return hashString

if __name__ == '__main__':
	print(zlib.adler32("mckinlaysbuttonrohanpaaddisonmezrattyjh45awojakzbedrosianamanolofflaxerwill85gc23chay,12"))
	app.run(debug = True)


