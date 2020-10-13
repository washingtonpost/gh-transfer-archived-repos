package Finder;

## no critic (ProhibitSubroutinePrototypes)
use Mojo::Base -strict, -base, -signatures;

use Net::GitHub::V4;

use Data::Dumper;

has 'org'           => undef;
has 'has_next_page' => 0;
has 'next_cursor'   => undef;
has 'results'       => undef;

my $_gh = undef;

sub new {
  my $pkg  = shift @_;
  my $self = $pkg->SUPER::new(@_);

  return bless $self, $pkg;
}

sub gh($self) {
  $_gh ||= Net::GitHub::V4->new(access_token => $ENV{GITHUB_ACCESS_TOKEN});

  return $_gh;
}

sub _next_batch_gql ($self, $after = undef) {
  my $org       = $self->org;
  my $after_str = !!$after ? ", after: \"${after}\"" : "";
  return <<"EOGQL";
{
  organization(login: "$org") {
    repositories(ownerAffiliations: OWNER, first: 50 ${after_str}) {
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
}

sub _next_batch($self) {
  my $gql = $self->_next_batch_gql($self->next_cursor);

  my $gh = $self->gh;

  return $gh->query($gql);
}

# _next() -> Promise<
sub _next( $self ) {
  if (!!$self->results and scalar @{ $self->results } > 0) {
    return shift @{ $self->results };
  }

  my $batch = $self->_next_batch()->{data}->{organization}->{repositories};

  $self->has_next_page(!!$batch->{pageInfo}->{hasNextPage} || undef);
  $self->next_cursor($batch->{pageInfo}->{endCursor}       || undef);
  $self->results($batch->{nodes}                           || []);

  return shift @{ $self->results };
}

sub find_matching_repository ($self, $match = undef) {

  # If there's no function to match, simply return the next result
  return $self->_next if (not $match or ref($match) ne 'CODE');

  # If we have a matching function, keep going until we find a match.
  while (my $result = $self->_next) {
    if (!!$match->($result)) {
      return $result;
    }
  }

  # In case we don't find any matches.
  return;
}

1;
