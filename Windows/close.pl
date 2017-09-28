eval 'exec /opt/VRTSperl/bin/perl -I `pwd`/../../lib -S $0 ${1+"$@"}'
	if 0;
use ag_i18n_inc;
use infinidat;
use Config;
our $location;
my $ostype=$Config{'osname'};
if $ostype=~ m/MSWin/ {
	$location='c:\\';
}
else {
 $location="/tmp/"; }

### Handle Input
my $ResName = shift;
VCSAG_SET_ENVS ($ResName, 20091);
our @required=qw(localbox UserLocal PasswordLocal remotebox UserRemote PasswordRemote LocalCG RemoteCG);
our %pars=infinidat::check_pars(\@ARGV,\@required);

sub deleteLockFile {
	my $ret;
	$file=$location  . $ResName . ".lock";
	#$file="/tmp/lock";
	if ( unlink $file ) {
  		VCSAG_LOG_MSG("I","removed locks file  ; Resource is offline ",19); $ret=0;  }
	else {
	  	VCSAG_LOG_MSG("E","Cannot remove lock file  ",1); $ret=15;   }
	return $ret;
}

$deleted=deleteLockFile();
exit($deleted);
