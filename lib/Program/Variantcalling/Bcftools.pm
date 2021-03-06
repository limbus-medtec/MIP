package Program::Variantcalling::Bcftools;

use strict;
use warnings;
use warnings qw( FATAL utf8 );
use utf8;  #Allow unicode characters in this script
use open qw( :encoding(UTF-8) :std );
use charnames qw( :full :short );

BEGIN {
    require Exporter;

    # Set the version for version checking
    our $VERSION = 1.00;

    # Inherit from Exporter to export functions and variables
    our @ISA = qw(Exporter);

    # Functions and variables which are exported by default
    our @EXPORT = qw();

    # Functions and variables which can be optionally exported
    our @EXPORT_OK = qw(call index view filter norm merge concat annotate roh stats reheader);

}

use Params::Check qw[check allow last_error];
$Params::Check::PRESERVE_CASE = 1;  #Do not convert to lower case


sub call {

##call

##Function : Perl wrapper for writing bcftools call recipe to $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $form_fields_ref, $outfile_path, $infile_path, $stderrfile_path, $FILEHANDLE, $samples_file, $multiallelic_caller, $output_type, $variants_only
##         : $form_fields_ref     => Output format fields {REF}
##         : $outfile_path        => Outfile path to write to
##         : $infile_path         => Infile path to read from
##         : $stderrfile_path     => Stderr file path to write to {OPTIONAL}
##         : $FILEHANDLE          => Filehandle to write to
##         : $samples_file        => PED file or a file with an optional column with sex
##         : $constrain           => One of: alleles, trio
##         : $multiallelic_caller => Alternative model for multiallelic and rare-variant calling
##         : $output_type         => 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]
##         : $variants_only       => Output variant sites only

    my ($arg_href) = @_;

    ## Default(s)
    my $multiallelic_caller;
    my $output_type;
    my $variants_only;

    ## Flatten argument(s)
    my $form_fields_ref;
    my $outfile_path;
    my $infile_path;
    my $stderrfile_path;
    my $FILEHANDLE;
    my $samples_file;
    my $constrain;

    my $tmpl = {
	form_fields_ref => { required => 1, defined => 1, default => [], strict_type => 1, store => \$form_fields_ref },
	outfile_path => { strict_type => 1, store => \$outfile_path },
	infile_path => { strict_type => 1, store => \$infile_path },
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path },
	FILEHANDLE => { store => \$FILEHANDLE },
	samples_file => { strict_type => 1, store => \$samples_file },
	constrain => { allow => [undef, "alleles", "trio"],
		       strict_type => 1, store => \$constrain },
	multiallelic_caller => { default => 1,
				 allow => [undef, 0, 1],
				 strict_type => 1, store => \$multiallelic_caller },
	output_type => { default => "v",
			 allow => ["b", "u", "z", "v"],
			 strict_type => 1, store => \$output_type },
	variants_only => { default => 1,
			   allow => [undef, 0, 1],
			   strict_type => 1, store => \$variants_only },
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools call);  #Stores commands depending on input parameters

    ## Options
    if ($multiallelic_caller) {

	push(@commands, "--multiallelic-caller");  
    }
    if (@$form_fields_ref) {

	push(@commands, "--format-fields ".join(",", @$form_fields_ref));
    }
    if ($variants_only) {

	push(@commands, "--variants-only");  
    }
    if ($samples_file) {

	push(@commands, "--samples-file ".$samples_file);
    }
    if ($constrain) {

	push(@commands, "--constrain ".$constrain);
    }
    if ($output_type) {

	push(@commands, "--output-type ".$output_type);  #Specify output type
    }
    if ($outfile_path) {

	push(@commands, "--output ".$outfile_path);  #Specify output filename
    }

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub index {

##index

##Function : Perl wrapper for writing bcftools index recipe to $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $infile_path, $stderrfile_path, $FILEHANDLE, $output_type
##         : $infile_path     => Infile path to read from
##         : $stderrfile_path => Stderr file path to write to {OPTIONAL}
##         : $FILEHANDLE      => Filehandle to write to
##         : $output_type     => 'csi' generate CSI-format index, 'tbi' generate TBI-format index

    my ($arg_href) = @_;

    ## Default(s)
    my $output_type;

    ## Flatten argument(s)
    my $infile_path;
    my $stderrfile_path;
    my $FILEHANDLE;

    my $tmpl = {
	infile_path => { required => 1, defined => 1, strict_type => 1, store => \$infile_path},
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path},
	FILEHANDLE => { store => \$FILEHANDLE},
	output_type => { default => "csi",
			 allow => ["csi", "tbi"],
			 strict_type => 1, store => \$output_type},
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools index);  #Stores commands depending on input parameters

    ## Options
    if ($output_type) {

	push(@commands, "--".$output_type);  #Specify output type
    }

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub view {

##view

##Function : Perl wrapper for writing bcftools view recipe to $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $apply_filters_ref, $exclude_types_ref, $infile_path, $outfile_path, $stderrfile_path, $stdoutfile_path, $FILEHANDLE, $output_type
##         : $apply_filters_ref => Require at least one of the listed FILTER strings
##         : $exclude_types_ref => Exclude comma-separated list of variant types: snps,indels,mnps,other
##         : $infile_path       => Infile path to read from
##         : $outfile_path      => Outfile path to write to
##         : $stderrfile_path   => Stderr file path to write to
##         : $stdoutfile_path   => Stdoutfile file path to write to
##         : $FILEHANDLE        => Filehandle to write to
##         : $output_type       => 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]

    my ($arg_href) = @_;

    ## Default(s)
    my $output_type;

    ## Flatten argument(s)
    my $apply_filters_ref;
    my $exclude_types_ref;
    my $infile_path;
    my $outfile_path;
    my $stderrfile_path;
    my $stdoutfile_path;
    my $FILEHANDLE;

    my $tmpl = {
	apply_filters_ref  => { default => [], strict_type => 1, store => \$apply_filters_ref },
	exclude_types_ref => { default => [], strict_type => 1, store => \$exclude_types_ref },
	infile_path => { strict_type => 1, store => \$infile_path },
	outfile_path => { strict_type => 1, store => \$outfile_path },
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path },
	stdoutfile_path => { strict_type => 1, store => \$stdoutfile_path },
	FILEHANDLE => { store => \$FILEHANDLE },
	output_type => { default => "v",
			 allow => ["b", "u", "z", "v"],
			 strict_type => 1, store => \$output_type },
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools view);  #Stores commands depending on input parameters

    ## Options
    if (@$apply_filters_ref) {

	push(@commands, "--apply-filters ".join(",", @$apply_filters_ref));
    }
    if (@$exclude_types_ref) {

	push(@commands, "--exclude-types ".join(",", @$exclude_types_ref));
    }
    if ($output_type) {

	push(@commands, "--output-type ".$output_type);  #Specify output type
    }
    if ($outfile_path) {

	push(@commands, "--output-file ".$outfile_path);  #Specify output filename
    }

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    if ($stdoutfile_path) {

	push(@commands, "1> ".$stdoutfile_path);  #Redirect stdout to program specific stderr file
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub filter {

##filter

##Function : Perl wrapper for writing bcftools filter recipe to $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $infile_path, $outfile_path, $stderrfile_path, $FILEHANDLE, $exclude, $soft_filter, $snp_gap, $indel_gap
##         : $infile_path     => Infile paths
##         : $outfile_path    => Outfile path
##         : $stderrfile_path => Stderrfile path
##         : $FILEHANDLE      => Filehandle to write to
##         : $exclude         => Exclude sites for which the expression is true
##         : $soft_filter     => Annotate FILTER column with <string> or unique filter name
##         : $snp_gap         => Filter SNPs within <int> base pairs of an indel
##         : $indel_gap       => Filter clusters of indels separated by <int> or fewer base pairs allowing only one to pass

    my ($arg_href) = @_;

    ## Flatten argument(s)
    my $infile_path;
    my $outfile_path;
    my $stderrfile_path;
    my $FILEHANDLE;
    my $exclude;
    my $soft_filter;
    my $snp_gap;
    my $indel_gap;

    my $tmpl = {
	infile_path => { strict_type => 1, store => \$infile_path },
	outfile_path => { strict_type => 1, store => \$outfile_path },
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path },
	FILEHANDLE => { store => \$FILEHANDLE },
	exclude => { strict_type => 1, store => \$exclude },
	soft_filter => { strict_type => 1, store => \$soft_filter },
	snp_gap => { allow => qr/^\d+$/,
		       strict_type => 1, store => \$snp_gap },
	indel_gap => { allow => qr/^\d+$/,
		       strict_type => 1, store => \$indel_gap },
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools filter);  #Stores commands depending on input parameters

    ## Options
    if ($exclude) {

	push(@commands, "--exclude ".$exclude);  
    }
    if ($soft_filter) {

	push(@commands, "--soft-filter ".$soft_filter);  
    }
    if ($snp_gap) {

	push(@commands, "--SnpGap ".$snp_gap);
    }
    if ($indel_gap) {

	push(@commands, "--IndelGap ".$indel_gap);
    }

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    if ($outfile_path) {

	push(@commands, "> ".$outfile_path);  #Specify output filename
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub norm {

##norm

##Function : Perl wrapper for writing bcftools norm recipe to $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $outfile_path, $reference_path, $infile_path, $stderrfile_path, $FILEHANDLE, $multiallelic, $output_type, $multiallelic_type
##         : $outfile_path      => Outfile path to write to
##         : $reference_path    => Human genome reference path
##         : $infile_path       => Infile path to read from
##         : $stderrfile_path   => Stderr file path to write to {OPTIONAL}
##         : $FILEHANDLE        => Filehandle to write to
##         : $multiallelic      => To split/join multiallelic calls or not
##         : $output_type       => 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]
##         : $multiallelic_type => Type of multiallelic to split/join {OPTIONAL}

    my ($arg_href) = @_;

    ## Default(s)
    my $output_type;
    my $multiallelic_type;

    ## Flatten argument(s)
    my $outfile_path;
    my $reference_path;
    my $infile_path;
    my $stderrfile_path;
    my $FILEHANDLE;
    my $multiallelic;

    my $tmpl = {
	outfile_path => { required => 1, defined => 1, strict_type => 1, store => \$outfile_path},
	reference_path => { required => 1, defined => 1, strict_type => 1, store => \$reference_path},
	infile_path => { strict_type => 1, store => \$infile_path},
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path},
	FILEHANDLE => { store => \$FILEHANDLE},
	multiallelic => { allow => ["+", "-"],
			  strict_type => 1, store => \$multiallelic},
	output_type => { default => "v",
			 allow => ["b", "u", "z", "v"],
			 strict_type => 1, store => \$output_type},
	multiallelic_type => { default => "both",
			       allow => ["snps", "indels", "both", "any"],
			       strict_type => 1, store => \$multiallelic_type},
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools norm);  #Stores commands depending on input parameters

    ## Options
    if ($multiallelic) {

	push(@commands, "--multiallelics ".$multiallelic.$multiallelic_type);  
    }
    if ($reference_path) {

	push(@commands, "--fasta-ref ".$reference_path);  
    }
    if ($output_type) {

	push(@commands, "--output-type ".$output_type);  #Specify output type
    }
    if ($outfile_path) {

	push(@commands, "--output ".$outfile_path);  #Specify output filename
    }

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub merge {

##merge

##Function : Perl wrapper for writing bcftools merge recipe to $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $infile_paths_ref, $outfile_path, $stderrfile_path, $stdoutfile_path, $FILEHANDLE, $output_type
##         : $infile_paths_ref => Infile path to read from
##         : $outfile_path     => Outfile path to write to
##         : $stderrfile_path  => Stderr file path to write to
##         : $stdoutfile_path  => Stdoutfile file path to write to
##         : $FILEHANDLE       => Filehandle to write to
##         : $output_type      => 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]

    my ($arg_href) = @_;

    ## Default(s)
    my $output_type;

    ## Flatten argument(s)
    my $infile_paths_ref;
    my $outfile_path;
    my $stderrfile_path;
    my $stdoutfile_path;
    my $FILEHANDLE;

    my $tmpl = {
	infile_paths_ref => { default => [], strict_type => 1, store => \$infile_paths_ref },
	outfile_path => { strict_type => 1, store => \$outfile_path },
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path },
	stdoutfile_path => { strict_type => 1, store => \$stdoutfile_path },
	FILEHANDLE => { store => \$FILEHANDLE },
	output_type => { default => "v",
			 allow => ["b", "u", "z", "v"],
			 strict_type => 1, store => \$output_type },
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools merge);  #Stores commands depending on input parameters

    ## Options
    if ($output_type) {

	push(@commands, "--output-type ".$output_type);  #Specify output type
    }
    if ($outfile_path) {

	push(@commands, "--output ".$outfile_path);  #Specify output filename
    }

    ## Infile
    if (@$infile_paths_ref) {

	push(@commands, join(" ", @$infile_paths_ref));
    }
    if ($stdoutfile_path) {

	push(@commands, "1> ".$stdoutfile_path);  #Redirect stdout to program specific stderr file
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub concat {

##concat

##Function : Perl wrapper for writing bcftools concat recipe to $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $infile_paths_ref, $outfile_path, $stderrfile_path, $stdoutfile_path, $FILEHANDLE, $allow_overlaps, $output_type
##         : $infile_paths_ref => Infile path to read from
##         : $outfile_path     => Outfile path to write to
##         : $stderrfile_path  => Stderr file path to write to
##         : $stdoutfile_path  => Stdoutfile file path to write to
##         : $FILEHANDLE       => Filehandle to write to
##         : $allow_overlaps   => First coordinate of the next file can precede last record of the current file
##         : $output_type      => 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]

    my ($arg_href) = @_;

    ## Default(s)
    my $output_type;

    ## Flatten argument(s)
    my $infile_paths_ref;
    my $outfile_path;
    my $stderrfile_path;
    my $stdoutfile_path;
    my $FILEHANDLE;
    my $allow_overlaps;

    my $tmpl = {
	infile_paths_ref => { default => [], strict_type => 1, store => \$infile_paths_ref },
	outfile_path => { strict_type => 1, store => \$outfile_path },
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path },
	stdoutfile_path => { strict_type => 1, store => \$stdoutfile_path },
	FILEHANDLE => { store => \$FILEHANDLE },
	allow_overlaps => { default => 0,
			    allow => [0, 1],
			    strict_type => 1, store => \$allow_overlaps },
	output_type => { default => "v",
			 allow => ["b", "u", "z", "v"],
			 strict_type => 1, store => \$output_type },
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools concat);  #Stores commands depending on input parameters

    ## Options
    if ($allow_overlaps) {

	push(@commands, "--allow-overlaps");
    }
    if ($output_type) {

	push(@commands, "--output-type ".$output_type);  #Specify output type
    }
    if ($outfile_path) {

	push(@commands, "--output ".$outfile_path);  #Specify output filename
    }

    ## Infile
    if (@$infile_paths_ref) {

	push(@commands, join(" ", @$infile_paths_ref));
    }
    if ($stdoutfile_path) {

	push(@commands, "1> ".$stdoutfile_path);  #Redirect stdout to program specific stderr file
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub annotate {

##annotate

##Function : Perl wrapper for writing bcftools annotate recipe to $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $remove_ids_ref, $infile_path, $outfile_path, $stderrfile_path, $FILEHANDLE, $samples_file, $headerfile_path, $output_type, $set_id
##         : $remove_ids_ref  => List of annotations to remove
##         : $infile_path     => Infile path to read from
##         : $outfile_path    => Outfile path to write to
##         : $stderrfile_path => Stderr file path to write to {OPTIONAL}
##         : $FILEHANDLE      => Filehandle to write to
##         : $samples_file    => File of samples to annotate
##         : $headerfile_path => File with lines which should be appended to the VCF header
##         : $set_id          => Set ID column
##         : $output_type     => 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]

    my ($arg_href) = @_;

    ## Default(s)
    my $output_type;

    ## Flatten argument(s)
    my $remove_ids_ref;
    my $infile_path;
    my $outfile_path;
    my $stderrfile_path;
    my $FILEHANDLE;
    my $samples_file;
    my $headerfile_path;
    my $set_id;

    my $tmpl = {
	remove_ids_ref => { defined => 1, default => [], strict_type => 1, store => \$remove_ids_ref},
	infile_path => { strict_type => 1, store => \$infile_path },
	outfile_path => { strict_type => 1, store => \$outfile_path },
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path },
	FILEHANDLE => { store => \$FILEHANDLE },
	samples_file => { strict_type => 1, store => \$samples_file },
	headerfile_path => { strict_type => 1, store => \$headerfile_path },
	set_id => { strict_type => 1, store => \$set_id },
	output_type => { default => "v",
			 allow => ["b", "u", "z", "v"],
			 strict_type => 1, store => \$output_type },
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools annotate);  #Stores commands depending on input parameters

    ## Options
    if (@$remove_ids_ref) {

	push(@commands, "--remove ".join(",", @$remove_ids_ref));
    }
    if ($set_id) {

	push(@commands, "--set-id ".$set_id);
    }
    if ($samples_file) {

	push(@commands, "--samples-file ".$samples_file);
    }
    if ($headerfile_path) {

	push(@commands, "--header-lines ".$headerfile_path);
    }
    if ($output_type) {

	push(@commands, "--output-type ".$output_type);  #Specify output type
    }

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    if ($outfile_path) {

	push(@commands, "> ".$outfile_path);  #Specify output filename
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub roh {

##roh

##Function : Perl wrapper for writing bcftools roh recipe to $FILEHANDLE or return commands array. Based on bcftools 1.4.1.
##Returns  : "@commands"
##Arguments:  $sample_ids_ref, $infile_path, $outfile_path, $stderrfile_path, $stdoutfile_path, $FILEHANDLE, $af_file_path, $skip_indels
##         : $sample_ids_ref  => Sample to analyze
##         : $infile_path     => Infile path to read from
##         : $outfile_path    => Outfile path to write to
##         : $stderrfile_path => Stderr file path to write to
##         : $stdoutfile_path => Stdoutfile file path to write to
##         : $FILEHANDLE      => Filehandle to write to
##         : $af_file_path    => Read allele frequencies from file (CHR\tPOS\tREF,ALT\tAF)
##         : $skip_indels     => Skip indels as their genotypes are enriched for errors

    my ($arg_href) = @_;

    ## Default(s)
    my $skip_indels;

    ## Flatten argument(s)
    my $sample_ids_ref;
    my $infile_path;
    my $outfile_path;
    my $stderrfile_path;
    my $stdoutfile_path;
    my $FILEHANDLE;
    my $af_file_path;

    my $tmpl = {
	sample_ids_ref => { default => [], strict_type => 1, store => \$sample_ids_ref },
	infile_path => { required => 1, defined => 1, strict_type => 1, store => \$infile_path },
	outfile_path => { strict_type => 1, store => \$outfile_path },
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path },
	stdoutfile_path => { strict_type => 1, store => \$stdoutfile_path },
	FILEHANDLE => { store => \$FILEHANDLE },
	af_file_path => { strict_type => 1, store => \$af_file_path },
	skip_indels => { default => 0,
			 allow => [0, 1],
			 strict_type => 1, store => \$skip_indels },
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## bcftools
    my @commands = qw(bcftools roh);  #Stores commands depending on input parameters

    ## Options
    if ($af_file_path) {

	push(@commands, "--AF-file ".$af_file_path);
    }
    if ($skip_indels) {

	push(@commands, "--skip-indels");
    }
    if (@$sample_ids_ref) {

	push(@commands, "--samples ".join(",", @$sample_ids_ref));
    }

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    if ($outfile_path) {

	push(@commands, "> ".$outfile_path);  #Specify output filename
    }
    if ($stdoutfile_path) {

	push(@commands, "1> ".$stdoutfile_path);  #Redirect stdout to program specific stderr file
    }
    if ($stderrfile_path) {

	push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub stats {

##stats

##Function : Perl wrapper for writing bcftools stats recipe to already open $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $infile_path, $outfile_path, $stderrfile_path, $stdoutfile_path, $FILEHANDLE, $append_stderr_info
##         : $infile_path        => Infile path
##         : $outfile_path       => Outfile path
##         : $stderrfile_path    => Stderrfile path
##         : $stdoutfile_path    => Stdoutfile path
##         : $FILEHANDLE         => Filehandle to write to
##         : $append_stderr_info => Append stderr info to file

    my ($arg_href) = @_;

    ## Default(s)
    my $append_stderr_info;
	
    ## Flatten argument(s)
    my $infile_path;
    my $outfile_path;
    my $stderrfile_path;
    my $stdoutfile_path;
    my $FILEHANDLE;

	my $tmpl = { 
	infile_path => { strict_type => 1, store => \$infile_path},
	outfile_path => { strict_type => 1, store => \$outfile_path},
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path},
	stdoutfile_path => { strict_type => 1, store => \$stdoutfile_path },
	FILEHANDLE => { store => \$FILEHANDLE},
	append_stderr_info => { default => 0,
				allow => [0, 1],
				strict_type => 1, store => \$append_stderr_info},
    };
    
    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## Bcftools stats
    my @commands = qw(bcftools stats);  #Stores commands depending on input parameters

    ## Options

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    ## Outfile
    if ($outfile_path) {

	push(@commands, "> ".$outfile_path);
    }
    if ($stdoutfile_path) {

	push(@commands, "1> ".$stdoutfile_path);  #Redirect stdout to program specific stdout file
    }
    if ($stderrfile_path) {

	if ($append_stderr_info) {

	    push(@commands, "2>> ".$stderrfile_path);  #Redirect and append stderr output to program specific stderr file
	}
	else {
	    
	    push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
	}
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


sub reheader {

##reheader

##Function : Perl wrapper for writing bcftools reheader recipe to already open $FILEHANDLE or return commands array. Based on bcftools 1.3.1.
##Returns  : "@commands"
##Arguments: $infile_path, $outfile_path, $stderrfile_path, $stdoutfile_path, $samples_file_path, $FILEHANDLE, $append_stderr_info
##         : $infile_path        => Infile path
##         : $outfile_path       => Outfile path
##         : $stderrfile_path    => Stderrfile path
##         : $stdoutfile_path    => Stdoutfile path
##         : $samples_file_path  => File with new sample names
##         : $FILEHANDLE         => Filehandle to write to
##         : $append_stderr_info => Append stderr info to file

    my ($arg_href) = @_;

    ## Default(s)
    my $append_stderr_info;
	
    ## Flatten argument(s)
    my $infile_path;
    my $outfile_path;
    my $stderrfile_path;
    my $stdoutfile_path;
    my $samples_file_path;
    my $FILEHANDLE;

	my $tmpl = { 
	infile_path => { strict_type => 1, store => \$infile_path},
	outfile_path => { strict_type => 1, store => \$outfile_path},
	stderrfile_path => { strict_type => 1, store => \$stderrfile_path},
	stdoutfile_path => { strict_type => 1, store => \$stdoutfile_path },
	samples_file_path  => { strict_type => 1, store => \$samples_file_path },
	FILEHANDLE => { store => \$FILEHANDLE},
	append_stderr_info => { default => 0,
				allow => [0, 1],
				strict_type => 1, store => \$append_stderr_info},
    };
    
    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## Bcftools reheader
    my @commands = qw(bcftools reheader);  #Stores commands depending on input parameters

    ## Options
    if ($samples_file_path) {

	push(@commands, "--samples ".$samples_file_path);
    }

    ## Infile
    if ($infile_path) {

	push(@commands, $infile_path);
    }
    ## Outfile
    if ($outfile_path) {

	push(@commands, "> ".$outfile_path);
    }
    if ($stdoutfile_path) {

	push(@commands, "1> ".$stdoutfile_path);  #Redirect stdout to program specific stdout file
    }
    if ($stderrfile_path) {

	if ($append_stderr_info) {

	    push(@commands, "2>> ".$stderrfile_path);  #Redirect and append stderr output to program specific stderr file
	}
	else {
	    
	    push(@commands, "2> ".$stderrfile_path);  #Redirect stderr output to program specific stderr file
	}
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


1;
