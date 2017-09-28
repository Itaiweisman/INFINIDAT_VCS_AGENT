

eval 'exec /opt/VRTSperl/bin/perl -I `pwd`/../../lib -S $0 ${1+"$@"}'
	if 0;


use ag_i18n_inc;

use JSON;
use Data::Dumper;
use MIME::Base64;
use Config;
###
my $ResName=shift;
VCSAG_SET_ENVS ($ResName, 20091);
my $ostype=$Config{'osname'};
our $use_infinishell=0;
our $location='/tmp/' if ($ostype eq 'linux' or $osname eq 'aix' );
our $location='c:\\' if ($ostype =~ m/MSWin/);
$use_infinishell=1 if $ostype =~ m/MSWin/ ;
require infinidat;
our $lock=$location  . $ResName . ".lock";
our $sleep=300;
our $dbg="c:\\dbg.out";

#open(our $fh, '>', $dbg) || die "cant open lock"; ### To Remove
#open(our $fh, '>', $lock) || die "cant open lock";
#print $fh "I'm able to write to lock file \n";
#print $fh "Our Args are: \n";

#for $a(@ARGV) { print $fh "- $a \n"; }

our @required=qw(localbox UserLocal PasswordLocal remotebox UserRemote PasswordRemote LocalCG RemoteCG);
our %pars=infinidat::check_pars(\@ARGV,\@required);
if (! %pars) {
    VCSAG_LOG_MSG("E", "Unable to parse parameters. quitting",17);
    exit(0);
}
our $user;
our $password;

sub determine_action {
    $role = shift;  $replica_state = shift;  $sync_state=shift;  $link_state = shift;
    print $fh "detemining ... base on $role ; $replica_state ; $sync_state ; $link_state \n";
    VCSAG_LOG_MSG("I","detemining action base on role is $role, replica state is $replica_state, link state is $link_state ",100);
    @warn_states=('INITIALIZING' ,'SYNC_IN_PROGRESS', 'OUT_OF_SYNC', 'INITIALIZING_PENDING');
    @fail_states=('SUSPENDED','AUTO_SUSPENDED');
    $ret=0;
    my $exit_message="NULL MESSAGE";
    if ($role eq 'SOURCE') {
        print $fh "SRC-1";
        if ($replica_state eq 'ACTIVE' && $sync_state eq 'SYNCHRONIZED' && $link_state eq 'UP') {
            print $fh "SRC-OK";
            $exit_message="Working on source, All is sync";
            VCSAG_LOG_MSG("I","Working on source, data is Synchronized to target ",101);
            $ret=1;
        }
       if ($replica_state eq 'ACTIVE'  && $link_state eq 'UP' && (grep {$_ eq $sync_state} @warn_states)) {
            print $fh "SRC-2";
            $exit_message="WARNING replica is not Synchronized";
            VCSAG_LOG_MSG("W","Replica is not Synchronized",200);
            $ret=1;
        }
        if ($sync_state eq 'OUT_OF_SYNC' && $link_state eq 'UP' && (grep {$_ eq $replica_state} @fail_states)) {
            print $fh "SRC-3";
            $exit_message="ERROR replica state is not on valid condition";
            VCSAG_LOG_MSG("E","Replica state is invalid ",300);
            $ret=0;
        }
        if ($sync_state eq 'OUT_OF_SYNC' && $link_state ne 'UP' && (grep {$_ eq $replica_state} @fail_states)) {
            print $fh "SRC-4";
            $exit_message="ERROR replica state is not on valid condition";
            VCSAG_LOG_MSG("E","Relica state is invalid ",301);
            $ret=0;
        }

    }
    if ($role eq 'TARGET') {
        print $fh "B-1 \n";
        if ($link_state ne 'UP') {
            $exit_message='ERROR Unable to query other box ';
            VCSAG_LOG_MSG("E","Unable to query paired box",310);
            $ret=0;
        }
        else {
            print $fh "B2 \n";
            if ($replica_state ne 'ACTIVE') {
                print $fh "B4 \n";
                VCSAG_LOG_MSG("E","Replica is not up ",301);
                $exit_message="ERROR - Replica is not up";
                $ret=0;
            }
            else {
                print $fh "B5 \n";
                if ($sync_state eq 'SYNCHRONIZED') {
                    print $fh "B6 \n";
                    print $fh "Attempt to switch role \n";
                    VCSAG_LOG_MSG("I","Attempt to switch role ",102);
                    if (infinidat::switchRoleFromLocal($ResName,$pars{'remotebox'},$pars{'UserRemote'},$pars{'PasswordRemote'},$remote_cg_hash{'id'},$remote_cg_hash{'local_dataset'})) {
                        print $fh "B7 \n";
                        VCSAG_LOG_MSG("I","Switch role ended successfully",103);
                        $exit_message="OK - switched role";
                        $ret=1;
                    }
                    else {
                        print $fh "B8 \n";
                        VCSAG_LOG_MSG("E","Switch role failed",310);
                        $exit_message="ERROR - unable to switch role";
                        $ret=0;
                    }
                }
                else {
                    print $fh "B9 \n";
                    print $fh "Waiting for pairs to sync \n";
                    VCSAG_LOG_MSG("I","Waiting for synchronized state before switching role ",105);
                    sleep $sleep;
					# Itai C1
                    #$local_cg=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'localbox'},$pars{'UserLocal'},$pars{'PasswordLocal'},'replicas',$pars{'LocalCG'},'local_cg_name');
                    #%local_cg_hash=%{$local_cg};
					#%local_cg=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'localbox'},$pars{'UserLocal'},$pars{'PasswordLocal'},'replicas',$pars{'LocalCG'},'local_cg_name');
                    #%local_cg_hash=%local_cg;
                    %remote_cg_new=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'remotebox'},$pars{'UserRemote'},$pars{'PasswordRemote'},'replica',$pars{'RemoteCG'},'local_dataset');
                    %remote_cg_hash_new=%remote_cg_new;
					### Itai C1
                    if ($remote_cg_hash_new{'sync_state'} eq 'SYNCHRONIZED') {
                        print $fh "Pairs are now SYNCHRONIZED, attempting to switch role \n";
                        VCSAG_LOG_MSG("I","Pairs are now SYNCHRONIZED, attempting to switch role",106);
                        if (infinidat::switchRoleFromLocal($ResName,$pars{'remotebox'},$pars{'UserRemote'},$pars{'PasswordRemote'},$remote_cg_hash{'id'},$remote_cg_hash{'local_dataset'})) {
                        print $fh "B7 \n";
                        VCSAG_LOG_MSG("I","Switch role ended successfully",103);
                        $exit_message="OK - switched role";
                        $ret=1;
                    }
                    else {
                        print $fh "B8 \n";
                        $exit_message="ERROR - unable to switch role";
                        VCSAG_LOG_MSG("E","Swtich role failed",310);
                        $ret=0;
                    }
                    }
                    else {
                        $exit_message="Pairs did not get Synchronized on a timely fashion \n";
                        VCSAG_LOG_MSG("E","Pairs did not get Synchronized on a timely fashion",311);
                        $ret=0;
                    }
                }

            }

        }
    }
    print $fh "$exit_message \n";
    print $fh "returning $ret";
    return $ret;

}

sub create_lock_file($) {
    $lockfile=shift;
    VCSAG_LOG_MSG("I","Creating lock file",1000);
    open($lockfile, ">$lock") ||  VCSAG_LOG_MSG("E","cannot create lock file",711);
    close $lockfile;
}

###Program starts here



if ($use_infinishell) {
    $replica_objtype='replica';
    $link_objtype='link';
    $link_namevar='remote_system';
    $replica_namevar="local_dataset";
    $link_ident=$local_cg_hash{'remote_system'};
}
else {
    $replica_objtype='replicas';
    $replica_namevar='local_cg_name';
    $link_objtype='links';
    $link_namvar='id';
    $link_ident=$local_cg_hash{'link_id'};
}

## ITAI C1 replcaed reference with hash on windows version - will fail when no infinishell
%local_cg=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'localbox'},$pars{'UserLocal'},$pars{'PasswordLocal'},$replica_objtype,$pars{'LocalCG'},$replica_namevar);
%remote_cg=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'remotebox'},$pars{'UserRemote'},$pars{'PasswordRemote'},$replica_objtype,$pars{'RemoteCG'},$replica_namevar);

%local_cg_hash=%local_cg; ### ITAI C1
%remote_cg_hash=%remote_cg; ### ITAI C1


#%remote_cg_hash=%{$remote_cg};


if ($local_cg_hash{'role'} && $local_cg_hash{'role'} eq $remote_cg_hash{'role'}) {
    VCSAG_LOG_MSG("E","Both sides are set as $local_cg_hash{'role'}, quiting",511);
    exit(0);
    }


if (! $local_cg_hash{'role'}) {
    VCSAG_LOG_MSG("E","Unable to query local box, quitting",511);
    exit(0);
    }

if ($local_cg_hash{'role'} eq 'SOURCE') {
    print $fh "Getting pars from local \n";
    VCSAG_LOG_MSG("I","Working on source, getting parameters from local box",11);
    $replica_state=$local_cg_hash{'state'};
    $sync_state=$local_cg_hash{'sync_state'} ;

    if ($use_infinishell) {
		$link_objtype="link";
		$link_ident=$local_cg_hash{'remote_system'};
		$link_namevar='remote_system';
    }
	else { print 'to be added for non infinishell versions \n'; }
    ## ITAI C1 #$link=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'localbox'},$pars{'UserLocal'},$pars{'PasswordLocal'},$link_objtype,$link_ident,$link_namevar);
    %link=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'localbox'},$pars{'UserLocal'},$pars{'PasswordLocal'},$link_objtype,$link_ident,$link_namevar);

	#%link_hash=%{$link}; #ITAI C1
	%link_hash=%link;
    $link_state=$link_hash{'link_state'};
}
elsif ($remote_cg_hash{'role'} eq 'SOURCE') {
    print $fh "Getting pars from remote \n";
    VCSAG_LOG_MSG("I","Working on target , getting parameters from remote box",12);
    $replica_state=$remote_cg_hash{'state'};
    $sync_state=$remote_cg_hash{'sync_state'};
    if ($use_infinishell) {
		$link_objtype='link';
        $link_ident=$pars{'localbox'};
		$link_namevar='remote_system';
    }
    else {$link_ident = $remote_cg_hash{'link_id'} ; }
	## ITAI C1
    #$link=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'remotebox'},$pars{'UserRemote'},$pars{'PasswordRemote'},$link_namevar,$link_ident,$link_namevar);
    %link=infinidat::getInfiniBoxSingleObjectByName($ResName,$pars{'remotebox'},$pars{'UserRemote'},$pars{'PasswordRemote'},$link_objtype,$link_ident,$link_namevar);

	#%link_hash=%{$link};
	%link_hash=%link;
	### ITAI C1

    $link_state=$link_hash{'link_state'};
}
else {
    VCSAG_LOG_MSG("E","Cannot determine source",31);
    exit(0);
}
print $fh "pars are replica_state $replica_state ; sync_state $sync_state ; link_state $link_state \n";
if (determine_action($local_cg_hash{'role'}, $replica_state, $sync_state, $link_state)) {

    create_lock_file($lock);
    }
close $lock;
exit(0);
