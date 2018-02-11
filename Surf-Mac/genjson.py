#!/usr/bin/env python
#coding=utf-8

import json
import sys
import re
config = {}
General = {}
Proxy = {}
Rule = {}
DOMAINKEYWORD = {}
DOMAINSUFFIX = {}
IPCIDR = {}


def fread(file):
	dict = {}
	i = 0 
	for line in file:
		i = i+ 1
		print ++i
		if re.match('#', line):
			print "# and pass"
			continue
		if re.match('//', line):
			print "// and pass"
			continue
		if len(line) <=2:
			print "no need" + line
			continue
		
		if re.match('\[General\]', line):
			print "Found General"
			dict = General
			continue
		elif re.match('\[Proxy\]', line):
			print "Found Proxy"
			dict = Proxy
			continue
		elif re.match('\[Rule\]', line):
			dict = Rule
			print "Found Proxy"
			continue
		else :
			 #print "Not found block this is rule" + 
			 pass
		#print line
		list  = line.split('=')
		if len(list) >1:
			print list
			x = list[1].split(',')
			if  len(x)> 1:
				if dict ==  Proxy:
					hostconfig = {}
					hostconfig['protocol'] =  x[0].strip()
					hostconfig['host'] =  x[1].strip()
					hostconfig['port'] =  x[2].strip()
					hostconfig['methd'] =  x[3].strip()
					hostconfig['passwd'] =  x[4].strip()
					#hostconfig['xx'] =  x[5]
					dict[list[0]] = hostconfig
				else:
					print line
					dict[list[0]] =  [str(j).strip() for j in x]
			else:
				dict[list[0]] = list[1]
			
		else:
			if re.match('DOMAIN-KEYWORD',line):
				k  = line.split(',')
				#k.remove(k[0])
				#r = ', '.join([str(x) for x in k]) 
				rule = {}
				rule["Proxy"] = k[2].strip()
				try:
					rule["force-remote-dns"] = k[3].strip()
				except Exception, e:
					print e
				
				DOMAINKEYWORD[k[1]] = rule 
			elif re.match('DOMAIN-SUFFIX',line):
				k  = line.split(',')
				#k.remove(k[0])
				#r = ', '.join([str(x) for x in k]) 
				rule = {}
				rule["Proxy"] = k[2].strip()
				try:
					rule["force-remote-dns"] = k[3].strip()
				except Exception, e:
					print e
				
				DOMAINSUFFIX[k[1]] = rule
			elif re.match('IP-CIDR',line):
				k  = line.split(',')
				#k.remove(k[0])
				#r = ', '.join([str(x) for x in k]) 
				rule = {}
				rule["Proxy"] = k[2].strip()
				try:
					rule["no-resolve"] = k[3].strip()
				except Exception, e:
					print e
				
				IPCIDR[k[1]] = rule
			else:
				pass	
	#print dict
	print "[General]"
	print General
	General["author"] = "yarshure"
	General["commnet"] = "这是comment"
	print "[Proxy]"
	print Proxy
	print "[Rule]"
	Rule["DOMAIN-KEYWORD"] = DOMAINKEYWORD
	Rule["DOMAIN-SUFFIX"] = DOMAINSUFFIX
	Rule["IP-CIDR"] = IPCIDR
	#print Rule
	print "cool"
	config["General"] = General
	config["Proxy"] = Proxy
	config["Rule"] = Rule
	
	saveRuslt()
	# print "[DOMAINKEYWORD]"
	# print DOMAINKEYWORD
	# print "[DOMAINSUFFIX]"
	# print DOMAINSUFFIX
	# print "[IPCIDR]"
	# print IPCIDR
def saveRuslt():
	#print config
	s = json.dumps(config)
	f = open("surf.conf","w")
	f.write(s)
	f.close()
if __name__ == '__main__':
	if len(sys.argv) == 1:
		print "add surge file path"
	surgeconfig = sys.argv[1]
	print surgeconfig
	file = open(surgeconfig)
	fread(file)
	file.close() 