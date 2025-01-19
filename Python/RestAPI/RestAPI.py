import urllib.request as urllib2
import base64

base_url = "{baseurl}/rest/latest/"

# Username and password should be stored according
# to your organization's security policies
username = "{username}"
password = "{password}"

resource = "users"

request = urllib2.Request(base_url + resource)
credentials = '{}:{}'.format(username, password)
base64string = base64.b64encode(credentials.encode('utf-8')).decode('utf-8')
request.add_header("Authorization", "Basic %s" % base64string)

response = urllib2.urlopen(request)

print(response.read().decode('utf-8'))
