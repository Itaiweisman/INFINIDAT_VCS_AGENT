package InfiniBoxShell;
use Config;
our $osname=$Config{osname};
use Exporter qw(import);
our @EXPORT_OK = qw(parseInfinishellOneLine SwitchRoleIInfinishell);
print "OS is $osname \n";
#our $shell="/Users/iweisman/infinishell-ve/bin/infinishell";
$shell='C:\\"Program Files\"\Infinidat\InfiniShell\bin\infinishell.exe' if $osname =~ m/MSWin/;
$shell='~/infinishell-ve/bin/infinishell' if $osname =~ m/darwin/;
$shell='/usr/bin/infinishell' if $osnmae=~/linux/;

open(F,"$shell --version |") || die 'Unable to find shell';
$infinishell_version=<F>;
$version=$1 if ($infinishell_version =~ m/InfiniBox Command Line Shell (.*)/); 
die "version is $version, This module requires version family of 4.x" if $version !~ m/v4/;
	
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub SwitchRoleInfinishell {
	my $box = shift;
	my $user = shift; 
	my $password = shift;
	my $replica = shift;
	my $type = shift;
	my $suffix = defined $type ? "dataset_type=$type" : '' ; 
	my $cmd = "replica.switch_role local_dataset=$replica $suffix";
	print " * $cmd * \n";
	return (! system("$shell -u $user -p $password -c \"$cmd --yes \" $box"));

}

sub parseInfinishellOneLine {
	
	our $box = shift;
	our $user = shift; 
	our $password = shift;
	our $cmd = shift;
	our %return=();
	our $err='';
	#print "$shell -u $user -p $password --no-paging --csv -c \" $cmd --columns=*\" $box";
	open(SHELL, "$shell -u $user -p $password --no-paging --csv -c \" $cmd --columns=*\" $box |" )  || ($err=$!) ; 
	if ($err) {
		print "error is $err \n";
		retrun %return;
	}
	$keys=<SHELL>;
	
	chomp $keys;
	#$keys=~ s/\n//g;
	$keys=~ s/_//g;
	$keys=lc($keys);
	#print "$keys \n";
	$keys=~ s/\s$//g;
	$keys=~ s/\s/_/g;
	#print "keys are >$keys< \n"
	$values=<SHELL>;
	chomp $values;
	$values=~ s/\s$//g;
	$values=trim($values);
	#print "values are $values";
	@keys_list=split(',',$keys);
	@values_list=split(',',$values);
	for my $idx (0 .. $#keys_list) {
		#print ">$keys_list[$idx]< >$values_list[$idx]< \n";
    	$return{$keys_list[$idx]}=$values_list[$idx];
	
	
	}
	
	close SHELL;
	foreach $k(keys %return) { print "-key >$k< -value >$return{$k}< \n";}
	return %return;

}


1;