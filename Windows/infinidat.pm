package infinidat;
## Changes to online:
## use require instead of 'use'
## add use_infinishell scalar
print "Infinishell: " . $::use_infinishell . "\n";

if ($::use_infinishell) {
use InfiniBoxShell; }
else {
#use REST::Client;
use JSON;
use ag_i18n_inc;
use MIME::Base64;
use Data::Dumper; }
use Exporter qw(import); 
our @EXPORT_OK = qw(check_pars switchRoleFromLocal getInfiniBoxSingleObjectByNames);
sub check_pars {
        my ($par_list_ref,$required_pars_ref)=@_;
        my @par_list=@ { $par_list_ref };
        my @required_pars_list=@ { $required_pars_ref };
        my %pars;
        while (@par_list) {
                $name=shift @par_list;
                $count=shift @par_list;
                $val=shift @par_list;
                last if (! length "$count");
                if ($count != '1') {
                    VCSAG_LOG_MSG("E","All values should be scalars",9);
                    return {};
                }


                $pars{$name}=$val;
        }
        for $req(@required_pars_list) {
                if (not exists $pars{$req}) {
                    VCSAG_LOG_MSG("E","Mandatory key $req does not exist!",11);
                    return {};
                    } 
                }
        return %pars;
        }
sub getByInfinishell {
	$box=shift;
	$user=shift;
	$password=shift;
	$objtype=shift;
	$object=shift;
	$namevar=shift;
	my $cmd="${objtype}.query ${namevar}=${object}";
	print "cmd is $cmd ;  box: $box \n";
	%ref=InfiniBoxShell::parseInfinishellOneLine($box,$user,$password,$cmd);
	return %ref;
	#print "cmd is $cmd \n"
}
sub getInfiniBoxSingleObjectByName {
        my $ResName=shift;
        VCSAG_SET_ENVS ($ResName, 20091);
        #open ($d,">>/tmp/infinidat.pm.out ") || die "cannot D";
        #print $d "***** calling with @_ \n";
        #print $d "***** calling with @_ \n";
 
        my $host=shift;
        my $user=shift;
        my $password=shift;
        my $objtype=shift;
        my $object=shift;
        my $namevar=shift;
		
        my @result=[];
        $namevar = defined $namevar ? $namevar : "name" ;
		
        my $EncPword = VCSAG_SQUEEZE_SPACES($password);
       
		our $DecPword = `$ag_i18n_inc::HADECRYPT $EncPword`;
		 
		if ($::use_infinishell) {
		%ref=getByInfinishell($host, $user, $DecPword, $objtype, $object, $namevar);
		return %ref;
		}
        our $headers = {Accept => 'application/json', Authorization => 'Basic ' . encode_base64($user . ':' . $DecPword)};
        my $client = REST::Client->new();
        print $d "Querying --> http://$host\n";
        $client->setHost("http://$host");
        my $uri="/api/rest/". $objtype . "?" . $namevar ."=" .$object;
        print $d "host is $host ; uri is $uri \n";
        $client->GET( $uri, $headers);
        $ok = eval {$response = from_json($client->responseContent());1};
	if (! $ok ) { 
        VCSAG_LOG_MSG("E","Caught Error - Can't get response from $host",3001);
		print  $d "Caught Error - Can't get response from $host" ;  return 0 ;
	}
        @result=$response->{'result'};
        @error=$response->{'error'};
        if ( @{$result[0]} )  {
                VCSAG_LOG_MSG("I","Response from http://${host}/${uri} is not empty",1001);
                print  $d "Response is not empty \n";
                 }
        else {
                VCSAG_LOG_MSG("W","Response from http://${host}/${uri} is empty",2001);
                print  $d "Response is empty \n";
                if ($error[0]{'code'}) {
                        VCSAG_LOG_MSG("E","Caught Error - $error[0]{'message'}",3002);
                        print  $d "Caught Error - $error[0]{'message'} \n";
                }
                return {};
                }
        #return @result;
        close $d;
	return $result[0][0];
}


sub switchRoleFromLocal {
    $ResName=shift;
    VCSAG_SET_ENVS ($ResName, 20091);

    my $host=shift;
    my $user=shift;
    my $password=shift;
    my $id=shift;
	my $replica=shift;
    my $EncPword = VCSAG_SQUEEZE_SPACES($password);
    our $DecPword = `$ag_i18n_inc::HADECRYPT $EncPword`;
	return InfiniBoxShell::SwitchRoleInfinishell($box,$user,$DecPword,$replica,'CG') if $::use_infinishell;
    our $headers = {Accept => 'application/json', Authorization => 'Basic ' . encode_base64($user . ':' . $DecPword)};
    my $uri="/api/rest/replicas/".$id."/switch_role?approved=true";
        my $post = REST::Client->new();
        $post->setHost("http://$host");
        $post->POST ( $uri,'{}', $headers);
        $ok = eval {$response = from_json($post->responseContent());1};
        if (! $ok ) { 
        VCSAG_LOG_MSG("E","Caught Error - Can't get response from $host",3101);
        print  $d "Caught Error - Can't get response from $host" ;  return 0 ;
        }   
        @result=$response->{'result'};
        @error=$response->{'error'};
        if ( $result[0])   {
                print "Response is not empty \n";
                VCSAG_LOG_MSG("I","Response from http://${host}/${uri} is not empty",13);


                 }
        else {
                print "Response is empty \n";
                VCSAG_LOG_MSG("E","Response from http://${host}/${uri} is  empty",13);
                if ($error[0]{'code'}) {
                        print "Caught Error - $error[0]{'message'} \n";
                        VCSAG_LOG_MSG("E","Caught Error - $error[0]{'message'}",7);

                }
                return 0;
                }
        return 1;
}
1;
