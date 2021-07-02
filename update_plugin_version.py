import xml.etree.ElementTree as ET
from xml.sax.saxutils import unescape
import sys
import json

version = ""
id = ""

# read package.json variables to set on the plugin.xml
with open('package.json') as package_json:
    data = json.load(package_json)
    version = data['version']
    id = data['cordova']['id']

# read and set the properties to the xml
ET.register_namespace('',"http://apache.org/cordova/ns/plugins/1.0")
ET.register_namespace('android',"http://schemas.android.com/apk/res/android")
doc = ET.parse("plugin.xml")
root = doc.getroot()
root.set('id', id)
root.set('version', version)
out = unescape(ET.tostring(root,"UTF-8"))
with open("plugin.xml", 'w') as f:
    f.write(out)