#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Cwd qw(cwd);
use lib 'modules';
use GenerateDocTools;
use File::Basename;

my $working_dir = "/homes/biertank/cristian/workspace/MIRfix_V2/RUNexample";
my $tto_name = $ARGV[0] or die "Please, provide the name of your test\n";
my $current_directory = cwd;
my $documentation_file = "$current_directory/README.md";
my $exists = GenerateDocTools::checkIfExistsFile($documentation_file);
if ($exists == 0){
	GenerateDocTools::createManualFile($current_directory);
} elsif ($exists == 1){
	;	
} else {
	GenerateDocTools::die();
}
my $all_data_codes = GenerateDocTools::extractInfoTest($working_dir, $tto_name);
GenerateDocTools::writeTTO($tto_name, $current_directory, \$all_data_codes);
exit;
