package File::Format::Yaml;

use Modern::Perl '2014';
use warnings qw( FATAL utf8 );
use autodie;
use v5.18;  #Require at least perl 5.18
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
    our @EXPORT_OK = qw(load_yaml write_yaml);
    
}

use Params::Check qw[check allow last_error];
 

## Third party module(s)
use YAML;

sub load_yaml {

##load_yaml

##Function : Loads a YAML file into an arbitrary hash and returns it.
##Returns  : %yaml
##Arguments: $yaml_file
##         : $yaml_file => The yaml file to load

    my ($arg_href) = @_;

    ##Flatten argument(s)
    my $yaml_file;

    my $tmpl = {
	yaml_file => { required => 1, defined => 1, strict_type => 1, store => \$yaml_file},
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    my %yaml;

    open (my $YAML, "<", $yaml_file) or die "can't open ".$yaml_file.":".$!, "\n";
    local $YAML::QuoteNumericStrings = 1;  #Force numeric values to strings in YAML representation
    %yaml = %{ YAML::LoadFile($yaml_file) };  #Load hashreference as hash

    close($YAML);

    return %yaml;
}


sub write_yaml {

##write_yaml

##Function : Writes a YAML hash to file
##Returns  : ""
##Arguments: $yaml_href, $yaml_file_path_ref
##         : $yaml_href          => The hash to dump {REF}
##         : $yaml_file_path_ref => The yaml file to write to {REF}

    my ($arg_href) = @_;

    ## Flatten argument(s)
    my $yaml_href;
    my $yaml_file_path_ref;

    my $tmpl = {
	yaml_href => { required => 1, defined => 1, default => {}, strict_type => 1, store => \$yaml_href},
	yaml_file_path_ref => { required => 1, defined => 1, default => \$$, strict_type => 1, store => \$yaml_file_path_ref},
    };

    check($tmpl, $arg_href, 1) or die qw[Could not parse arguments!];

    open (my $YAML, ">", $$yaml_file_path_ref) or die("Can't open '".$$yaml_file_path_ref."':".$!."\n");
    local $YAML::QuoteNumericStrings = 1;  #Force numeric values to strings in YAML representation
    say $YAML Dump( $yaml_href );
    close($YAML);
}


1;
