#!/usr/bin/perl
#
# Mail merge 
# http://linux.die.net/man/1/msmtp
#
#
#

# Check number of command-line arguments
$numArgs = $#ARGV + 1;

if ($numArgs < 2) {
	print "Usage: template data [subject]\n";
	print "   template - A file containing the message\n";
	print "          Each \$1, \$2, ... is replaced with\n";
	print "          columns in the data file\n";
	print "   data - tab separated with one line per email\n";
	print "          first column is the address\n";
	print "   subject - A subject for each email. You can use\n";
	print "          \\\$1, \\\$2, ... which will be replaced\n";
	print "          using columns in the data file\n\n";
	exit;
}

$template = $ARGV[0];
$datafile = $ARGV[1];
$subject = $ARGV[2];

open (FILE, $template) or die "Can't open message template: $!\n";
{
	local($/) = undef;
	$message = <FILE>;
}
close(FILE);

print "message: $message";

# Read in the data
open (FILE, $datafile) or die "Can't open recipient data file: $!\n";
{
	while(<FILE>) { chomp;
		($address, @fields) = split(/\t/);
		if ($address) {
			print "Generating message for $address...\n";
			
			$sub = $subject;
			foreach $num (1 .. ($#fields+1)) {
                                $pattern = "\\\$$num";
                                $val = $fields[($num-1)];
                                $sub =~ s/$pattern/$val/g;
                        }
			print "Subject: $sub\n";
			
			$msg = $message;
			foreach $num (1 .. ($#fields+1)) {
				$pattern = "\\\$$num";
				$val = $fields[($num-1)];
				$msg =~ s/$pattern/$val/g;
				print "$num: $pattern -> $val\n";
			}
			print "Message: $msg\n";
			
			open( MAIL, "| /usr/bin/msmtp $address") or die "Can't run msmtp: $!\n";
			if ($sub) {
				print MAIL "Subject: $sub"
			}
			print MAIL $msg;
			close(MAIL);
			sleep(1);
		}
	}

}
close(FILE);



