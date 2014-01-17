#! /usr/bin/perl

package Net::OnApp::Tools;

use strict;
use 5.010;
use Carp;
use YAML qw/LoadFile/;
use Net::OnApp;


use base 'Exporter';
our @EXPORT = qw(getOnAppCredentials apiUrl columnify tabulate connectToOnApp);

use Data::Dumper;
sub apiUrl {
	return "cloudbase.us.positive-internet.com";
}

sub getConfig{
	my $args = shift;
	my $f_cf = $ENV{'ONAPP_CLOUDS_CONFIG'} || "/etc/onapp-tools/clouds.cf";
	my $cf = LoadFile($f_cf);
	my $cloud = $args->{'cloud'} || $cf->{'default_cloud'};

	if($cf->{'clouds'}->{$cloud}){
		return $cf->{'clouds'}->{$cloud};
	}else{
		die ("Unknown cloud '$cloud'");
	}
}

sub connectToOnApp{
	my $args = shift;
	my $cf = getConfig($args);
	my $onapp = Net::OnApp->new(
		api_email => $cf->{'user'},
		api_key   => $cf->{'password'},
		api_url   => $cf->{'url'},
	) or die ("Failed to connect to OnApp");
	return $onapp;
}

sub getOnAppCredentials {
	my $credentialsFile = $ENV{'HOME'}."/.onapp_credentials";
	my ($email,$key);
	unless ( -f $credentialsFile ){
	        print "OnApp requires that you log in with either a username and\n";    
	        print "password or an email address and API key. You can avoid\n";
	        print "being prompted by creating a file at ~/.onapp_credentials\n";
	        print "with your username or email on the first line and password\n";
	        print "or API key on the second\n\n";
	        print "Enter username or email address:\n";
	        $email = <>; 
	        print "Password or API key:\n";
	        system('stty','-echo');
	        $key = <>; 
	        system('stty','echo');
	        print "\n";
	}else{
		($email,$key) = _getCredentialsFromFile($credentialsFile);
	}
	return($email,$key);
}


sub _getCredentialsFromFile {
	my $file = shift;
	open(my $f, "<", $file) or confess "Error opening credentials file $file";
	my ($user,$pass) = <$f>;
	close($f);
	chomp $user;
	chomp $pass;
	return($user,$pass);
}

sub columnify {
	my $string = shift;
	my $maxlen = shift;
	my $length = $maxlen + 4;
	my $truncatedString = sprintf("%-$length"."s", substr($string, 0, $maxlen));
	return $truncatedString;
}

sub tabulate {
	my @data = @_;
	my @colwidths;
	foreach my $r (@data){
		my @row = @{$r};
		for(my $column = 0; $column < $#row+1 ; $column++ ){
			$colwidths[$column] = length($row[$column]) if (length($row[$column]) > $colwidths[$column]);
		}
	}
	# Last element of first line gets an extra linebreak.
	$data[0][-1] .= "\n";
	print "\n";
	foreach my $r (@data){
		my @row = @{$r};
		for(my $column = 0; $column < $#row+1 ; $column++){
			print columnify($row[$column], $colwidths[$column]);
		}
		print "\n";
	}
}
