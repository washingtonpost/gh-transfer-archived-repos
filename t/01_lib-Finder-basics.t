use strict;
use warnings;

use Test2::V0;
use Test2::Tools::Class;

use Finder;

# Verify that the query changes with state and cursor
my $t = Finder->new(org => 'fake-org');
isa_ok $t, [qw/Finder Mojo::Base/], 'Correct instance type.';
is $t->has_next_page => 0,     'Init state: has_next_page';
is $t->next_cursor   => undef, 'Init state: next_cursor';
is $t->results       => undef, 'Init state: results';

done_testing;
