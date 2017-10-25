#!/bin/bash
#
#Synopsis:      Install TeamSpeak 3 Server from Ports
#
#Description:   Updates ports
#			          Installs TeamSpeak3 Server from ports.
#               Adds teamspeak_enable="YES" to /etc/rc.conf
#               Stop, start, and check status of TeamSpeak service
#               Displays ServerAdmin privilege key
#
#Notes:
#
#	File Name:    Install_TeamSpeak3_Server_Ports_1_0.sh
#	Version:		  N/A
#	Author:			  Steven J. DeZalia
#	Contact:		  https://github.com/StevenDeZalia/
#	Prerequisite: FreeBSD OS Installed with an active internet connection, built
#               and tested on 10.3-Release-p8.
#
#               As of this Writing 11+ breaks the TeamSpeak3 Server.
#	Date:         09/23/2016
#	Copyright:
#		Copyright (c) 2016, Steven J. DeZalia
#		All rights reserved.
#		Redistribution and use in source and binary forms, with or without
#		modification, are permitted provided that the following conditions are met:
#	    * Redistributions of source code must retain the above copyright
#	      notice, this list of conditions and the following disclaimer.
#	    * Redistributions in binary form must reproduce the above copyright
#	      notice, this list of conditions and the following disclaimer in the
#	      documentation and/or other materials provided with the distribution.
#	    * Neither the name of the Steven J DeZalia nor the names of its
#       contributors may be used to endorse or promote products derived from
#       this software without specific prior written permission.
#
#		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED. IN NO EVENT SHALL Steven J DeZalia DIRECT, INDIRECT,
#   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES BE LIABLE FOR ANY
#   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#   OUT OF THE USE  OF THIS	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.
#
#Link:
#
#Instructions:	Run as root
#
#			To activate a license place the licensekey.dat file into the
#     /usr/local/etc/teamspeak directory, Then stop, start the server.
#     ServerAdmin privilege key is located in a log @ /var/log/teamspeak,
#     this will be searched and displayed at the end of this script.
#
#     If migrating from another instance of TeamSpeak3 place files into
#     /var/db/teamspeak, then stop, start the server as notated below.
#
#				Permissions listed below:
#
#	ls -l /var/db/teamspeak/
#	total 1512
#	drwx------	4	teamspeak	teamspeak	512		Oct 23	2012	files/
#	-rw-r--r--	1	teamspeak	teamspeak	1		Jul 13	2012	query_ip_blacklist.txt
#	-rw-r--r--	1	teamspeak	teamspeak	10		Jul 13	2012	query_ip_whitelist.txt
#	-rw-------	1	root		teamspeak	5		Aug 31	23:47	teamspeak_server.pid
#	-rw-r--r--	1	teamspeak	teamspeak	416768	Sep 9	14:36	ts3server.sqlitedb
#	-rw-r--r--	1	teamspeak	teamspeak	32768	Sep 11	00:36	ts3server.sqlitedb-shm
#	-rw-r--r--	1	teamspeak	teamspeak	1048032	Sep 11	00:34	ts3server.sqlitedb-wal


#
#Updates for FreeBSD, Ports, and PKG
#

#	Fetches all the latest binary updates for currently installed FreeBSD world
freebsd-update fetch install

#	Fetches for updates to ports, extracts them, and updated them
portsnap fetch extract update

#	Updates PKG system
PKG Update



#
#Installs Open-VM-Tools if you are running in an VM Enviromenet
#

pkg install open-vm-tools



#
#Adds Open-VM-Tools startup items to /etc/rc.conf to have them automatically
#run at boot
#

#	vmblock is block filesystem driver to provide drag-and-drop functionality
#from the remote console.
sysrc vmware_guest_vmblock_enable="YES"

#	vmhgfs is the driver that allows the shared files feature of VMware
#Workstation and other products that use it. This is not optimal to use on
#server therefore we do not enable it.
sysrc vmware_guest_vmhgfs_enable="NO"

#	vmemctl is driver for memory ballooning
sysrc vmware_guest_vmmemctl_enable="YES"

#	vmxnet is paravirtualized network driver
sysrc vmware_guest_vmxnet_enable="YES"

#	VMware Guest Daemon (guestd) is the daemon for controlling communication
#between the guest and the host including time synchronization.
sysrc vmware_guestd_enable="YES"



#
#Install TeamSpeak 3 Server
#

#	Change directory to TeamSpeak server in ports
cd /usr/ports/audio/teamspeak3-server

#	Install TeamSpeak 3 Server
make install clean; rehash

#	Adds teamspeak_enable="YES" to /etc/rc.conf
sysrc teamspeak_enable="YES"



#
#Stop, Start, and check status of TeamSpeak service
#

#	Stops TeamSpeak service
service teamspeak stop

#	Starts TeamSpeak service
service teamspeak start

#	Checks status of TeamSpeak service
service teamspeak status



#
#Display ServerAdmin privilege key
#

#	Navigates to /var/log/TeamSpeak
cd /var/log/teamspeak

#	Searches the directory and sub directories for 'token=' and displays the
# line in the log
grep -r 'token=' *


#########################################
# Optional To reduce boot/reboot times  #
#########################################

#
#Removes/Disables Sendmail
#
sysrc sendmail_enable="NO"
chmod 0 /usr/libexec/sendmail/sendmail
chmod 0 /usr/sbin/sendmail
mv /usr/libexec/sendmail/sendmail /usr/libexec/sendmail/sendmail.bak
mv /usr/sbin/sendmail /usr/sbin/sendmail.bak



#
#Sets Boot Delay to one (1) second	*Speeds up Boot and reboots*
#
echo 'autoboot_delay="1"' >> /boot/loader.conf



#
#Sets AutoBoot Wait to 0	*Speeds up Boot and reboots*
#
echo 'autoboot_wait="0"' >> /boot/loader.conf
