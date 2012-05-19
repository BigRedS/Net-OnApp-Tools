#! /usr/bin/perl

package Net::OnApp::Tools;

use strict;
use 5.010;
use Carp;


use base 'Exporter';
our @EXPORT = qw(getOnAppCredentials apiUrl columnify tabulate);

use Data::Dumper;
sub apiUrl {
	return "cloudbase.us.positive-internet.com";
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
