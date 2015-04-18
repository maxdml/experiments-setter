#!/usr/bin/python

import sys
import io
import argparse

description =  'Tool to generate kvm guest manifests.'

parser = argparse.ArgumentParser(description=description)

parser.add_argument('nodename', help='Name of the guest')
parser.add_argument('ram', help='The amount of desired RAM for the guest')
parser.add_argument('cpus', help='The number of desired cpus for the guest')
parser.add_argument('vdisk', help='The name of the virtual disk')

args = parser.parse_args()

guestManifest = io.open(args.nodename + '.pp' , 'w')

for line in io.open('guest.tpl', 'r'):
    line = line.replace('$nodename', args.nodename)
    line = line.replace('$ram', args.ram)
    line = line.replace('$cpus', args.cpus)
    line = line.replace('$vdisk', args.vdisk)
    guestManifest.write(line)

guestManifest.close()

guestsManifest = io.open('guests-nodes.pp', 'ab')
guestsManifest.write('include ' + args.nodename + '\n')
