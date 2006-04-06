##
# DBM::Deep Test
##
use strict;
use Test::More tests => 5;
use t::common qw( new_fh );

use_ok( 'DBM::Deep' );

my ($fh, $filename) = new_fh();

my $max_levels = 1000;

{
    my $db = DBM::Deep->new(
        file => $filename,
        type => DBM::Deep->TYPE_HASH,
    );

    ##
    # basic deep hash
    ##
    $db->{company} = {};
    $db->{company}->{name} = "My Co.";
    $db->{company}->{employees} = {};
    $db->{company}->{employees}->{"Henry Higgins"} = {};
    $db->{company}->{employees}->{"Henry Higgins"}->{salary} = 90000;

    is( $db->{company}->{name}, "My Co.", "Set and retrieved a second-level value" );
    is( $db->{company}->{employees}->{"Henry Higgins"}->{salary}, 90000, "Set and retrieved a fourth-level value" );

    ##
    # super deep hash
    ##
    $db->{base_level} = {};
    my $temp_db = $db->{base_level};

    for my $k ( 0 .. $max_levels ) {
        $temp_db->{"level$k"} = {};
        $temp_db = $temp_db->{"level$k"};
    }
    $temp_db->{deepkey} = "deepvalue";
}

{
    my $db = DBM::Deep->new(
        file => $filename,
        type => DBM::Deep->TYPE_HASH,
    );

    my $cur_level = -1;
    my $temp_db = $db->{base_level};
    for my $k ( 0 .. $max_levels ) {
        $cur_level = $k;
        $temp_db = $temp_db->{"level$k"};
        eval { $temp_db->isa( 'DBM::Deep' ) } or last;
    }
    is( $cur_level, $max_levels, "We read all the way down to level $cur_level" );
    is( $temp_db->{deepkey}, "deepvalue", "And we retrieved the value at the bottom of the ocean" );
}
