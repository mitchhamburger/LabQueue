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

options = {
	SILENTREMOVE: handleSilentRemove,
	SILENTENQUEUE: handleSilentEnqueue,
	NOTIFYMATCH: handleNotifyMatch,
	NOTIFYFIVE: handleNotifyFive,
	NOTIFYTEN: handleNotifyTen
}

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
		'RequestID': 0,
		'Name': u"Matt McKinlay",
		'NetID': u"mckinlay",
		'Help Message': u"I have to eat maple syrup but I dont have a spoon or pancakes or anything else that you eat syrup with",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 126"
	},
	{
		'RequestID': 1,
		'Name': u"Sam Button",
		'NetID': u"sbutton",
		'Help Message': u"I just dont get any of it I wrestle so my head dont work so good with concussions and all of that etc loreum episoum",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 217"
	},
	{
		'RequestID': 2,
		'Name': u"Rohan Patlolla",
		'NetID': u"rohanp",
		'Help Message': u"I have never taken a cos course so I want help with cos 126 with the nbody and recursion is too much",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 126"
	},
	{
		'RequestID': 3,
		'Name': u"Austin Addison",
		'NetID': u"aaddison",
		'Help Message': u"im austin and i like to dance at the cap and gown club because its good fun to dance at the club",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 226"
	},
	{
		'RequestID': 4,
		'Name': u"Michael East",
		'NetID': u"mteast",
		'Help Message': u"i ate stump and now I'm sick as a dog",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 109"
	},
	{
		'RequestID': 5,
		'Name': u"Jason Hamburger",
		'NetID': u"jh45",
		'Help Message': u"Im in arizona so i dont know how to take cos 109 but i can start a fire with my feet i think",
		'Been Helped': False,
		'Canceled': False,
		'In Queue': True,
		'Request Time': datetime.datetime.now(),
		'Helped Time': u"",
		'Attending TA': u"",
		'Course': u"COS 109"
	},
	{
		'RequestID': 6,
		'Name': u"Alexa Wojak",
		'NetID': u"jlumbroso",
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
		'RequestID': 7,
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
		'RequestID': 8,
		'Name': u"Alex Manoloff",
		'NetID': u"acm4",
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
		'RequestID': 9,
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
		'RequestID': 10,
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
		'RequestID': 11,
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
		activeQueue = getActiveQueue()
		return jsonify({'Queue': activeQueue})
	else:
		if not request.json:
			abort(400)
		index = len(HelpRequests)
		newEntry = {
			'RequestID': index,
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
			'Course': request.json['Course'],
			'RequestID': index
			}
		handleSilentEnqueue(senderID, info, syncToken)
		return jsonify({'RequestID': index}), 201

@app.route('/LabQueue/v2/<senderID>/Requests/<requestID>/Helped', methods = ['GET'])
def markAsHelped(senderID, requestID):
	bigentry = [entry for entry in HelpRequests if entry['RequestID'] == int(requestID)]
	if len(entry) == 0:
		abort(404)
	else:
		alreadyCanceled = bigentry[0]['In Queue']
		syncToken = getSyncToken()
		bigentry[0]['Been Helped'] = True
		bigentry[0]['Helped Time'] = datetime.datetime.now()
		bigentry[0]['In Queue'] = False
		bigentry[0]['Attending TA'] = senderID
		activeQueue = []
		for entry in HelpRequests:
			if entry['In Queue'] == True:
				activeQueue.append(entry)
		handleNotifyMatch(senderID, bigentry[0]['NetID'], syncToken)
		handleNotifyFive(senderID, syncToken)
		handleNotifyTen(senderID, syncToken)
		if alreadyCanceled == True:
			handleSilentRemove(senderID, requestID, syncToken)
		return jsonify({bigentry[0]['NetID']: bigentry}), 201

@app.route('/LabQueue/v2/<senderID>/Requests/<requestID>/Canceled', methods = ['GET'])
def markAsCanceled(senderID, requestID):
	bigentry = [entry for entry in HelpRequests if entry['RequestID'] == int(requestID)]
	if len(entry) == 0:
		abort(404)
	else:
		alreadyCanceled = bigentry[0]['In Queue']
		syncToken = getSyncToken()
		bigentry[0]['Canceled'] = True
		bigentry[0]['In Queue'] = False
		activeQueue = getActiveQueue()
		handleNotifyFive(senderID, syncToken)
		handleNotifyTen(senderID, syncToken)
		if alreadyCanceled == True:
			handleSilentRemove(senderID, requestID, syncToken)
		return jsonify({bigentry[0]['NetID']: bigentry}), 201

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

def handleSilentRemove(senderID, removeID, syncToken):
	activeUsers = getAllActiveUsers()
	CERT_FILE = 'LabQueuePush.pem'
	USE_SANDBOX = True
	apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)
	payload = Payload(content_available = 1, custom = {'type': 'SilentRemove', 'id': int(removeID), 'Sync Token': syncToken})
	for entry in activeUsers:
		if entry['NetID'] != senderID:
			userToken = getTokenFromID(entry['NetID'])
			apns.gateway_server.send_notification(userToken, payload)
	return 'Notification success'

def handleSilentEnqueue(senderID, enqueueStudentInfo, syncToken):
	activeUsers = getAllActiveUsers()
	CERT_FILE = 'LabQueuePush.pem'
	USE_SANDBOX = True
	apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)
	payload = Payload(content_available = 1, custom = {'type': 'SilentEnqueue', 'studentinfo': enqueueStudentInfo, 'Sync Token': syncToken})
	for entry in activeUsers:
		if entry['NetID'] != senderID:
			userToken = getTokenFromID(entry['NetID'])
			apns.gateway_server.send_notification(userToken, payload)
	return 'notification success'

def handleNotifyMatch(senderID, receiverID, syncToken):
	receiverToken = getTokenFromID(receiverID)
	entry = [entry for entry in LabTAs if entry['NetID'] == senderID and entry['Is Active'] == True]
	message = entry[0]['First Name'] + " " + entry[0]['Last Name'] + " is coming to help you"
	CERT_FILE = 'LabQueuePush.pem'
	USE_SANDBOX = True
	apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)
	payload = Payload(content_available = 1, alert=message, sound="default", custom = {'type': NOTIFYMATCH, 'id': senderID, 'Sync Token': syncToken})
	apns.gateway_server.send_notification(receiverToken, payload)

def handleNotifyFive(senderID, syncToken):
	activeQueue = getActiveQueue()
	if len(activeQueue) <= 4:
		return
	receiverToken = getTokenFromID(activeQueue[4]['NetID'])
	message = "There are 5 students ahead of you in the queue."
	CERT_FILE = 'LabQueuePush.pem'
	USE_SANDBOX = True
	apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)
	payload = Payload(alert=message, sound="default", custom = {'type': NOTIFYFIVE, 'id': senderID, 'Sync Token': syncToken})
	apns.gateway_server.send_notification(receiverToken, payload)

def handleNotifyTen(senderID, syncToken):
	activeQueue = getActiveQueue()
	if len(activeQueue) <= 9:
		return
	receiverToken = getTokenFromID(activeQueue[9]['NetID'])
	message = "There are 10 students ahead of you in the queue."
	CERT_FILE = 'LabQueuePush.pem'
	USE_SANDBOX = True
	apns = APNs(use_sandbox=USE_SANDBOX, cert_file=CERT_FILE, enhanced=True)
	payload = Payload(alert=message, sound="default", custom = {'type': NOTIFYTEN, 'id': senderID, 'Sync Token': syncToken})
	apns.gateway_server.send_notification(receiverToken, payload)

def getActiveQueue():
	activeQueue = []
	for entry in HelpRequests:
		if entry['In Queue'] == True:
			activeQueue.append(entry)
	return activeQueue

def getAllActiveUsers():
	activeUsers = []
	for entry in HelpRequests:
		if entry['In Queue'] == True:
			activeUsers.append(entry)
	for entry in LabTAs:
		if entry['Is Active'] == True:
			activeUsers.append(entry)
	return activeUsers

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
	#print(zlib.adler32("mckinlaysbuttonrohanpaaddisonmezrattyjh45awojakzbedrosianamanolofflaxerwill85gc23chay,12"))
	app.run(debug = True)


