#!flask/bin/python
from flask import Flask, jsonify, abort, make_response, request

app = Flask(__name__)

LabTAs = [
	{
		'First Name': u"Mitchell",
		'Last Name': u"Hamburger",
		'Email': u"mh20@princeton.edu",
		'Class Year': 2018,
		'Is Active': True
	},
	{
		'First Name': u"Harry",
		'Last Name': u"Heffernan",
		'Email': u"hmlh@princeton.edu",
		'Class Year': 2018,
		'Is Active': False
	},
	{
		'First Name': u"Sergio",
		'Last Name': u"Cruz",
		'Email': u"slc2@princeton.edu",
		'Class Year': 2018,
		'Is Active': True
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
	}
]

@app.route('/LabQueue/v1/fullqueue', methods = ['GET'])
def getFullQueue():
	return jsonify({'Queue': Queue})


