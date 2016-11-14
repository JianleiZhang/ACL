package ACL::Controller::Permission;
use Mojo::Base 'Mojolicious::Controller';


sub list {
  my $self = shift;

  $self->render_later;

  Mojo::IOLoop->delay(
    sub {
      my $delay = shift;
      $self->pg->db->query('SELECT * FROM roles ORDER BY id', $delay->begin);
      $self->pg->db->query('SELECT id,name FROM permissions', $delay->begin);
    },
    sub {
      my ($delay, $err1, $res1, $err2, $res2) = @_;
      my @roles       = $res1->hashes->each;
      my $permissions = $res2->hashes;
      foreach (@roles){
        my $role            = $_;
        my $new_permissions = [];
        foreach (@$permissions) {
          my $permission          = $_;
          my $new_permission      = {};
          $new_permission->{id}   = $permission->{id};
          $new_permission->{name} = $permission->{name};
          foreach (@{$role->{permissions}}) {
            if ($permission->{id} == $_) {
              $new_permission->{checked} = 'checked';
              last;
            }
          }
          push @$new_permissions, $new_permission;
        }
        $role->{permissions} = $new_permissions;
      }
      $self->render(roles => \@roles);
    });
}

sub update {
  my $self = shift;

  my $name        = $self->param('name');
  my $permissions = $self->every_param('permission');

  $self->render_later;

  Mojo::IOLoop->delay(
    sub {
      my $delay = shift;
      my $sql   = "UPDATE roles SET permissions = ARRAY[" . join(',', @$permissions) . "] where name = '$name'";
      $self->pg->db->query($sql, $delay->begin);
    },
    sub {
      my ($delay, $err, $result) = @_;
      $self->pg->pubsub->notify(permission => 'update');
      return $self->render(text => 'success!');
    });
}

1;
