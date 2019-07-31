package GenerateDocTools;

use strict;
use warnings;
use Data::Dumper;
use File::Basename;

sub checkIfExistsFile {
	my $name = shift;
	$name =~ s/(\.\.\/|\/.*\/|\.\/)(.*)/$2/g;
	my $folder = $1;
	if (-z "${folder}${name}" || !-e "${folder}${name}" ){
		return 0;
	} else {
		return 1;
	}
}

sub createManualFile {
	my $current_path2 = shift;
	open my $OUT, "> $current_path2/README.md" or die "Imposible to create the new file!\n";
	my $header = write_header_markdown();	
	print $OUT "\# $$header{title}\n";
	print $OUT "> $$header{author}\t$$header{time}\n\n";
	print $OUT "----\n\n";
	print $OUT "$$header{description}\n\n";
	print $OUT "----\n\n";
	close $OUT;
	return;
}

sub write_header_markdown {
	my %header_info;
	my $time = localtime();
	my $author = "Cristian A. Velandia-Huerto";
	my $separator = "########################";
	my $title = "Library of MIRFix test files";
	my $last_modification = localtime();
	my $description = "This file is the description of the test performed on **MIRfix** as control pipeline.";
	$header_info{"time"} = $time;
	$header_info{"author"} = $author;
	$header_info{"title"} = $title;
	$header_info{"last_modification"} = $time;
	$header_info{"separator"} = $separator;
	$header_info{"description"} = $description;
	return \%header_info;
}

sub writeTTOdescriptionMrkdwn {
	my $name = shift;
	my %main;
	my $name_list = "${name}_list.txt";
	my $name_mapping = "${name}_mappingtest.txt";
       	my $name_mature = "${name}_maturetest.fa";
	my $name_genomes = "${name}_genomes_list.txt";	
	my $name_hairpin = "${name}.fa";
	$main{"list"} = $name_list;
	$main{"mapping"} = $name_mapping;
	$main{"mature"} = $name_mature;
	$main{"genomes"} = $name_genomes;
	$main{"hairpin"} = $name_hairpin;
	$main{"nametto"} = $name;
	return \%main;
}

sub writeTTO {
	my $name_tto = $_[0];
	my $current_path = $_[1];
	my $all_data_files = $_[2];
	open my $IN, ">> $current_path/README.md" or die "Not possible to create temp file to write documentation\n";
	my $content = writeTTOdescriptionMrkdwn($name_tto);	
	my @files = ("list", "mapping", "mature", "genomes", "hairpin");

	print $IN "\#\# Test: $$content{nametto}:\n";
	for (my $i=0; $i <= $#files; $i++){
		print $IN "- $$content{$files[$i]}:\n";
		print $IN "   - Number: $$all_data_files->{$files[$i]}{number}\n";
		print $IN "   - Candidates: $$all_data_files->{$files[$i]}{candidates}\n";
	}
	close $IN;
	return;
}

sub extractInfoTest {
	my ($work_path, $tto) = @_;
	my %all_data;
	open my $LIST, "< $work_path/${tto}_list.txt" or die "List file is not available\n";
	open my $MAPPING, "< $work_path/${tto}_mappingtest.txt" or die "List file is not available\n";
	open my $MATURE, "< $work_path/${tto}_maturetest.fa" or die "List file is not available\n";
	open my $GENOMES, "< $work_path/${tto}_genomes_list.txt" or die "List file is not available\n";
	open my $HAIRPIN, "< $work_path/Families/${tto}.fa" or die "List file is not available\n";
	my (%list, %mapping, %mature, %genomes, %hairpin);
	while (<$LIST>){
		chomp;
		$list{$_} = 0;
	}
	while (<$MAPPING>){
		chomp;
		next if ($_ =~ /^$/);
		my @split = split /\s+|\t/, $_;
		my $num = scalar @split;
		if ($num == 10){
			$mapping{$split[2]} = "$split[4]\t$split[5]";
		} elsif ($num == 7){
			$mapping{$split[2]} = $split[4];
		} elsif ($num > 10){
			my $complete;
			foreach my $field (@split){
				if ($field =~ /^MIMAT/){
					$complete .= "$field\t";
				}
			}
			$complete =~ s/(.*)(\s+)$/$1/g;
			$mapping{$split[2]} = $complete;
		} else {
			die "$_ has more columns and is not compatible!\n";
		}
	}	
	while (<$MATURE>){
		chomp;
		next if ($_ =~ /^$/);
		if ($_ =~ /^\>/){
			my @spl = split /\s+|\t/, $_;
			$mature{$spl[1]} = 0;
		}
	}
	while (<$GENOMES>){
		chomp;
		my $name = basename($_);
		$name =~ s/\s+$//g;
		$genomes{$name} = 0;
	}
	while (<$HAIRPIN>){
		chomp;
		if ($_ =~ /^\>/){
			my @spl = split /\s+|\t/, $_;
			$hairpin{$spl[1]} = 0;
		}
	}
	my $size_list = keys %list;
	my $size_mapping = keys %mapping;
	my $size_mature = keys %mature;
	my $size_genomes = keys %genomes;
	my $size_hairpin = keys %hairpin;

	my ($all_list, $all_mapping, $all_mature, $all_genomes, $all_hairpin);
	###Inclusion of everything on %all_data
	foreach my $list_cand (sort keys %list){
		$all_list .= "$list_cand,";
	}
	foreach my $mapping_cand (sort keys %mapping){
		$all_mapping .= "$mapping_cand,";
		push @{$all_data{"mapping"}{"relation"}{$mapping_cand}}, $mapping{$mapping_cand};
	}
	foreach my $mature_cand (sort keys %mature){
		$all_mature .= "$mature_cand,";
	}
	foreach my $genomes_cand (sort keys %genomes){
		$all_genomes .= "$genomes_cand,";
	}
	foreach my $hairpin_cand (sort keys %hairpin){
		$all_hairpin .= "$hairpin_cand,";
	}
	$all_list =~ s/(.*)(\,)$/$1/g;
	$all_mapping =~ s/(.*)(\,)$/$1/g;
	$all_mature =~ s/(.*)(\,)$/$1/g;
	$all_genomes =~ s/(.*)(\,)$/$1/g;
	$all_hairpin =~ s/(.*)(\,)$/$1/g;
	$all_data{"list"}{"number"} = $size_list;
	$all_data{"list"}{"candidates"} = $all_list;
	$all_data{"mapping"}{"number"} = $size_mapping;
	$all_data{"mapping"}{"candidates"} = $all_mapping;
	$all_data{"mature"}{"number"} = $size_mature;
	$all_data{"mature"}{"candidates"} = $all_mature;
	$all_data{"genomes"}{"number"} = $size_genomes;
	$all_data{"genomes"}{"candidates"} = $all_genomes;
	$all_data{"hairpin"}{"number"} = $size_hairpin;
	$all_data{"hairpin"}{"candidates"} = $all_hairpin;
	close $LIST; close $MAPPING; close $MATURE; close $GENOMES; close $HAIRPIN;
	return \%all_data;
}

1;
