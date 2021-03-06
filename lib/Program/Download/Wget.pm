package Program::Download::Wget;

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
    our @EXPORT_OK = qw(wget);

}

use Params::Check qw[check allow last_error];
$Params::Check::PRESERVE_CASE = 1;  #Do not convert to lower case


sub wget {

##wget

##Function : Perl wrapper for writing wget recipe to $FILEHANDLE or return commands array. Based on GNU Wget 1.12, a non-interactive network retriever.
##Returns  : "@commands"
##Arguments: $FILEHANDLE, $outfile_path, $url, $quiet, $verbose
##         : $FILEHANDLE   => Filehandle to write to
##         : $outfile_path => Outfile path. Write documents to FILE 
##         : $url          => Url to use for download
##         : $quiet        => Quiet (no output)
##         : $verbose      => Verbosity

    my ($arg_href) = @_;

    ## Default(s)
    my $quiet;
    my $verbose;

    ## Flatten argument(s)
    my $FILEHANDLE;
    my $outfile_path;
    my $url;

    my $tmpl = {
	FILEHANDLE => { required => 1, defined => 1, store => \$FILEHANDLE},
	outfile_path => { strict_type => 1, store => \$outfile_path},
	url => { required => 1, defined => 1, strict_type => 1, store => \$url},
	quiet => { default => 0,
		   strict_type => 1, store => \$quiet},
	verbose => { default => 1,
		     strict_type => 1, store => \$verbose},
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    ## Wget
    my @commands = qw(wget);  #Stores commands depending on input parameters

    if ($quiet) {

	push(@commands, "--quiet ");
    }
    if ($verbose) {

	push(@commands, "--verbose");
    }
    else {

	push(@commands, "--no-verbose");
    }
    ##URL
    push(@commands, $url);

    if ($outfile_path) {

	push(@commands, "-O ".$outfile_path);  #Outfile
    }
    if($FILEHANDLE) {
	
	print $FILEHANDLE join(" ", @commands)." ";
    }
    return @commands;
}


1;
