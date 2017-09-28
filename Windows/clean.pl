eval 'exec /opt/VRTSperl/bin/perl -I `pwd`/../../lib -S $0 ${1+"$@"}'
	if 0;
use ag_i18n_inc;
our $use_infinishell=0;
our $location;
use Config;
my $ostype=$Config{'osname'};
if ($ostype=~ m/MSWin/) {
	$location='c:\\';
	 $use_infinishell=1;
}
else {
 $location="/tmp/"; }
require infinidat;

### Handle Input
my $ResName = shift;
VCSAG_SET_ENVS ($ResName, 20091);
#our @required=qw(localbox UserLocal PasswordLocal remotebox UserRemote PasswordRemote LocalCG RemoteCG);
#our %pars=infinidat::check_pars(\@ARGV,\@required);

sub deleteLockFile {
	my $ret;
	$file=$location  . $ResName . ".lock";
	print "lock is $file \n";
	#$file="/tmp/lock";
	if (! -e $file ) {
		VCSAG_LOG_MSG("I","lock file does not exist",10);
		$ret=0;
		}
	else {
	if ( unlink $file ) {
  		VCSAG_LOG_MSG("I","removed locks file ; Resource cleaned",0); $ret=0; }
	else {
	  	VCSAG_LOG_MSG("E","Cannot remove lock file  ",3); $ret=15;   }
	return $ret;
}
}
$deleted=deleteLockFile();
exit($deleted);
