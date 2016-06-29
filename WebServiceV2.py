#!flask/bin/python
from flask import Flask, jsonify, abort, make_response, request
import datetime
from apns import APNs, Frame, Payload
import sys
import logging
import os
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
		HelpRequests.append(newEntry)
		return jsonify({'Queue': HelpRequests}), 201

@app.route('/LabQueue/v2/<senderID>/Requests/<requestID>/Helped', methods = ['GET'])
def markAsHelped(senderID, requestID):
	entry = [entry for entry in HelpRequests if entry['NetID'] == requestID]
	if len(entry) == 0:
		abort(404)
	else:
		entry[0]['Been Helped'] = True
		entry[0]['Helped Time'] = datetime.datetime.now()
		entry[0]['In Queue'] = False
		entry[0]['Attending TA'] = senderID
		return jsonify({requestID: entry}), 201

@app.route('/LabQueue/v2/<senderID>/Requests/<requestID>/Helped', methods = ['GET'])
def markAsCanceled(senderID, requestID):
	entry = [entry for entry in HelpRequests if entry['NetID'] == requestID]
	if len(entry) == 0:
		abort(404)
	else:
		entry[0]['Canceled'] = True
		entry[0]['In Queue'] = False
		return jsonify({requestID: entry}), 201

if __name__ == '__main__':
	app.run(debug = True)


