import xml.etree.ElementTree as ET
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
out = ET.tostring(root,"UTF-8")
doc.write("plugin.xml",  xml_declaration = True, encoding = 'utf-8', method = 'xml')