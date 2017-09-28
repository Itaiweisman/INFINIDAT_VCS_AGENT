eval 'exec /opt/VRTSperl/bin/perl -I `pwd`/../../lib -S $0 ${1+"$@"}'
	if 0;
use ag_i18n_inc;

use Config;
my $osname=$Config{'osname'};
our $location;
if ($osname =~ m/MSWin/) {
	$location='c:\\';
}
else {
our $location="/tmp/"; }
 
my $ResName = shift;

VCSAG_LOG_MSG("I","lock to delete $file ",7);

sub deleteLockFile {
	my $ret;
	$file=$location  . $ResName . ".lock";
	VCSAG_LOG_MSG("I","lock to delete $file ",7);
	#$file="/tmp/lock";
	if ( unlink $file ) { 
  		VCSAG_LOG_MSG("I","removed locks file  ; Resource is offline ",19); $ret=0;  }
	else {
	  	VCSAG_LOG_MSG("E","Cannot remove lock file  ",1); $ret=15;   }
	return $ret;
}

$deleted=deleteLockFile();
exit($deleted);

