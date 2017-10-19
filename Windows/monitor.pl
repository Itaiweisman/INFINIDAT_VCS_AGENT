

eval 'exec /opt/VRTSperl/bin/perl -I `pwd`/../../lib -S $0 ${1+"$@"}'
	if 0;

use strict;
use warnings;
use ag_i18n_inc;
use Config;
my $ResName = shift;
our $use_infinishell=1;
require infinidat;
VCSAG_SET_ENVS ($ResName, 20091);
our $location;
my $osname=$Config{osname};

if ($osname=~ m/MSWin/) {
	$location='c:\\';
}
else {
$location="/tmp/"; }
our $lock=$location  . $ResName . ".lock";
our $ONLINE=101;
our $OFFLINE=100;

VCSAG_LOG_MSG("I","lock is $lock",1);
if (-e $lock) {
	#print  "lock exist \n";
 	#VCSAG_LOG_MSG("I","Lock file exist - resource is ONLINE",2);
	exit($ONLINE);} 
#VCSAG_LOG_MSG("E","Lock file does not exist - Resource is OFFLINE ",3);
exit($OFFLINE);

