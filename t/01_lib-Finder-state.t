use strict;
use warnings;

use Test2::V0;

use Finder;

# Verify that the query changes with state and cursor
my $t = Finder->new(org => 'fake-org');

is $t->_next_batch_gql, <<"EOGQL", 'Plain org query.';
{
  organization(login: "fake-org") {
    repositories(ownerAffiliations: OWNER, first: 50 ) {
      nodes {
        isArchived
        name
        nameWithOwner
        viewerCanAdminister
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
EOGQL

is $t->_next_batch_gql('Dummy-Cursor'), <<"EOGQL", 'Plain org query.';
{
  organization(login: "fake-org") {
    repositories(ownerAffiliations: OWNER, first: 50 , after: "Dummy-Cursor") {
      nodes {
        isArchived
        name
        nameWithOwner
        viewerCanAdminister
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
EOGQL



done_testing;
