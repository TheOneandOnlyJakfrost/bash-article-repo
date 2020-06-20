#!/usr/bin/env python

# A quick hack to determine which RPMs are in the `kde-desktop` group
# but aren't installed in the base FAW install.

import xml.etree.ElementTree as ET
import subprocess

tree = ET.parse('comps-f28.xml.in')
root = tree.getroot()

for group in root.iter('group'):
    gid = group.find('id').text
    if gid == 'kde-desktop':
        pkglist = group.find('packagelist')

kde_list=[]
for pkg in pkglist.iter('packagereq'):
    kde_list.append(pkg.text)

r = subprocess.Popen(['rpm', '-qa', '--queryformat="%{NAME}" '], stdout=subprocess.PIPE)
rpmlist = (r.communicate())

reqlist = ""
for k in kde_list:
    if k not in rpmlist:
        reqlist += k + " "

print reqlist
