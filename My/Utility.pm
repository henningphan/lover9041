package My::Utility;
use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(findStudent output);

sub findStudent($){
  my($username) =@_;
  my $path = "./students/$username";
  if( -e $path ){
    return 1;
  }
  return 0;
}

1;
